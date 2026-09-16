import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'role_selection_screen.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  String _studentIdCode = '';

  @override
  void initState() {
    super.initState();
    _loadOrGenerateCode();
  }

  Future<void> _loadOrGenerateCode() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedCode = prefs.getString('my_student_code');

    if (savedCode == null) {
      final random = Random();
      savedCode = (100000 + random.nextInt(900000)).toString();
      await prefs.setString('my_student_code', savedCode);
    }

    setState(() {
      _studentIdCode = savedCode!;
    });
  }

  Future<void> _changeRole() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_role');
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("O'quvchi Paneli", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz, color: Colors.cyanAccent),
            tooltip: "Rolni almashtirish",
            onPressed: _changeRole,
          )
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ID Kod Paneli
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1E1035), Color(0xFF0D253F)]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.cyanAccent.withAlpha(80)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Mening Ulanish Kodim", style: TextStyle(color: Colors.grey, fontSize: 13)),
                        const SizedBox(height: 6),
                        Text(
                          _studentIdCode,
                          style: const TextStyle(color: Colors.cyanAccent, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 3),
                        ),
                        const SizedBox(height: 4),
                        const Text("Ustozingizga ushbu kodni bering", style: TextStyle(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy, color: Colors.cyanAccent, size: 28),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _studentIdCode));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("ID Kod nusxalandi!")),
                        );
                      },
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}