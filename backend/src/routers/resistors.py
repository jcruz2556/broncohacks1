from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from supabase_client import supabase

router = APIRouter(prefix="/resistors", tags=["resistors"])


class Resistor(BaseModel):
    panel_id: int
    output_w: float


class ResistorUpdate(BaseModel):
    panel_id: Optional[int] = None
    output_w: Optional[float] = None


# GET all resistors
@router.get("/")
def get_all_resistors():
    response = supabase.table("resistors").select("*").execute()
    return response.data


# GET resistor by ID
@router.get("/{id}")
def get_resistor(id: int):
    response = supabase.table("resistors").select("*").eq("id", id).execute()
    if not response.data:
        raise HTTPException(status_code=404, detail="Resistor not found")
    return response.data[0]


# GET all resistors for a panel
@router.get("/panel/{panel_id}")
def get_resistors_by_panel(panel_id: int):
    response = supabase.table("resistors").select("*").eq("panel_id", panel_id).execute()
    return response.data


# POST create a resistor
@router.post("/", status_code=201)
def create_resistor(resistor: Resistor):
    response = supabase.table("resistors").insert(resistor.model_dump()).execute()
    return response.data


# PATCH update a resistor
@router.patch("/{id}")
def update_resistor(id: int, resistor: ResistorUpdate):
    payload = {k: v for k, v in resistor.model_dump().items() if v is not None}
    response = supabase.table("resistors").update(payload).eq("id", id).execute()
    if not response.data:
        raise HTTPException(status_code=404, detail="Resistor not found")
    return response.data


# DELETE a resistor
@router.delete("/{id}")
def delete_resistor(id: int):
    supabase.table("resistors").delete().eq("id", id).execute()
    return {"message": f"Resistor {id} deleted successfully"}