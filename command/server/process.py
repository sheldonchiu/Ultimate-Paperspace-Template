import time
from db import db, Task
from sd_fooocus import process_t2i as fooocus_process

import logging
logging.basicConfig(level=logging.INFO)


def process():
    logging.info("Start background process")
    while True:
        task = None
        with db.transaction():
            task = (
                Task.select()
                .where((Task.status == "Pending") & (Task.lock == False))
                .first()
            )
            if task:
                logging.info(f"Processing task {task.id}")
                task.status = "Running"
                task.lock = True
                task.save()
        if task:
            if task.task_type == "fooocus_t2i":
                fooocus_process(task)
                
        time.sleep(1)

if __name__ == "__main__":
    process()
