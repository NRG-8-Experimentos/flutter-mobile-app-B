import 'dart:convert';

import '../../shared/client/api_client.dart';
import '../models/request.dart';

class RequestService {
  Future<List<Request>> getMemberRequests() async {
    final response = await ApiClient.get('member/group/requests');
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Request.fromJson(json)).toList();
    }
    throw Exception('Failed to load member requests');
  }

  Future<Request> getRequestById(int taskId, int requestId) async {
    final response = await ApiClient.get('tasks/$taskId/requests/$requestId');
    if (response.statusCode == 200) {
      return Request.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to load request');
  }

  Future<Request> createRequest(int taskId, String description, String requestType) async {
    final response = await ApiClient.post('tasks/$taskId/requests',
      body:{
        'description': description,
        'requestType': requestType,
      },
    );
    if (response.statusCode == 201) {
      return Request.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create request');
  }

  Future<void> deleteRequest(int taskId, int requestId) async {
    final response = await ApiClient.delete('tasks/$taskId/requests/$requestId');
    if (response.statusCode != 204) {
      throw Exception('Failed to delete request');
    }
  }

  Future<List<Request>> getRequestsByTaskId(int taskId) async {
    final response = await ApiClient.get('tasks/$taskId/requests');
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Request.fromJson(json)).toList();
    }
    throw Exception('Failed to load requests for task');
  }
}