import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;

  TaskFormScreen({this.task});

  @override
  _TaskFormScreenState createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();

  DateTime? dueDate;
  String status = "To-Do";
  int? blockedBy;

  // 🔁 NEW
  bool isRecurring = false;
  String recurringType = "daily";

  bool loading = false;

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      _title.text = widget.task!.title;
      _desc.text = widget.task!.description;
      dueDate = widget.task!.dueDate;
      status = widget.task!.status;
      blockedBy = widget.task!.blockedBy;

      // 🔁 Load recurring data
      isRecurring = widget.task!.isRecurring;
      recurringType = widget.task!.recurringType ?? "daily";
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Task Form")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: InputDecoration(labelText: "Title"),
            ),

            TextField(
              controller: _desc,
              decoration: InputDecoration(labelText: "Description"),
            ),

            SizedBox(height: 10),

            ElevatedButton(
              child: Text(
                dueDate == null
                    ? "Select Date"
                    : dueDate!.toLocal().toString().split(' ')[0],
              ),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                setState(() => dueDate = picked);
              },
            ),

            SizedBox(height: 10),

            DropdownButton<String>(
              value: status,
              items: ["To-Do", "In Progress", "Done"]
                  .map((e) =>
                      DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => status = val!),
            ),

            SizedBox(height: 10),

            DropdownButton<int?>(
              hint: Text("Blocked By"),
              value: blockedBy,
              items: [
                DropdownMenuItem(value: null, child: Text("None")),
                ...provider.tasks.map((t) =>
                    DropdownMenuItem(value: t.id, child: Text(t.title)))
              ],
              onChanged: (val) => setState(() => blockedBy = val),
            ),

            SizedBox(height: 10),

            // 🔁 RECURRING TOGGLE
            SwitchListTile(
              title: Text("Recurring Task"),
              value: isRecurring,
              onChanged: (val) {
                setState(() => isRecurring = val);
              },
            ),

            if (isRecurring)
              DropdownButton<String>(
                value: recurringType,
                items: ["daily", "weekly"]
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(e),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() => recurringType = val!);
                },
              ),

            SizedBox(height: 20),

            // 💾 SAVE BUTTON (WITH LOADING)
            ElevatedButton(
              onPressed: loading
                  ? null
                  : () async {
                      setState(() => loading = true);

                      final task = Task(
                        title: _title.text,
                        description: _desc.text,
                        dueDate: dueDate ?? DateTime.now(),
                        status: status,
                        blockedBy: blockedBy,
                        isRecurring: isRecurring,
                        recurringType:
                            isRecurring ? recurringType : null,
                      );

                      if (widget.task == null) {
                        await provider.addTask(task);
                      } else {
                        await provider.api
                            .updateTask(widget.task!.id!, task.toJson());
                        await provider.fetchTasks();
                      }

                      setState(() => loading = false);
                      Navigator.pop(context);
                    },
              child: loading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}