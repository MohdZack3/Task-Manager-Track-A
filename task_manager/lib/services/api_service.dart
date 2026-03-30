import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiService {
  final String baseUrl = "http://127.0.0.1:8000";

Future<List<Task>> getTasks() async {
  final res = await http.get(Uri.parse("$baseUrl/tasks"));

  print("STATUS: ${res.statusCode}");
  print("BODY: ${res.body}");

  final data = jsonDecode(res.body);
  return data.map<Task>((t) => Task.fromJson(t)).toList();
}

  Future<void> createTask(Task task) async {
    await http.post(
      Uri.parse("$baseUrl/tasks"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(task.toJson()),
    );
  }

  Future<void> updateTask(int id, Task task) async {
    await http.put(
      Uri.parse("$baseUrl/tasks/$id"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(task.toJson()),
    );
  }

  Future<void> deleteTask(int id) async {
    await http.delete(Uri.parse("$baseUrl/tasks/$id"));
  }
}