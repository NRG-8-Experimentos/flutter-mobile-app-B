class Task {
  final int id;
  final String title;
  final String description;
  final String dueDate;
  final String createdAt;
  final String updatedAt;
  final String status;
  final int timesRearranged;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    this.timesRearranged = 0,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      dueDate: json['dueDate'] ?? json['due_date'] ?? '',
      createdAt: json['createdAt'] ?? json['created_at'] ?? '',
      updatedAt: json['updatedAt'] ?? json['updated_at'] ?? '',
      status: json['status'] ?? 'ON_HOLD',
      timesRearranged: json['timesRearranged'] ?? json['times_rearranged'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'status': status,
      'timesRearranged': timesRearranged,
    };
  }
}