from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from supabase_client import supabase

router = APIRouter(prefix="/panel-readings", tags=["panel_readings"])


class PanelReading(BaseModel):
    panel_id: int
    reading: Optional[int] = None       # nullable int2
    battery_state: Optional[str] = None
    efficiency_percentage: Optional[int] = None


class PanelReadingUpdate(BaseModel):
    panel_id: Optional[int] = None
    reading: Optional[int] = None
    battery_state: Optional[str] = None
    efficiency_percentage: Optional[int] = None


# GET all readings
@router.get("/")
def get_all_readings():
    response = supabase.table("panel_readings").select("*").execute()
    return response.data


# GET reading by panel_id (unique — returns single record)
@router.get("/panel/{panel_id}")
def get_reading_by_panel(panel_id: int):
    response = supabase.table("panel_readings").select("*").eq("panel_id", panel_id).execute()
    if not response.data:
        raise HTTPException(status_code=404, detail="No reading found for this panel")
    return response.data[0]


# GET reading by ID
@router.get("/{id}")
def get_reading(id: int):
    response = supabase.table("panel_readings").select("*").eq("id", id).execute()
    if not response.data:
        raise HTTPException(status_code=404, detail="Reading not found")
    return response.data[0]


# POST create a reading
@router.post("/", status_code=201)
def create_reading(reading: PanelReading):
    response = supabase.table("panel_readings").insert(reading.model_dump()).execute()
    return response.data


# PATCH update a reading
@router.patch("/{id}")
def update_reading(id: int, reading: PanelReadingUpdate):
    payload = {k: v for k, v in reading.model_dump().items() if v is not None}
    response = supabase.table("panel_readings").update(payload).eq("id", id).execute()
    if not response.data:
        raise HTTPException(status_code=404, detail="Reading not found")
    return response.data


# DELETE a reading
@router.delete("/{id}")
def delete_reading(id: int):
    supabase.table("panel_readings").delete().eq("id", id).execute()
    return {"message": f"Reading {id} deleted successfully"}