import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationAudioService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _notifications.initialize(initSettings);
  }

  // Reja vaqti uchun notification joylash
  static Future<void> scheduleAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // Eslatma vaqtini hisoblash va Android notification chiqarish
    // Vaqti kelganda signal berish uchun Audio ijro etiladi
  }

  // Tanlangan audio faylni yoki ovozli xabarni ijro etish
  static Future<void> playMotivationAudio() async {
    final prefs = await SharedPreferences.getInstance();
    final customPath = prefs.getString('custom_audio_path');

    if (customPath != null && File(customPath).existsSync()) {
      await _audioPlayer.play(DeviceFileSource(customPath));
    } else {
      // Standart motivatsiya audiosi yoki aktiv fayl
      await _audioPlayer.play(AssetSource('audios/motivation.mp3'));
    }
  }

  static Future<void> stopAudio() async {
    await _audioPlayer.stop();
  }
}