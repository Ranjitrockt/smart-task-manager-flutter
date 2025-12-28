import 'package:flutter/material.dart';
import '../service/task_history_service.dart';
import '../model/task_history.dart';

class TaskHistoryPage extends StatefulWidget {
  final String taskId;

  const TaskHistoryPage({super.key, required this.taskId});

  @override
  State<TaskHistoryPage> createState() => _TaskHistoryPageState();
}

class _TaskHistoryPageState extends State<TaskHistoryPage> {
  final _service = TaskHistoryService();
  List<TaskHistory> history = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final data = await _service.fetchHistory(widget.taskId);
    setState(() {
      history = data;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task History')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                final h = history[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(h.action),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (h.oldValue != null) Text('Old: ${h.oldValue}'),
                        if (h.newValue != null) Text('New: ${h.newValue}'),
                        Text('By: ${h.changedBy}'),
                      ],
                    ),
                    trailing: Text(
                      h.changedAt.toLocal().toString().substring(0, 16),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
