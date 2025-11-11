import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:synhub_flutter/requests/bloc/request_bloc.dart';

import '../../l10n/app_localizations.dart';
import '../../tasks/bloc/task/task_event.dart';
import '../../tasks/bloc/task/task_bloc.dart';
import '../../tasks/bloc/task/task_state.dart';
import '../../tasks/models/task.dart';
import '../../tasks/services/task_service.dart';
import '../../tasks/views/tasks_screen.dart';
import '../bloc/request_event.dart';
import '../services/request_service.dart';

class CreateRequestScreen extends StatefulWidget {
  final Task task;

  const CreateRequestScreen({super.key, required this.task});

  @override
  State<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends State<CreateRequestScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => TaskBloc(taskService: TaskService())
              ..add(LoadTaskByIdEvent(widget.task.id)),
          ),
          BlocProvider(
            create: (context) => RequestBloc(requestService: RequestService()),
          ),
        ],
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            title: Text(
              widget.task.title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          body: BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state is TaskLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TaskDetailLoaded) {
                return _buildTaskCard(context, state.task);
              } else if (state is TaskError) {
                return Center(child: Text(state.message));
              }
              return Center(child: Text(localizations.taskNotFound));
            },
          ),
        )
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
    final progressColor = _getDividerColor(task.createdAt, task.dueDate);
    final formattedDates = _formatTaskDates(task);
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Card(
        color: Color(0xFFF5F5F5),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 160,
                  minWidth: double.infinity,
                ),
                child: Card(
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(
                      task.description,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  formattedDates,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: localizations.comment,
                  border: OutlineInputBorder(),
                  hintText: localizations.commentHint,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    final comment = _commentController.text.trim();
                    if (comment.isNotEmpty) {
                      BlocProvider.of<RequestBloc>(context).add(
                        CreateRequestEvent(
                          taskId: task.id,
                          description: comment,
                          requestType: 'MODIFICATION',
                        ),
                      );
                      BlocProvider.of<TaskBloc>(context).add(
                        UpdateTaskStatusEvent(
                          taskId: task.id,
                          status: 'ON_HOLD',
                        ),
                      );

                      Navigator.push(context, MaterialPageRoute(builder: (context) => const TasksScreen()));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(localizations.commentEmptyError)),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFF9800),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(localizations.sendComment, style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDividerColor(String createdAt, String dueDate) {
    try {
      // Parsear fechas considerando la zona horaria
      final created = _parseDateWithTimeZone(createdAt);
      final due = _parseDateWithTimeZone(dueDate);
      final now = DateTime.now();

      final totalSeconds = due.difference(created).inSeconds.toDouble();
      final secondsPassed = now.difference(created).inSeconds.toDouble();

      if (totalSeconds <= 0) return const Color(0xFFF44336);

      final progress = (secondsPassed / totalSeconds).clamp(0.0, 1.0);

      if (now.isAfter(due)) {
        return const Color(0xFFF44336); // Rojo - Tarea vencida
      } else if (progress < 0.7) {
        return const Color(0xFF4CAF50); // Verde - Buen progreso
      } else {
        return const Color(0xFFFDD634); // Amarillo - Progreso crítico
      }
    } catch (e) {
      return const Color(0xFF4CAF50); // Verde por defecto si hay error
    }
  }

  DateTime _parseDateWithTimeZone(String dateString) {
    try {
      // Intenta parsear como fecha con zona horaria (ISO 8601)
      return DateTime.parse(dateString).toLocal();
    } catch (e) {
      try {
        // Intenta parsear como fecha simple
        return DateFormat("yyyy-MM-dd").parse(dateString);
      } catch (e) {
        // Si falla, devuelve la fecha actual como fallback
        return DateTime.now();
      }
    }
  }

  String _formatTaskDates(Task task) {
    try {
      final createdAt = _parseDateWithTimeZone(task.createdAt);
      final dueDate = _parseDateWithTimeZone(task.dueDate);

      final format1 = DateFormat('dd/MM/yyyy');
      final format2 = DateFormat('dd/MM/yyyy HH:mm');
      return '${format1.format(createdAt)} - ${format2.format(dueDate)}';
    } catch (e) {
      // Si falla el parsing, usar los primeros 10 caracteres
      return '${task.createdAt.substring(0, 10)} - ${task.dueDate.substring(0, 10)}';
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy').format(date);
    } catch (e) {
      return dateString.length > 10 ? dateString.substring(0, 10) : dateString;
    }
  }

  bool _isTaskOverdue(String dueDate) {
    try {
      final due = DateTime.parse(dueDate);
      return DateTime.now().isAfter(due);
    } catch (e) {
      return false;
    }
  }
}
