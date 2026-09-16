import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class NetworkMonitorScreen extends StatefulWidget {
  const NetworkMonitorScreen({super.key});

  @override
  State<NetworkMonitorScreen> createState() => _NetworkMonitorScreenState();
}

class _NetworkMonitorScreenState extends State<NetworkMonitorScreen> {
  String? _userRole;
  String _studentIdCode = '';
  final TextEditingController _codeController = TextEditingController();
  String? _connectedStudentCode;
  bool _isConnected = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRole = prefs.getString('user_role');
    
    String? myCode = prefs.getString('my_student_code');
    if (myCode == null) {
      myCode = (100000 + Random().nextInt(900000)).toString();
      await prefs.setString('my_student_code', myCode);
    }

    final savedConnectedCode = prefs.getString('connected_student_code');

    setState(() {
      _userRole = savedRole;
      _studentIdCode = myCode!;
      if (savedConnectedCode != null && savedConnectedCode.isNotEmpty) {
        _connectedStudentCode = savedConnectedCode;
        _isConnected = true;
      }
      _isLoading = false;
    });
  }

  Future<void> _selectRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
    setState(() => _userRole = role);
  }

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
    }
  }

  Future<void> _disconnectStudent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('connected_student_code');
    setState(() {
      _connectedStudentCode = null;
      _isConnected = false;
    });
  }

  Future<void> _triggerFeature(String feature, Permission permission) async {
    final status = await permission.request();
    if (status.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$feature faollashtirildi!"), backgroundColor: Colors.cyan),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$feature uchun ruxsat berilmadi"), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF090D16),
        body: Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Xarita va Kuzatuv', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz, color: Colors.cyanAccent),
            onPressed: () => setState(() => _userRole = null),
            tooltip: 'Rolni o\'zgartirish',
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_userRole == null)
                _buildRoleSelectionCard()
              else if (_userRole == 'student')
                _buildStudentCard()
              else
                _buildTeacherCard(),

              const SizedBox(height: 20),

              // Map simulation banner
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF101B35),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
                ),
                child: Stack(
                  children: [
                    Center(child: Icon(Icons.map, size: 100, color: Colors.cyanAccent.withValues(alpha: 0.15))),
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on, color: Colors.cyanAccent, size: 36),
                          SizedBox(height: 4),
                          Text("GPS Joylashuv monitoringi", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Text('Joylashuv bo\'yicha amallar', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              _buildActionTile(
                icon: Icons.mic,
                title: 'Mikrofon',
                onTap: () => _triggerFeature('Mikrofon', Permission.microphone),
              ),
              _buildActionTile(
                icon: Icons.camera_alt,
                title: 'Kamera',
                onTap: () => _triggerFeature('Kamera', Permission.camera),
              ),
              _buildActionTile(
                icon: Icons.location_on,
                title: 'Lokatsiya',
                onTap: () => _triggerFeature('Lokatsiya', Permission.location),
              ),
              _buildActionTile(
                icon: Icons.all_inclusive,
                title: 'Hammasini faollashtirish',
                onTap: () async {
                  await Permission.microphone.request();
                  await Permission.camera.request();
                  await Permission.location.request();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelectionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101B35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Text("Kuzatuv rejimi uchun rolingizni tanlang", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B61F6)),
                  onPressed: () => _selectRole('student'),
                  child: const Text("O'quvchi", style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
                  onPressed: () => _selectRole('teacher'),
                  child: const Text("Ustoz", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStudentCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101B35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Mening ID Kodim", style: TextStyle(color: Colors.grey, fontSize: 12)),
              Text(_studentIdCode, style: const TextStyle(color: Colors.cyanAccent, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.cyanAccent),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _studentIdCode));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("ID Kod nusxalandi")));
            },
          )
        ],
      ),
    );
  }

  Widget _buildTeacherCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101B35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_isConnected) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Ulangan ID: $_connectedStudentCode", style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                TextButton(onPressed: _disconnectStudent, child: const Text("Uzish", style: TextStyle(color: Colors.redAccent))),
              ],
            )
          ] else ...[
            const Text("O'quvchiga ulanmagan", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF0F172A),
                    title: const Text("ID Kod kiriting", style: TextStyle(color: Colors.white)),
                    content: TextField(
                      controller: _codeController,
                      style: const TextStyle(color: Colors.cyanAccent),
                      keyboardType: TextInputType.number,
                    ),
                    actions: [
                      ElevatedButton(onPressed: _saveAndConnectStudent, child: const Text("Saqlash")),
                    ],
                  ),
                );
              },
              child: const Text("ID kiritish", style: TextStyle(color: Colors.black)),
            )
          ]
        ],
      ),
    );
  }

  Widget _buildActionTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF101B35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.15)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.cyanAccent),
        title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
        onTap: onTap,
      ),
    );
  }
}