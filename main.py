from fastapi import FastAPI, HTTPException, Request
from pydantic import BaseModel
from typing import List

app = FastAPI()

class PanelReading(BaseModel):
    panel_id:str
    readings: List[int]
    timestamp: str
    current_angle_deg: float
    output_w: float
    battery_state: str

class ResistorReading(BaseModel):
    resistor_id: str
    reading: int
    timestamp: str

# --- Routes ---
@app.get("/")
def root():
    return {"message": "API is running"}

@app.post("/readings/panel")
async def panel_reading(request: Request):
    data = await request.json()
    print(f"Panel data: {data}")
    return {"status": "ok", "received": data}

@app.post("/readings/resistor")
async def resistor_reading(data: ResistorReading):
    print(f"Resistor: {data}")
    return {"status": "ok", "recieved": data}


    