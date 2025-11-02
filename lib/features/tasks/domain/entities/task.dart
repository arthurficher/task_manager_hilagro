import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final String id;
  final String title;
  final String description;
  final bool done;
  final DateTime createdAt;
  final DateTime? dueDate;
  final String userId;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    this.done = false,
    required this.createdAt,
    this.dueDate,
    required this.userId,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? done,
    DateTime? createdAt,
    DateTime? dueDate,
    String? userId,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      done: done ?? this.done,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'done': done ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'due_date': dueDate?.millisecondsSinceEpoch,
      'user_id': userId,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      done: (map['done'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      dueDate: map['due_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['due_date'] as int)
          : null,
      userId: map['user_id'] as String,
    );
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      done: json['done'] as bool? ?? false,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      dueDate: json['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dueDate'] as int)
          : null,
      userId: json['userId'] as String,
    );
  }

  @override
  List<Object?> get props => [id, title, description, done, createdAt, dueDate, userId];

  @override
  String toString() {
    return 'Task{id: $id, title: $title, done: $done, createdAt: $createdAt, dueDate: $dueDate, userId: $userId}';
  }
}
