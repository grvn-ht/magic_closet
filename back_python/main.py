from flask import Flask, request, jsonify
from model import setup_db, db_drop_and_create_all, TodoSchema, TodoItem
from flask_cors import CORS

app = Flask(__name__)
CORS(app)  
# Initialize schema
todo_schema = TodoSchema()
todos_schema = TodoSchema(many=True)

db = setup_db(app)
db_drop_and_create_all(app)

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
    db.session.delete(todo_to_delete)
    db.session.commit()

    return todo_schema.jsonify(todo_to_delete)

if __name__ == '__main__':
    app.run(debug=True)