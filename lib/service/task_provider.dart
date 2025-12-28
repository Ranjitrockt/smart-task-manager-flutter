import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task_service.dart';

/// Defines a provider for accessing the singleton instance of [TaskService].
///
/// This allows the service to be easily mocked for testing and accessed
/// consistently throughout the application via Riverpod's dependency injection.
final taskServiceProvider = Provider<TaskService>((ref) {
  return TaskService();
});
