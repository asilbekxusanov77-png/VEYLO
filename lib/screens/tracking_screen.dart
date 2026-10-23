// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/student_tracking_provider.dart';

// class TrackingScreen extends StatefulWidget {
//   const TrackingScreen({super.key});

//   @override
//   State<TrackingScreen> createState() => _TrackingScreenState();
// }

// class _TrackingScreenState extends State<TrackingScreen> {
//   final TextEditingController _codeController = TextEditingController();

//   @override
//   void dispose() {
//     _codeController.dispose();
//     super.dispose();
//   }

//   Future<void> _connectToStudent(BuildContext dialogContext) async {
//     final provider = context.read<StudentTrackingProvider>();
//     final code = _codeController.text.trim();

//     if (code.length != 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Iltimos, to'g'ri 6 xonali ID kodni kiriting!")),
//       );
//       return;
//     }

//     // Async operatsiya
//     final error = await provider.linkStudentByCode(code);

//     // Widget hali ekranda mavjudligini va muloqot oynasi ochiqligini tekshiramiz
//     if (!mounted) return;

//     if (dialogContext.mounted) {
//       Navigator.pop(dialogContext);
//     }

//     // SnackBar chiqarish
//     if (error == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("O'quvchi (ID: $code) muvaffaqiyatli ulandi!")),
//       );
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<StudentTrackingProvider>();

//     return Scaffold(
//       backgroundColor: const Color(0xFF070B14),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.cyanAccent),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Xarita va Yordamchi',
//           style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
//         ),
//         actions: [
//           if (provider.isConnected)
//             IconButton(
//               icon: const Icon(Icons.link_off, color: Colors.redAccent),
//               tooltip: "Ulanishni uzish",
//               onPressed: () {
//                 provider.disconnect();
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text("O'quvchi bilan ulanish uzildi")),
//                 );
//               },
//             )
//           else
//             IconButton(
//               icon: const Icon(Icons.location_on, color: Colors.cyanAccent),
//               onPressed: () {},
//             ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 16),

//             // Kuzatuv paneli
//             Container(
//               height: 200,
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: const Color(0xFF101B35),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4), width: 1.5),
//                 boxShadow: [
//                   BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.12), blurRadius: 10, spreadRadius: 1),
//                 ],
//               ),
//               child: Stack(
//                 children: [
//                   const Positioned.fill(
//                     child: Opacity(
//                       opacity: 0.15,
//                       child: Icon(Icons.map, size: 220, color: Colors.cyanAccent),
//                     ),
//                   ),
//                   Center(
//                     child: !provider.isConnected
//                         ? Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               const Icon(Icons.location_on, color: Colors.cyanAccent, size: 40),
//                               const SizedBox(height: 8),
//                               const Text(
//                                 "Hozirda hech qanday o'quvchi ulanmagan",
//                                 style: TextStyle(color: Colors.white70, fontSize: 12),
//                               ),
//                               const SizedBox(height: 10),
//                               ElevatedButton.icon(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: Colors.cyanAccent,
//                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                                 ),
//                                 onPressed: () => _showCodeInputDialog(context),
//                                 icon: const Icon(Icons.add_link, color: Colors.black),
//                                 label: const Text(
//                                   "O'quvchi ID Kodini Kiritish",
//                                   style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
//                                 ),
//                               ),
//                             ],
//                           )
//                         : StreamBuilder<DocumentSnapshot>(
//                             stream: provider.getLinkedStudentLocationStream(),
//                             builder: (context, snapshot) {
//                               if (!snapshot.hasData || !snapshot.data!.exists) {
//                                 return const Text(
//                                   "Lokatsiya kutilmoqda...",
//                                   style: TextStyle(color: Colors.white70, fontSize: 12),
//                                 );
//                               }
//                               final data = snapshot.data!.data() as Map<String, dynamic>;
//                               final lat = data['latitude'];
//                               final lng = data['longitude'];
//                               return Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   const Icon(Icons.location_on, color: Colors.cyanAccent, size: 40),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     "O'quvchi ulandi (ID: ${provider.studentCode})",
//                                     style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
//                                   ),
//                                   const SizedBox(height: 4),
//                                   Text(
//                                     "Lat: $lat, Lng: $lng",
//                                     style: const TextStyle(color: Colors.white70, fontSize: 12),
//                                   ),
//                                 ],
//                               );
//                             },
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),

