from fastapi import APIRouter, Depends, BackgroundTasks
from fastapi.responses import StreamingResponse
from pydantic import BaseModel
from typing import Optional, List
from app.middleware.auth_middleware import get_current_user, AuthUser
from app.services.ai_service import AIService
from app.db.supabase import supabase
import uuid
import json

from app.tasks.chat_tasks import save_ai_message_task
from app.services.rag.main import ask_question
from app.services.hr.intent_router import extract_intent_and_entities
from app.services.hr import (
    employee_service,
    leave_service,
    recruitment_service,
    promotion_service,
    salary_service,
)

router = APIRouter(prefix="/chat", tags=["chat"])


class ChatRequest(BaseModel):
    message: str
    session_id: Optional[str] = None
    has_attachment: bool = False
    filename: Optional[str] = None


def build_hr_context(intent: str, entities: dict) -> str:
    """
    Routes to the correct HR service based on intent,
    fetches real data, and builds a structured context string for the LLM.
    """
    name = entities.get("name")
    department = entities.get("department")
    status_filter = entities.get("status_filter")
    record_id = entities.get("record_id")
    cycle = entities.get("cycle")

    ctx_lines = []

    try:
        if intent == "employee_query":
            if name:
                emp = employee_service.get_employee_by_name(name)
                if emp:
                    ctx_lines.append(f"EMPLOYEE RECORD:\n{json.dumps(emp, indent=2, default=str)}")
                else:
                    ctx_lines.append(f"No employee found matching '{name}'.")
            else:
                emps = employee_service.get_employees(department=department)
                ctx_lines.append(f"EMPLOYEE LIST ({len(emps)} records):")
                for e in emps[:10]:
                    ctx_lines.append(
                        f"- {e.get('full_name')} | {e.get('emp_code')} | {e.get('department')} | {e.get('designation')} | Level {e.get('level')} | Rating {e.get('performance_rating')}"
                    )

        elif intent in ("leave_query", "leave_action"):
            # If action and we have a name, find the employee's pending leave
            if intent == "leave_action" and name and not record_id:
                emp = employee_service.get_employee_by_name(name)
                if emp:
                    leaves = leave_service.get_leave_requests(status="pending")
                    emp_leaves = [l for l in leaves if l.get("emp_id") == emp.get("id")]
                    if emp_leaves:
                        target_leave = emp_leaves[0]
                        record_id = target_leave.get("id")
                        ctx_lines.append(f"FOUND PENDING LEAVE FOR {emp.get('full_name')}:")
                        ctx_lines.append(json.dumps(target_leave, indent=2, default=str))

                        # Determine approve or reject from original query
                        # (LLM will confirm the action; we pass the data)
                    else:
                        ctx_lines.append(f"No pending leave requests found for {emp.get('full_name')}.")
                else:
                    ctx_lines.append(f"No employee found matching '{name}'.")
            else:
                leaves = leave_service.get_leave_requests(
                    status=status_filter, department=department
                )
                ctx_lines.append(f"LEAVE REQUESTS ({len(leaves)} records, filter: status={status_filter or 'all'}):")
                for l in leaves[:10]:
                    ctx_lines.append(
                        f"- [{l.get('status').upper()}] {l.get('emp_name')} | {l.get('leave_type')} | {l.get('days_count')} days | Applied: {str(l.get('applied_at', ''))[:10]}"
                    )

        elif intent in ("candidate_query", "candidate_action"):
            if name and intent == "candidate_action":
                # Find candidate by name
                all_cands = recruitment_service.get_candidates()
                matched = [c for c in all_cands if name.lower() in c.get("full_name", "").lower()]
                if matched:
                    ctx_lines.append(f"CANDIDATE RECORD:")
                    ctx_lines.append(json.dumps(matched[0], indent=2, default=str))
                else:
                    ctx_lines.append(f"No candidate found matching '{name}'.")
            else:
                cands = recruitment_service.get_candidates(status=status_filter)
                ctx_lines.append(f"CANDIDATES ({len(cands)} records, filter: status={status_filter or 'all'}):")
                for c in cands[:10]:
                    ctx_lines.append(
                        f"- {c.get('full_name')} | {c.get('role_applied')} | ATS: {c.get('ats_score')} | {c.get('experience_years')} yrs | [{c.get('status').upper()}]"
                    )

        elif intent in ("promotion_query", "promotion_action"):
            promos = promotion_service.get_promotions(cycle=cycle, status=status_filter)
            ctx_lines.append(f"PROMOTIONS ({len(promos)} records):")
            for p in promos[:10]:
                ctx_lines.append(
                    f"- {p.get('emp_name')} | {p.get('from_level')}→{p.get('to_level')} | Eligible: {p.get('overall_eligible')} | Status: {p.get('status').upper()}"
                )

        elif intent == "salary_query":
            level = entities.get("name")  # user might say "L4 salary bands"
            bands = salary_service.get_salary_bands(level=level)
            ctx_lines.append(f"SALARY BANDS ({len(bands)} records):")
            for b in bands[:10]:
                ctx_lines.append(
                    f"- Level {b.get('level')} | {b.get('department') or 'All Depts'} | ₹{b.get('min_salary'):,.0f} – ₹{b.get('max_salary'):,.0f}"
                )

    except Exception as e:
        ctx_lines.append(f"[HR Data Error: {str(e)}]")

    return "\n".join(ctx_lines) if ctx_lines else ""


