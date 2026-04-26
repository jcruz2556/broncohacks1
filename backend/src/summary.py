import asyncio
import os
import httpx

from fastapi import APIRouter, HTTPException
from supabase_client import supabase
from backboard import AsyncBackboardClient  # pip install backboard-sdk

router = APIRouter(prefix="/summary", tags=["summary"])

GEMINI_API_KEY = os.environ.get("GEMINI_API_KEY")
BACKBOARD_API_KEY = os.environ.get("BACKBOARD_API_KEY")
GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"


# ── Formulas (mirrors houses.py) ─────────────────────────────────────────────

def compute_output_w(raw_resistor_values: list[float]) -> float:
    if not raw_resistor_values:
        return 0.0
    avg = sum(raw_resistor_values) / len(raw_resistor_values)
    return round((avg / 1023.0) * 100.0, 2)


def compute_efficiency_percentage(output_w: float, max_output_w: float = 100.0) -> float:
    if max_output_w == 0:
        return 0.0
    return round((output_w / max_output_w) * 100.0, 2)


# ── Backboard helpers ─────────────────────────────────────────────────────────

def get_backboard_client() -> AsyncBackboardClient:
    return AsyncBackboardClient(api_key=BACKBOARD_API_KEY)


async def get_or_create_house_assistant(client: AsyncBackboardClient, house_id: int) -> str:
    """
    Each house gets its own Backboard assistant so memories are isolated per house.
    Reuses the assistant if it already exists.
    """
    name = f"Solar House {house_id}"
    assistants = await client.list_assistants()

    for a in assistants:
        if a.name == name:
            return a.assistant_id

    assistant = await client.create_assistant(
        name=name,
        system_prompt=(
            f"You are an energy analyst for House {house_id}. "
            "You monitor solar panel performance and provide summaries based on sensor data. "
            "You remember past summaries and use them to identify trends over time."
        ),
    )
    return assistant.assistant_id


# ── Gemini helper ─────────────────────────────────────────────────────────────

def call_gemini(prompt: str) -> str:
    with httpx.Client() as http:
        res = http.post(
            f"{GEMINI_URL}?key={GEMINI_API_KEY}",
            json={"contents": [{"parts": [{"text": prompt}]}]},
            timeout=30,
        )
        if res.status_code != 200:
            raise HTTPException(status_code=502, detail=f"Gemini error: {res.text}")
        return res.json()["candidates"][0]["content"]["parts"][0]["text"]


# ── Data fetcher ──────────────────────────────────────────────────────────────

def fetch_house_energy_data(house_id: int) -> dict:
    house_resp = supabase.table("houses").select("*").eq("house_id", house_id).execute()
    if not house_resp.data:
        raise HTTPException(status_code=404, detail="House not found")

    panels_resp = supabase.table("panels").select("*").eq("house_id", house_id).execute()
    panels = panels_resp.data

    panel_summaries = []
    for panel in panels:
        panel_id = panel["id"]

        reading_resp = (
            supabase.table("panel_readings")
            .select("*")
            .eq("panel_id", panel_id)
            .order("recorded_at", desc=True)
            .limit(1)
            .execute()
        )
        latest_reading = reading_resp.data[0] if reading_resp.data else None

        resistors_resp = (
            supabase.table("resistors")
            .select("*")
            .eq("panel_id", panel_id)
            .order("created_at", desc=True)
            .limit(4)
            .execute()
        )
        resistor_values = [r["output_w"] for r in resistors_resp.data]
        output_w = compute_output_w(resistor_values)
        efficiency = compute_efficiency_percentage(output_w)

        panel_summaries.append({
            "panel_id": panel_id,
            "output_w": output_w,
            "efficiency_percentage": efficiency,
            "latest_reading": latest_reading,
        })

    return {
        "house_id": house_id,
        "total_panels": len(panels),
        "panels": panel_summaries,
    }


# ── Summary endpoint ──────────────────────────────────────────────────────────

@router.get("/{house_id}")
async def get_energy_summary(house_id: int):
    """
    Flow:
    1. Fetch live energy data from Supabase
    2. Build a prompt from the data
    3. Call Gemini to generate the summary
    4. Send the summary to Backboard with memory="Auto" so it:
       - Saves the summary as a memory on the house assistant
       - Recalls past summaries automatically in future calls
    5. Return the Gemini summary
    """

    # 1. Fetch live data
    energy_data = fetch_house_energy_data(house_id)

    # 2. Build prompt for Gemini
    panel_lines = ""
    for p in energy_data["panels"]:
        panel_lines += (
            f"  - Panel {p['panel_id']}: "
            f"output = {p['output_w']}W, "
            f"efficiency = {p['efficiency_percentage']}%, "
            f"latest reading = {p['latest_reading']}\n"
        )

    gemini_prompt = f"""
You are an energy analyst assistant for a solar panel monitoring system.

Current energy data for House {house_id}:
- Total panels: {energy_data['total_panels']}
{panel_lines}

Write a clear and concise summary (3-5 sentences) covering:
- Whether the solar panels are performing efficiently or inefficiently
- Which panels are underperforming if any
- A practical recommendation for the homeowner
""".strip()

    # 3. Call Gemini for the summary
    gemini_summary = call_gemini(gemini_prompt)

    # 4. Send to Backboard with memory="Auto"
    #    This saves the summary as a persistent memory on the house assistant
    #    and will automatically recall past summaries in future calls
    client = get_backboard_client()
    assistant_id = await get_or_create_house_assistant(client, house_id)
    thread = await client.create_thread(assistant_id)

    backboard_message = (
        f"New energy summary for House {house_id}:\n\n"
        f"{gemini_summary}\n\n"
        f"Raw data: {energy_data}"
    )

    response = await client.add_message(
        thread_id=thread.thread_id,
        content=backboard_message,
        memory="Auto",   # Saves this summary + recalls past ones automatically
        stream=False,
    )

    # Optional: wait for memory to be saved before returning
    if response.memory_operation_id:
        await _wait_for_memory(client, response.memory_operation_id)

    return {
        "house_id": house_id,
        "summary": gemini_summary,
        "based_on_panels": energy_data["total_panels"],
        "memory_saved": response.memory_operation_id is not None,
    }


async def _wait_for_memory(client: AsyncBackboardClient, operation_id: str, timeout: float = 15.0):
    """Poll until Backboard finishes saving the memory."""
    import time
    start = time.time()
    while time.time() - start < timeout:
        status = await client.get_memory_operation_status(operation_id)
        if status.status == "COMPLETED":
            return
        if status.status == "FAILED":
            return  # Non-fatal — summary still returned
        await asyncio.sleep(1)