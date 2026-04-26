from supabase import create_client, Client
from google.cloud import secretmanager
import os

def get_secret(secret_id):
    client = secretmanager.SecretManagerServiceClient()
    name = f"projects/broncohacks-494423/secrets/{secret_id}/versions/latest"
    response = client.access_secret_version(request={"name": name})
    return response.payload.data.decode("UTF-8")

ENV = os.environ.get("ENV", "development")

if ENV == "production":
    SUPABASE_URL = get_secret("SUPABASE_URL")
    SUPABASE_KEY = get_secret("SUPABASE_KEY")
else:
    SUPABASE_URL = os.environ.get("SUPABASE_URL")
    SUPABASE_KEY = os.environ.get("SUPABASE_KEY")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)