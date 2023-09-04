from flask import Flask, request, jsonify, json, Blueprint
from model_old import setup_db, db_drop_and_create_all, TodoSchema, TodoItem, User, db
from flask_cors import CORS
from urllib.parse import parse_qs
import re
from werkzeug.security import generate_password_hash, check_password_hash
from flask_login import current_user, UserMixin, LoginManager, login_user, logout_user, login_required
from typing import Union

app = Flask(__name__)

app.secret_key = 'ceci est ma cle secrete'  # Change this!
login_manager = LoginManager()

CORS(app, supports_credentials=True)

app.config['SESSION_COOKIE_SECURE'] = True
app.config['SESSION_COOKIE_HTTPONLY'] = True
# Initialize schema
todo_schema = TodoSchema()
todos_schema = TodoSchema(many=True)

db = setup_db(app)
db_drop_and_create_all(app)

login_manager.init_app(app)

@login_manager.user_loader
def user_loader(user_id):
    return User.query.get(int(user_id))

views = Blueprint('views', __name__)

@app.route('/todo', methods=['POST'])
def add_todo():
    if request.json is None:
        return jsonify({'error': 'Invalid JSON data'}), 400
    
    try:
        name = request.json['name']
        is_executed = request.json['is_executed']

        new_todo_item = TodoItem(name, is_executed)
        db.session.add(new_todo_item)
        db.session.commit()

        return todo_schema.jsonify(new_todo_item)
    except KeyError:
        return jsonify({'error': 'Missing or invalid data'}), 400

@app.route('/todo', methods=['GET'])
def get_todos():
    all_todos = TodoItem.query.all()
    result = todos_schema.dump(all_todos)

    return jsonify(result)


@app.route('/todo/<id>', methods=['PUT', 'PATCH'])
def execute_todo(id):
    todo = TodoItem.query.get(id)

    todo.is_executed = not todo.is_executed
    db.session.commit()

    return todo_schema.jsonify(todo)

@app.route('/todo/<id>', methods=['DELETE'])
def delete_todo(id):
    todo_to_delete = TodoItem.query.get(id)
    print(todo_to_delete)
    db.session.delete(todo_to_delete)
    db.session.commit()
    return todo_schema.jsonify(todo_to_delete)

@app.route('/current_user', methods=['GET'])
@login_required
def get_current_user():
    print('heyyy')
    try:
        print(request.cookies)
        user = current_user._get_current_object() if isinstance(current_user, UserMixin) else None #user = current_user if isinstance(current_user, UserMixin) else None
        if user and user.is_authenticated:
            user_data = {
                'id': user.get_id(),
                'email': user.email
                }
            return jsonify(user_data)
        else:
            return jsonify({'message': 'User not authenticated'}), 401
    except KeyError:
        print(KeyError)
        return jsonify({'error': 'error current user'}), 400



@views.route('/register', methods=["POST"])
def register():
    content = request.form
    print(content)
    try:
        d={}
        mail = content.get("email")
        password = content.get("password")

        if mail is None:
            return jsonify(["missing mail"])
        if password is None:
            return jsonify(["missing password"])

        # Check for valid email format using regular expression
        #if not re.match(r"[^@]+@[^@]+\.[^@]+", mail):
        #    return jsonify(["Invalid email format"])

        # Check for a robust password (at least 8 characters, with upper/lowercase and digits)
        #if not (len(password) >= 8 and any(c.isupper() for c in password) and any(c.islower() for c in password) and any(c.isdigit() for c in password)):
        #    return jsonify(["Weak password"])
        
        password = generate_password_hash(password)

        email = User.query.filter_by(email=mail).first()

        if email is None:
            register = User(email=mail, password=password)

            db.session.add(register)
            db.session.commit()

            #login = Student.query.filter_by(email=mail).first()

            login_user(register)
            print(current_user)
            return jsonify(["Register success"])
        else:
            return jsonify(["user alredy exist"])
    except KeyError:
        return jsonify({'error': 'Missing or invalid data'}), 400


@views.route('/login', methods=["POST"])
def login():
    content = request.form
    print(content)
    try:
        d = {}
        mail = content.get("email")
        password = content.get("password")

        login = User.query.filter_by(email=mail).first()

        if login is None:
            return jsonify(["Wrong Credentials"]) 
        elif password is not None and check_password_hash(login.password, password):
            login_user(login)
            print(current_user)
            return jsonify(["success"])
        else:
            return jsonify(["Wrong Credentials"])
    except KeyError:
        return jsonify({'error': 'Missing or invalid data'}), 400

@views.route('/logout', methods=['POST'])
def logout():
    try:
        logout_user()
        return jsonify(['Logged out'])
    except KeyError:
        print(KeyError)
        return jsonify({'error': 'An error occurred during logout'}), 500

app.register_blueprint(views)

if __name__ == '__main__':
    app.run(debug=True)