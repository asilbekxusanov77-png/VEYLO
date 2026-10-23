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

    // --- Bildirishnoma va Signalni rejalashtirish ---
    DateTime? scheduledDate = parseScheduleTime(taskTime);
    if (scheduledDate != null) {
      try {
        await NotificationService().scheduleNotification(
          id: notificationId,
          title: 'Eslatma va Signal! ⏰',
          body: title,
          scheduledDate: scheduledDate,
        );
      } catch (e) {
        debugPrint("Signal o'rnatishda xatolik: $e");
      }
    }
  }

  // --- AI INTEGRATSIYA METODI ---

Future<bool> addTasksFromAi(String userPrompt, String apiKey) async {
    if (apiKey.isEmpty) {
      debugPrint("XATOLIK: OpenRouter API kaliti kiritilmagan!");
      return false;
    }

    _isLoadingAi = true;
    notifyListeners();

    final url = Uri.parse('https://openrouter.ai/api/v1/chat/completions');

    final prompt = '''
Siz kunlik reja tuzuvchi yordamchisiz.
Foydalanuvchi so'rovi: "$userPrompt"

DIQQAT: Faqat va faqat quyidagi JSON formatida javob bering, hech qanday ortiqcha matn, kirish yoki markdown (masalan ```json) YOZMANX.

[
  {"title": "Ertalabki badantarbiya", "time": "07:00 - 07:30"},
  {"title": "Nonushta", "time": "07:30 - 08:00"}
]
Javobingiz faqatgina yuqoridagi formatda bo'lishi kerak.
''';

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': '[https://veylo.uz](https://veylo.uz)',
          'X-Title': 'Veylo App',
        },
        body: jsonEncode({
          'model': 'google/gemini-2.0-flash-001', // OpenRouter uchun to'g'ri model nomi
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final String? content = data['choices']?[0]?['message']?['content'];

        if (content != null && content.isNotEmpty) {
          // JSON atrofidagi markdown belgilarini tozalash
          String cleanJson = content
              .replaceAll('```json', '')
              .replaceAll('```', '')
              .trim();

          final List<dynamic> decodedList = jsonDecode(cleanJson);

          for (var item in decodedList) {
            String title = item['title']?.toString() ?? '';
            String time = item['time']?.toString() ?? '';
            
            // AI qaytargan har bir vazifani ro'yxatga qo'shish
            // (Bu yerga o'zingizning vazifa qo'shuvchi funksiyangizni yozing)
            _addTaskToSchedule(title, time);
          }
   
          _isLoadingAi = false;
          notifyListeners();
          return true; // Reja muvaffaqiyatli tuzildi
        }
      } else {
        debugPrint('OpenRouter xato berdi (Status ${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      debugPrint('AI reja tuzishda kutilmagan xatolik: $e');
    }

    _isLoadingAi = false;
    notifyListeners();
    return false; // Xatolik yuz berdi
  }
  void _addTaskToSchedule(String title, String time) {
    // Masalan: _tasks.add(Task(title: title, time: time));
    // O'zingizning ScheduleProvider ichidagi vazifa qo'shish kodingizni kiriting
    addTask(title, time);
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