//             const Text(
//               "Joylashuv bo'yicha amallar",
//               style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),

//             _buildActionTile(
//               context,
//               Icons.mic,
//               "Mikrofon",
//               provider.isConnected ? () => _sendCommand(context, 'mic') : null,
//             ),
//             _buildActionTile(
//               context,
//               Icons.camera_alt,
//               "Kamera",
//               provider.isConnected ? () => _sendCommand(context, 'camera') : null,
//             ),
//             _buildActionTile(
//               context,
//               Icons.volume_up,
//               "Kolonka",
//               provider.isConnected ? () => _sendCommand(context, 'speaker') : null,
//             ),

//             Material(
//               color: Colors.transparent,
//               child: InkWell(
//                 onTap: provider.isConnected ? () => _sendCommand(context, 'all') : null,
//                 borderRadius: BorderRadius.circular(16),
//                 child: Container(
//                   margin: const EdgeInsets.only(bottom: 12),
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF0F172A),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.24)),
//                   ),
//                   child: const Row(
//                     children: [
//                       Icon(Icons.mic, color: Colors.cyanAccent, size: 20),
//                       SizedBox(width: 8),
//                       Icon(Icons.camera_alt, color: Colors.cyanAccent, size: 20),
//                       SizedBox(width: 8),
//                       Icon(Icons.volume_up, color: Colors.cyanAccent, size: 20),
//                       SizedBox(width: 16),
//                       Text("Hammasi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//                       Spacer(),
//                       Icon(Icons.chevron_right, color: Colors.grey),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _sendCommand(BuildContext context, String type) {
//     context.read<StudentTrackingProvider>().sendCommand(type);
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Buyruq yuborildi: $type")),
//     );
//   }

//   Widget _buildActionTile(
//     BuildContext context,
//     IconData icon,
//     String title,
//     VoidCallback? onTap,
//   ) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Material(
//         color: const Color(0xFF0F172A),
//         borderRadius: BorderRadius.circular(16),
//         clipBehavior: Clip.antiAlias,
//         child: ListTile(
//           leading: Container(
//             padding: const EdgeInsets.all(8),
//             decoration: const BoxDecoration(color: Color(0xFF1E293B), shape: BoxShape.circle),
//             child: Icon(icon, color: Colors.cyanAccent, size: 20),
//           ),
//           title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
//           trailing: const Icon(Icons.chevron_right, color: Colors.grey),
//           onTap: onTap,
//         ),
//       ),
//     );
//   }

//   void _showCodeInputDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (dialogContext) => AlertDialog(
//         backgroundColor: const Color(0xFF0F172A),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text("O'quvchiga ulanish", style: TextStyle(color: Colors.white)),
//         content: TextField(
//           controller: _codeController,
//           keyboardType: TextInputType.number,
//           maxLength: 6,
//           style: const TextStyle(color: Colors.cyanAccent, fontSize: 20, letterSpacing: 2),
//           decoration: const InputDecoration(
//             hintText: "6 xonali ID kod",
//             hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
//             enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
//             focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent, width: 2)),
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(dialogContext),
//             child: const Text("Bekor qilish", style: TextStyle(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
//             onPressed: () => _connectToStudent(dialogContext),
//             child: const Text("Ulanish", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );
//   }
// }





