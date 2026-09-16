import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sozlamalar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Hisoblar (Accounts)",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),
          
          // Akkaunt almashtirish
          ListTile(
            leading: const Icon(Icons.switch_account, color: Colors.cyan),
            title: const Text("Hisobni almashtirish"),
            subtitle: const Text("Mavjud akkauntlar o'rtasida o'tish"),
            onTap: () {
              _showSwitchAccountDialog(context);
            },
          ),
          
          // Akkaunt qo'shish
          ListTile(
            leading: const Icon(Icons.person_add, color: Colors.green),
            title: const Text("Yangi hisob qo'shish"),
            onTap: () {
              // Login / Sign Up oynasiga yo'naltirish logikasi
            },
          ),
          
          // Akkauntni o'chirish
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text("Hisobni o'chirish"),
            subtitle: const Text("Joriy hisobni ma'lumotlar bilan birga o'chirib tashlash"),
            onTap: () {
              _showDeleteAccountConfirm(context);
            },
          ),
        ],
      ),
    );
  }

  void _showSwitchAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hisobni tanlang"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const CircleAvatar(child: Text("U1")),
              title: const Text("Foydalanuvchi 1"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const CircleAvatar(child: Text("U2")),
              title: const Text("Foydalanuvchi 2"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Hisobni o'chirish"),
        content: const Text("Haqiqatdan ham ushbu hisobni o'chirib tashlamoqchimisiz? Ma'lumotlarni qaytarib bo'lmaydi."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Bekor qilish"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              // Firebase Auth yoki Local DB o'chirish chaqiruvi
              Navigator.pop(context);
            },
            child: const Text("O'chirish"),
          ),
        ],
      ),
    );
  }
}