from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from app.services.crop_engine import CropRecommendationEngine
from supabase import create_client, Client
import os
from dotenv import load_dotenv

# Load env in case this module is imported independently
load_dotenv()

router = APIRouter()
engine = CropRecommendationEngine()

# Supabase Setup
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY") # Use Service role for backend ops
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

class RecommendationRequest(BaseModel):
    field_id: str
    soil_record_id: str
    user_id: str

@router.post("/recommend")
async def get_crop_recommendation(req: RecommendationRequest):
    try:
        # 1. Fetch Soil Data
        soil_resp = supabase.table("soil_records").select("*").eq("id", req.soil_record_id).single().execute()
        if not soil_resp.data:
            raise HTTPException(status_code=404, detail="Soil record not found")
        
        soil = soil_resp.data

        # 2. Fetch Field Data (for soil type)
        field_resp = supabase.table("fields").select("*").eq("id", req.field_id).single().execute()
        if not field_resp.data:
            raise HTTPException(status_code=404, detail="Field not found")
        
        field = field_resp.data

        # 3. Run Engine
        results = engine.recommend(
            n=float(soil["nitrogen_kg_ha"]),
            p=float(soil["phosphorus_kg_ha"]),
            k=float(soil["potassium_kg_ha"]),
            ph=float(soil["ph_level"]),
            soil_type=field["soil_type"]
        )

        # 4. Save to Database (Matching schema.sql)
        recommendation_data = {
            "field_id": req.field_id,
            "soil_record_id": req.soil_record_id,
            "generated_by": req.user_id,
            "model_version": "v1.0.0-icar",
            "recommended_crops": results,
            "season": "Current"
        }

        db_resp = supabase.table("crop_recommendations").insert(recommendation_data).execute()
        
        if not db_resp.data:
            raise HTTPException(status_code=500, detail="Failed to save recommendation")

        return db_resp.data[0]

    except Exception as e:
        print(f"Error in recommendation: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))
