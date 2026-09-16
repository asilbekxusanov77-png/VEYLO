import 'package:flutter/material.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  final TextEditingController _idController = TextEditingController();
  bool isConnected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101B35),
        title: const Text('Xarita va Yordamchi', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on, color: Colors.cyanAccent),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ID kiritish paneli
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF101B35),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _idController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'O\'quvchi ID sini kiriting...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                    onPressed: () {
                      if (_idController.text.trim().isNotEmpty) {
                        setState(() {
                          isConnected = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('ID: ${_idController.text} ga ulanilmoqda...')),
                        );
                      }
                    },
                    child: const Text('Ulanish', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Xarita kartochkasi
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF101B35),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.2)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(Icons.map_outlined, size: 100, color: Colors.cyanAccent.withValues(alpha: 0.15)),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF090D16).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('07.09.2026 / 17:32:58', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ),
                  ),
                  const Center(
                    child: Icon(Icons.location_on, color: Colors.cyanAccent, size: 36),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Joylashuv bo\'yicha amallar',
                style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 12),

            // Boshqaruv tugmalari (Kamera, Mikrofon, Kolonka)
            _buildActionTile(
              icon: Icons.mic_none,
              title: 'Mikrofon',
              onTap: isConnected ? () {} : null,
            ),
            _buildActionTile(
              icon: Icons.camera_alt_outlined,
              title: 'Kamera',
              onTap: isConnected ? () {} : null,
            ),
            _buildActionTile(
              icon: Icons.volume_up_outlined,
              title: 'Kolonka',
              onTap: isConnected ? () {} : null,
            ),
            _buildActionTile(
              icon: Icons.widgets_outlined,
              title: 'Hammasi',
              onTap: isConnected ? () {} : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({required IconData icon, required String title, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF101B35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.cyanAccent),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}