import os
from pydantic import BaseModel
from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import HTTPBasic, HTTPBasicCredentials
from subprocess import PIPE, run, CalledProcessError

app = FastAPI()
security = HTTPBasic()

class Command(BaseModel):
    command: str

username = os.environ['COMMAND_USERNAME']
password = os.environ['COMMAND_PASSWORD']

# define a function to authenticate users
def authenticate(credentials: HTTPBasicCredentials = Depends(security)):
    """Authenticate users with basic auth"""

    if credentials.username != username or credentials.password != password:
        raise HTTPException(status_code=401, detail="Invalid username or password")
    return True

# define a route that executes a command and returns the output
@app.post("/execute")
def execute_command(command: Command, authenticated: bool = Depends(authenticate)):
    """Execute a command and return the output"""
    try:
        result = run(command.command, shell=True, stdout=PIPE, stderr=PIPE, universal_newlines=True)
        output = result.stdout
        error = result.stderr
    except CalledProcessError as e:
        raise HTTPException(status_code=500, detail=f"Error executing command: {e}")
    return {"code": result.returncode, "output": output, "error": error}

@app.post("/run")
async def start_process(command: Command, authenticated: bool = Depends(authenticate)):
    """Start a background process"""
    try:
        run(command.command, shell=True, check=False)
    except CalledProcessError as e:
        raise HTTPException(status_code=500, detail=f"Error starting process: {e}")
    return {"code": "0", "output": "Process started in the background."}