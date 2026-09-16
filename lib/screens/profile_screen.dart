import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart'; // Yo'lni loyihangizga moslang

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: const Color(0xFF5B61F6),
                    child: Text(
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
                    ),
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

            // Akkauntni Almashtirish tugmasi
            _buildProfileOption(
              Icons.switch_account,
              'Akkauntni almashtirish',
              onTap: () => _showSwitchAccountDialog(context, authProvider),
            ),
            _buildProfileOption(Icons.settings, 'Sozlamalar'),
            _buildProfileOption(Icons.notifications, 'Bildirishnomalar'),
            _buildProfileOption(Icons.security, 'Xavfsizlik'),
            _buildProfileOption(
              Icons.help_outline,
              'Yordam va qo\'llab-quvvatlash',
            ),

            // Chiqish tugmasi
            _buildProfileOption(
              Icons.logout,
              'Chiqish',
              isRed: true,
              onTap: () => _showSignOutDialog(context, authProvider),
            ),
          ],
        ),
      ),
    );
  }
Widget _buildProfileOption(
  IconData icon,
  String title, {
  bool isRed = false,
  VoidCallback? onTap,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Material(
      color: const Color(0xFF131B2E),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias, // InkSplash (bosish effekti) ko'rinishi uchun
      child: ListTile(
        leading: Icon(icon, color: isRed ? Colors.redAccent : Colors.white),
        title: Text(
          title,
          style: TextStyle(color: isRed ? Colors.redAccent : Colors.white),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    ),
  );
}

  // Akkauntni almashtirish dialogi
  void _showSwitchAccountDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF131B2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Akkauntni almashtirish',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.g_mobiledata,
                    color: Colors.redAccent, size: 32),
                title: const Text('Google orqali kirish',
                    style: TextStyle(color: Colors.white)),
                onTap: () async {
                  Navigator.pop(context);
                  try {
                    await authProvider.switchGoogleAccount();
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Xatolik: $e")),
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.email, color: Color(0xFF5B61F6)),
                title: const Text('Boshqa Email bilan kirish',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/login');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Chiqishni tasdiqlash dialogi
  void _showSignOutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF131B2E),
        title: const Text('Tizimdan chiqish',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Haqiqatan ham akkauntdan chiqmoqchimisiz?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Yo\'q', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: const Text('Ha, chiqish',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}