@router.post("/stream")
async def chat_stream(
    request: ChatRequest,
    user: AuthUser = Depends(get_current_user)
):
    # 1. Ensure public user profile exists
    if not user.is_guest:
        check = supabase.table("users").select("id").eq("id", user.id).execute()
        if not check.data:
            supabase.table("users").insert({
                "id": user.id,
                "email": user.email,
                "display_name": user.email.split("@")[0]
            }).execute()

    # 2. Resolve session
    session_id = request.session_id
    if not session_id:
        if user.is_guest:
            supabase.table("guest_sessions").upsert({"id": user.id}).execute()

        session_data = {
            "title": request.message[:50],
            "user_id": user.id if not user.is_guest else None,
            "guest_session_id": user.id if user.is_guest else None
        }
        res = supabase.table("sessions").insert(session_data).execute()
        session_id = res.data[0]["id"]

    # 3. Save user message
    db_content = request.message
    if request.has_attachment and request.filename:
        db_content += f"\n\n📎 *Attached: {request.filename}*"

    supabase.table("messages").insert({
        "session_id": session_id,
        "role": "user",
        "content": db_content
    }).execute()

    # 4. Fetch recent history
    history_res = supabase.table("messages") \
        .select("role", "content") \
        .eq("session_id", session_id) \
        .order("created_at", desc=True) \
        .limit(10) \
        .execute()

    history = [{"role": m["role"], "content": m["content"]} for m in history_res.data[::-1]]

    # 5. Intent extraction + HR context injection (for authenticated users)
    context_prefix = ""
    system_prompt_content = GENERAL_SYSTEM_PROMPT
    is_hr_intent = False

    if not user.is_guest:
        try:
            parsed = await extract_intent_and_entities(request.message)
            intent = parsed.get("intent", "general")
            entities = parsed.get("entities", {})

            if intent != "general":
                is_hr_intent = True
                hr_context = build_hr_context(intent, entities)
                if hr_context:
                    context_prefix += f"--- LIVE HR DATA ---\n{hr_context}\n--- END HR DATA ---\n\n"
                system_prompt_content = HR_SYSTEM_PROMPT
        except Exception as e:
            print(f"[ChatStream] Intent extraction failed: {e}")

    # 6. RAG context for general / policy questions
    if not is_hr_intent:
        try:
            rag_result = ask_question(request.message)
            if rag_result["source"] == "rag" and rag_result["context"]:
                context_prefix += f"KNOWLEDGE BASE CONTEXT:\n{rag_result['context']}\n\n"
            elif rag_result["source"] == "fallback" and rag_result.get("fallback_answer"):
                fb = rag_result["fallback_answer"]
                context_prefix += f"GENERAL GUIDANCE:\nAnswer: {fb.get('answer')}\n\n"
        except Exception as e:
            print(f"[ChatStream] RAG failed: {e}")

    # 7. Handle uploaded file context
    if request.has_attachment:
        try:
            doc_res = supabase.table("documents") \
                .select("filename", "content") \
                .eq("session_id", session_id) \
                .execute()
            if doc_res.data:
                context_prefix += "CONTEXT FROM UPLOADED FILES:\n"
                for doc in doc_res.data:
                    context_prefix += f"--- {doc['filename']} ---\n{doc['content']}\n\n"
        except Exception as e:
            print(f"[ChatStream] Document fetch failed: {e}")

    # 8. Inject combined context into last user message
    if context_prefix and history and history[-1]["role"] == "user":
        history[-1]["content"] = f"{context_prefix}\nUSER QUESTION: {history[-1]['content']}"

    # 9. Stream response + save via Celery
    async def stream_and_collect():
        full_content = []
        async for chunk in AIService.stream_chat(
            history,
            system_prompt_override=system_prompt_content
        ):
            yield chunk
            if chunk.startswith("data: {"):
                try:
                    data = json.loads(chunk[6:])
                    if "token" in data:
                        full_content.append(data["token"])
                except Exception:
                    pass

        final_text = "".join(full_content)
        save_ai_message_task.delay(session_id, final_text)

    return StreamingResponse(
        stream_and_collect(),
        media_type="text/event-stream",
        headers={
            "X-Session-Id": session_id,
            "Cache-Control": "no-cache",
        }
    )
