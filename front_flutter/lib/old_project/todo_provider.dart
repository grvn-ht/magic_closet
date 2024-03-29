import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/old_project/models/todo_item.dart';
import 'package:http/http.dart' as http;

class TodoProvider with ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  bool _hasError = false;
  bool get hasError => _hasError;
  List<TodoItem> _items = [];

  final appModeUrl = 'http://10.0.2.2:5000/todo';
  final webModeUrl = 'http://127.0.0.1:5000/todo';

  String get url {
    // Check if you are running in a web environment
    if (kIsWeb) {
      return webModeUrl;
    } else {
      return appModeUrl;
    }
  }
  // final url = 'http://127.0.0.1:5000/todo';
  //'http://10.0.2.2:5000/todo';'http://127.0.0.1:5000/todo'

  List<TodoItem> get items {
    return [..._items];
  }

  Future<void> addTodo(String task) async {
    if (task.isEmpty) {
      return;
    }
    Map<String, dynamic> request = {"name": task, "is_executed": false};
    final headers = {'Content-Type': 'application/json'};
    final response = await http.post(Uri.parse(url),
        headers: headers, body: json.encode(request));
    Map<String, dynamic> responsePayload = json.decode(response.body);
    final todo = TodoItem(
        id: responsePayload["id"],
        itemName: responsePayload["name"],
        isExecuted: responsePayload["is_executed"]);
    _items.add(todo);
    notifyListeners();
  }

  Future<void> get getTodos async {
    var response;
    try {
      response = await http.get(Uri.parse(url));
      List<dynamic> body = json.decode(response.body);
      _items = body
          .map((e) => TodoItem(
              id: e['id'], itemName: e['name'], isExecuted: e['is_executed']))
          .toList();
    } catch (e) {
      print(e);
    }

    notifyListeners();
  }

  Future<void> deleteTodo(int todoId) async {
    var response;
    try {
      response = await http.delete(Uri.parse("$url/$todoId"));
      final body = json.decode(response.body);
      _items.removeWhere((element) => element.id == body["id"]);
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }

  Future<void> executeTask(int todoId) async {
    try {
      final response = await http.patch(Uri.parse("$url/$todoId"));
      Map<String, dynamic> responsePayload = json.decode(response.body);
      _items.forEach((element) => {
            if (element.id == responsePayload["id"])
              {element.isExecuted = responsePayload["is_executed"]}
          });
    } catch (e) {
      print(e);
    }
    notifyListeners();
  }
}
