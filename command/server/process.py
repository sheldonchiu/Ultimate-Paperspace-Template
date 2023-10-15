import time
import requests
from db import db, Task
from sd_fooocus import process_t2i as fooocus_process

import logging
logging.basicConfig(level=logging.INFO)


def wait_for_server_ready(url):
    while True:
        try:
            response = requests.get(url)
            if response.status_code == 200:
                return True
        except requests.exceptions.ConnectionError:
            pass
        time.sleep(1)
        


def process():
    logging.info("Start background process")
    while True:
        task = None
        with db.transaction():
            task = (
                Task.select()
                .where(Task.status == "Pending")
                .first()
            )
            if task:
                logging.info(f"Processing task {task.id}")
                task.status = "Running"
                task.save()
        if task:
            if task.task_type == "fooocus_t2i":
                wait_for_server_ready("https://localhost:7015")
                fooocus_process(task)
                
        time.sleep(1)

if __name__ == "__main__":
    process()
