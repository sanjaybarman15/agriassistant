from fastapi import APIRouter, HTTPException
from supabase import create_client, Client
import os

router = APIRouter()

# Supabase Setup
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

@router.get("/alerts/{district_id}")
async def get_district_alerts(district_id: str):
    try:
        # 1. Fetch active alerts for the district (Matching schema.sql)
        # Status must be 'published'
        resp = supabase.table("pest_alerts") \
            .select("*") \
            .eq("district_id", district_id) \
            .eq("status", "published") \
            .order("severity", desc=True) \
            .execute()
        
        # 2. Mock some active alerts if DB is empty for demo
        if not resp.data:
            return [
                {
                    "id": "demo-1",
                    "title": "Red Spider Mite Outbreak",
                    "description": "High infestation reported in southern tea estates. Humidity favors spread.",
                    "affected_crops": ["Tea"],
                    "severity": "high",
                    "advisory": "Maintain shade and increase irrigation. Apply sulfur-based miticides if population exceeds 4 per leaf.",
                    "reported_at": "2026-04-30T10:00:00Z"
                },
                {
                    "id": "demo-2",
                    "title": "Stem Borer Warning",
                    "description": "Larvae activity detected in Boro rice nurseries.",
                    "affected_crops": ["Rice"],
                    "severity": "medium",
                    "advisory": "Install pheromone traps (5 per bigha). Monitor for 'dead hearts' regularly.",
                    "reported_at": "2026-04-29T14:30:00Z"
                }
            ]

        return resp.data

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
