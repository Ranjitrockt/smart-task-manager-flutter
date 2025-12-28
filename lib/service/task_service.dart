import 'package:dio/dio.dart';
import '../model/task.dart';

// A placeholder URL for your deployed backend.
// Replace this with your actual Render.com service URL.
const String _baseUrl = 'https://smart-task-manager-backend-5.onrender.com/api';

class TaskService {
  final Dio _dio;

  // Private constructor for Singleton pattern
  TaskService._internal()
    : _dio = Dio(
        BaseOptions(
          baseUrl: _baseUrl,
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      ) {
    // Add interceptors for logging, error handling, or authentication
    _dio.interceptors.add(
      LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  // Singleton instance
  static final TaskService _instance = TaskService._internal();

  // Factory constructor to return the singleton instance
  factory TaskService() => _instance;

  /// Fetches a paginated and filtered list of tasks from the API.
  Future<Map<String, dynamic>> fetchTasksPage({
    int page = 0,
    int limit = 10,
    String? status,
    String? category,
    String? priority,
  }) async {
    try {
      final Map<String, dynamic> queryParameters = {
        'offset': page * limit,
        'limit': limit,
      };

      // Add filters to the query if they are not null or empty
      if (status != null && status.isNotEmpty)
        queryParameters['status'] = status;
      if (category != null && category.isNotEmpty)
        queryParameters['category'] = category;
      if (priority != null && priority.isNotEmpty)
        queryParameters['priority'] = priority;

      final response = await _dio.get(
        '/tasks',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200 && response.data is Map) {
        final tasks = ((response.data['content'] ?? []) as List)
            .map((taskJson) => Task.fromJson(taskJson))
            .toList();
        final totalPages = (response.data['totalPages'] ?? 0) as int;

        return {'tasks': tasks, 'totalPages': totalPages};
      } else {
        throw Exception('API returned an invalid response format.');
      }
    } on DioException catch (e) {
      throw Exception('Failed to load tasks: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Creates a new task by sending it to the backend.
  /// The backend is expected to handle the classification logic.
  Future<Task> createTask(Task task) async {
    try {
      // We only send the data the user creates. The backend will fill in the rest.
      final Map<String, dynamic> taskData = {
        'title': task.title,
        'description': task.description,
        'assignedTo': task.assignedTo,
        'dueDate': task.dueDate?.toIso8601String(),
        // Allow user to override the category/priority
        'category': task.category,
        'priority': task.priority,
      };

      final response = await _dio.post('/tasks', data: taskData);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data is Map) {
        return Task.fromJson(response.data);
      } else {
        throw Exception('API returned an invalid response for task creation.');
      }
    } on DioException catch (e) {
      throw Exception(
        'Failed to create task: ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Updates an existing task.
  Future<Task> updateTask(String id, Task task) async {
    try {
      // Only send editable fields. Sending 'id', 'createdAt', etc. can cause backend errors.
      final Map<String, dynamic> updateData = {
        'title': task.title,
        'description': task.description,
        'category': task.category,
        'priority': task.priority,
        'status': task.status,
        'assignedTo': task.assignedTo,
        'dueDate': task.dueDate?.toIso8601String(),
      };

      final response = await _dio.patch('/tasks/$id', data: updateData);
      if (response.statusCode == 200 && response.data is Map) {
        return Task.fromJson(response.data);
      } else {
        throw Exception('API returned an invalid response for task update.');
      }
    } on DioException catch (e) {
      throw Exception(
        'Failed to update task: ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Deletes a task by its ID.
  Future<void> deleteTask(String id) async {
    try {
      final response = await _dio.delete('/tasks/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        // 204 No Content is the expected success response
        throw Exception(
          'Failed to delete task, received status code ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(
        'Failed to delete task: ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Fetches a single task and its history.
  Future<Map<String, dynamic>> getTaskWithHistory(String id) async {
    try {
      final response = await _dio.get('/tasks/$id');
      if (response.statusCode == 200 && response.data is Map) {
        // Assuming the API returns the task and a 'history' field
        return response.data;
      } else {
        throw Exception('API returned an invalid response for task details.');
      }
    } on DioException catch (e) {
      throw Exception(
        'Failed to get task details: ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}
