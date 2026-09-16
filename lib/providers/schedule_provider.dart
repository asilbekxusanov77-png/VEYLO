import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_service.dart';


class ScheduleTask {
  final String id;
  final String title;
  final String time;
  bool isCompleted;

  ScheduleTask({
    required this.id,
    required this.title,
    required this.time,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'time': time,
    'isCompleted': isCompleted,
  };

  factory ScheduleTask.fromJson(Map<String, dynamic> json, {String? docId}) =>
      ScheduleTask(
        id: docId ?? json['id'] ?? '',
        title: json['title'] ?? '',
        time: json['time'] ?? '',
        isCompleted: json['isCompleted'] ?? false,
      );
}

class ScheduleProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ScheduleTask> _tasks = [];
  bool _isLoadingAi = false;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<QuerySnapshot>? _firestoreSubscription;

  List<ScheduleTask> get tasks => _tasks;
  bool get isLoadingAi => _isLoadingAi;

  ScheduleProvider() {
    _authSubscription = _auth.authStateChanges().listen((user) {
      _initTasks(user);
    });
  }

  // Tizimga kirganiga qarab yuklash turini aniqlaydi
  Future<void> _initTasks(User? user) async {
    await _firestoreSubscription?.cancel();

    if (user != null) {
      _listenToFirestore(user.uid);
    } else {
      _tasks.clear();
      await _loadLocalTasks();
    }
  }
  DateTime? parseScheduleTime(String timeStr) {
  try {
    final now = DateTime.now();
    
    // Matndan birinchi uchragan "09:00" yoki "9:00" shaklidagi vaqtni topish
    final regExp = RegExp(r'(\d{1,2}):(\d{2})');
    final match = regExp.firstMatch(timeStr);

    if (match != null) {
      int hour = int.parse(match.group(1)!);
      int minute = int.parse(match.group(2)!);

      DateTime scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      // Agar ko'rsatilgan vaqt bugun o'tib ketgan bo'lsa, ertangi kunga belgilaydi
      if (scheduledDateTime.isBefore(now)) {
        scheduledDateTime = scheduledDateTime.add(const Duration(days: 1));
      }

      return scheduledDateTime;
    }
  } catch (e) {
    debugPrint('Vaqtni formatlashda xatolik: $e');
  }
  return null;
}

  // --- FIRESTORE BO'LIMI ---

  void _listenToFirestore(String uid) {
    _firestoreSubscription = _firestore
        .collection('users')
        .doc(uid)
        .collection('schedules')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _tasks = snapshot.docs
                .map((doc) => ScheduleTask.fromJson(doc.data(), docId: doc.id))
                .toList();
            notifyListeners();
          },
          onError: (error) {
            debugPrint('Firestore tinglashda xatolik: $error');
          },
        );
  }

  // --- LOCAL (SharedPreferences) BO'LIMI ---

  Future<void> _loadLocalTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString('saved_tasks');
    if (tasksString != null) {
      final List<dynamic> decoded = jsonDecode(tasksString);
      _tasks = decoded.map((item) => ScheduleTask.fromJson(item)).toList();
    } else {
      _tasks = [
        ScheduleTask(
          id: '1',
          title: 'Ertalabki mashqlar',
          time: '07:00 - 08:00',
          isCompleted: true,
        ),
        ScheduleTask(id: '2', title: 'Flutter loyihasi', time: '10:00 - 12:00'),
      ];
      _saveLocalTasks();
    }
    notifyListeners();
  }

  Future<void> _saveLocalTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(
      _tasks.map((task) => task.toJson()).toList(),
    );
    await prefs.setString('saved_tasks', encoded);
  }

  // --- METODLAR ---

  Future<void> toggleTask(String id) async {
    final user = _auth.currentUser;
    final index = _tasks.indexWhere((task) => task.id == id);

    if (index != -1) {
      final newStatus = !_tasks[index].isCompleted;

      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('schedules')
            .doc(id)
            .update({'isCompleted': newStatus});
      } else {
        _tasks[index].isCompleted = newStatus;
        _saveLocalTasks();
        notifyListeners();
      }
    }
  }

  Future<void> addTask(String title, String time) async {
    if (title.trim().isEmpty) return;

    final user = _auth.currentUser;
    final taskTime = time.isEmpty ? 'Kechroq' : time;
    final int notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('schedules')
          .add({
            'title': title.trim(),
            'time': taskTime,
            'isCompleted': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
    } else {
      _tasks.add(
        ScheduleTask(
          id: notificationId.toString(),
          title: title.trim(),
          time: taskTime,
        ),
      );
      _saveLocalTasks();
      notifyListeners();
    }

    // --- Notification ulash qismi ---
    DateTime? scheduledDate = parseScheduleTime(taskTime);
    if (scheduledDate != null) {
      await NotificationService().scheduleNotification(
        id: notificationId,
        title: 'Dars vaqti bo\'ldi! 📚',
        body: title,
        scheduledDate: scheduledDate,
      );
    }
  }

  // --- AI INTEGRATSIYA METODI ---

  Future<bool> addTasksFromAi(String userPrompt, String apiKey) async {
    if (userPrompt.trim().isEmpty) return false;

    _isLoadingAi = true;
    notifyListeners();

    try {
      final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

      final prompt = '''
Siz rejalashtiruvchi yordamchisiz. Foydalanuvchiga hech qanday savol bermang va qo'shimcha tushuntirish matni yoza ko'rmang. 

Foydalanuvchi so'rovi: "$userPrompt"

Sizning yagona vazifangiz: Shu so'rovdan kelib chiqib, bir kunlik reja/jadval tuzing va uni FAQAT JSON massivi shaklida qaytaring. 

Format strictly JSON:
[
  {"title": "Ertalabki mashqlar", "time": "08:00 - 09:00"},
  {"title": "Dars qilish", "time": "10:00 - 12:00"}
]
''';

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey', // OpenRouter key: sk-or-v1-...
        },
        body: jsonEncode({
          "model": "google/gemini-flash-1.5",
          "messages": [
            {"role": "user", "content": prompt}
          ],
          "response_format": {"type": "json_object"}
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String rawText = data['choices'][0]['message']['content'];
        
        final dynamic parsedJson = jsonDecode(rawText);
        List<dynamic> taskList = [];

        if (parsedJson is List) {
          taskList = parsedJson;
        } else if (parsedJson is Map && parsedJson.containsKey('tasks')) {
          taskList = parsedJson['tasks'];
        } else if (parsedJson is Map) {
          taskList = parsedJson.values.firstWhere((e) => e is List, orElse: () => []);
        }

        for (var item in taskList) {
          final title = item['title']?.toString() ?? '';
          final time = item['time']?.toString() ?? 'Kechroq';
          if (title.isNotEmpty) {
            await addTask(title, time);
          }
        }

        _isLoadingAi = false;
        notifyListeners();
        return true;
      } else {
        debugPrint("OpenRouter API xatosi: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      debugPrint("AI Reja yaratishda xatolik: $e");
    }

    _isLoadingAi = false;
    notifyListeners();
    return false;
  }

  Future<void> deleteTask(String id) async {
    final user = _auth.currentUser;

    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('schedules')
          .doc(id)
          .delete();
    } else {
      _tasks.removeWhere((task) => task.id == id);
      _saveLocalTasks();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _firestoreSubscription?.cancel();
    super.dispose();
  }
}
