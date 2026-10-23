

// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../providers/auth_provider.dart';
// import '../screens/attendance_screen.dart';
// import '../screens/text_to_speech_screen.dart';
// import '../screens/sos_screen.dart';
// import '../screens/tracking_screen.dart';
// import '../screens/student_tracking_screen.dart';

// class ProfileScreen extends StatefulWidget {
//   const ProfileScreen({super.key});

//   @override
//   State<ProfileScreen> createState() => _ProfileScreenState();
// }

// class _ProfileScreenState extends State<ProfileScreen> {
//   File? _imageFile;

//   @override
//   void initState() {
//     super.initState();
//     _loadSavedImage();
//   }

//   // Saqlangan profil rasmini yuklab olish
//   Future<void> _loadSavedImage() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final String? imagePath = prefs.getString('profile_image_path');
//       if (imagePath != null && File(imagePath).existsSync()) {
//         setState(() {
//           _imageFile = File(imagePath);
//         });
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print("Rasmni yuklashda xatolik: $e");
//       }
//     }
//   }

//   // Galereyadan rasm tanlab saqlash
//   Future<void> _pickAndSaveImage() async {
//     try {
//       final ImagePicker picker = ImagePicker();
//       final XFile? pickedFile = await picker.pickImage(
//         source: ImageSource.gallery,
//         imageQuality: 80, // Rasm sifatini ozgina kamaytirish xotirani tejaydi
//       );

//       if (pickedFile != null) {
//         final File file = File(pickedFile.path);
//         final SharedPreferences prefs = await SharedPreferences.getInstance();
//         await prefs.setString('profile_image_path', file.path);

//         setState(() {
//           _imageFile = file;
//         });
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print("Rasmni tanlashda xatolik: $e");
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
//     final user = authProvider.currentUser;

//     return Scaffold(
//       backgroundColor: const Color(0xFF090D16),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text('Profil', style: TextStyle(color: Colors.white)),
//         // Sozlamalar tugmasi olib tashlandi (Faqat pastdagi tab orqali kiriladi)
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Profile Header with Image Picker
//             Center(
//               child: Column(
//                 children: [
//                   Stack(
//                     children: [
//                       CircleAvatar(
//                         radius: 45,
//                         backgroundColor: const Color(0xFF5B61F6),
//                         backgroundImage: _imageFile != null
//                             ? FileImage(_imageFile!)
//                             : null,
//                         child: _imageFile == null
//                             ? Text(
//                                 user?.displayName?.isNotEmpty == true
//                                     ? user!.displayName![0].toUpperCase()
//                                     : (user?.email?.isNotEmpty == true
//                                           ? user!.email![0].toUpperCase()
//                                           : 'U'),
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 32,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               )
//                             : null,
//                       ),
//                       Positioned(
//                         bottom: 0,
//                         right: 0,
//                         child: InkWell(
//                           onTap: _pickAndSaveImage,
//                           borderRadius: BorderRadius.circular(20),
//                           child: Container(
//                             padding: const EdgeInsets.all(6),
//                             decoration: const BoxDecoration(
//                               color: Colors.cyanAccent,
//                               shape: BoxShape.circle,
//                             ),
//                             child: const Icon(
//                               Icons.camera_alt,
//                               color: Color(0xFF090D16),
//                               size: 18,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     user?.displayName ?? 'Foydalanuvchi',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     user?.email ?? 'Email ko\'rsatilmagan',
//                     style: const TextStyle(color: Colors.grey, fontSize: 14),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 32),

