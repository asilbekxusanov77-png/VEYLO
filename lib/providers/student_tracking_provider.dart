import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class StudentTrackingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _studentCode;
  String? get studentCode => _studentCode;

  String? _linkedStudentUid;
  String? get linkedStudentUid => _linkedStudentUid;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  StreamSubscription<Position>? _positionSub;

  // ---------------- O'QUVCHI TOMONI ----------------

  /// O'quvchi uchun 6 xonali unikal ID kod yaratadi va Firestore'ga yozadi
  Future<String> generateStudentCode() async {
    final user = _auth.currentUser;
    if (user == null) return '';

    final code = (100000 + Random().nextInt(900000)).toString();
    _studentCode = code;

    await _firestore.collection('users').doc(user.uid).set({
      'studentCode': code,
      'isLinked': false,
    }, SetOptions(merge: true));

    await _firestore.collection('student_codes').doc(code).set({
      'studentUid': user.uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    notifyListeners();
    return code;
  }

  /// O'quvchi qurilmasida GPS joylashuvni doimiy Firestore'ga jo'natish
  Future<void> startSendingLocation() async {
    final user = _auth.currentUser;
    if (user == null) return;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _errorMessage = "Joylashuvga ruxsat berilmadi";
        notifyListeners();
        return;
      }
    }

    await _positionSub?.cancel();
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) async {
      await _firestore.collection('locations').doc(user.uid).set({
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  void stopSendingLocation() {
    _positionSub?.cancel();
    _positionSub = null;
  }

  /// O'quvchi qurilmasi ustozdan kelgan buyruqlarni (mic/camera/speaker) tinglaydi
  Stream<DocumentSnapshot> listenForCommands() {
    final user = _auth.currentUser;
    return _firestore.collection('commands').doc(user?.uid).snapshots();
  }

  // ---------------- USTOZ TOMONI ----------------

  /// Ustoz o'quvchi kodini kiritib ulanadi
  Future<String?> linkStudentByCode(String code) async {
    final teacherUser = _auth.currentUser;
    if (teacherUser == null) return "Avtorizatsiyadan o'tilmagan";

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final codeDoc =
          await _firestore.collection('student_codes').doc(code.trim()).get();

      if (!codeDoc.exists) {
        _isLoading = false;
        notifyListeners();
        return "Bunday ID kodli o'quvchi topilmadi!";
      }

      final data = codeDoc.data() as Map<String, dynamic>;
      final studentUid = data['studentUid'] as String? ?? '';

      if (studentUid.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return "Xatolik yuz berdi";
      }

      await _firestore
          .collection('teacher_connections')
          .doc(teacherUser.uid)
          .set({
        'linkedStudentUid': studentUid,
        'linkedCode': code.trim(),
        'linkedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await _firestore.collection('users').doc(studentUid).set({
        'isLinked': true,
        'teacherUid': teacherUser.uid,
      }, SetOptions(merge: true));

      _linkedStudentUid = studentUid;
      _isConnected = true;
      _studentCode = code.trim();
      _isLoading = false;
      notifyListeners();
      return null; // muvaffaqiyatli
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return "Ulanishda xatolik yuz berdi";
    }
  }

  void disconnect() {
    _linkedStudentUid = null;
    _isConnected = false;
    _studentCode = null;
    notifyListeners();
  }

  /// Ulangan o'quvchining real-vaqt lokatsiya oqimi
  Stream<DocumentSnapshot>? getLinkedStudentLocationStream() {
    if (_linkedStudentUid == null) return null;
    return _firestore.collection('locations').doc(_linkedStudentUid).snapshots();
  }

  /// Ustoz mikrofon / kamera / kolonka / hammasi buyrug'ini o'quvchiga yuboradi
  Future<void> sendCommand(String type) async {
    if (_linkedStudentUid == null) return;
    await _firestore.collection('commands').doc(_linkedStudentUid).set({
      'type': type, // 'mic' | 'camera' | 'speaker' | 'all'
      'requestedBy': _auth.currentUser?.uid,
      'requestedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }
}