from peewee import BooleanField, CharField, Model, SqliteDatabase

db = SqliteDatabase('task.db', pragmas={'foreign_keys': 1})
db.connect()

class Task(Model):
    name = CharField()
    status = CharField()
    result = CharField()
    lock = BooleanField(default=False)

    class Meta:
        database = db