import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_tracking_provider.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _connectToStudent(BuildContext dialogContext) async {
    final provider = context.read<StudentTrackingProvider>();
    final code = _codeController.text.trim();

    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Iltimos, to'g'ri 6 xonali ID kodni kiriting!")),
      );
      return;
    }

    final error = await provider.linkStudentByCode(code);

    if (!mounted) return;

    if (dialogContext.mounted) {
      Navigator.pop(dialogContext);
    }

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("O'quvchi (ID: $code) muvaffaqiyatli ulandi!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  void _sendCommand(BuildContext context, String type) {
    context.read<StudentTrackingProvider>().sendCommand(type);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Buyruq yuborildi: $type")),
    );
  }

  void _showCodeInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("O'quvchiga ulanish", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _codeController,
          style: const TextStyle(color: Colors.cyanAccent, fontSize: 20, letterSpacing: 2),
          decoration: const InputDecoration(
            hintText: "6 xonali ID kod",
            hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
            focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent, width: 2)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Bekor qilish", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
            onPressed: () => _connectToStudent(dialogContext),
            child: const Text("Ulanish", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StudentTrackingProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.cyanAccent),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Xarita va Kuzatuv',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          if (provider.isConnected)
            IconButton(
              icon: const Icon(Icons.link_off, color: Colors.redAccent),
              tooltip: "Ulanishni uzish",
              onPressed: () {
                provider.disconnect();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("O'quvchi bilan ulanish uzildi")),
                );
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.add_link, color: Colors.cyanAccent),
              onPressed: () => _showCodeInputDialog(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Kuzatuv Paneli
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF101B35),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withValues(alpha: 0.12),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: Opacity(
                      opacity: 0.15,
                      child: Icon(Icons.map, size: 220, color: Colors.cyanAccent),
                    ),
                  ),
                  Center(
                    child: !provider.isConnected
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_off, color: Colors.grey, size: 40),
                              const SizedBox(height: 8),
                              const Text(
                                "Hozirda hech qanday o'quvchi ulanmagan",
                                style: TextStyle(color: Colors.white70, fontSize: 13),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.cyanAccent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onPressed: () => _showCodeInputDialog(context),
                                icon: const Icon(Icons.add_link, color: Colors.black),
                                label: const Text(
                                  "O'quvchi ID Kodini Kiritish",
                                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          )
                        : StreamBuilder<DocumentSnapshot>(
                            stream: provider.getLinkedStudentLocationStream(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData || !snapshot.data!.exists) {
                                return const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(color: Colors.cyanAccent),
                                    SizedBox(height: 10),
                                    Text(
                                      "O'quvchi joylashuvi kutilmoqda...",
                                      style: TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                  ],
                                );
                              }
                              final data = snapshot.data!.data() as Map<String, dynamic>?;
                              final lat = data?['latitude'] ?? 'Noma\'lum';
                              final lng = data?['longitude'] ?? 'Noma\'lum';

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.my_location, color: Colors.greenAccent, size: 44),
                                  const SizedBox(height: 8),
                                  Text(
                                    "O'quvchi ulandi (ID: ${provider.studentCode})",
                                    style: const TextStyle(
                                      color: Colors.greenAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Lat: $lat, Lng: $lng",
                                    style: const TextStyle(color: Colors.white, fontSize: 13),
                                  ),
                                ],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Kuzatuv va Masofaviy Boshqaruv",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            _buildActionTile(
              context,
              Icons.mic,
              "Mikrofonni eshitish",
              provider.isConnected ? () => _sendCommand(context, 'mic') : null,
            ),
            _buildActionTile(
              context,
              Icons.camera_alt,
              "Kameradan jonli tasvir",
              provider.isConnected ? () => _sendCommand(context, 'camera') : null,
            ),
            _buildActionTile(
              context,
              Icons.volume_up,
              "Ovoz chiqarish (Kolonka)",
              provider.isConnected ? () => _sendCommand(context, 'speaker') : null,
            ),

            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: provider.isConnected ? () => _sendCommand(context, 'all') : null,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.24)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.mic, color: Colors.cyanAccent, size: 20),
                      SizedBox(width: 8),
                      Icon(Icons.camera_alt, color: Colors.cyanAccent, size: 20),
                      SizedBox(width: 8),
                      Icon(Icons.volume_up, color: Colors.cyanAccent, size: 20),
                      SizedBox(width: 16),
                      Text("Barcha manbalarni yoqish", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      Spacer(),
                      Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback? onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFF1E293B), shape: BoxShape.circle),
            child: Icon(icon, color: onTap != null ? Colors.cyanAccent : Colors.grey, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: onTap != null ? Colors.white : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: Icon(Icons.chevron_right, color: onTap != null ? Colors.grey : Colors.white10),
          onTap: onTap,
        ),
      ),
    );
  }
}