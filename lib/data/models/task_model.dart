enum TaskPriority { low, medium, high, urgent }

enum TaskStatus { pending, inProgress, completed, cancelled }

enum TaskCategory { personal, work, study, health, other }

class TaskModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final TaskPriority priority;
  final TaskStatus status;
  final TaskCategory category;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final List<String> tags;
  final bool isImportant;
  final String? attachments; // URL to attachments

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.pending,
    this.category = TaskCategory.personal,
    required this.createdAt,
    this.dueDate,
    this.completedAt,
    this.tags = const [],
    this.isImportant = false,
    this.attachments,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'priority': priority.name,
      'status': status.name,
      'category': category.name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'tags': tags,
      'isImportant': isImportant,
      'attachments': attachments,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      category: TaskCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => TaskCategory.personal,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      dueDate: json['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dueDate'] as int)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'] as int)
          : null,
      tags: List<String>.from(json['tags'] as List? ?? []),
      isImportant: json['isImportant'] as bool? ?? false,
      attachments: json['attachments'] as String?,
    );
  }

  TaskModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    TaskPriority? priority,
    TaskStatus? status,
    TaskCategory? category,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? completedAt,
    List<String>? tags,
    bool? isImportant,
    String? attachments,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      tags: tags ?? this.tags,
      isImportant: isImportant ?? this.isImportant,
      attachments: attachments ?? this.attachments,
    );
  }

  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.completed) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDue = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return today == taskDue;
  }

  bool get isDueTomorrow {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final taskDue = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return tomorrow == taskDue;
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, priority: $priority, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TaskModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
