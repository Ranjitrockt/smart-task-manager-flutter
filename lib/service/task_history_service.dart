import 'package:dio/dio.dart';
import '../model/task_history.dart';

class TaskHistoryService {
  final Dio _dio;

  TaskHistoryService({String? baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl:
              baseUrl ?? 'https://smart-task-manager-backend-5.onrender.com',
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
          headers: {'Content-Type': 'application/json'},
        ),
      );

  Future<List<TaskHistory>> fetchHistory(String taskId) async {
    final response = await _dio.get('/api/tasks/$taskId/history');

    final List data = response.data;
    return data.map((e) {
      // Sanitize: If any field value is a Map (JSON object), convert it to a String
      // to prevent "type '_JsonMap' is not a subtype of type 'String?'" error.
      if (e is Map<String, dynamic>) {
        for (var key in e.keys) {
          if (e[key] is Map) {
            e[key] = e[key].toString();
          }
        }
      }
      return TaskHistory.fromJson(e);
    }).toList();
  }
}
