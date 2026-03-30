import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';

class TaskProvider extends ChangeNotifier {
  List<Task> tasks = [];
  bool isLoading = false;

  final api = ApiService();

  Future<void> fetchTasks() async {
    isLoading = true;
    notifyListeners();

    tasks = await api.getTasks();

    isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    isLoading = true;
    notifyListeners();

    await api.createTask(task);
    await fetchTasks();
  }

  Future<void> deleteTask(int id) async {
    await api.deleteTask(id);
    await fetchTasks();
  }
}