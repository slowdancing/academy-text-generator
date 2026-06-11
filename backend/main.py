from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from schemas import ReportInput
from ai_comment import generate_ai_comment

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=r"http://(localhost|127\.0\.0\.1):\d+",
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def health_check():
    return {"message": "academy text generator backend is running"}


@app.post("/generate-comment")
def generate_comment(data: ReportInput):
    comment = generate_ai_comment(data)
    return {"comment": comment}