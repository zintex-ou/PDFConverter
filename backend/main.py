from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

class Message(BaseModel):
    text: str

@app.get("/")
def root():
    return {"message": "Hello from FastAPI"}

@app.post("/send")
def send_message(msg: Message):
    return {"received": msg.text}
