from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from supabase_client import supabase

router = APIRouter(prefix="/houses", tags=["houses"])


class House(BaseModel):
    user_id: int
    latitude: float
    longitude: float


class HouseUpdate(BaseModel):
    user_id: Optional[int] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None

#functions and formulas for output and efficiency
def compute_output_w(raw_resistor_values: list[float]) -> float:
    if not raw_resistor_values:
        return 0.0
    return sum(raw_resistor_values)

    """Lowk forgot the formulas for this KENNY HELP"""

def compute_efficiency_percentage(output_w: float, max_output_w: float = 100.0) -> float:
    if output_w <= 0:
        return 0.0
    return round((output_w / max_output_w) * 100, 1)
"""ALSO FORGOT"""

#Status endpoint
@router.get("/{house_id}/status")
def get_house_status(house_id: int):
    #verify house exists
    house_resp = supabase.table("houses").select("*").eq("house_id", house_id).execute()
    if not house_resp.data:
        raise HTTPException(status_code=404, detail="House not found")

    #get all panels
    panels_resp = supabase.table("panels").select("*").eq("house_id", house_id).execute()
    panels = panels_resp.data
    result = []

    for panel in panels:
        panel_id = panel["id"]

        reading_resp = (supabase.table("panel_readings").select("*").eq("panel_id", panel_id).order("recorded_at", desc=True).limit(1).execute())
        latest_reading = reading_resp.data[0] if reading_resp.data else None

        resistor_resp = (supabase.table("resistors").select("*").eq("panel_id", panel_id).order("created_at", desc=True).limit(4).execute())
        resistor_values = [r["output_w"] for r in resistor_resp.data]

        computed_output_w = compute_output_w(resistor_values)
        computed_efficiency = compute_efficiency_percentage(computed_output_w, panel["output_w"])

        result.append({
            "panel_id": panel_id,
            "house_id": house_id,
            "panel_output_w": panel["output_w"],
            "is_online": latest_reading is not None and computed_output_w > 0,
            "latest_reading": latest_reading,
            "computed":{
                "output_w": computed_output_w,
                "efficiency_percentage": computed_efficiency,
            }
        })

    return {
        "house_id": house_id,
        "house": house_resp.data[0],
        "panels": result

    }
            




# GET all houses
@router.get("/")
def get_all_houses():
    response = supabase.table("houses").select("*").execute()
    return response.data


# GET all houses by user
@router.get("/user/{user_id}")
def get_houses_by_user(user_id: int):
    response = supabase.table("houses").select("*").eq("user_id", user_id).execute()
    return response.data


# GET house by ID
@router.get("/{house_id}")
def get_house(house_id: int):
    response = supabase.table("houses").select("*").eq("house_id", house_id).execute()
    if not response.data:
        raise HTTPException(status_code=404, detail="House not found")
    return response.data[0]


# POST create a house
@router.post("/", status_code=201)
def create_house(house: House):
    response = supabase.table("houses").insert(house.model_dump()).execute()
    return response.data


# PATCH update a house
@router.patch("/{house_id}")
def update_house(house_id: int, house: HouseUpdate):
    payload = {k: v for k, v in house.model_dump().items() if v is not None}
    response = supabase.table("houses").update(payload).eq("house_id", house_id).execute()
    if not response.data:
        raise HTTPException(status_code=404, detail="House not found")
    return response.data


# DELETE a house
@router.delete("/{house_id}")
def delete_house(house_id: int):
    supabase.table("houses").delete().eq("house_id", house_id).execute()
    return {"message": f"House {house_id} deleted successfully"}
