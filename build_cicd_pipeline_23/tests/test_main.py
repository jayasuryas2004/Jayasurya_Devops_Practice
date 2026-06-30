from fastapi.testclient import TestClient
from src.main import app

client = TestClient(app)

def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"status": "success", "message": "Welcome to the DevOps Interview Pipeline!"}

def test_health_check():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "healthy"}

# INTENTIONAL FAILURE: Uncomment the lines below during your interview prep
# to prove that GitHub Actions halts the pipeline when a test fails.
# def test_intentional_failure():
#     assert False, "This is an intentional failure to test the CI pipeline"