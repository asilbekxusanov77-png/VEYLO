import 'package:flutter/material.dart';

class StudentAttendance {
  final String id;
  final String name;
  bool isPresent;

  StudentAttendance({
    required this.id,
    required this.name,
    this.isPresent = false,
  });
}

class AttendanceProvider extends ChangeNotifier {
  final List<StudentAttendance> _students = [
    StudentAttendance(id: '1', name: 'Ali Valiyev'),
    StudentAttendance(id: '2', name: 'Sardor Karimov'),
    StudentAttendance(id: '3', name: 'Madina Umarova'),
    StudentAttendance(id: '4', name: 'Javohir Toshov'),
    StudentAttendance(id: '5', name: 'Zilola Aliyeva'),
  ];

  List<StudentAttendance> get students => _students;

  int get presentCount => _students.where((s) => s.isPresent).length;
  int get absentCount => _students.length - presentCount;
  double get percentage => _students.isEmpty ? 0 : (presentCount / _students.length) * 100;

  void toggleAttendance(int index) {
    _students[index].isPresent = !_students[index].isPresent;
    notifyListeners();
  }

  void addStudent(String name) {
    if (name.trim().isNotEmpty) {
      _students.add(StudentAttendance(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name.trim(),
      ));
      notifyListeners();
    }
  }

  void removeStudent(int index) {
    _students.removeAt(index);
    notifyListeners();
  }
}