from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"status": "success", "message": "Welcome to the Aivar DevOps Interview Pipeline!"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}