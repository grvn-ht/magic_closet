from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import LargeBinary,Date, DateTime
from werkzeug.security import generate_password_hash, check_password_hash
import os

database_path = os.path.abspath(os.path.dirname(__file__))

db = SQLAlchemy()

def setup_db(app, database_path=database_path):
    app.config["SQLALCHEMY_DATABASE_URI"] = 'sqlite:///' + os.path.join(database_path, 'db.sqlite')
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
    db.init_app(app)
    return db

def db_drop_and_create_all(app):
    with app.app_context():
        db.drop_all()
        db.create_all()

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(100), nullable=False, unique=True)
    password = db.Column(db.String(100), nullable=False)
    closets = db.relationship('Closet', backref='user', lazy=True)

    def __init__(self, email, password):
        self.email = email
        self.password = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password, password)

class Closet(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('user.id'), nullable=False)
    infos = db.relationship('Info', backref='closet', lazy=True)

class Info(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    temp = db.Column(db.Float)
    hum = db.Column(db.Float)
    ph = db.Column(db.Float)
    ec = db.Column(db.Float)
    image = db.Column(LargeBinary)
    event_date = db.Column(Date, nullable=False)
    created_at = db.Column(DateTime, nullable=False, server_default=db.func.now())
    closet_id = db.Column(db.Integer, db.ForeignKey('closet.id'), nullable=False)
