from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.services.advisory_service import AdvisoryService
from typing import Optional

router = APIRouter()
advisory_service = AdvisoryService()

class AdvisoryRequest(BaseModel):
    query: str
    farmer_id: str
    field_id: Optional[str] = None
    session_id: Optional[str] = None

@router.post("/chat")
async def chat_with_advisor(req: AdvisoryRequest):
    result = await advisory_service.get_advice(
        query=req.query,
        farmer_id=req.farmer_id,
        field_id=req.field_id,
        session_id=req.session_id
    )
    
    if "error" in result:
        raise HTTPException(status_code=500, detail=result["error"])
        
    return result