//             // Additional Features Section
//             const Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 'Qo\'shimcha funksiyalar',
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Feature Cards Grid
//             GridView.count(
//               crossAxisCount: 2,
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               mainAxisSpacing: 12,
//               crossAxisSpacing: 12,
//               childAspectRatio: 0.85,
//               children: [
//                 _buildFeatureCard(
//                   context,
//                   Icons.checklist,
//                   'Davomat',
//                   'O\'quvchilar dars qatnashish holatini qayd qiling.',
//                   () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const AttendanceScreen(),
//                     ),
//                   ),
//                 ),
//                 _buildFeatureCard(
//                   context,
//                   Icons.volume_up,
//                   'Matnni Ovozga',
//                   'Kiritilgan matnni ovozga aylantirish.',
//                   () => Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const TextToSpeechScreen(),
//                     ),
//                   ),
//                 ),
//                 _buildFeatureCard(
//                   context,
//                   Icons.warning_amber_rounded,
//                   'S.O.S',
//                   'Favqulodda xabar yuborish va yordam so\'rash.',
//                   () => Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const SosScreen()),
//                   ),
//                 ),
//                 _buildFeatureCard(
//                   context,
//                   Icons.location_on,
//                   'Kuzatuv',
//                   'Real vaqtda joylashuvni kuzatish.',
//                   () {
//                     final role = context.read<AuthProvider>().role;
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => role == 'teacher'
//                             ? const TrackingScreen()
//                             : const StudentTrackingScreen(),
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFeatureCard(
//     BuildContext context,
//     IconData icon,
//     String title,
//     String description,
//     VoidCallback onTap,
//   ) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(16),
//       child: Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           gradient: const LinearGradient(
//             colors: [Color(0xFF131B2E), Color(0xFF1A2332)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.15)),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.cyanAccent.withValues(alpha: 0.2),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Icon(icon, color: Colors.cyanAccent, size: 24),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               title,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 15,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               description,
//               style: const TextStyle(color: Colors.grey, fontSize: 11),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }



import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../screens/attendance_screen.dart';
import '../screens/text_to_speech_screen.dart';
import '../screens/sos_screen.dart';
import '../screens/tracking_screen.dart';
import '../screens/student_tracking_screen.dart';
// Agar ilovalarni bloklash uchun alohida ekraningiz bo'lsa import qilasiz:
// import '../screens/app_blocker_screen.dart'; 
import '../screens/app_blocker_screen.dart'; // Agar AppBlockerScreen mavjud bo'lsa import qilinadi

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _loadSavedImage();
  }

  Future<void> _loadSavedImage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? imagePath = prefs.getString('profile_image_path');
      if (imagePath != null && File(imagePath).existsSync()) {
        setState(() {
          _imageFile = File(imagePath);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Rasmni yuklashda xatolik: $e");
      }
    }
  }

  Future<void> _pickAndSaveImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('profile_image_path', file.path);

        setState(() {
          _imageFile = file;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print("Rasmni tanlashda xatolik: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profil', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: const Color(0xFF5B61F6),
                        backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                        child: _imageFile == null
                            ? Text(
                                user?.displayName?.isNotEmpty == true
                                    ? user!.displayName![0].toUpperCase()
                                    : (user?.email?.isNotEmpty == true
                                        ? user!.email![0].toUpperCase()
                                        : 'U'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: _pickAndSaveImage,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.cyanAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Color(0xFF090D16),
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.displayName ?? 'Foydalanuvchi',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'Email ko\'rsatilmagan',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Qo\'shimcha funksiyalar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Feature Cards Grid (Ilovalar bloklovchisi qo'shildi)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
              children: [
                // --- ILOVALARNI BLOKLOVCHI KARTOGKASI ---
                _buildFeatureCard(
                  context,
                  Icons.block,
                  'Ilova Bloklovchi',
                  'Chalg\'ituvchi ilovalarni vaqtinchalik bloklash.',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AppBlockerScreen()),
                    );
                    // Agar maxsus AppBlockerScreen bo'lsa shu yerga yozasiz, 
                    // yoki dialog / boshqa sahifaga o'tish:
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Ilova bloklovchi ochilmoqda...")),
                    );
                  },
                ),
                _buildFeatureCard(
                  context,
                  Icons.checklist,
                  'Davomat',
                  'O\'quvchilar dars qatnashish holatini qayd qiling.',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AttendanceScreen()),
                  ),
                ),
                _buildFeatureCard(
                  context,
                  Icons.volume_up,
                  'Matnni Ovozga',
                  'Kiritilgan matnni ovozga aylantirish.',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const TextToSpeechScreen()),
                  ),
                ),
                _buildFeatureCard(
                  context,
                  Icons.warning_amber_rounded,
                  'S.O.S',
                  'Favqulodda xabar yuborish va yordam so\'rash.',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SosScreen()),
                  ),
                ),
                _buildFeatureCard(
                  context,
                  Icons.location_on,
                  'Kuzatuv',
                  'Real vaqtda joylashuvni kuzatish.',
                  () {
                    final role = context.read<AuthProvider>().role;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => role == 'teacher'
                            ? const TrackingScreen()
                            : const StudentTrackingScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF131B2E), Color(0xFF1A2332)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.cyanAccent.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.cyanAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.cyanAccent, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(color: Colors.grey, fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}