import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'task_form_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String search = "";
  String filter = "All";
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<TaskProvider>(context, listen: false).fetchTasks());
  }

  void onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(Duration(milliseconds: 300), () {
      setState(() {
        search = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);

    List<Task> filtered = provider.tasks.where((task) {
      final matchSearch =
          task.title.toLowerCase().contains(search.toLowerCase());

      final matchFilter =
          filter == "All" || task.status == filter;

      return matchSearch && matchFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: Text("Task Manager"), centerTitle: true),

      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search tasks...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: onSearchChanged,
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButtonFormField<String>(
              value: filter,
              items: ["All", "To-Do", "In Progress", "Done"]
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) {
                setState(() => filter = val!);
              },
            ),
          ),

          SizedBox(height: 10),

          Expanded(
            child: provider.isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final task = filtered[index];

                      final isBlocked = provider.tasks.any((t) =>
                          t.id == task.blockedBy &&
                          t.status != "Done");

                      return Card(
                        color: isBlocked
                            ? Colors.grey[200]
                            : Colors.white,
                        margin: EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        child: ListTile(
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  task.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: task.status == "Done"
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                              ),

                              // 🔁 Recurring Icon
                              if (task.isRecurring)
                                Icon(Icons.repeat,
                                    color: Colors.blue, size: 18),
                            ],
                          ),

                          subtitle: Text(
                            "${task.status} • Due: ${task.dueDate.toLocal().toString().split(' ')[0]}"
                            "${task.isRecurring ? ' • ${task.recurringType}' : ''}",
                          ),

                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              provider.deleteTask(task.id!);
                            },
                          ),

                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TaskFormScreen(task: task),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskFormScreen(),
            ),
          );
        },
      ),
    );
  }
}