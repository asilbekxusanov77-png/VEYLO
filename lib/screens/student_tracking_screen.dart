import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/student_tracking_provider.dart';

class StudentTrackingScreen extends StatefulWidget {
  const StudentTrackingScreen({super.key});

  @override
  State<StudentTrackingScreen> createState() => _StudentTrackingScreenState();
}

class _StudentTrackingScreenState extends State<StudentTrackingScreen> {
  bool _isSharing = false;

  @override
  void dispose() {
    context.read<StudentTrackingProvider>().stopSendingLocation();
    super.dispose();
  }

  Future<void> _toggleSharing() async {
    final tracking = context.read<StudentTrackingProvider>();
    if (_isSharing) {
      tracking.stopSendingLocation();
      setState(() => _isSharing = false);
    } else {
      await tracking.startSendingLocation();
      setState(() => _isSharing = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final studentId = auth.studentId;

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Mening ID kodim', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: const Color(0xFF101B35),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.cyanAccent.withAlpha(100), width: 1.5),
              ),
              child: Column(
                children: [
                  const Text("Sizning ID kodingiz", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 12),
                  Text(
                    studentId ?? '------',
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Ushbu kodni ustozingizga bering",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.cyanAccent.withAlpha(60)),
              ),
              child: Row(
                children: [
                  Icon(
                    _isSharing ? Icons.location_on : Icons.location_off,
                    color: _isSharing ? Colors.greenAccent : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _isSharing ? "Joylashuv yuborilmoqda" : "Joylashuv yuborilmayapti",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Switch(
                    value: _isSharing,
                    activeThumbColor: Colors.cyanAccent,
                    onChanged: (_) => _toggleSharing(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}