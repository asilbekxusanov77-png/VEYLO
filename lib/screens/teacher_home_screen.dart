import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'role_selection_screen.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({super.key});

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  final TextEditingController _codeController = TextEditingController();
  String? _connectedStudentCode;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _loadSavedStudent();
  }

  // Saqlangan ID ni yuklash
  Future<void> _loadSavedStudent() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('connected_student_code');
    if (savedCode != null && savedCode.isNotEmpty) {
      setState(() {
        _connectedStudentCode = savedCode;
        _isConnected = true;
      });
    }
  }

  // ID ni xotiraga saqlash
  Future<void> _saveAndConnectStudent() async {
    final code = _codeController.text.trim();
    if (code.length == 6) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('connected_student_code', code);

      setState(() {
        _connectedStudentCode = code;
        _isConnected = true;
      });

      _codeController.clear();
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("O'quvchi (ID: $code) ulandi va saqlandi!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Iltimos, 6 xonali to'g'ri kod kiriting!")),
      );
    }
  }

  // Ulanishni o'chirish
  Future<void> _disconnectStudent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('connected_student_code');

    setState(() {
      _connectedStudentCode = null;
      _isConnected = false;
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
      backgroundColor: const Color(0xFF070B14),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Ustoz Paneli — Kuzatuv', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz, color: Colors.cyanAccent),
            tooltip: "Rolni almashtirish",
            onPressed: _changeRole,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF101B35),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.cyanAccent.withAlpha(100)),
              ),
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: Opacity(
                      opacity: 0.1,
                      child: Icon(Icons.map, size: 220, color: Colors.cyanAccent),
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isConnected ? Icons.location_on : Icons.location_off,
                          color: _isConnected ? Colors.greenAccent : Colors.grey,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        if (_isConnected) ...[
                          Text(
                            "Ulangan O'quvchi ID: $_connectedStudentCode",
                            style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          const Text("Holati: Faol (Real-vaqt kuzatuvida)", style: TextStyle(color: Colors.white70, fontSize: 12)),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.redAccent)),
                            onPressed: _disconnectStudent,
                            icon: const Icon(Icons.link_off, color: Colors.redAccent, size: 18),
                            label: const Text("Ulanishni uzish", style: TextStyle(color: Colors.redAccent)),
                          )
                        ] else ...[
                          const Text("Hozirda hech qanday o'quvchi saqlanmagan", style: TextStyle(color: Colors.white70, fontSize: 13)),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                            onPressed: () => _showCodeDialog(context),
                            icon: const Icon(Icons.add_link, color: Colors.black),
                            label: const Text("ID Kod Kiritish va Saqlash", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          )
                        ]
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        title: const Text("O'quvchi ID kodini kiriting", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: const TextStyle(color: Colors.cyanAccent, fontSize: 22, letterSpacing: 4),
          decoration: const InputDecoration(
            hintText: "000000",
            hintStyle: TextStyle(color: Colors.grey, letterSpacing: 1),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Bekor qilish", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
            onPressed: _saveAndConnectStudent,
            child: const Text("Saqlash va Ulanish", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}