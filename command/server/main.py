from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .terminal import router as terminal_router

app = FastAPI(docs_url=None, redoc_url=None)

# Allow CORS from all origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(terminal_router)
