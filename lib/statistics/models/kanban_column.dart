import '../../tasks/models/task.dart';

class KanbanColumn {
  final String status;
  final String title;
  final List<Task> tasks;
  final String color;
  final String icon;

  KanbanColumn({
    required this.status,
    required this.title,
    required this.tasks,
    required this.color,
    required this.icon,
  });
}

