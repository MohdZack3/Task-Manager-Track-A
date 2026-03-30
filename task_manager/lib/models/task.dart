class Task {
  final int? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String status;
  final int? blockedBy;
  final bool isRecurring;
  final String? recurringType;

Task({
  this.id,
  required this.title,
  required this.description,
  required this.dueDate,
  required this.status,
  this.blockedBy,
  this.isRecurring = false,
  this.recurringType,
});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['due_date']),
      status: json['status'],
      blockedBy: json['blocked_by'],
      isRecurring: json['is_recurring'] ?? false,
      recurringType: json['recurring_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "due_date": dueDate.toIso8601String().split("T")[0],
      "status": status,
      "blocked_by": blockedBy,
      "is_recurring": isRecurring,
      "recurring_type": recurringType,
      "priority": 0,
    };
  }
}