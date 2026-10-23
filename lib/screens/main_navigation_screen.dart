// import 'package:flutter/foundation.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz_data;
// import 'package:flutter_timezone/flutter_timezone.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class MainNavigationScreen {
//   static final MainNavigationScreen _instance = MainNavigationScreen._internal();
//   factory MainNavigationScreen() => _instance;
//   MainNavigationScreen._internal();

//   final FlutterLocalNotificationsPlugin _notificationsPlugin =
//       FlutterLocalNotificationsPlugin();

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
//         await playSelectedAlarmAudio();
//       },
//     );
    
//     final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
//         _notificationsPlugin.resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>();

//     await androidImplementation?.requestNotificationsPermission();
//     await androidImplementation?.requestExactAlarmsPermission();
//   }

//   Future<void> playSelectedAlarmAudio() async {
//     final prefs = await SharedPreferences.getInstance();
//     final String? audioPath = prefs.getString('selected_audio_path');

//     if (audioPath != null && audioPath.isNotEmpty) {
//       final AudioPlayer audioPlayer = AudioPlayer();
//       try {
//         if (audioPath.startsWith('http') || audioPath.startsWith('blob')) {
//           await audioPlayer.play(UrlSource(audioPath));
//         } else {
//           await audioPlayer.play(DeviceFileSource(audioPath));
//         }
//       } catch (e) {
//         if (kDebugMode) {
//           print("Audioni avtomatik chalishda xatolik: $e");
//         }
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
//           ),
//           iOS: DarwinNotificationDetails(),
//         ),
//         uiLocalNotificationDateInterpretation:
//             UILocalNotificationDateInterpretation.absoluteTime,
//         androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       );
//     } catch (e) {
//       // Agar aniq vaqt ruxsati xato bersa, oddiy usulda rejalashtirishga harakat qiladi
//       try {
//         await _notificationsPlugin.zonedSchedule(
//           id,
//           title,
//           body,
//           tz.TZDateTime.from(scheduledDate, tz.local),
//           const NotificationDetails(
//             android: AndroidNotificationDetails(
//               'alarm_channel_id',
//               'Eslatma va Signallar',
//               importance: Importance.max,
//               priority: Priority.high,
//               playSound: true,
//             ),
//             iOS: DarwinNotificationDetails(),
//           ),
//           uiLocalNotificationDateInterpretation:
//               UILocalNotificationDateInterpretation.absoluteTime,
//           androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//         );
//       } catch (innerError) {
//         if (kDebugMode) {
//           print("Bildirishnoma o'rnatishda xatolik: $innerError");
//         }
//       }
//     }
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:flutter_application_3/screens/home_screen.dart';
// import 'student_home_screen.dart'; // Yoki o'zingizning asosiy bosh sahifa faylingiz (HomeDashboardView turgan joy)
// import 'schedule_screen.dart';
// import 'chat_screen.dart';
// import 'profile_screen.dart';
// import 'settings_screen.dart';

// class MainNavigationScreen extends StatefulWidget {
//   const MainNavigationScreen({super.key});

//   @override
//   State<MainNavigationScreen> createState() => _MainNavigationScreenState();
// }

// class _MainNavigationScreenState extends State<MainNavigationScreen> {
//   int _currentIndex = 0;

//   // Barcha sahifalar ro'yxati (tartib raqami bilan mos kelishi shart)
//   final List<Widget> _screens = [
//     const HomeScreen(), // 0 - Bosh sahifa (1-rasmdagi ko'rinish)
//     const ScheduleScreen(),    // 1 - Reja / Kun tartibi (2-rasmdagi ekran)
//     const ChatScreen(),        // 2 - Chat
//     const ProfileScreen(),     // 3 - Profil
//     const SettingsScreen(),    // 4 - Sozlamalar
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_currentIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _currentIndex,
//         selectedItemColor: Colors.cyanAccent,
//         unselectedItemColor: Colors.grey,
//         backgroundColor: const Color(0xFF090D16),
//         type: BottomNavigationBarType.fixed,
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//           });
//         },
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Bosh sahifa',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.schedule),
//             label: 'Reja',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.chat),
//             label: 'Chat',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profil',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.settings),
//             label: 'Sozlamalar',
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ChatScreen(),
    const ProfileScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF090D16),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Bosh sahifa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Sozlamalar',
          ),
        ],
      ),
    );
  }
}