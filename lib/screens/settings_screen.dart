// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:android_intent_plus/android_intent.dart';

// class SettingsScreen extends StatefulWidget {
//   const SettingsScreen({super.key});

//   @override
//   State<SettingsScreen> createState() => _SettingsScreenState();
// }

// class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   // Foydalanuvchi telefon sozlamalaridan ilovaga qaytganda ishlaydi
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     if (state == AppLifecycleState.resumed) {
//       // Foydalanuvchi sozlamalardan qaytdi, xohlasangiz xabar berib orqaga qaytarish mumkin
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Ruxsat tekshirildi!")),
//       );
//     }
//   }

//   // Aniq signal ruxsatini ochuvchi funksiya
//   Future<void> openExactAlarmSettings() async {
//     if (!kIsWeb) {
//       try {
//         const AndroidIntent intent = AndroidIntent(
//           action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
//         );
//         await intent.launch();
//       } catch (e) {
//         const AndroidIntent fallbackIntent = AndroidIntent(
//           action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
//           data: 'package:com.example.flutter_application_3',
//         );
//         await fallbackIntent.launch();
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sozlamalar'),
//       ),
//       body: ListView(
//         padding: const EdgeInsets.all(16),
//         children: [
//           const Text(
//             "Bildirishnoma va Signallar",
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//           const SizedBox(height: 10),
//           ListTile(
//             leading: const Icon(Icons.alarm_on, color: Colors.cyan),
//             title: const Text("Signal va eslatmalar ruxsati"),
//             subtitle: const Text("Telefon sozlamalaridan aniq vaqtni yoqish"),
//             trailing: IconButton(
//               icon: const Icon(Icons.arrow_back, color: Colors.green),
//               tooltip: "Sozlamalardan chiqish",
//               onPressed: () => Navigator.pop(context), // <--- Sozlamalardan chiqish uchun tugma
//             ),
//             onTap: () => openExactAlarmSettings(),
//           ),

//           const Divider(height: 30),

//           const Text(
//             "Hisoblar (Accounts)",
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//           const SizedBox(height: 10),

//           ListTile(
//             leading: const Icon(Icons.switch_account, color: Colors.cyan),
//             title: const Text("Hisobni almashtirish"),
//             subtitle: const Text("Mavjud akkauntlar o'rtasida o'tish"),
//             onTap: () {
//               _showSwitchAccountDialog(context);
//             },
//           ),

//           ListTile(
//             leading: const Icon(Icons.person_add, color: Colors.green),
//             title: const Text("Yangi hisob qo'shish"),
//             onTap: () {},
//           ),

//           ListTile(
//             leading: const Icon(Icons.delete_forever, color: Colors.red),
//             title: const Text("Hisobni o'chirish"),
//             subtitle: const Text("Joriy hisobni ma'lumotlar bilan birga o'chirib tashlash"),
//             onTap: () {
//               _showDeleteAccountConfirm(context);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   void _showSwitchAccountDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Hisobni tanlang"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const CircleAvatar(child: Text("U1")),
//               title: const Text("Foydalanuvchi 1"),
//               onTap: () => Navigator.pop(context),
//             ),
//             ListTile(
//               leading: const CircleAvatar(child: Text("U2")),
//               title: const Text("Foydalanuvchi 2"),
//               onTap: () => Navigator.pop(context),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showDeleteAccountConfirm(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Hisobni o'chirish"),
//         content: const Text("Haqiqatdan ham ushbu hisobni o'chirib tashlamoqchimisiz? Ma'lumotlarni qaytarib bo'lmaydi."),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Bekor qilish"),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: const Text("O'chirish"),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../screens/auth_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // --- 1. HISOBNI O'CHIRISH (Xavfsizlik talabini boshqarish bilan) ---
  void _showDeleteAccountDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF101B35),
        title: const Text(
          "Hisobni o'chirish",
          style: TextStyle(color: Colors.redAccent),
        ),
        content: const Text(
          "Haqiqatan ham hisobingizni o'chirib yubormoqchimisiz? Eslatma: Agar xavfsizlik xatoligi chiqsa, iltimos hisobdan chiqib, qayta kirgandan so'ng o'chirib ko'ring.",
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              "Bekor qilish",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await authProvider.deleteAccount();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Xavfsizlik uchun qayta kirib, so'ng o'chiring (Log out & Login again)",
                      ),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
            },
            child: const Text(
              "O'chirish",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- AKKAUNTLARNI BOSHQARISH VA RO'YXATGA CHIQARISH ---
  void _showAccountManagerModal(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    // 1. Joriy foydalanuvchining telefon raqamini Firestore'dan olamiz
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();
    final phone = userDoc.data()?['phone'];

    if (phone == null || phone.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Telefon raqam topilmadi!")),
        );
      }
      return;
    }

    // 2. Shu telefon raqamiga ochilgan barcha akkauntlarni olamiz
    final accounts = await authProvider.getAccountsByPhone(phone);

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF101B35),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Akkauntlarni Boshqarish",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Raqam: $phone (Ochilgan: ${accounts.length}/5 ta)",
                style: const TextStyle(color: Colors.cyanAccent, fontSize: 12),
              ),
              const SizedBox(height: 16),

              // Shu raqamdagi barcha akkauntlar ro'yxati
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: accounts.length,
                  itemBuilder: (context, index) {
                    final acc = accounts[index];
                    final isCurrent = acc['uid'] == currentUser.uid;

                    return Card(
                      color: const Color(0xFF1E293B),
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isCurrent
                              ? Colors.greenAccent
                              : Colors.cyanAccent,
                          child: Text(
                            acc['name']?[0]?.toUpperCase() ?? 'U',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          acc['name'] ?? 'Foydalanuvchi',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          acc['email'] ?? '',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        trailing: isCurrent
                            ? const Chip(
                                label: Text(
                                  "Faol",
                                  style: TextStyle(fontSize: 10),
                                ),
                                backgroundColor: Colors.greenAccent,
                              )
                            : TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _showSwitchAccountDialog(context, acc);
                                },
                                child: const Text(
                                  "O'tish",
                                  style: TextStyle(color: Colors.cyanAccent),
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Yangi hisob qo'shish (agar 5 tadan kam bo'lsa)
              if (accounts.length < 5)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context); // Avval pastki oynani yopadi
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthScreen(),
                        ),
                      ); // Darhol ro'yxatdan o'tish oynasini ochadi
                    },
                    icon: const Icon(Icons.add),
                    label: const Text(
                      "Yangi Hisob Qo'shish (Maks: 5 ta)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // --- 2. BOSHQA AKKAUNTGA O'TISH (PAROL BILAN) ---
  void _showSwitchAccountDialog(
    BuildContext context,
    Map<String, dynamic> targetAccount,
  ) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF101B35),
        title: Text(
          "Kirish: ${targetAccount['name']}",
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Email: ${targetAccount['email']}",
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Parolni kiriting",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Bekor qilish",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              try {
                await authProvider.signInWithEmail(
                  targetAccount['email'],
                  passwordController.text.trim(),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Akkaunt muvaffaqiyatli almashtirildi!"),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Xatolik: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              "Kirish",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. TUSHUNTIRISH VA KEYINGI QADAM (AuthScreen ga o'tish) ---
  // // --- 3. TUSHUNTIRISH VA KEYINGI QADAM (AuthScreen ga o'tish) ---
  // void _showAddAccountInstructions(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (dialogContext) => AlertDialog(
  //       backgroundColor: const Color(0xFF101B35),
  //       title: const Text(
  //         "Yangi Hisob Ochish Qoidalari",
  //         style: TextStyle(color: Colors.cyanAccent),
  //       ),
  //       content: const Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             "1. Telefon raqam kiritish MAJBURIY.\n2. Bitta telefon raqamiga faqatgina 5 tagacha akkaunt ochishga ruxsat beriladi.\n3. Ro'yxatdan o'tishda telefon raqamingizga tasdiqlash kodi keladi.",
  //             style: TextStyle(
  //               color: Colors.white70,
  //               height: 1.4,
  //               fontSize: 13,
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(dialogContext),
  //           child: const Text(
  //             "Bekor qilish",
  //             style: TextStyle(color: Colors.grey),
  //           ),
  //         ),
  //         ElevatedButton(
  //           style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
  //           onPressed: () {
  //             Navigator.pop(dialogContext); // Dialogni yopamiz

  //             // Xatolikning oldini olish uchun mounted tekshiruvi
  //             if (!context.mounted) return;

  //             // Yangi hisob ochish uchun Auth ekraniga o'tamiz
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(builder: (context) => const AuthScreen()),
  //             );
  //           },
  //           child: const Text(
  //             "Davom etish",
  //             style: TextStyle(
  //               color: Colors.black,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // --- 3. YANGI HISOB QO'SHISHGA O'TISH ---
  // void _showAddAccountInstructions(BuildContext context) {
  //   // Modal yoki dialogsiz to'g'ridan-to'g'ri AuthScreen ga o'tamiz
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const AuthScreen()),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.currentUser;

    final userCode = user != null && user.uid.length >= 6
        ? user.uid.substring(0, 6).toUpperCase()
        : "V-123456";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sozlamalar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF101B35),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.cyanAccent.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sizning Shaxsiy ID raqamingiz:',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userCode,
                      style: const TextStyle(
                        color: Colors.cyanAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white),
                  tooltip: 'ID ni nusxalash',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: userCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("ID nusxalandi!")),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          ListTile(
            leading: const Icon(Icons.switch_account, color: Colors.cyanAccent),
            title: const Text(
              'Akkauntni almashtirish va qo\'shish',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text(
              'Bitta raqam uchun 5 tagacha hisob',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () => _showAccountManagerModal(context, authProvider),
          ),
          const Divider(),

          SwitchListTile(
            title: const Text(
              'Qorong\'i rejim (Dark Mode)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            secondary: Icon(
              themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: Colors.cyanAccent,
            ),
            value: themeProvider.isDarkMode,
            onChanged: (bool value) {
              themeProvider.toggleTheme(value);
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
            title: const Text(
              'Hisobni o\'chirish',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _showDeleteAccountDialog(context, authProvider),
          ),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.amberAccent),
            title: const Text(
              'Hisobdan chiqish',
              style: TextStyle(
                color: Colors.amberAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
