import io
from PIL import Image, ImageDraw
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app, raise_server_exceptions=False)

# Login as student
login_res = client.post("/api/auth/login", json={"email": "arun.kumar@scantosecure.edu", "password": "Student@12345"})
print("Login status:", login_res.status_code)
token = login_res.json()["access_token"]
headers = {"Authorization": f"Bearer {token}"}

# Create a small valid PNG image
img = Image.new("RGB", (400, 200), color=(255, 255, 255))
d = ImageDraw.Draw(img)
d.text((20, 20), "Certificate of Achievement", fill=(0, 0, 0))
d.text((20, 50), "Awarded to Arun Kumar", fill=(0, 0, 0))
buf = io.BytesIO()
img.save(buf, format="PNG")
buf.seek(0)

files = {"file": ("test_cert_fresh.png", buf.getvalue(), "image/png")}
res = client.post("/api/certificates/upload", files=files, headers=headers)
print("Upload status:", res.status_code)
print("Upload response:", res.text)
