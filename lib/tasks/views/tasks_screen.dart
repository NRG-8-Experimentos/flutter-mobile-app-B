import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:synhub_flutter/requests/views/create_request_screen.dart';
import 'package:synhub_flutter/tasks/views/task_detail.dart';

import '../../l10n/app_localizations.dart';
import '../../requests/bloc/request_bloc.dart';
import '../bloc/task/task_bloc.dart';
import '../bloc/task/task_event.dart';
import '../bloc/task/task_state.dart';
import '../models/task.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {

  @override
  void initState() {
    super.initState();
    // Cargar las tareas al iniciar la pantalla
    context.read<TaskBloc>().add(LoadMemberTasksEvent());
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(localizations.myTasks, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                border: Border.fromBorderSide(
                  BorderSide(
                    color: Color(0xFF2C2C2C),
                    width: 2,
                  ),
                ),
                color: Colors.white,
              ),
              child: IconButton(
                icon: const Icon(Icons.question_mark, color: Color(0xFF2C2C2C), size: 16),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(localizations.help, style: TextStyle(color: Color(0xFF1A4E85), fontWeight: FontWeight.bold)),
                      content:
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(localizations.helpDialog1, textAlign: TextAlign.justify),
                          SizedBox(height: 8),
                          Text(localizations.helpDialog2, textAlign: TextAlign.justify),
                          SizedBox(height: 8),
                          Text(localizations.helpDialog3, style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 8),
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Color(0xFF4CAF50),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(localizations.helpDialog4, textAlign: TextAlign.justify),
                          SizedBox(height: 8),
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Color(0xFFFDD634),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(localizations.helpDialog5, textAlign: TextAlign.justify),
                          SizedBox(height: 8),
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Color(0xFFF44336),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(localizations.helpDialog6, textAlign: TextAlign.justify),
                          SizedBox(height: 8),
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Color(0xFFFF832A),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(localizations.helpDialog7, textAlign: TextAlign.justify),
                          SizedBox(height: 8),
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Color(0xFF4A90E2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(localizations.helpDialog8, textAlign: TextAlign.justify),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(localizations.close, style: const TextStyle(color: Color(0xFF1A4E85))),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MemberTasksLoaded) {
            return _buildTaskContent(state.tasks, context);
          } else if (state is TaskError) {
            return Center(child: Text(state.message));
          }
          return Center(child: Text(localizations.noData));
        },
      ),
    );
  }

  Widget _buildTaskContent(List<Task> tasks, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final inProgressTasks = tasks.where((t) => t.status == "IN_PROGRESS").toList();
    final completedTasks = tasks.where((t) => t.status == "COMPLETED").toList();
    final expiredTasks = tasks.where((t) => t.status == "EXPIRED").toList();
    final doneTasks = tasks.where((t) => t.status == "DONE").toList();
    final onHoldTasks = tasks.where((t) => t.status == "ON_HOLD").toList();

    Widget buildSection(String title, List<Task> sectionTasks) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A4E85))),
          ),
          sectionTasks.isEmpty
              ? Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A4E85),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                localizations.noTasksInSection,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          )
              : Column(
            children: sectionTasks.map((task) => _buildTaskCard(task, context)).toList(),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSection(localizations.section_in_progress, inProgressTasks),
            buildSection(localizations.section_expired, expiredTasks),
            buildSection(localizations.section_on_hold, onHoldTasks),
            buildSection(localizations.section_marked_done, completedTasks),
            buildSection(localizations.section_completed, doneTasks),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Task task, BuildContext contextT) {
    final localizations = AppLocalizations.of(contextT)!;
    final progressColor = _getDividerColor(task.createdAt, task.dueDate, task.status);
    final formattedDates = _formatTaskDates(task);

    return InkWell(
      onTap: () {
        // Navegar a la pantalla de detalles de la tarea
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TaskDetail(taskId: task.id)
            )
        );
      },
      child: Card(
        color: Color(0xFFF5F5F5),
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.black
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 100,
                  minWidth: double.infinity,
                ),
                child: Card(
                  color: Colors.white,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child:
                  Padding(
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
              // Barra de progreso con color según estado
              const SizedBox(height: 12),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: progressColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              if (task.status == "IN_PROGRESS") ...[
                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context, 
                          MaterialPageRoute(builder: (context) => CreateRequestScreen(task: task))
                      );
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
                const SizedBox(height: 12),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      final confirmation = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(localizations.completedDialogTitle),
                          content: Text(localizations.confirmMarkCompleted),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(localizations.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text(localizations.confirm, style: TextStyle(color: Colors.green)),
                            ),
                          ],
                        ),
                      );
                      if (confirmation == true) {
                        try {
                          await context.read<RequestBloc>()
                              .requestService.createRequest(
                              task.id,
                              'Se ha completado la tarea.',
                              'SUBMISSION'
                          );
                          context.read<TaskBloc>().add(
                            UpdateTaskStatusEvent(
                              taskId: task.id,
                              status: 'COMPLETED',
                            ),
                          );
                          context.read<TaskBloc>().add(LoadMemberTasksEvent());

                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(localizations.requestCreatedSuccess)),
                          );
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(localizations.requestCreatedFailure)),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(localizations.markAsCompleted, style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getDividerColor(String createdAt, String dueDate, String status) {
    if (status == "COMPLETED") return Color(0xFF4CAF50); // Verde para tareas completadas
    if (status == "ON_HOLD") return Color(0xFFFF832A); // Naranja para tareas en espera
    if (status == "DONE") return Color(0xFF4A90E2); // Azul para tareas hechas
    if(status == "EXPIRED") return Color(0xFFF44336); // Rojo para tareas vencidas
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
}
