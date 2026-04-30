from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from app.middleware.auth_middleware import get_current_user, AuthUser
from app.db.supabase import supabase

router = APIRouter(prefix="/session", tags=["sessions"])

class SessionCreate(BaseModel):
    title: str = "New Chat"

@router.post("")
async def create_session(
    data: SessionCreate,
    user: AuthUser = Depends(get_current_user)
):
    if user.is_guest:
        supabase.table("guest_sessions").upsert({"id": user.id}).execute()

    session_data = {
        "title": data.title,
        "user_id": user.id if not user.is_guest else None,
        "guest_session_id": user.id if user.is_guest else None
    }
    res = supabase.table("sessions").insert(session_data).execute()
    if not res.data:
        raise HTTPException(status_code=500, detail="Failed to create session")
    return res.data[0]

@router.get("/{session_id}")
async def get_session(
    session_id: str,
    user: AuthUser = Depends(get_current_user)
):
    res = supabase.table("sessions").select("*").eq("id", session_id).execute()
    if not res.data:
        raise HTTPException(status_code=404, detail="Session not found")
    
    session = res.data[0]
    # Check ownership
    if user.is_guest:
        if session["guest_session_id"] != user.id:
            raise HTTPException(status_code=403)
    else:
        if session["user_id"] != user.id:
            raise HTTPException(status_code=403)
            
    return session
