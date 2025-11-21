import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String title;
  final int points;

  Task({
    String? id,
    required this.title,
    required this.points,
  }) : id = id ?? const Uuid().v4();

  // JSON serialization
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      points: json['points'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'points': points,
    };
  }
}
