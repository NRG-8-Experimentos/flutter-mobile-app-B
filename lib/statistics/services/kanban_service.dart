import '../models/kanban_column.dart';
import '../../tasks/models/task.dart';

class KanbanService {
  static const Map<String, Map<String, dynamic>> _columnConfig = {
    'ON_HOLD': {
      'title': 'Pendientes',
      'color': '#f59e42',
      'icon': 'pause_circle_outline',
    },
    'IN_PROGRESS': {
      'title': 'En Progreso',
      'color': '#3b82f6',
      'icon': 'autorenew',
    },
    'COMPLETED': {
      'title': 'Completadas',
      'color': '#22c55e',
      'icon': 'check_circle',
    },
    'DONE': {
      'title': 'Terminadas',
      'color': '#14b8a6',
      'icon': 'done_all',
    },
    'EXPIRED': {
      'title': 'Atrasadas',
      'color': '#ef4444',
      'icon': 'error_outline',
    },
  };

  List<KanbanColumn> organizeTasksIntoColumns(List<Task> tasks) {
    final columns = <KanbanColumn>[];

    _columnConfig.forEach((status, config) {
      final columnTasks = tasks.where((task) => task.status == status).toList();

      columns.add(KanbanColumn(
        status: status,
        title: config['title'] as String,
        tasks: columnTasks,
        color: config['color'] as String,
        icon: config['icon'] as String,
      ));
    });

    return columns;
  }

  int getTaskCountByStatus(List<Task> tasks, String status) {
    return tasks.where((task) => task.status == status).length;
  }
}

