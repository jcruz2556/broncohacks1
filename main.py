from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI()

# --- Routes ---
@app.get("/")
def root():
    return {"message": "API is running"}