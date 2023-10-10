import os
from fastapi import HTTPException, Depends
from fastapi.security import HTTPBasic, HTTPBasicCredentials

username = os.environ['COMMAND_USERNAME']
password = os.environ['COMMAND_PASSWORD']

security = HTTPBasic()
# define a function to authenticate users
def authenticate(credentials: HTTPBasicCredentials = Depends(security)):
    """Authenticate users with basic auth"""

    if credentials.username != username or credentials.password != password:
        raise HTTPException(status_code=401, detail="Invalid username or password")
    return True