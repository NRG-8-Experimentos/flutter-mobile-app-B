import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../bloc/statistics_bloc.dart';
import '../bloc/statistics_event.dart';
import '../bloc/statistics_state.dart';
import '../services/statistics_service.dart';
import '../../tasks/services/task_service.dart';
import '../../tasks/models/task.dart';

// Se mantienen colores de marca
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
  bool _loadingTasks = true;

  @override
  void initState() {
    super.initState();
    _fetchMemberTasks();
  }

  Future<void> _fetchMemberTasks() async {
    try {
      final tasks = await TaskService().getMemberTasks();
      setState(() {
        _memberTasks = tasks;
        _loadingTasks = false;
      });
    } catch (_) {
      setState(() {
        _memberTasks = [];
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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: Text(localizations.statisticsTitle, style: TextStyle(color: Theme.of(context).appBarTheme.foregroundColor)),
          iconTheme: IconThemeData(color: Theme.of(context).appBarTheme.foregroundColor),
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
                        color: Theme.of(context).cardColor,
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
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
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold, fontSize: 18, color: kBluePrimary)),
                                    const SizedBox(height: 2),
                                    Text(widget.username,
                                      style: TextStyle(
                                        color: Theme.of(context).colorScheme.onSurface.withOpacity(.6),
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

                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatCard(label: localizations.statMarkedCompleted, value: stats.overview.completed.toString(), color: Colors.green),
                            _StatCard(label: localizations.completed, value: (stats.overview.done ?? 0).toString(), color: Colors.teal),
                            _StatCard(label: localizations.inProgress, value: stats.overview.inProgress.toString(), color: Colors.blue),
                            _StatCard(label: localizations.statPending, value: stats.overview.pending.toString(), color: Colors.orange),
                            _StatCard(label: localizations.statOverdue, value: stats.overview.overdue.toString(), color: Colors.red),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      _SectionCard(
                        icon: Icons.list_alt,
                        title: localizations.tasksDistribution,
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
                            child: Text(localizations.noAssignedTasks,
                                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(.7))),
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
                                      const Text('•',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold, color: kBluePrimary)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(task.title,
                                            style: TextStyle(
                                                fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
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

                      _SectionCard(
                        icon: Icons.build,
                        title: localizations.totalReschedules,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _MetricRow(label: localizations.rescheduled, value: stats.rescheduledTasks.rescheduled.toString()),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      _SectionCard(
                        icon: Icons.date_range,
                        title: localizations.avgCompletionTimeTitle,
                        child: Row(
                          children: [
                            const Icon(Icons.timer, color: kBlueAccent),
                            const SizedBox(width: 8),
                            Text(_formatAvgCompletionTime(stats.avgCompletionTime.avgDays),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16, color: kBlueAccent)),
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

  Color get vibrantBackground {
    if (color == Colors.green) return const Color(0xFFB9F6CA);
    if (color == Colors.blue)  return const Color(0xFF82B1FF);
    if (color == Colors.orange)return const Color(0xFFFFE082);
    if (color == Colors.red)   return const Color(0xFFFF8A80);
    return color.withOpacity(0.15);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: vibrantBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: SizedBox(
        width: 110, height: 90,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 6),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 13),
                  textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
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
                Icon(icon, color: kBluePrimary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: kBluePrimary, fontWeight: FontWeight.bold, fontSize: 18),
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
          Text(label, style: TextStyle(fontSize: 15, color: Theme.of(context).colorScheme.onSurface)),
          const Spacer(),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: kBlueAccent)),
        ],
      ),
    );
  }
}
