import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../bloc/statistics_bloc.dart';
import '../bloc/statistics_event.dart';
import '../bloc/statistics_state.dart';
import '../services/statistics_service.dart';
import '../services/kanban_service.dart';
import '../models/kanban_column.dart';
import '../../tasks/models/task.dart';
import 'package:intl/intl.dart';

const Color kBluePrimary = Color(0xFF1A4E85);
const Color kBlueLight = Color(0xFFE3F2FD);
const Color kBlueLighter = Color(0xFFF0F6FF);
const Color kBlueAccent = Color(0xFF1976D2);
const Color kBlueCard = Color(0xFFF5F9FF);

class StatisticsScreen extends StatefulWidget {
  final String memberId;
  final String memberName;
  final String username;
  final String profileImageUrl;

  const StatisticsScreen({
    super.key,
    required this.memberId,
    required this.memberName,
    required this.username,
    required this.profileImageUrl,
  });

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<Task> _memberTasks = [];
  List<KanbanColumn> _kanbanColumns = [];
  bool _loadingTasks = true;
  final KanbanService _kanbanService = KanbanService();

  @override
  void initState() {
    super.initState();
    _fetchMemberTasks();
  }

  Future<void> _fetchMemberTasks() async {
    try {
      print('Fetching tasks for member: ${widget.memberId}');

      // Intentar primero con el endpoint directo de miembro
      List<Task> tasks = await StatisticsService().fetchMemberTasks(widget.memberId);

      // Si no hay tareas, intentar con el método por estado
      if (tasks.isEmpty) {
        print('No tasks from direct endpoint, trying by status...');
        tasks = await StatisticsService().fetchMemberTasksByStatus(widget.memberId);
      }

      print('Tasks received: ${tasks.length}');

      for (var task in tasks) {
        print('Task: ${task.title}, Status: ${task.status}');
      }

      final columns = _kanbanService.organizeTasksIntoColumns(tasks);
      print('Columns created: ${columns.length}');

      for (var column in columns) {
        print('Column ${column.title}: ${column.tasks.length} tasks');
      }

      setState(() {
        _memberTasks = tasks;
        _kanbanColumns = columns;
        _loadingTasks = false;
      });
    } catch (e) {
      print('Error in _fetchMemberTasks: $e');
      setState(() {
        _memberTasks = [];
        _kanbanColumns = [];
        _loadingTasks = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BlocProvider(
      create: (_) => StatisticsBloc(StatisticsService())..add(LoadMemberStatistics(widget.memberId)),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(localizations.statisticsTitle, style: TextStyle(color: kBluePrimary)),
          iconTheme: const IconThemeData(color: kBluePrimary),
          elevation: 0,
        ),
        body: BlocBuilder<StatisticsBloc, StatisticsState>(
          builder: (context, state) {
            if (state is StatisticsLoading || _loadingTasks) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is StatisticsLoaded) {
              final stats = state.statistics;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        color: Colors.white, // Card principal en blanco
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: kBlueLight,
                                backgroundImage: widget.profileImageUrl.isNotEmpty
                                    ? NetworkImage(widget.profileImageUrl)
                                    : null,
                                child: widget.profileImageUrl.isEmpty
                                    ? Icon(Icons.person, color: kBluePrimary, size: 32)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.memberName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: kBluePrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.username,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Cajas de estado de tareas
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatCard(
                              label: localizations.statMarkedCompleted,
                              value: stats.overview.completed.toString(),
                              color: Colors.green,
                            ),
                            _StatCard(
                              label: localizations.completed,
                              value: (stats.overview.done ?? 0).toString(),
                              color: Colors.teal,
                            ),
                            _StatCard(
                              label: localizations.inProgress,
                              value: stats.overview.inProgress.toString(),
                              color: Colors.blue,
                            ),
                            _StatCard(
                              label: localizations.statPending,
                              value: stats.overview.pending.toString(),
                              color: Colors.orange,
                            ),
                            _StatCard(
                              label: localizations.statOverdue,
                              value: stats.overview.overdue.toString(),
                              color: Colors.red,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Tablero Kanban
                      _SectionCard(
                        icon: Icons.view_kanban,
                        title: 'Tablero de Tareas',
                        child: _buildKanbanBoard(),
                      ),
                      const SizedBox(height: 18),
                      // Distribución de tareas debajo de las cajas de estado
                      _SectionCard(
                        icon: Icons.list_alt,
                        title: localizations.tasksDistribution,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 200,
                          ),
                          child: _loadingTasks
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8.0),
                                  child: Center(child: CircularProgressIndicator()),
                                )
                              : _memberTasks.isEmpty
                                  ? Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text(localizations.noAssignedTasks, style: TextStyle(color: Colors.black54)),
                                    )
                                  : Scrollbar(
                                      thumbVisibility: true,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        itemCount: _memberTasks.length,
                                        itemBuilder: (context, index) {
                                          final task = _memberTasks[index];
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 2.0),
                                            child: Row(
                                              children: [
                                                Text(
                                                  '${index + 1}.',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: kBluePrimary,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    task.title,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      // Otras secciones
                      _SectionCard(
                        icon: Icons.build,
                        title: localizations.totalReschedules,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _MetricRow(
                              label: localizations.rescheduled,
                              value: stats.rescheduledTasks.rescheduled.toString(),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _SectionCard(
                        icon: Icons.date_range,
                        title: localizations.avgCompletionTimeTitle,
                        child: Row(
                          children: [
                            Icon(Icons.timer, color: kBlueAccent),
                            const SizedBox(width: 8),
                            Text(
                              _formatAvgCompletionTime(stats.avgCompletionTime.avgDays),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: kBlueAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (state is StatisticsError) {
              return Center(child: Text(state.message));
            }
            // Cambia el mensaje por defecto para mayor claridad
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildKanbanBoard() {
    if (_loadingTasks) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando tablero...', style: TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      );
    }

    if (_kanbanColumns.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(40.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox, size: 48, color: Colors.black26),
              SizedBox(height: 16),
              Text('No hay tareas disponibles', style: TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 450,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _kanbanColumns.length,
        itemBuilder: (context, index) {
          final column = _kanbanColumns[index];
          return _buildKanbanColumn(column);
        },
      ),
    );
  }

  Widget _buildKanbanColumn(KanbanColumn column) {
    final color = _parseColor(column.color);

    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: kBluePrimary.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(_getIconData(column.icon), color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    column.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${column.tasks.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: column.tasks.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 48, color: Colors.black26),
                          SizedBox(height: 8),
                          Text(
                            'Sin tareas',
                            style: TextStyle(color: Colors.black38, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: column.tasks.length,
                    itemBuilder: (context, index) {
                      return _buildTaskCard(column.tasks[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return GestureDetector(
      onTap: () => _showTaskDetailsDialog(task),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kBlueLighter,
          border: Border.all(color: kBlueLight),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: kBluePrimary,
                    ),
                  ),
                ),
                const Icon(Icons.more_vert, color: Colors.black38, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              task.description,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: kBlueLight),
            const SizedBox(height: 12),
            // Footer
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.event, size: 16, color: Colors.black54),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _formatDate(task.dueDate),
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                if (task.timesRearranged > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFfef3c7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.sync, size: 14, color: Color(0xFF92400e)),
                        const SizedBox(width: 4),
                        Text(
                          '${task.timesRearranged}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF92400e),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTaskDetailsDialog(Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _getStatusColor(task.status),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(_getStatusIcon(task.status), color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Detalles de la Tarea',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getStatusLabel(task.status),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título
                        const Text(
                          'Título',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          task.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: kBluePrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        // Descripción
                        const Text(
                          'Descripción',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          task.description.isNotEmpty ? task.description : 'Sin descripción',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Información adicional
                        _buildDetailRow(
                          icon: Icons.event,
                          label: 'Fecha de vencimiento',
                          value: _formatDate(task.dueDate),
                          color: Colors.blue,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          icon: Icons.calendar_today,
                          label: 'Fecha de creación',
                          value: _formatDate(task.createdAt),
                          color: Colors.green,
                        ),
                        const SizedBox(height: 12),
                        _buildDetailRow(
                          icon: Icons.update,
                          label: 'Última actualización',
                          value: _formatDate(task.updatedAt),
                          color: Colors.orange,
                        ),
                        if (task.timesRearranged > 0) ...[
                          const SizedBox(height: 12),
                          _buildDetailRow(
                            icon: Icons.sync,
                            label: 'Veces reprogramada',
                            value: task.timesRearranged.toString(),
                            color: const Color(0xFF92400e),
                          ),
                        ],
                        const SizedBox(height: 20),
                        // ID de la tarea
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: kBlueLighter,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: kBlueLight),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.tag, size: 18, color: kBluePrimary),
                              const SizedBox(width: 8),
                              Text(
                                'ID: ${task.id}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: kBluePrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Footer
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kBluePrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cerrar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ON_HOLD':
        return Colors.orange;
      case 'IN_PROGRESS':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.green;
      case 'DONE':
        return Colors.teal;
      case 'EXPIRED':
        return Colors.red;
      default:
        return kBluePrimary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'ON_HOLD':
        return Icons.pause_circle_outline;
      case 'IN_PROGRESS':
        return Icons.autorenew;
      case 'COMPLETED':
        return Icons.check_circle;
      case 'DONE':
        return Icons.done_all;
      case 'EXPIRED':
        return Icons.error_outline;
      default:
        return Icons.task;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'ON_HOLD':
        return 'Pendiente';
      case 'IN_PROGRESS':
        return 'En Progreso';
      case 'COMPLETED':
        return 'Completada';
      case 'DONE':
        return 'Terminada';
      case 'EXPIRED':
        return 'Atrasada';
      default:
        return status;
    }
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'pause_circle_outline':
        return Icons.pause_circle_outline;
      case 'autorenew':
        return Icons.autorenew;
      case 'check_circle':
        return Icons.check_circle;
      case 'done_all':
        return Icons.done_all;
      case 'error_outline':
        return Icons.error_outline;
      default:
        return Icons.task;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Sin fecha';
    }
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy', 'es_ES').format(date);
    } catch (_) {
      return 'Fecha inválida';
    }
  }

  String _formatAvgCompletionTime(double avgDays) {
    final totalMinutes = (avgDays * 24 * 60).round();
    final days = totalMinutes ~/ (24 * 60);
    final hours = (totalMinutes % (24 * 60)) ~/ 60;
    final minutes = totalMinutes % 60;

    List<String> parts = [];
    if (days > 0) parts.add('$days día${days == 1 ? '' : 's'}');
    if (hours > 0) parts.add('$hours hora${hours == 1 ? '' : 's'}');
    if (minutes > 0 || parts.isEmpty) parts.add('$minutes minuto${minutes == 1 ? '' : 's'}');

    return parts.join(', ');
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  Color get vibrantBackground {
    if (color == Colors.green) {
      return const Color(0xFFB9F6CA);
    } else if (color == Colors.blue) {
      return const Color(0xFF82B1FF);
    } else if (color == Colors.orange) {
      return const Color(0xFFFFE082);
    } else if (color == Colors.red) {
      return const Color(0xFFFF8A80);
    }
    return color.withOpacity(0.15);
  }

  @override
  Widget build(BuildContext context) {
    // Soluciona overflow para textos largos como 'Marcadas como Completadas'
    return Card(
      color: vibrantBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: 110,
        height: 90,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white, // Fondo blanco para todas las section cards
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start, // <-- Añadido para alinear arriba
              children: [
                Icon(icon, color: kBluePrimary),
                const SizedBox(width: 10),
                Expanded( // <-- Añadido para evitar overflow en títulos largos
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: kBluePrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetricRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.black87)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: kBlueAccent)),
        ],
      ),
    );
  }
}
