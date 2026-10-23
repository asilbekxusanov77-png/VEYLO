// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/app_blocker_provider.dart';
// import '../providers/schedule_provider.dart';
// import '../services/notification_service.dart';
// import '../screens/schedule_screen.dart';
// import '../screens/settings_screen.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     Provider.of<AppBlockerProvider>(context);
//     final scheduleProvider = Provider.of<ScheduleProvider>(context);

//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 34, 36, 42),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF101B35),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.settings, color: Colors.white),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const SettingsScreen()),
//               );
//             },
//           ),
//         ],
//         title: const Text(
//           'Bosh Sahifa',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // --- SIGNAL CHALAYOTGANDA CHIQADIGAN TO'XTATISH BANNERI ---
//             StatefulBuilder(
//               builder: (context, setStateBanner) {
//                 if (!NotificationService.isAlarmPlaying) {
//                   return const SizedBox.shrink();
//                 }
//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 20),
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.redAccent,
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Row(
//                         children: [
//                           Icon(Icons.alarm_on, color: Colors.white, size: 28),
//                           SizedBox(width: 12),
//                           Text(
//                             "Vazifa signali chalmoqda! ⏰",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.white,
//                           foregroundColor: Colors.redAccent,
//                         ),
//                         onPressed: () async {
//                           await NotificationService.stopAlarmAudio();
//                           setStateBanner(() {}); // <--- Xatolik to'g'irlandi
//                         },
//                         child: const Text("To'xtatish", style: TextStyle(fontWeight: FontWeight.bold)),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),

//             // Banner
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color.fromARGB(255, 255, 0, 0), Color.fromARGB(255, 0, 225, 255)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Xush kelibsiz! 🙋',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     'Bugungi kun tartibi va ilovalar cheklovini samarali boshqaring.',
//                     style: TextStyle(
//                       color: Colors.white.withValues(alpha: 0.8),
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),

