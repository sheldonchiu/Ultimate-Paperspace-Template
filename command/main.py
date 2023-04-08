import os
from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import HTTPBasic, HTTPBasicCredentials
from subprocess import PIPE, run, CalledProcessError

app = FastAPI()
security = HTTPBasic()

username = os.environ['COMMAND_USERNAME']
password = os.environ['COMMAND_PASSWORD']

# define a function to authenticate users
def authenticate(credentials: HTTPBasicCredentials = Depends(security)):
    """Authenticate users with basic auth"""

    if credentials.username != username or credentials.password != password:
        raise HTTPException(status_code=401, detail="Invalid username or password")
    return True

# define a route that executes a command and returns the output
@app.get("/execute")
def execute_command(command: str, authenticated: bool = Depends(authenticate)):
    """Execute a command and return the output"""
    try:
        result = run(command, shell=True, stdout=PIPE, stderr=PIPE, universal_newlines=True)
        output = result.stdout
        error = result.stderr
    except CalledProcessError as e:
        raise HTTPException(status_code=500, detail=f"Error executing command: {e}")
    return {"code": result.returncode, "output": output, "error": error}

@app.post("/run")
async def start_process(command: str, authenticated: bool = Depends(authenticate)):
    """Start a background process"""
    try:
        run(command, shell=True, check=False)
    except CalledProcessError as e:
        raise HTTPException(status_code=500, detail=f"Error starting process: {e}")
    return {"message": "Process started in the background."}