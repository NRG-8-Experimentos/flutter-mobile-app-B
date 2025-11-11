import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../l10n/app_localizations.dart';
import '../bloc/request_bloc.dart';
import '../bloc/request_event.dart';
import '../bloc/request_state.dart';
import '../models/request.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {

  @override
  void initState() {
    super.initState();
    context.read<RequestBloc>().add(LoadMemberRequestsEvent());
  }

  IconData _getRequestStatusIcon(String requestStatus) {
    switch (requestStatus) {
      case 'MODIFICATION':
        return Icons.timer;
      case 'SUBMISSION':
        return Icons.check;
      default:
        return Icons.close_rounded;
    }
  }

  Color _setTypeColor(String requestType) {
    switch (requestType) {
      case 'MODIFICATION':
        return const Color(0xFFFF832A);
      case 'SUBMISSION':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFFF44336);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(localizations.requestsScreenTitle,
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
            )
        ),
      ),
      body: BlocBuilder<RequestBloc, RequestState>(
        builder: (context, state) {
          if (state is RequestLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is MemberRequestsLoaded) {
            return _buildRequestsContent(state.requests, context);
          } else if (state is RequestError) {
            return Center(
              child: Text(state.message)
            );
          }
          return Center(
            child: Text(localizations.noSentRequests,
              style: TextStyle(fontSize: 18, color: Colors.grey)
            )
          );
        }
      )
    );
  }

  Widget _buildRequestsContent(List<Request> requests, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final pendingRequests = requests.where((r) => r.requestStatus == 'PENDING').toList();
    final solvedRequests = requests.where((r) => r.requestStatus != 'PENDING').toList();

    Widget buildSection(String title, List<Request> requests, bool isSolved) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A4E85)
                )
            ),
          ),

          if (requests.isEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A4E85),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  localizations.noAvailableRequests,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            )
          else
            Column(
              children:
                requests.map((r) => _buildRequestCard(r, isSolved, context)).toList(),
            )
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSection(localizations.section_pendingRequests, pendingRequests, false),
            buildSection(localizations.section_solvedRequests, solvedRequests, true),
          ],
        ),
      )
    );
  }

  Widget _buildRequestCard(Request request, bool isSolved, BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () async {
        if (isSolved) {
          final confirmation = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
                title: Text(localizations.requestAlreadyValidatedTitle),
                content: Text(localizations.requestAlreadyValidatedContent),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(localizations.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(localizations.clear),
                  ),
                ],
              )

          );

          if (confirmation == true) {
            try {
              await context.read<RequestBloc>()
                  .requestService.deleteRequest(request.task.id, request.id);
              if (!mounted) return;
              context.read<RequestBloc>().add(LoadMemberRequestsEvent());
            } catch (e) {}
          }
        }
      },

      child: Column(
        children: [
          Container(
            height: 190,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(0xFF1A4E85),
            ),

            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Card(
                        margin: const EdgeInsets.all(10),
                        color: Colors.white,
                        child: Container(
                          height: 160,
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(request.task.title,
                                  style: const TextStyle(
                                      color: Colors.black
                                  )
                              ),
                              const Divider(thickness: 2),
                              const SizedBox(height: 8),
                              Text('${localizations.comment}: ${request.description}', style: const TextStyle(color: Colors.black)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        height: 160,
                        margin: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: request.requestType == "EXPIRED"
                            ? Color(0xFFF44336)
                            : _setTypeColor(request.requestType),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Icon(
                            request.requestType == "EXPIRED"
                              ? Icons.warning_amber_rounded
                              : _getRequestStatusIcon(request.requestType),
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            )
          ),
          SizedBox(height: 20)
        ],
      )
    );
  }
}
