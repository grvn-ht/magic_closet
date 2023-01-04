from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
import os

database_path = os.path.abspath(os.path.dirname(__file__))


db = SQLAlchemy()
ma = Marshmallow()

def setup_db(app, database_path=database_path):
    app.config["SQLALCHEMY_DATABASE_URI"] = 'sqlite:///' + os.path.join(database_path, 'db.sqlite')
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
    db.app = app
    db.init_app(app)
    ma.app = app
    ma.init_app(app)
    return db

def db_drop_and_create_all(app):
    with app.app_context():
        db.drop_all()
        db.create_all() 

class TodoItem(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100))
    is_executed = db.Column(db.Boolean)

    def __init__(self, name, is_executed):
        self.name = name
        self.is_executed = is_executed

# Todo schema
class TodoSchema(ma.Schema):
    class Meta:
        fields = ('id', 'name', 'is_executed')

