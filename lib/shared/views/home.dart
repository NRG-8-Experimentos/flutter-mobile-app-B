import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../group/views/group_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../statistics/views/statistics_screen.dart';
import '../../tasks/models/task.dart';
import '../../tasks/views/tasks_screen.dart';
import '../../requests/views/requests_screen.dart';
import '../../shared/client/api_client.dart';
import '../bloc/member/member_bloc.dart';
import '../bloc/member/member_event.dart';
import '../bloc/member/member_state.dart';
import '../components/language_switcher_button.dart';
import '../services/member_service.dart';
import '../../statistics/bloc/statistics_bloc.dart';
import '../../statistics/bloc/statistics_event.dart';
import '../../statistics/bloc/statistics_state.dart';
import '../../statistics/services/statistics_service.dart';
import '../../requests/bloc/request_bloc.dart';
import '../../requests/services/request_service.dart';
import '../../tasks/bloc/task/task_bloc.dart';
import '../../tasks/bloc/task/task_event.dart';
import '../../tasks/bloc/task/task_state.dart';

// NUEVO
import '../components/appearance_switcher_button.dart';
import '../views/Login.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _name = '';
  String _surname = '';
  String _imgUrl = '';
  String _memberId = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<MemberBloc>().add(FetchMemberDetailsEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return BlocListener<MemberBloc, MemberState>(
      listener: (context, state) {
        if (state is MemberLoaded) {
          setState(() {
            _name = state.member.name;
            _surname = state.member.surname;
            _imgUrl = state.member.imgUrl;
            _memberId = state.member.id.toString();
          });
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          title: Text(
            'SynHub',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).appBarTheme.foregroundColor,
            ),
          ),
        ),
        drawerEnableOpenDragGesture: true,
        drawer: _CustomDrawer(
          name: _name,
          surname: _surname,
          imgUrl: _imgUrl,
          onNavigate: (route) {
            Navigator.pop(context);
            if (route == 'Group') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const GroupScreen()));
            } else if (route == 'Group/Invitations') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const RequestsScreen()));
            } else if (route == 'Tasks') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const TasksScreen()));
            } else if (route == 'AnalyticsAndReports') {
              if (_memberId.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StatisticsScreen(
                      memberId: _memberId,
                      memberName: '$_name $_surname',
                      username: _name,
                      profileImageUrl: _imgUrl,
                    ),
                  ),
                );
              }
            } else if (route == 'Requests') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const RequestsScreen()));
            } else if (route == 'Login') {
              ApiClient.resetToken();
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const Login()));
            }
          },
        ),
        body: PopScope(
          canPop: false,
          child: BlocProvider<MemberBloc>(
            create: (context) =>
            MemberBloc(memberService: MemberService())..add(LoadNextTaskEvent()),
            child: BlocBuilder<MemberBloc, MemberState>(
              builder: (context, state) {
                // MÉTRICAS RESUMIDAS
                Widget metricsSummary = (_memberId.isNotEmpty)
                    ? BlocProvider(
                  create: (_) => StatisticsBloc(StatisticsService())
                    ..add(LoadMemberStatistics(_memberId)),
                  child:
                  BlocBuilder<StatisticsBloc, StatisticsState>(builder: (context, statsState) {
                    if (statsState is StatisticsLoaded) {
                      final overview = statsState.statistics.overview;
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StatisticsScreen(
                                memberId: _memberId,
                                memberName: '$_name $_surname',
                                username: _name,
                                profileImageUrl: _imgUrl,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          color: const Color(0xFF1A4E85),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 18, horizontal: 20),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Resumen de métricas',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.check_circle,
                                            color: Colors.greenAccent,
                                            size: 20),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Completadas: ${overview.done}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                        const SizedBox(width: 16),
                                        const Icon(Icons.autorenew,
                                            color: Colors.blueAccent,
                                            size: 20),
                                        const SizedBox(width: 4),
                                        Text(
                                          'En progreso: ${overview.inProgress}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Icon(Icons.arrow_forward_ios,
                                    color: Colors.white, size: 20),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else if (statsState is StatisticsLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  }),
                )
                    : const SizedBox.shrink();

                if (state is NextTaskLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is NextTaskLoaded) {
                  final task = state.task;
                  return Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        metricsSummary,
                        if (_memberId.isNotEmpty) const SizedBox(height: 18),
                        Text(
                          localizations.taskDueSoon,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A4E85),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: Card(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Text(
                                      task.title,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    height: 2,
                                    color: Theme.of(context).dividerColor,
                                  ),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 100,
                                      minWidth: double.infinity,
                                    ),
                                    child: Card(
                                      color: Theme.of(context).cardColor,
                                      margin:
                                      const EdgeInsets.symmetric(vertical: 10),
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Text(
                                          task.description,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Center(
                                    child: Text(
                                      _formatTaskDates(task),
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: _getDividerColor(
                                          task.createdAt,
                                          task.dueDate,
                                          task.status),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is NoNextTaskAvailable) {
                  return Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        metricsSummary,
                        if (_memberId.isNotEmpty) const SizedBox(height: 18),
                        Text(
                          localizations.taskDueSoon,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A4E85),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: Card(
                            color: const Color(0xFF1A4E85),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: Text(
                                  localizations.noUpcomingTasks,
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is NextTaskError) {
                  return Center(child: Text(state.message));
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
      ),
    );
  }

  Color _getDividerColor(String createdAt, String dueDate, String status) {
    if (status == "COMPLETED") return const Color(0xFF4CAF50);
    if (status == "ON_HOLD") return const Color(0xFFFF832A);
    if (status == "DONE") return const Color(0xFF4A90E2);
    if (status == "EXPIRED") return const Color(0xFFF44336);
    try {
      final created = _parseDateWithTimeZone(createdAt);
      final due = _parseDateWithTimeZone(dueDate);
      final now = DateTime.now();
      final totalSeconds = due.difference(created).inSeconds.toDouble();
      final secondsPassed = now.difference(created).inSeconds.toDouble();
      if (totalSeconds <= 0) return const Color(0xFFF44336);
      final progress = (secondsPassed / totalSeconds).clamp(0.0, 1.0);
      if (now.isAfter(due)) return const Color(0xFFF44336);
      if (progress < 0.7) return const Color(0xFF4CAF50);
      return const Color(0xFFFDD634);
    } catch (_) {
      return const Color(0xFF939393);
    }
  }

  DateTime _parseDateWithTimeZone(String dateString) {
    try {
      return DateTime.parse(dateString).toLocal();
    } catch (_) {
      try {
        return DateFormat("yyyy-MM-dd").parse(dateString);
      } catch (_) {
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
    } catch (_) {
      return '${task.createdAt.substring(0, 10)} - ${task.dueDate.substring(0, 10)}';
    }
  }
}

class _CustomDrawer extends StatelessWidget {
  final String name;
  final String surname;
  final String imgUrl;
  final Function(String) onNavigate;

  const _CustomDrawer({
    required this.name,
    required this.surname,
    required this.imgUrl,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    const double gap = 15.0;

    return Drawer(
      child: Container(
        color: const Color(0xFF1A4E85),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 60),
            Center(
              child: Text('$name $surname',
                  style: const TextStyle(fontSize: 24, color: Colors.white)),
            ),
            const SizedBox(height: gap),
            Center(
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: imgUrl.isNotEmpty
                      ? Image.network(
                    imgUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.person,
                          size: 80, color: Colors.white);
                    },
                  )
                      : const Icon(Icons.person, size: 80, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: gap),
            const Divider(color: Colors.white),
            const SizedBox(height: gap),

            _buildDrawerItem(
              icon: Icons.groups,
              label: localizations.group,
              onTap: () => onNavigate('Group'),
            ),
            _buildDrawerItem(
              icon: Icons.assignment_outlined,
              label: localizations.tasks,
              onTap: () => onNavigate('Tasks'),
            ),
            _buildDrawerItem(
              icon: Icons.bar_chart,
              label: localizations.performance,
              onTap: () => onNavigate('AnalyticsAndReports'),
            ),
            _buildDrawerItem(
              icon: Icons.fact_check,
              label: localizations.requests,
              onTap: () => onNavigate('Requests'),
            ),

            const SizedBox(height: gap),
            const Divider(color: Colors.white),
            const SizedBox(height: gap),

            // Si tus botones NO tienen constructor const, déjalos así:
            LanguageSwitcherButton(),
            const SizedBox(height: gap),

            // Debajo del language switcher:
            AppearanceSwitcherButton(),

            const SizedBox(height: gap),
            const Divider(color: Colors.white),
            const SizedBox(height: gap),

            _buildDrawerItem(
              icon: Icons.logout,
              label: localizations.signOut,
              onTap: () => onNavigate('Login'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white), // <-- sin const
      title: Text(
        label,
        style: const TextStyle(fontSize: 17, color: Colors.white),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      onTap: onTap,
    );
  }
}
