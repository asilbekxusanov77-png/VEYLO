// import 'package:flutter/foundation.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz_data;
// import 'package:flutter_timezone/flutter_timezone.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class NotificationService {
//   static final NotificationService _instance = NotificationService._internal();
//   factory NotificationService() => _instance;
//   NotificationService._internal();

//   final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   // Global AudioPlayer instansi (ovoz kesilib qolmasligi uchun)
//   final AudioPlayer _audioPlayer = AudioPlayer();

//   Future<void> init() async {
//     tz_data.initializeTimeZones();
    
//     try {
//       final timezoneInfo = await FlutterTimezone.getLocalTimezone();
//       final String timeZoneName = timezoneInfo.toString();
//       tz.setLocalLocation(tz.getLocation(timeZoneName));
//     } catch (e) {
//       tz.setLocalLocation(tz.local);
//     }

//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings settings = InitializationSettings(
//       android: androidSettings,
//       iOS: DarwinInitializationSettings(),
//     );

//     await _notificationsPlugin.initialize(
//       settings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) async {
//         // Foydalanuvchi bildirishnomani bosganda tovushni to'xtatish yoki qayta chalish
//         await stopAudio();
//       },
//     );
    
//     // Ruxsatlarni so'rash
//     final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
//         _notificationsPlugin.resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>();

//     await androidImplementation?.requestNotificationsPermission();
//     await androidImplementation?.requestExactAlarmsPermission();
//   }

//   // Tanlangan audioni chalish
//   Future<void> playSelectedAlarmAudio() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String? audioPath = prefs.getString('selected_audio_path');

//       if (audioPath != null && audioPath.isNotEmpty) {
//         if (audioPath.startsWith('http') || audioPath.startsWith('blob')) {
//           await _audioPlayer.play(UrlSource(audioPath));
//         } else {
//           await _audioPlayer.play(DeviceFileSource(audioPath));
//         }
//       } else {
//         // Agar maxsus audio tanlanmagan bo'lsa, asset yoki standart ovoz ishlatish mumkin
//         if (kDebugMode) {
//           print("Maxsus audio topilmadi, standart bildirishnoma ovozi ishlatiladi.");
//         }
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print("Audioni chalishda xatolik: $e");
//       }
//     }
//   }

//   // Audioni to'xtatish uchun yordamchi metod
//   Future<void> stopAudio() async {
//     try {
//       await _audioPlayer.stop();
//     } catch (e) {
//       if (kDebugMode) {
//         print("Audioni to'xtatishda xatolik: $e");
//       }
//     }
//   }

//   Future<void> scheduleNotification({
//     required int id,
//     required String title,
//     required String body,
//     required DateTime scheduledDate,
//   }) async {
//     if (scheduledDate.isBefore(DateTime.now())) return;

//     // Bildirishnoma chiqqan paytda audioni ham baravariga ishga tushiramiz
//     // (Agar ilova ochiq yoki fonda turgan bo'lsa darhol chaladi)
//     // Eslatma: To'liq o'chirilgan (terminated) holatda background handler ishlatish kerak bo'ladi.
//     await playSelectedAlarmAudio();

//     try {
//       await _notificationsPlugin.zonedSchedule(
//         id,
//         title,
//         body,
//         tz.TZDateTime.from(scheduledDate, tz.local),
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'alarm_channel_id',
//             'Eslatma va Signallar',
//             channelDescription: 'Vazifalar uchun eslatma va signallar',
//             importance: Importance.max,
//             priority: Priority.high,
//             playSound: true,
//             enableVibration: true,
//           ),
//           iOS: DarwinNotificationDetails(
//             presentSound: true,
//           ),
//         ),
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//         androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       );
//     } catch (e) {
//       // Agar aniq vaqt ruxsati muammo qilsa, inexact rejimga tushiramiz
//       await _notificationsPlugin.zonedSchedule(
//         id,
//         title,
//         body,
//         tz.TZDateTime.from(scheduledDate, tz.local),
//         const NotificationDetails(
//           android: AndroidNotificationDetails(
//             'alarm_channel_id',
//             'Eslatma va Signallar',
//             channelDescription: 'Vazifalar uchun eslatma va signallar',
//             importance: Importance.max,
//             priority: Priority.high,
//             playSound: true,
//           ),
//           iOS: DarwinNotificationDetails(),
//         ),
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//         androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//       );
//     }
//   }
// }


import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final AudioPlayer audioPlayer = AudioPlayer(); 
  static bool isAlarmPlaying = false; 

  Future<void> init() async {
    tz_data.initializeTimeZones();
    
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = timezoneInfo.toString();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      tz.setLocalLocation(tz.local);
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: DarwinInitializationSettings(),
    );

    await _notificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        await stopAlarmAudio();
      },
    );
    
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    try {
      await androidImplementation?.requestNotificationsPermission();
      await androidImplementation?.requestExactAlarmsPermission();
    } catch (e) {
      if (kDebugMode) {
        print("Ruxsatlarni so'rashda ogohlantirish: $e");
      }
    }
  }

  // Tanlangan audioni budilnik kabi chalish
  Future<void> playAlarmAudio() async {
    if (isAlarmPlaying) return; 
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? audioPath = prefs.getString('selected_audio_path');

      isAlarmPlaying = true;
      if (audioPath != null && audioPath.isNotEmpty) {
        if (audioPath.startsWith('http') || audioPath.startsWith('blob')) {
          await audioPlayer.setSource(UrlSource(audioPath));
        } else {
          await audioPlayer.setSource(DeviceFileSource(audioPath));
        }
      } else {
        // Agar maxsus audio tanlanmagan bo'lsa asset'dagi standart ovozni ishlatish
        try {
          await audioPlayer.setSource(AssetSource('audio/alarm.mp3'));
        } catch (_) {
          // Agar asset topilmasa ham xato bermasligi uchun
        }
      }
      await audioPlayer.setReleaseMode(ReleaseMode.loop);
      await audioPlayer.resume();
    } catch (e) {
      isAlarmPlaying = false;
      if (kDebugMode) {
        print("Budilnik audiosini chalishda xatolik: $e");
      }
    }
  }

  // Audioni to'xtatish
  static Future<void> stopAlarmAudio() async {
    try {
      isAlarmPlaying = false;
      await audioPlayer.stop();
    } catch (e) {
      if (kDebugMode) {
        print("Audioni to'xtatishda xatolik: $e");
      }
    }
  }

  // Vaqtni rejalashtirish va aniq vaqt kelganda audioni ishga tushirish
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    // MUHIM QO'SHIMCHA: Ilova ochiq yoki fonda turganda vaqt kelganda avtomatik chalishi uchun Timer
    final duration = scheduledDate.difference(DateTime.now());
    Timer(duration, () async {
      if (!isAlarmPlaying) {
        await playAlarmAudio();
      }
    });

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'alarm_channel_id',
        'Eslatma va Signallar',
        channelDescription: 'Budilnik va vazifalar signallari',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        fullScreenIntent: true,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'stop_alarm_action',
            'To\'xtatish',
            showsUserInterface: false,
            cancelNotification: true,
          ),
        ],
      ),
      iOS: DarwinNotificationDetails(
        presentSound: true,
      ),
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'stop',
      );
    } catch (e) {
      try {
        await _notificationsPlugin.zonedSchedule(
          id,
          title,
          body,
          tz.TZDateTime.from(scheduledDate, tz.local),
          notificationDetails,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          payload: 'stop',
        );
      } catch (innerError) {
        if (kDebugMode) {
          print("Signalni rejalashtirishda xatolik: $innerError");
        }
      }
    }
  }
}