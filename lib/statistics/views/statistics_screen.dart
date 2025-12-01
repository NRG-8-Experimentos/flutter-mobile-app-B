import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../bloc/statistics_bloc.dart';
import '../bloc/statistics_event.dart';
import '../bloc/statistics_state.dart';
import '../services/statistics_service.dart';
import '../services/kanban_service.dart';
import '../models/kanban_column.dart';
import '../../tasks/models/task.dart';

// Colores de marca (solo acentos)
const Color kBluePrimary = Color(0xFF1A4E85);
const Color kBlueLight   = Color(0xFFE3F2FD);
const Color kBlueLighter = Color(0xFFF0F6FF);
const Color kBlueAccent  = Color(0xFF1976D2);

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
      List<Task> tasks = await StatisticsService().fetchMemberTasks(widget.memberId);
      if (tasks.isEmpty) {
        tasks = await StatisticsService().fetchMemberTasksByStatus(widget.memberId);
      }
      final columns = _kanbanService.organizeTasksIntoColumns(tasks);
      setState(() {
        _memberTasks = tasks;
        _kanbanColumns = columns;
        _loadingTasks = false;
      });
    } catch (e) {
      setState(() {
        _memberTasks = [];
        _kanbanColumns = [];
        _loadingTasks = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => StatisticsBloc(StatisticsService())..add(LoadMemberStatistics(widget.memberId)),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: Text(
            l10n.statisticsTitle,
            style: TextStyle(color: Theme.of(context).appBarTheme.foregroundColor),
          ),
          iconTheme: IconThemeData(color: Theme.of(context).appBarTheme.foregroundColor),
          elevation: 0,
        ),
        body: BlocBuilder<StatisticsBloc, StatisticsState>(
          builder: (context, state) {
            if (state is StatisticsLoading || _loadingTasks) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is StatisticsLoaded) {
              final stats = state.statistics;
              final cs = Theme.of(context).colorScheme;
              final tt = Theme.of(context).textTheme;

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header de usuario
                      Card(
                        color: Theme.of(context).cardColor,
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: cs.surfaceVariant,
                                backgroundImage: widget.profileImageUrl.isNotEmpty
                                    ? NetworkImage(widget.profileImageUrl)
                                    : null,
                                child: widget.profileImageUrl.isEmpty
                                    ? const Icon(Icons.person, color: kBluePrimary, size: 32)
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(widget.memberName,
                                        style: tt.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: cs.onSurface,
                                        )),
                                    const SizedBox(height: 2),
                                    Text(
                                      widget.username,
                                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // KPIs
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _StatCard(label: l10n.statMarkedCompleted, value: stats.overview.completed.toString(), color: Colors.green),
                            _StatCard(label: l10n.completed,           value: (stats.overview.done ?? 0).toString(), color: Colors.teal),
                            _StatCard(label: l10n.inProgress,          value: stats.overview.inProgress.toString(),   color: Colors.blue),
                            _StatCard(label: l10n.statPending,         value: stats.overview.pending.toString(),      color: Colors.orange),
                            _StatCard(label: l10n.statOverdue,         value: stats.overview.overdue.toString(),      color: Colors.red),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Kanban
                      _SectionCard(
                        icon: Icons.view_kanban,
                        title: 'Tablero de Tareas',
                        child: _buildKanbanBoard(),
                      ),
                      const SizedBox(height: 18),

                      // Distribución de tareas
                      _SectionCard(
                        icon: Icons.list_alt,
                        title: l10n.tasksDistribution,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: _loadingTasks
                              ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                              : _memberTasks.isEmpty
                              ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              l10n.noAssignedTasks,
                              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                            ),
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
                                      Icon(Icons.circle, size: 6, color: cs.primary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          task.title,
                                          style: tt.bodyMedium?.copyWith(color: cs.onSurface),
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

                      // Reprogramaciones
                      _SectionCard(
                        icon: Icons.build,
                        title: l10n.totalReschedules,
                        child: _MetricRow(label: l10n.rescheduled, value: stats.rescheduledTasks.rescheduled.toString()),
                      ),
                      const SizedBox(height: 18),

                      // Tiempo promedio
                      _SectionCard(
                        icon: Icons.date_range,
                        title: l10n.avgCompletionTimeTitle,
                        child: Row(
                          children: [
                            Icon(Icons.timer, color: cs.primary),
                            const SizedBox(width: 8),
                            Text(
                              _formatAvgCompletionTime(stats.avgCompletionTime.avgDays),
                              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary),
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
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildKanbanBoard() {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (_loadingTasks) {
      return Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text('Cargando tablero...', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      );
    }

    if (_kanbanColumns.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox, size: 48, color: cs.onSurfaceVariant),
              const SizedBox(height: 16),
              Text('No hay tareas disponibles', style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
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
        itemBuilder: (context, index) => _buildKanbanColumn(_kanbanColumns[index]),
      ),
    );
  }

  Widget _buildKanbanColumn(KanbanColumn column) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final headerColor = _parseColor(column.color);

    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: cs.shadow.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(_getIconData(column.icon), color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    column.title,
                    style: tt.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                  child: Text('${column.tasks.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: column.tasks.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 48, color: cs.onSurfaceVariant),
                    const SizedBox(height: 8),
                    Text('Sin tareas', style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: column.tasks.length,
              itemBuilder: (context, index) => _buildTaskCard(column.tasks[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => _showTaskDetailsDialog(task),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cs.surfaceVariant,
          border: Border.all(color: Theme.of(context).dividerColor),
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
                    style: tt.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),
                ),
                Icon(Icons.more_vert, color: cs.onSurfaceVariant, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              task.description,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: Theme.of(context).dividerColor),
            const SizedBox(height: 12),
            // Footer
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.event, size: 16, color: cs.onSurfaceVariant),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _formatDate(task.dueDate),
                          style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
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
                      color: cs.tertiaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sync, size: 14, color: cs.onTertiaryContainer),
                        const SizedBox(width: 4),
                        Text(
                          '${task.timesRearranged}',
                          style: tt.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: cs.onTertiaryContainer,
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            color: Theme.of(context).cardColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _getStatusColor(task.status),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
                  ),
                  child: Row(
                    children: [
                      Icon(_getStatusIcon(task.status), color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Detalles de la Tarea',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
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
                        Text('Título', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(task.title, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: kBluePrimary)),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text('Descripción', style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(
                          task.description.isNotEmpty ? task.description : 'Sin descripción',
                          style: tt.bodyMedium?.copyWith(color: cs.onSurface, height: 1.5),
                        ),
                        const SizedBox(height: 20),
                        _buildDetailRow(icon: Icons.event, label: 'Fecha de vencimiento', value: _formatDate(task.dueDate), color: Colors.blue),
                        const SizedBox(height: 12),
                        _buildDetailRow(icon: Icons.calendar_today, label: 'Fecha de creación', value: _formatDate(task.createdAt), color: Colors.green),
                        const SizedBox(height: 12),
                        _buildDetailRow(icon: Icons.update, label: 'Última actualización', value: _formatDate(task.updatedAt), color: Colors.orange),
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
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Theme.of(context).dividerColor),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.tag, size: 18, color: kBluePrimary),
                              const SizedBox(width: 8),
                              Text('ID: ${task.id}', style: tt.labelMedium?.copyWith(color: kBluePrimary, fontWeight: FontWeight.w600)),
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
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Cerrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
              const SizedBox(height: 2),
              Text(value, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface)),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'ON_HOLD':    return Colors.orange;
      case 'IN_PROGRESS':return Colors.blue;
      case 'COMPLETED':  return Colors.green;
      case 'DONE':       return Colors.teal;
      case 'EXPIRED':    return Colors.red;
      default:           return kBluePrimary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'ON_HOLD':    return Icons.pause_circle_outline;
      case 'IN_PROGRESS':return Icons.autorenew;
      case 'COMPLETED':  return Icons.check_circle;
      case 'DONE':       return Icons.done_all;
      case 'EXPIRED':    return Icons.error_outline;
      default:           return Icons.task;
    }
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexColor', radix: 16));
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'pause_circle_outline': return Icons.pause_circle_outline;
      case 'autorenew':            return Icons.autorenew;
      case 'check_circle':         return Icons.check_circle;
      case 'done_all':             return Icons.done_all;
      case 'error_outline':        return Icons.error_outline;
      default:                     return Icons.task;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'Sin fecha';
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
    final parts = <String>[];
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = color.withOpacity(isDark ? 0.25 : 0.15);
    final tt = Theme.of(context).textTheme;

    return Card(
      color: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: 110, height: 90,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                label,
                style: tt.labelLarge?.copyWith(color: color, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      color: Theme.of(context).cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: cs.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: tt.titleMedium?.copyWith(color: cs.primary, fontWeight: FontWeight.bold),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(label, style: tt.bodyMedium?.copyWith(color: cs.onSurface)),
          const Spacer(),
          Text(value, style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: cs.primary)),
        ],
      ),
    );
  }
}
