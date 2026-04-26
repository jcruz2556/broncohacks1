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

# How many past readings to analyze per panel
READINGS_HISTORY_LIMIT = 10


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


# ── Reading analysis helpers ──────────────────────────────────────────────────

def parse_reading_json(reading: dict | None) -> dict:
    """
    Safely parse a panel_readings.reading jsonb value.
    Expected shape: {"LL": int, "UL": int, "UR": int, "LR": int}
    Returns zeroed dict if missing or malformed.
    """
    if not reading:
        return {"LL": 0, "UL": 0, "UR": 0, "LR": 0}
    return {
        "LL": reading.get("LL", 0),
        "UL": reading.get("UL", 0),
        "UR": reading.get("UR", 0),
        "LR": reading.get("LR", 0),
    }


def average_sensors(reading_json: dict) -> float:
    """Average the 4 sensor values from a reading jsonb."""
    values = list(reading_json.values())
    return round(sum(values) / len(values), 2) if values else 0.0


def analyze_reading_trend(readings: list[dict]) -> dict:
    """
    Given a list of panel_readings rows (ordered oldest → newest),
    compute per-sensor trends and overall output trend.

    Returns a dict with:
    - per_sensor_trend: {LL, UL, UR, LR} -> "increasing" | "decreasing" | "stable"
    - avg_output_trend: "increasing" | "decreasing" | "stable"
    - first_avg: float  (oldest reading avg)
    - latest_avg: float (newest reading avg)
    - delta: float      (latest - first)
    - dominant_sensor: which sensor consistently has highest value (most light)
    """
    if not readings:
        return {}

    parsed = [parse_reading_json(r.get("reading")) for r in readings]

    # Per-sensor trend (compare first half avg vs second half avg)
    mid = max(1, len(parsed) // 2)
    first_half = parsed[:mid]
    second_half = parsed[mid:]

    sensor_trends = {}
    for sensor in ["LL", "UL", "UR", "LR"]:
        first_avg = sum(p[sensor] for p in first_half) / len(first_half)
        second_avg = sum(p[sensor] for p in second_half) / len(second_half)
        delta = second_avg - first_avg
        if delta > 20:
            sensor_trends[sensor] = "increasing"
        elif delta < -20:
            sensor_trends[sensor] = "decreasing"
        else:
            sensor_trends[sensor] = "stable"

    # Overall output trend
    avgs = [average_sensors(p) for p in parsed]
    first_avg = avgs[0]
    latest_avg = avgs[-1]
    delta = latest_avg - first_avg

    if delta > 10:
        overall_trend = "increasing"
    elif delta < -10:
        overall_trend = "decreasing"
    else:
        overall_trend = "stable"

    # Dominant sensor (most light = highest avg across all readings)
    sensor_totals = {s: sum(p[s] for p in parsed) for s in ["LL", "UL", "UR", "LR"]}
    dominant_sensor = max(sensor_totals, key=sensor_totals.get)

    return {
        "per_sensor_trend": sensor_trends,
        "avg_output_trend": overall_trend,
        "first_avg": round(first_avg, 2),
        "latest_avg": round(latest_avg, 2),
        "delta": round(delta, 2),
        "dominant_sensor": dominant_sensor,
        "reading_count": len(readings),
    }


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
            "You monitor solar panel performance and analyze sensor readings over time. "
            "You remember past summaries and use them to identify efficiency trends. "
            "Sensor positions: LL=Lower Left, UL=Upper Left, UR=Upper Right, LR=Lower Right."
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
    """
    Fetches panels + last N panel_readings per panel.
    Analyzes the jsonb reading field for sensor trends over time.
    """
    house_resp = supabase.table("houses").select("*").eq("house_id", house_id).execute()
    if not house_resp.data:
        raise HTTPException(status_code=404, detail="House not found")

    panels_resp = supabase.table("panels").select("*").eq("house_id", house_id).execute()
    panels = panels_resp.data

    panel_summaries = []
    for panel in panels:
        panel_id = panel["id"]

        # Fetch last N readings ordered oldest → newest for trend analysis
        readings_resp = (
            supabase.table("panel_readings")
            .select("*")
            .eq("panel_id", panel_id)
            .order("recorded_at", desc=False)   # oldest first for trend direction
            .limit(READINGS_HISTORY_LIMIT)
            .execute()
        )
        readings = readings_resp.data

        # Latest reading
        latest_reading = readings[-1] if readings else None
        latest_parsed = parse_reading_json(latest_reading.get("reading") if latest_reading else None)
        latest_avg = average_sensors(latest_parsed)

        # Resistors for output computation
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

        # Trend analysis across all fetched readings
        trend = analyze_reading_trend(readings)

        panel_summaries.append({
            "panel_id": panel_id,
            "output_w": output_w,
            "efficiency_percentage": efficiency,
            "latest_sensor_values": latest_parsed,   # {LL, UL, UR, LR}
            "latest_avg_sensor": latest_avg,
            "trend": trend,                           # full trend analysis
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
    1. Fetches last 10 panel_readings per panel and analyzes sensor JSON trends
    2. Builds a detailed prompt with per-sensor and overall trends
    3. Calls Gemini for a human-readable summary
    4. Sends to Backboard with memory="Auto" — saves this summary and recalls past ones
    5. Returns the summary + trend data
    """

    # 1. Fetch and analyze data
    energy_data = fetch_house_energy_data(house_id)

    # 2. Build prompt with trend data from jsonb readings
    panel_lines = ""
    for p in energy_data["panels"]:
        trend = p.get("trend", {})
        sensor_trends = trend.get("per_sensor_trend", {})
        panel_lines += (
            f"\n  Panel {p['panel_id']}:\n"
            f"    - Computed output: {p['output_w']}W, efficiency: {p['efficiency_percentage']}%\n"
            f"    - Latest sensor readings: LL={p['latest_sensor_values']['LL']}, "
            f"UL={p['latest_sensor_values']['UL']}, "
            f"UR={p['latest_sensor_values']['UR']}, "
            f"LR={p['latest_sensor_values']['LR']}\n"
            f"    - Sensor trends over last {trend.get('reading_count', 0)} readings:\n"
            f"        LL: {sensor_trends.get('LL', 'unknown')}, "
            f"UL: {sensor_trends.get('UL', 'unknown')}, "
            f"UR: {sensor_trends.get('UR', 'unknown')}, "
            f"LR: {sensor_trends.get('LR', 'unknown')}\n"
            f"    - Overall output trend: {trend.get('avg_output_trend', 'unknown')} "
            f"(first avg: {trend.get('first_avg', 0)}, latest avg: {trend.get('latest_avg', 0)}, "
            f"delta: {trend.get('delta', 0)})\n"
            f"    - Dominant light sensor: {trend.get('dominant_sensor', 'unknown')}\n"
        )

    gemini_prompt = f"""
You are an energy analyst assistant for a solar panel monitoring system.

Each panel has 4 light sensors (LL=Lower Left, UL=Upper Left, UR=Upper Right, LR=Lower Right).
Higher sensor values mean more light detected. Sensors are 0-1023 (10-bit Arduino analog read).

Current energy data for House {house_id} ({energy_data['total_panels']} panels):
{panel_lines}

Based on this sensor data and trends, write a clear summary (4-6 sentences) covering:
- Overall solar panel efficiency across the house
- Which panels or sensors are performing well vs underperforming
- Whether energy output is trending up, down, or stable over time
- What the dominant light direction suggests about panel orientation
- One practical recommendation for the homeowner
""".strip()

    # 3. Call Gemini
    gemini_summary = call_gemini(gemini_prompt)

    # 4. Send to Backboard — memory="Auto" saves this + recalls past summaries
    client = get_backboard_client()
    assistant_id = await get_or_create_house_assistant(client, house_id)
    thread = await client.create_thread(assistant_id)

    backboard_message = (
        f"Energy summary for House {house_id}:\n\n"
        f"{gemini_summary}\n\n"
        f"Trend data: {[{'panel_id': p['panel_id'], 'trend': p['trend']} for p in energy_data['panels']]}"
    )

    response = await client.add_message(
        thread_id=thread.thread_id,
        content=backboard_message,
        memory="Auto",  # saves this summary + recalls past ones in future calls
        stream=False,
    )

    # Wait for memory to be saved
    if response.memory_operation_id:
        await _wait_for_memory(client, response.memory_operation_id)

    return {
        "house_id": house_id,
        "summary": gemini_summary,
        "panel_trends": [
            {
                "panel_id": p["panel_id"],
                "efficiency_percentage": p["efficiency_percentage"],
                "output_w": p["output_w"],
                "latest_sensor_values": p["latest_sensor_values"],
                "trend": p["trend"],
            }
            for p in energy_data["panels"]
        ],
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