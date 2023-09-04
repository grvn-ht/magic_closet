from flask_sqlalchemy import SQLAlchemy
from flask_marshmallow import Marshmallow
import os
from flask_login import UserMixin
#from ../main.py import app
database_path = os.path.abspath(os.path.dirname(__file__))


db = SQLAlchemy()
ma = Marshmallow()

def setup_db(app, database_path=database_path):
    app.config["SQLALCHEMY_DATABASE_URI"] = 'sqlite:///' + os.path.join(database_path, 'db.sqlite')
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
    db.init_app(app)
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

class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(100), nullable=False)
    password = db.Column(db.String(100), nullable=False)

    def __init__(self, email, password):
        self.email = email
        self.password = password
    def get_id(self):
        return str(self.id)  # Convert to string as required by Flask-Login
    def get_mail(self):
        return str(self.email)  # Convert to string as required by Flask-Login
    def to_json(self):
        return {"name": self.name,
                "email": self.email}
    def is_authenticated(self):
        return True
    def is_active(self):
        return True
    def is_anonymous(self):
        return False
