class TaskHistory {
  final String action;
  final String? oldValue;
  final String? newValue;
  final String changedBy;
  final DateTime changedAt;

  TaskHistory({
    required this.action,
    this.oldValue,
    this.newValue,
    required this.changedBy,
    required this.changedAt,
  });

  factory TaskHistory.fromJson(Map<String, dynamic> json) {
    return TaskHistory(
      action: json['action'],
      oldValue: json['oldValue'],
      newValue: json['newValue'],
      changedBy: json['changedBy'],
      changedAt: DateTime.parse(json['changedAt']),
    );
  }
}
