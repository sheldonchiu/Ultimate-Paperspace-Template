from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from playhouse.shortcuts import model_to_dict

from terminal import router as terminal_router
from sd_fooocus import router as fooocus_router
from db import Task

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
app.include_router(fooocus_router)

@app.get("/tasks/{task_id}")
def get_task(task_id: int):
    task = Task.get(Task.id==task_id)
    #TODO
    return model_to_dict(task)