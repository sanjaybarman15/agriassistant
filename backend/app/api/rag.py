from fastapi import APIRouter, UploadFile, File, Form, Depends, HTTPException
from app.middleware.auth_middleware import get_current_user, AuthUser
from app.db.supabase import supabase
from app.services.ai_service import AIService
import uuid

router = APIRouter(prefix="/rag", tags=["rag"])

@router.post("/ingest")
async def ingest_document(
    file: UploadFile = File(...),
    session_id: str = Form(...),
    user: AuthUser = Depends(get_current_user)
):
    try:
        # Validate session_id
        try:
            target_session_id = str(uuid.UUID(session_id))
        except ValueError:
            raise HTTPException(status_code=400, detail="Invalid session_id format")

        content = await file.read()
        text_content = ""
        
        if file.filename.endswith((".txt", ".md", ".json", ".csv")):
            text_content = content.decode("utf-8")
        else:
            text_content = f"[File: {file.filename} - PDF/Docx text extraction pending]"

        # Generate Embeddings!
        print(f"DEBUG: Generating embeddings for {file.filename}...")
        vector = await AIService.generate_embedding(text_content)

        doc_data = {
            "session_id": target_session_id,
            "filename": file.filename,
            "content": text_content,
            "embedding": vector if vector else None,
            "file_type": file.content_type,
            "size": len(content)
        }
        
        print(f"DEBUG: Ingesting file {file.filename} for session {target_session_id}")
        res = supabase.table("documents").insert(doc_data).execute()
        
        if not res.data:
            print(f"ERROR: Database insert returned no data: {res}")
            raise HTTPException(status_code=500, detail="Database save failed")

        return {
            "status": "success",
            "document_id": res.data[0]["id"],
            "filename": file.filename
        }
    except Exception as e:
        print(f"CRITICAL ERROR in /rag/ingest: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Ingestion failed: {str(e)}")
