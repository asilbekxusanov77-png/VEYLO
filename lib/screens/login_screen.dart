import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.shield_outlined, size: 80, color: Colors.cyanAccent),
            const SizedBox(height: 16),
            const Text(
              'A1 - Nazorat Tizimi',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            
            // Rol Tanlash
            const Text('Rolingizni tanlang:', style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedRole = 'ustoz'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selectedRole == 'ustoz' ? Colors.cyan.withValues(alpha: 0.2) : const Color(0xFF101B35),
                        border: Border.all(color: selectedRole == 'ustoz' ? Colors.cyanAccent : Colors.transparent),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.school, color: Colors.cyanAccent),
                          SizedBox(height: 8),
                          Text('Ustoz', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedRole = 'o_quvchi'),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selectedRole == 'o_quvchi' ? Colors.cyan.withValues(alpha: 0.2) : const Color(0xFF101B35),
                        border: Border.all(color: selectedRole == 'o_quvchi' ? Colors.cyanAccent : Colors.transparent),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.person, color: Colors.cyanAccent),
                          SizedBox(height: 8),
                          Text('O\'quvchi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Google tugmasi
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: selectedRole == null || authProvider.isLoading
                  ? null
                  : () async {
                      final creds = await authProvider.signInWithGoogle();
                      if (creds != null) {
                        await authProvider.setUserRoleAndGenerateId(selectedRole!);
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                          );
                        }
                      }
                    },
              icon: const Icon(Icons.g_mobiledata, color: Colors.black, size: 30),
              label: authProvider.isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text('Google orqali kirish', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}