//             const Text(
//               'Asosiy Bo\'limlar',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Navigation Cards
//             Row(
//               children: [
//                 Expanded(
//                   child: InkWell(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const ScheduleScreen(),
//                         ),
//                       );
//                     },
//                     borderRadius: BorderRadius.circular(16),
//                     child: Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF101B35),
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(
//                           color: Colors.cyanAccent.withValues(alpha: 0.3),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color: Colors.cyanAccent.withValues(alpha: 0.2),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: const Icon(
//                               Icons.calendar_today,
//                               color: Colors.cyanAccent,
//                               size: 28,
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           const Text(
//                             'Kun tartibi',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           const Text(
//                             'Ro\'yxatdagi vazifalarni ko\'ring',
//                             style: TextStyle(color: Colors.grey, fontSize: 12),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),

//             // --- VAZIFALAR RO'YXATI ---
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Bugungi Rejalar',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const ScheduleScreen()),
//                     );
//                   },
//                   child: const Text('Barchasi', style: TextStyle(color: Colors.cyanAccent)),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),

//             // --- Xatolik to'g'irlandi (? va : qo'shildi) ---
//             scheduleProvider.tasks.isEmpty
//                 ? const Center(
//                     child: Padding(
//                       padding: EdgeInsets.all(20.0),
//                       child: Text('Hozircha vazifalar yo\'q', style: TextStyle(color: Colors.grey)),
//                     ),
//                   )
//                 : ListView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: scheduleProvider.tasks.length > 3 ? 3 : scheduleProvider.tasks.length,
//                     itemBuilder: (context, index) {
//                       final task = scheduleProvider.tasks[index];
//                       return Container(
//                         margin: const EdgeInsets.only(bottom: 12),
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF101B35),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Row(
//                           children: [
//                             const Icon(Icons.alarm, color: Colors.cyanAccent),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     task.title,
//                                     style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     task.time,
//                                     style: const TextStyle(color: Colors.grey, fontSize: 12),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/app_blocker_provider.dart';
// import '../providers/schedule_provider.dart';
// import '../services/notification_service.dart';
// import '../screens/schedule_screen.dart';
// import '../screens/settings_screen.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     Provider.of<AppBlockerProvider>(context);
//     final scheduleProvider = Provider.of<ScheduleProvider>(context);

//     return Scaffold(
//       backgroundColor: const Color.fromARGB(255, 34, 36, 42),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF101B35),
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.settings, color: Colors.white),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(builder: (context) => const SettingsScreen()),
//               );
//             },
//           ),
//         ],
//         title: const Text(
//           'Bosh Sahifa',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // --- SIGNAL CHALAYOTGANDA BOSH SAHifada CHIQADIGAN TO'XTATISH TUGMASI ---
//             StatefulBuilder(
//               builder: (context, setStateBanner) {
//                 if (!NotificationService.isAlarmPlaying) {
//                   return const SizedBox.shrink();
//                 }
//                 return Container(
//                   margin: const EdgeInsets.only(bottom: 20),
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.redAccent,
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Row(
//                         children: [
//                           Icon(Icons.alarm_on, color: Colors.white, size: 28),
//                           SizedBox(width: 12),
//                           Text(
//                             "Signal chalmoqda! ⏰",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 14,
//                             ),
//                           ),
//                         ],
//                       ),
//                       ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.white,
//                           foregroundColor: Colors.redAccent,
//                         ),
//                         onPressed: () async {
//                           await NotificationService.stopAlarmAudio();
//                           setStateBanner(() {}); // Bannerni yopish uchun yangilash
//                         },
//                         child: const Text("To'xtatish", style: TextStyle(fontWeight: FontWeight.bold)),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),

//             // Banner
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color.fromARGB(255, 255, 0, 0), Color.fromARGB(255, 0, 225, 255)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Xush kelibsiz! 🙋',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     'Bugungi kun tartibi va ilovalar cheklovini samarali boshqaring.',
//                     style: TextStyle(
//                       color: Colors.white.withValues(alpha: 0.8),
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),

//             const Text(
//               'Asosiy Bo\'limlar',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Navigation Cards
//             Row(
//               children: [
//                 Expanded(
//                   child: InkWell(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => const ScheduleScreen(),
//                         ),
//                       );
//                     },
//                     borderRadius: BorderRadius.circular(16),
//                     child: Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: const Color(0xFF101B35),
//                         borderRadius: BorderRadius.circular(16),
//                         border: Border.all(
//                           color: Colors.cyanAccent.withValues(alpha: 0.3),
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(10),
//                             decoration: BoxDecoration(
//                               color: Colors.cyanAccent.withValues(alpha: 0.2),
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             child: const Icon(
//                               Icons.calendar_today,
//                               color: Colors.cyanAccent,
//                               size: 28,
//                             ),
//                           ),
//                           const SizedBox(height: 12),
//                           const Text(
//                             'Kun tartibi',
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           const Text(
//                             'Ro\'yxatdagi vazifalarni ko\'ring',
//                             style: TextStyle(color: Colors.grey, fontSize: 12),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),

//             // --- VAZIFALAR RO'YXATI ---
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text(
//                   'Bugungi Rejalar',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const ScheduleScreen()),
//                     );
//                   },
//                   child: const Text('Barchasi', style: TextStyle(color: Colors.cyanAccent)),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),

//             scheduleProvider.tasks.isEmpty
//                 ? const Center(
//                     child: Padding(
//                       padding: EdgeInsets.all(20.0),
//                       child: Text('Hozircha vazifalar yo\'q', style: TextStyle(color: Colors.grey)),
//                     ),
//                   )
//                 : ListView.builder(
//                     shrinkWrap: true,
//                     physics: const NeverScrollableScrollPhysics(),
//                     itemCount: scheduleProvider.tasks.length > 3 ? 3 : scheduleProvider.tasks.length,
//                     itemBuilder: (context, index) {
//                       final task = scheduleProvider.tasks[index];
//                       return Container(
//                         margin: const EdgeInsets.only(bottom: 12),
//                         padding: const EdgeInsets.all(12),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF101B35),
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Row(
//                           children: [
//                             const Icon(Icons.alarm, color: Colors.cyanAccent),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     task.title,
//                                     style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     task.time,
//                                     style: const TextStyle(color: Colors.grey, fontSize: 12),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_blocker_provider.dart';
import '../providers/schedule_provider.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';
import '../screens/schedule_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<AppBlockerProvider>(context);
    final scheduleProvider = Provider.of<ScheduleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    final int totalTasks = scheduleProvider.tasks.length;
    final int completedTasks = scheduleProvider.tasks
        .where((t) => t.isCompleted)
        .length;

    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? const Color.fromARGB(255, 34, 36, 42) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF101B35) : Colors.blue,
        elevation: 0,
        actions: [
          // --- DARK MODE TUGMASI ---
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: Colors.cyanAccent,
            ),
            onPressed: () {
              themeProvider.toggleTheme(!isDark);
            },
          ),
        ],
        title: const Text(
          'Bosh Sahifa',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SIGNAL TO'XTATISH BANNERI ---
            StatefulBuilder(
              builder: (context, setStateBanner) {
                if (!NotificationService.isAlarmPlaying) {
                  return const SizedBox.shrink();
                }
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.alarm_on, color: Colors.white, size: 28),
                          SizedBox(width: 12),
                          Text(
                            "Signal chalmoqda! ⏰",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.redAccent,
                        ),
                        onPressed: () async {
                          await NotificationService.stopAlarmAudio();
                          setStateBanner(() {});
                        },
                        child: const Text(
                          "To'xtatish",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // --- DOIMIY AYLANIB TURADIGAN RANGLI CONTAINER ---
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: const [
                        Color.fromARGB(255, 227, 0, 0),
                        Color.fromARGB(255, 0, 59, 197),
                        Color.fromARGB(255, 217, 0, 255),
                        Color.fromARGB(255, 0, 255, 187),
                      ],
                      begin: Alignment(-1.0 + _controller.value, -1.0),
                      end: Alignment(1.0 - _controller.value, 1.0),
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Xush kelibsiz! 🙋',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Bugungi kun tartibi va ilovalar cheklovini samarali boshqaring.',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            Text(
              'Asosiy Bo\'limlar',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // --- KUN TARTIBI KARTOGKASI (Vazifalar soni bilan) ---
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ScheduleScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF101B35) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.cyanAccent.withValues(alpha: 0.3),
                        ),
                        boxShadow: isDark
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.cyanAccent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.calendar_today,
                                  color: Colors.cyanAccent,
                                  size: 28,
                                ),
                              ),
                              // Vazifalar statistikasi (bajarilgan / jami)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.cyanAccent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$completedTasks / $totalTasks bajarildi',
                                  style: const TextStyle(
                                    color: Colors.cyanAccent,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Kun tartibi',
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Ro\'yxatdagi vazifalarni ko\'ring',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- VAZIFALAR RO'YXATI ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bugungi Rejalar',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ScheduleScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Barchasi',
                    style: TextStyle(color: Colors.cyanAccent),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            scheduleProvider.tasks.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'Hozircha vazifalar yo\'q',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: scheduleProvider.tasks.length > 3
                        ? 3
                        : scheduleProvider.tasks.length,
                    itemBuilder: (context, index) {
                      final task = scheduleProvider.tasks[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF101B35) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: isDark
                              ? []
                              : [
                                  BoxShadow(
                                    color: Colors.grey.withValues(alpha: 0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.alarm, color: Colors.cyanAccent),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task.title,
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    task.time,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}