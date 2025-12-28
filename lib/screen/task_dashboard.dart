import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../service/task_service.dart';
import '../model/task.dart';
import 'create_task.dart';
import 'edit_task_page.dart';
import 'task_history_page.dart';

// Class to hold filter parameters for the provider
@immutable
class TaskFilter {
  final int page;
  final String? category;
  final String? priority;
  final String? status;

  const TaskFilter({this.page = 0, this.category, this.priority, this.status});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TaskFilter &&
        other.page == page &&
        other.category == category &&
        other.priority == priority &&
        other.status == status;
  }

  @override
  int get hashCode {
    return page.hashCode ^
        category.hashCode ^
        priority.hashCode ^
        status.hashCode;
  }
}

// Riverpod providers
final tasksProvider = FutureProvider.family<Map<String, dynamic>, TaskFilter>((
  ref,
  filter,
) async {
  final service = TaskService();
  return service.fetchTasksPage(
    page: filter.page,
    category: filter.category,
    priority: filter.priority,
    status: filter.status,
  );
});

final selectedCategoryFilter = StateProvider<String?>((ref) => null);
final selectedPriorityFilter = StateProvider<String?>((ref) => null);
final selectedStatusFilter = StateProvider<String?>((ref) => null);
final searchQueryProvider = StateProvider<String>((ref) => '');
final currentPageProvider = StateProvider<int>((ref) => 0);

class TaskDashboard extends ConsumerWidget {
  const TaskDashboard({super.key});

  Color getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
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

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryFilter = ref.watch(selectedCategoryFilter);
    final priorityFilter = ref.watch(selectedPriorityFilter);
    final statusFilter = ref.watch(selectedStatusFilter);
    final currentPage = ref.watch(currentPageProvider);

    final filter = TaskFilter(
      page: currentPage,
      category: categoryFilter,
      priority: priorityFilter,
      status: statusFilter,
    );

    final tasksAsync = ref.watch(tasksProvider(filter));
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Task Manager'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: tasksAsync.when(
        loading: () => _buildShimmerLoading(),
        error: (err, stack) {
          final isOffline =
              err.toString().toLowerCase().contains('socket') ||
              err.toString().toLowerCase().contains('connection');

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isOffline ? Icons.wifi_off : Icons.error,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    isOffline
                        ? 'You are offline or cannot connect to the server.'
                        : 'An error occurred: $err',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(tasksProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        },
        data: (data) {
          // Safely cast the tasks list
          List<Task> tasks = data['tasks'] as List<Task>;

          final int totalPages = data['totalPages'] ?? 1;

          // Client-side search
          if (searchQuery.isNotEmpty) {
            tasks = tasks.where((task) {
              final titleMatch = task.title.toLowerCase().contains(
                searchQuery.toLowerCase(),
              );
              final descriptionMatch =
                  task.description?.toLowerCase().contains(
                    searchQuery.toLowerCase(),
                  ) ??
                  false;
              return titleMatch || descriptionMatch;
            }).toList();
          }

          // Calculate statistics
          int pending = tasks
              .where((t) => t.status.toLowerCase() == 'pending')
              .length;
          int inProgress = tasks
              .where((t) => t.status.toLowerCase() == 'in_progress')
              .length;
          int completed = tasks
              .where((t) => t.status.toLowerCase() == 'completed')
              .length;

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(tasksProvider);
            },
            child: Column(
              children: [
                // SUMMARY CARDS
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSummaryCard('Pending', pending, Colors.orange),
                      _buildSummaryCard('In Progress', inProgress, Colors.blue),
                      _buildSummaryCard('Completed', completed, Colors.green),
                    ],
                  ),
                ),
                const Divider(),

                // SEARCH AND FILTER
                _buildSearchAndFilter(context, ref),
                const Divider(),

