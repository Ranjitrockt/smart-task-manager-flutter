class Task {
  final String id;
  final String title;
  final String? description; // Nullable बनाया
  final String category;
  final String priority;
  final String status;
  final String? assignedTo; // Nullable बनाया
  final DateTime? dueDate; // Nullable बनाया
  final List<String> extractedEntities;
  final List<String> suggestedActions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.category,
    required this.priority,
    required this.status,
    this.assignedTo,
    this.dueDate,
    required this.extractedEntities,
    required this.suggestedActions,
    this.createdAt,
    this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse date
    DateTime? _parseDate(dynamic date) {
      if (date is String) {
        return DateTime.tryParse(date);
      }
      return null;
    }

    return Task(
      id: json['id'] ?? '',
      title: json['title'] ?? 'No Title',
      description: json['description'], // अब यह null हो सकता है
      category: json['category'] ?? 'general',
      priority: json['priority'] ?? 'low',
      status: json['status'] ?? 'pending',
      assignedTo: json['assignedTo'], // अब यह null हो सकता है
      dueDate: _parseDate(json['dueDate']), // अब यह null हो सकता है
      // यह null को हैंडल करने का सबसे सुरक्षित तरीका है
      extractedEntities:
          (json['extractedEntities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],

      suggestedActions:
          (json['suggestedActions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],

      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'assignedTo': assignedTo,
      'dueDate': dueDate?.toIso8601String(),
      'extractedEntities': extractedEntities,
      'suggestedActions': suggestedActions,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Task copyWith({
    String? title,
    String? description,
    String? category,
    String? priority,
    String? status,
    String? assignedTo,
    DateTime? dueDate,
    List<String>? extractedEntities,
    List<String>? suggestedActions,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      extractedEntities: extractedEntities ?? this.extractedEntities,
      suggestedActions: suggestedActions ?? this.suggestedActions,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
