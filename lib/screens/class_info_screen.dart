import 'package:flutter/material.dart';

class ClassInfoScreen extends StatelessWidget {
  const ClassInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> attendanceHistory = [
      {'date': '2026-09-10', 'present': 24, 'absent': 2, 'percent': '92%'},
      {'date': '2026-09-09', 'present': 25, 'absent': 1, 'percent': '96%'},
      {'date': '2026-09-08', 'present': 22, 'absent': 4, 'percent': '84%'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101B35),
        title: const Text('Sinf Haqida va Davomat Tarixi', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kunlik Saqlangan Davomatlar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: attendanceHistory.length,
                itemBuilder: (context, index) {
                  final item = attendanceHistory[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF101B35),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item['date'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text("Kelgan: ${item['present']} | Kelmagan: ${item['absent']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                        Text(item['percent'], style: const TextStyle(color: Colors.cyanAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}