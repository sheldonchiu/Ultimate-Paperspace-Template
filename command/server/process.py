from db import db, Task
from sd_fooocus import process as fooocus_process

task_return_image = [
    "fooocus_t2i",
]

def process():
    while True:
        task = None
        with db.transaction():
            task = (
                Task.select()
                .where((Task.status == "Pending") & (Task.lock == False))
                .first()
            )
            if task:
                task.lock = True
                task.save()
        if task:
            if task.task_type == "fooocus_t2i":
                fooocus_process(task)

