from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, EmailStr
from typing import Optional
from supabase_client import supabase

router = APIRouter(prefix="/users", tags=["users"])


class User(BaseModel):
    email: str
    password: str  # hash this before storing in production!
    name: str


class UserUpdate(BaseModel):
    email: Optional[str] = None
    password: Optional[str] = None
    name: Optional[str] = None


# GET all users
@router.get("/")
def get_all_users():
    response = supabase.table("users").select("id, email, name, created_at").execute()  # exclude password
    return response.data


# GET user by ID
@router.get("/{id}")
def get_user(id: int):
    response = supabase.table("users").select("id, email, name, created_at").eq("id", id).execute()
    if not response.data:
        raise HTTPException(status_code=404, detail="User not found")
    return response.data[0]


# POST create a user
@router.post("/", status_code=201)
def create_user(user: User):
    # WARNING: Hash the password before inserting in production
    # e.g. use passlib: user.password = bcrypt.hash(user.password)
    response = supabase.table("users").insert(user.model_dump()).execute()
    return response.data


# PATCH update a user
@router.patch("/{id}")
def update_user(id: int, user: UserUpdate):
    payload = {k: v for k, v in user.model_dump().items() if v is not None}
    response = supabase.table("users").update(payload).eq("id", id).execute()
    if not response.data:
        raise HTTPException(status_code=404, detail="User not found")
    return response.data


# DELETE a user
@router.delete("/{id}")
def delete_user(id: int):
    supabase.table("users").delete().eq("id", id).execute()
    return {"message": f"User {id} deleted successfully"}