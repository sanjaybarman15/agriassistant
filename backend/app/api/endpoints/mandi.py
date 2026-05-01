from fastapi import APIRouter, HTTPException
from supabase import create_client, Client
import os
from datetime import date

router = APIRouter()

# Supabase Setup
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_SERVICE_ROLE_KEY")
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

@router.get("/prices/{district_id}")
async def get_market_prices(district_id: str):
    try:
        # 1. Fetch prices for the district OR global prices (district_id is null)
        # Using a simple logic: Get all where district is null or matches district_id
        resp = supabase.table("mandi_prices").select("*").or_(f"district_id.eq.{district_id},district_id.is.null").order("price_date", desc=True).execute()
        
        if resp.data:
            return resp.data

        # 2. Hardcoded fallback only if DB is truly empty
        return [
            {"crop_name": "Tea (CTC)", "market_name": "Guwahati Auction", "price_inr_per_quintal": 21000, "price_date": str(date.today()), "trend": "+2.4%"},
            {"crop_name": "Rice (Sali)", "market_name": "Nagaon APMC", "price_inr_per_quintal": 2450, "price_date": str(date.today()), "trend": "-1.2%"},
        ]

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
