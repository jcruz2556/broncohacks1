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
