import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../requests/bloc/request_bloc.dart';
import '../../requests/views/create_request_screen.dart';
import '../bloc/task/task_bloc.dart';
import '../bloc/task/task_event.dart';
import '../bloc/task/task_state.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskDetail extends StatefulWidget {
  final int taskId;
  const TaskDetail({super.key, required this.taskId});
  @override
  State<TaskDetail> createState() => _TaskDetailState();
}

class _TaskDetailState extends State<TaskDetail> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => TaskBloc(taskService: TaskService())..add(LoadTaskByIdEvent(widget.taskId)),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: Text(localizations.taskDetailTitle,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
                  color: Theme.of(context).appBarTheme.foregroundColor)),
        ),
        body: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) return const Center(child: CircularProgressIndicator());
            if (state is TaskDetailLoaded) return _buildTaskCard(context, state.task);
            if (state is TaskError) return Center(child: Text(state.message));
            return Center(child: Text(localizations.taskNotFound));
          },
        ),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
    final localizations = AppLocalizations.of(context)!;
    final progressColor = _getDividerColor(task.createdAt, task.dueDate, task.status);
    final formattedDates = _formatTaskDates(task);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Card(
        color: Theme.of(context).colorScheme.surfaceVariant,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(task.title,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface)),
              ),
              Container(height: 2, color: Theme.of(context).dividerColor),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 100, minWidth: double.infinity),
                child: Card(
                  color: Theme.of(context).cardColor,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(task.description,
                        style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(formattedDates,
                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface)),
              ),
              const SizedBox(height: 12),
              Container(height: 8,
                decoration: BoxDecoration(color: progressColor, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(height: 12),
              if (task.status == "IN_PROGRESS")
                Column(
                  children: [
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) => CreateRequestScreen(task: task)));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(localizations.sendComment,
                            style: const TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          final confirmation = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(localizations.completed),
                              content: Text(localizations.confirmMarkCompleted),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(context).pop(false),
                                    child: Text(localizations.cancel)),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: Text(localizations.confirm, style: const TextStyle(color: Colors.green)),
                                ),
                              ],
                            ),
                          );
                          if (confirmation == true) {
                            try {
                              await context.read<RequestBloc>()
                                  .requestService.createRequest(task.id, localizations.requestCompletionMessage, 'SUBMISSION');
                              context.read<TaskBloc>().add(UpdateTaskStatusEvent(taskId: task.id, status: 'COMPLETED'));
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(localizations.requestCreatedSuccess)));
                            } catch (_) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(localizations.requestCreatedFailure)));
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff4CAF50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(localizations.markAsCompleted,
                            style: const TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDividerColor(String createdAt, String dueDate, String status) {
    if (status == "COMPLETED") return const Color(0xFF4CAF50);
    if (status == "ON_HOLD")  return const Color(0xFFFF832A);
    if (status == "DONE")     return const Color(0xFF4A90E2);
    if (status == "EXPIRED")  return const Color(0xFFF44336);
    try {
      final created = DateTime.parse(createdAt).toLocal();
      final due = DateTime.parse(dueDate).toLocal();
      final now = DateTime.now();
      final totalSeconds = due.difference(created).inSeconds.toDouble();
      final secondsPassed = now.difference(created).inSeconds.toDouble();
      if (totalSeconds <= 0) return const Color(0xFFF44336);
      final progress = (secondsPassed / totalSeconds).clamp(0.0, 1.0);
      if (now.isAfter(due)) return const Color(0xFFF44336);
      if (progress < 0.7)   return const Color(0xFF4CAF50);
      return const Color(0xFFFDD634);
    } catch (_) {
      return const Color(0xFF4CAF50);
    }
  }

  String _formatTaskDates(Task task) {
    try {
      final createdAt = DateTime.parse(task.createdAt).toLocal();
      final dueDate = DateTime.parse(task.dueDate).toLocal();
      final format1 = DateFormat('dd/MM/yyyy');
      final format2 = DateFormat('dd/MM/yyyy HH:mm');
      return '${format1.format(createdAt)} - ${format2.format(dueDate)}';
    } catch (_) {
      return '${task.createdAt.substring(0, 10)} - ${task.dueDate.substring(0, 10)}';
    }
  }
}
