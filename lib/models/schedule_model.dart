import 'dart:convert';

class ScheduleItem {
  final String id;
  final String title;
  final String time;
  final String duration;
  bool isCompleted;

  ScheduleItem({
    required this.id,
    required this.title,
    required this.time,
    required this.duration,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'duration': duration,
      'isCompleted': isCompleted,
    };
  }

  factory ScheduleItem.fromMap(Map<String, dynamic> map) {
    return ScheduleItem(
      id: map['id'],
      title: map['title'],
      time: map['time'],
      duration: map['duration'],
      isCompleted: map['isCompleted'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory ScheduleItem.fromJson(String source) =>
      ScheduleItem.fromMap(json.decode(source));
}