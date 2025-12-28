import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_task_manager_ui/main.dart';
import 'package:smart_task_manager_ui/model/task.dart';
import 'package:smart_task_manager_ui/screen/task_dashboard.dart';

void main() {
  testWidgets('Task Dashboard smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // We wrap MyApp in a ProviderScope to override the tasksProvider
    // so we don't make real network calls during tests.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tasksProvider.overrideWith((ref, page) async {
            return {'tasks': <Task>[], 'totalPages': 1, 'currentPage': 0};
          }),
        ],
        child: const MyApp(),
      ),
    );

    // Verify that the app title is displayed.
    expect(find.text('Smart Task Manager'), findsOneWidget);

    // Wait for the async provider to resolve.
    await tester.pumpAndSettle();

    // Verify that "No tasks found" is displayed (since we returned an empty list).
    expect(find.text('No tasks found'), findsOneWidget);
  });
}
