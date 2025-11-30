import 'dart:convert';
import '../models/statistics.dart';
import '../../shared/client/api_client.dart';
import '../../tasks/models/task.dart';

class StatisticsService {
  final String baseUrl;

  // No es necesario definir baseUrl, ApiClient ya lo maneja internamente
  StatisticsService({this.baseUrl = ''});

  bool _isHtml(String body) {
    return body.trimLeft().startsWith('<!DOCTYPE html') ||
           body.trimLeft().startsWith('<html');
  }

  Future<MemberStatistics> fetchMemberStatistics(String memberId) async {
    final overviewRes = await ApiClient.get('metrics/member/$memberId/tasks/overview');
    final distributionRes = await ApiClient.get('metrics/member/$memberId/tasks/distribution');
    final rescheduledRes = await ApiClient.get('metrics/member/$memberId/tasks/rescheduled');
    final avgCompletionRes = await ApiClient.get('metrics/member/$memberId/tasks/avg-completion-time');

    print('Overview status: ${overviewRes.statusCode}, body: ${overviewRes.body}');
    print('Distribution status: ${distributionRes.statusCode}, body: ${distributionRes.body}');
    print('Rescheduled status: ${rescheduledRes.statusCode}, body: ${rescheduledRes.body}');
    print('AvgCompletion status: ${avgCompletionRes.statusCode}, body: ${avgCompletionRes.body}');

    if (_isHtml(overviewRes.body) ||
        _isHtml(distributionRes.body) ||
        _isHtml(rescheduledRes.body) ||
        _isHtml(avgCompletionRes.body)) {
      throw Exception('La respuesta del servidor no es JSON. Verifica la URL base de la API.');
    }

    if (overviewRes.statusCode == 200 &&
        distributionRes.statusCode == 200 &&
        rescheduledRes.statusCode == 200 &&
        avgCompletionRes.statusCode == 200) {
      dynamic decodeBody(String body) {
        final decoded = json.decode(body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          return decoded['data'];
        }
        return decoded;
      }

      final overview = TaskOverview.fromJson(decodeBody(overviewRes.body));
      final distribution = TaskDistribution.fromJson(decodeBody(distributionRes.body));
      final rescheduled = RescheduledTasks.fromJson(decodeBody(rescheduledRes.body));
      final avgCompletion = AvgCompletionTime.fromJson(decodeBody(avgCompletionRes.body));

      return MemberStatistics(
        overview: overview,
        distribution: distribution,
        rescheduledTasks: rescheduled,
        avgCompletionTime: avgCompletion,
      );
    } else {
      throw Exception(
        'Failed to load statistics\n'
        'Overview: ${overviewRes.statusCode}\n'
        'Distribution: ${distributionRes.statusCode}\n'
        'Rescheduled: ${rescheduledRes.statusCode}\n'
        'AvgCompletion: ${avgCompletionRes.statusCode}'
      );
    }
  }

  Future<List<Task>> fetchMemberTasks(String memberId) async {
    try {
      // Usar el mismo endpoint que Angular: /api/v1/members/{memberId}/tasks
      final response = await ApiClient.get('members/$memberId/tasks');

      if (_isHtml(response.body)) {
        throw Exception('La respuesta del servidor no es JSON.');
      }

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        print('Response from members/$memberId/tasks: $decoded');

        // El endpoint puede devolver directamente un array o un objeto con 'data'
        List<dynamic> tasksJson;
        if (decoded is Map<String, dynamic>) {
          tasksJson = decoded['data'] ?? decoded['tasks'] ?? [];
        } else if (decoded is List) {
          tasksJson = decoded;
        } else {
          tasksJson = [];
        }

        print('Tasks fetched: ${tasksJson.length}');

        // Transformar las tareas (igual que en Angular)
        final tasks = tasksJson.map((taskJson) {
          if (taskJson is Map<String, dynamic>) {
            // Asegurar que tenga los campos necesarios
            return Task.fromJson({
              'id': taskJson['id'],
              'title': taskJson['title'] ?? '',
              'description': taskJson['description'] ?? '',
              'status': taskJson['status'] ?? 'ON_HOLD',
              'dueDate': taskJson['dueDate'] ?? taskJson['due_date'] ?? '',
              'createdAt': taskJson['createdAt'] ?? taskJson['created_at'] ?? '',
              'updatedAt': taskJson['updatedAt'] ?? taskJson['updated_at'] ?? '',
              'timesRearranged': taskJson['timesRearranged'] ?? taskJson['times_rearranged'] ?? 0,
            });
          }
          return null;
        }).whereType<Task>().toList();

        print('Tasks parsed successfully: ${tasks.length}');
        return tasks;
      } else {
        print('Error response: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load member tasks: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching member tasks: $e');
      return [];
    }
  }

  // Método alternativo usando tasks por estado (como en Angular)
  Future<List<Task>> fetchMemberTasksByStatus(String memberId) async {
    try {
      final statuses = ['COMPLETED', 'DONE', 'IN_PROGRESS', 'ON_HOLD', 'EXPIRED'];
      List<Task> allTasks = [];

      for (var status in statuses) {
        try {
          final response = await ApiClient.get('tasks/status/$status');

          if (response.statusCode == 200) {
            final decoded = json.decode(response.body);

            List<dynamic> tasksJson;
            if (decoded is Map<String, dynamic>) {
              tasksJson = decoded['data'] ?? decoded['tasks'] ?? [];
            } else if (decoded is List) {
              tasksJson = decoded;
            } else {
              tasksJson = [];
            }

            print('Tasks for status $status: ${tasksJson.length}');

            // Filtrar tareas del miembro
            final memberTasks = tasksJson.where((taskJson) {
              if (taskJson is Map<String, dynamic>) {
                // Intentar diferentes estructuras de respuesta
                if (taskJson['memberId'] != null) {
                  return taskJson['memberId'].toString() == memberId;
                } else if (taskJson['member'] != null && taskJson['member'] is Map) {
                  return taskJson['member']['id'].toString() == memberId;
                } else if (taskJson['assignedTo'] != null) {
                  return taskJson['assignedTo'].toString() == memberId;
                } else if (taskJson['userId'] != null) {
                  return taskJson['userId'].toString() == memberId;
                }
              }
              return false;
            }).map((taskJson) {
              taskJson['status'] = status;
              return Task.fromJson(taskJson);
            }).toList();

            allTasks.addAll(memberTasks);
          }
        } catch (e) {
          print('Error fetching tasks for status $status: $e');
        }
      }

      print('Total member tasks fetched by status: ${allTasks.length}');
      return allTasks;
    } catch (e) {
      print('Error fetching member tasks by status: $e');
      return [];
    }
  }
}
