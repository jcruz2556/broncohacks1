from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from supabase_client import supabase

router = APIRouter(prefix="/panels", tags=["panels"])


class Panel(BaseModel):
    house_id: int
    output_w: float


class PanelUpdate(BaseModel):
    house_id: Optional[int] = None
    output_w: Optional[float] = None


# GET all panels
@router.get("/")
def get_all_panels():
    response = supabase.table("panels").select("*").execute()
    return response.data


# GET all panels for a house
@router.get("/house/{house_id}")
def get_panels_by_house(house_id: int):
    response = supabase.table("panels").select("*").eq("house_id", house_id).execute()
    return response.data


# GET panel by ID
@router.get("/{id}")
def get_panel(id: int):
    response = supabase.table("panels").select("*").eq("id", id).execute()
    if not response.data:
        raise HTTPException(status_code=404, detail="Panel not found")
    return response.data[0]


# POST create a panel
@router.post("/", status_code=201)
def create_panel(panel: Panel):
    response = supabase.table("panels").insert(panel.model_dump()).execute()
    return response.data


# PATCH update a panel
@router.patch("/{id}")
def update_panel(id: int, panel: PanelUpdate):
    payload = {k: v for k, v in panel.model_dump().items() if v is not None}
    response = supabase.table("panels").update(payload).eq("id", id).execute()
    if not response.data:
        raise HTTPException(status_code=404, detail="Panel not found")
    return response.data


# DELETE a panel
@router.delete("/{id}")
def delete_panel(id: int):
    supabase.table("panels").delete().eq("id", id).execute()
    return {"message": f"Panel {id} deleted successfully"}