                // TASK LIST
                Expanded(
                  child: tasks.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No tasks found.'),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            return _buildTaskCard(context, task, ref, filter);
                          },
                        ),
                ),

                // PAGINATION
                if (totalPages > 1)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: currentPage > 0
                              ? () => ref
                                    .read(currentPageProvider.notifier)
                                    .state--
                              : null,
                          icon: const Icon(Icons.arrow_back),
                        ),
                        Text(
                          'Page ${currentPage + 1} / $totalPages',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: currentPage < totalPages - 1
                              ? () => ref
                                    .read(currentPageProvider.notifier)
                                    .state++
                              : null,
                          icon: const Icon(Icons.arrow_forward),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () async {
          final result = await showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const CreateTaskPage(),
          );
          if (result == true) {
            ref.invalidate(tasksProvider);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Container(
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context, WidgetRef ref) {
    final categoryFilter = ref.watch(selectedCategoryFilter);
    final priorityFilter = ref.watch(selectedPriorityFilter);
    final statusFilter = ref.watch(selectedStatusFilter);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: TextField(
            onChanged: (value) =>
                ref.read(searchQueryProvider.notifier).state = value,
            decoration: InputDecoration(
              hintText: 'Search tasks...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  'Category',
                  categoryFilter,
                  ['scheduling', 'finance', 'technical', 'safety', 'general'],
                  selectedCategoryFilter,
                  ref,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Priority',
                  priorityFilter,
                  ['high', 'medium', 'low'],
                  selectedPriorityFilter,
                  ref,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Status',
                  statusFilter,
                  ['pending', 'in_progress', 'completed'],
                  selectedStatusFilter,
                  ref,
                ),
                const SizedBox(width: 8),
                if (categoryFilter != null ||
                    priorityFilter != null ||
                    statusFilter != null)
                  ActionChip(
                    label: const Text('Clear Filters'),
                    onPressed: () {
                      ref.read(selectedCategoryFilter.notifier).state = null;
                      ref.read(selectedPriorityFilter.notifier).state = null;
                      ref.read(selectedStatusFilter.notifier).state = null;
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, int count, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color.withAlpha(25),
          border: Border.all(color: color, width: 1),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String? selected,
    List<String> options,
    StateProvider<String?> provider,
    WidgetRef ref,
  ) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        ref.read(provider.notifier).state = selected == value ? null : value;
      },
      itemBuilder: (context) => options
          .map(
            (option) => PopupMenuItem(
              value: option,
              child: Row(
                children: [
                  Icon(
                    selected == option
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 16,
                    color: selected == option ? Colors.deepPurple : null,
                  ),
                  const SizedBox(width: 8),
                  Text(option),
                ],
              ),
            ),
          )
          .toList(),
      child: Chip(
        label: Text('$label: ${selected ?? 'All'}'),
        backgroundColor: selected != null
            ? Colors.deepPurple.withAlpha(50)
            : null,
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    Task task,
    WidgetRef ref,
    TaskFilter filter,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    task.status.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  backgroundColor: getStatusColor(task.status),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (task.description != null && task.description!.isNotEmpty)
              Text(
                task.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Chip(
                  label: Text(
                    task.priority.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                  backgroundColor: getPriorityColor(task.priority),
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 6),
                Chip(
                  label: Text(
                    task.category,
                    style: const TextStyle(fontSize: 10),
                  ),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.dueDate != null
                          ? '📅 ${DateFormat('MMM dd, yyyy').format(task.dueDate!)}'
                          : '📅 No due date',
                      style: const TextStyle(fontSize: 11),
                    ),
                    Text(
                      '👤 ${task.assignedTo ?? 'Unassigned'}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.history, size: 18),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskHistoryPage(taskId: task.id),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        size: 18,
                        color: Colors.blue,
                      ),
                      onPressed: () async {
                        final refreshed = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditTaskPage(task: task),
                          ),
                        );
                        if (refreshed == true) {
                          ref.invalidate(tasksProvider);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete,
                        size: 18,
                        color: Colors.red,
                      ),
                      onPressed: () =>
                          _showDeleteConfirmation(context, task, ref, filter),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Task task,
    WidgetRef ref,
    TaskFilter filter,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context); // Close the dialog first
              try {
                await TaskService().deleteTask(task.id);
                messenger.showSnackBar(
                  const SnackBar(content: Text('Task deleted successfully')),
                );
              } catch (e) {
                // Gracefully handle the case where the task is already deleted on the server.
                if (e.toString().toLowerCase().contains('not found')) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Task was already deleted.')),
                  );
                } else {
                  // Show a generic error for other issues (e.g., network).
                  messenger.showSnackBar(
                    SnackBar(content: Text('Error deleting task: $e')),
                  );
                }
              } finally {
                // Always invalidate to refresh the list and sync the UI.
                ref.invalidate(tasksProvider);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
