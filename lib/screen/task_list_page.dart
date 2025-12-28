import 'package:flutter/material.dart';
import '../service/task_service.dart';
import '../model/task.dart';
import '../screen/create_task.dart';
import '../screen/edit_task_page.dart';
import '../screen/task_history_page.dart';

class TaskListPage extends StatefulWidget {
  const TaskListPage({super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final TaskService _service = TaskService();

  List<Task> tasks = [];
  int currentPage = 0;
  int totalPages = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    setState(() => loading = true);

    try {
      final data = await _service.fetchTasksPage(page: currentPage);

      setState(() {
        tasks = data['tasks'] as List<Task>;
        totalPages = data['totalPages'] as int;
        loading = false;
      });
    } catch (e) {
      setState(() {
        tasks = [];
        totalPages = 0;
        loading = false;
      });
      // Show a snackbar or dialog with the error
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load tasks: $e')));
      }
    }
  }

  void nextPage() {
    if (currentPage < totalPages - 1) {
      currentPage++;
      loadTasks();
    }
  }

  void prevPage() {
    if (currentPage > 0) {
      currentPage--;
      loadTasks();
    }
  }

  void goToPage(int page) {
    currentPage = page;
    loadTasks();
  }

  void confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final currentContext = context;
              Navigator.pop(currentContext); // Close dialog
              try {
                await _service.deleteTask(id);
                if (!mounted) return;
                ScaffoldMessenger.of(currentContext).showSnackBar(
                  const SnackBar(content: Text('Task deleted successfully')),
                );
              } catch (e) {
                if (!mounted) return;
                if (e.toString().toLowerCase().contains('not found')) {
                  ScaffoldMessenger.of(currentContext).showSnackBar(
                    const SnackBar(content: Text('Task was already deleted.')),
                  );
                } else {
                  ScaffoldMessenger.of(
                    currentContext,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              } finally {
                // Refresh list to sync UI.
                if (mounted) loadTasks();
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget buildPageButtons() {
    List<Widget> buttons = [];

    for (int i = 0; i < totalPages; i++) {
      buttons.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: currentPage == i
                  ? Colors.deepPurple
                  : Colors.grey,
            ),
            onPressed: () => goToPage(i),
            child: Text(
              '${i + 1}',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: buttons,
      ),
    );
  }

  Color priorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Task Manager'),
        backgroundColor: Colors.deepPurple,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// TITLE
                              Text(
                                task.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 6),

                              /// DESCRIPTION
                              Text(
                                task.description ?? 'No description',
                                style: TextStyle(color: Colors.grey.shade700),
                              ),

                              const SizedBox(height: 10),

                              /// CHIPS ROW
                              Row(
                                children: [
                                  /// PRIORITY CHIP
                                  Chip(
                                    label: Text(
                                      task.priority.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: priorityColor(
                                      task.priority,
                                    ),
                                  ),

                                  const SizedBox(width: 6),

                                  /// STATUS CHIP
                                  Chip(
                                    label: Text(
                                      task.status.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: statusColor(task.status),
                                  ),

                                  const SizedBox(width: 6),

                                  /// CATEGORY CHIP
                                  Chip(label: Text(task.category)),
                                ],
                              ),

                              const SizedBox(height: 8),

                              /// FOOTER ROW
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  /// ASSIGNED TO
                                  Text(
                                    '👤 ${task.assignedTo}',
                                    style: const TextStyle(fontSize: 12),
                                  ),

                                  /// ACTION BUTTONS ROW
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      /// HISTORY BUTTON
                                      IconButton(
                                        icon: const Icon(
                                          Icons.history,
                                          color: Colors.deepPurple,
                                        ),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => TaskHistoryPage(
                                                taskId: task.id,
                                              ),
                                            ),
                                          );
                                        },
                                      ),

                                      /// EDIT BUTTON
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () async {
                                          final refreshed =
                                              await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      EditTaskPage(task: task),
                                                ),
                                              );

                                          if (refreshed == true) {
                                            loadTasks();
                                          }
                                        },
                                      ),

                                      /// DELETE BUTTON
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => confirmDelete(task.id),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                /// PAGINATION CONTROLS
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: prevPage,
                          icon: const Icon(Icons.arrow_back),
                        ),
                        Text(
                          'Page ${currentPage + 1} / $totalPages',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: nextPage,
                          icon: const Icon(Icons.arrow_forward),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    buildPageButtons(),
                    const SizedBox(height: 8),
                  ],
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateTaskPage()),
          );

          if (result == true) {
            loadTasks(); // refresh list
          }
        },
      ),
    );
  }
}
