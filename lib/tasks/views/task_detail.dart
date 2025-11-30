import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../requests/bloc/request_bloc.dart';
import '../../requests/models/request.dart';
import '../../requests/services/request_service.dart';
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
  final RequestService _requestService = RequestService();
  List<Request> _comments = [];
  bool _loadingComments = false;
  bool _showCommentForm = false;
  final TextEditingController _commentController = TextEditingController();
  bool _savingComment = false;

  @override
  void initState() {
    super.initState();
    // Load comments when the screen initializes
    _loadComments(widget.taskId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

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

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              color: Theme.of(context).colorScheme.surfaceVariant,
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
                    Center(
                        child: Text(
                            task.title,
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface)
                        )
                    ),
                    Container(
                      height: 2,
                      decoration: BoxDecoration(color: Colors.black),
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: 100,
                        minWidth: double.infinity,
                      ),
                      child:
                        Card(
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
                                  style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface))
                          ),
                        ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: progressColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 12),
                    if (task.status == "IN_PROGRESS") ...[
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            final confirmation = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(localizations.completed),
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
                                    localizations.requestCompletionMessage,
                                    'SUBMISSION'
                                );
                                context.read<TaskBloc>().add(
                                  UpdateTaskStatusEvent(
                                    taskId: task.id,
                                    status: 'COMPLETED',
                                  ),
                                );

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
                    ]
                  ],
                )
              ),
            ),
            const SizedBox(height: 20),
            _buildCommentsSection(task),
          ],
        ),
      )
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


  Future<void> _loadComments(int taskId) async {
    setState(() {
      _loadingComments = true;
    });

    try {
      final comments = await _requestService.getRequestsByTaskId(taskId);
      setState(() {
        _comments = comments;
        _loadingComments = false;
      });
    } catch (e) {
      setState(() {
        _loadingComments = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.commentsLoadError)),
        );
      }
    }
  }

  void _toggleCommentForm() {
    setState(() {
      _showCommentForm = !_showCommentForm;
      if (!_showCommentForm) {
        _commentController.clear();
      }
    });
  }

  Future<void> _addComment(int taskId) async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _savingComment = true;
    });

    try {
      await _requestService.createRequest(
        taskId,
        _commentController.text.trim(),
        'MODIFICATION',
      );

      _commentController.clear();
      setState(() {
        _savingComment = false;
        _showCommentForm = false;
      });

      await _loadComments(taskId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.commentAddedSuccess)),
        );
      }
    } catch (e) {
      setState(() {
        _savingComment = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.commentAddError)),
        );
      }
    }
  }

  Widget _buildCommentsSection(Task task) {
    final localizations = AppLocalizations.of(context)!;
    return Card(
      color: Color(0xFFF5F5F5),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localizations.commentsTitle,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if(task.status == "IN_PROGRESS")
                  ElevatedButton.icon(
                    onPressed: _toggleCommentForm,
                    icon: Icon(_showCommentForm ? Icons.close : Icons.add_comment),
                    label: Text(_showCommentForm ? localizations.cancel : localizations.addCommentButton),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      elevation: 2,
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                  )
              ],
            ),
            const SizedBox(height: 16),
            if (_showCommentForm) ...[
              Card(
                color: Colors.white,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _commentController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: localizations.commentHint,
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _savingComment ? null : () => _addComment(task.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4CAF50),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: _savingComment
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  localizations.sendCommentButton,
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_loadingComments)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_comments.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    localizations.noCommentsYet,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  final comment = _comments[index];
                  return _buildCommentItem(comment);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(Request comment) {
    Color statusColor;
    switch (comment.requestStatus) {
      case 'PENDING':
        statusColor = Colors.orange;
        break;
      case 'APPROVED':
        statusColor = Colors.green;
        break;
      case 'REJECTED':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    Color typeColor;
    switch (comment.requestType) {
      case 'MODIFICATION':
        typeColor = Colors.blue;
        break;
      case 'SUBMISSION':
        typeColor = Colors.purple;
        break;
      default:
        typeColor = Colors.grey;
    }

    return Card(
      color: Colors.white,
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    comment.requestType,
                    style: TextStyle(
                      color: typeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    comment.requestStatus,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              comment.description,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
