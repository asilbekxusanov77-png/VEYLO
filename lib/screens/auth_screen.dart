// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/auth_provider.dart';

// class AuthScreen extends StatefulWidget {
//   const AuthScreen({super.key});

//   @override
//   State<AuthScreen> createState() => _AuthScreenState();
// }

// class _AuthScreenState extends State<AuthScreen> {
//   bool isLogin = true;
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _nameController = TextEditingController();
//   String selectedRole = 'student'; // 'teacher' yoki 'student'
//   bool isLoading = false;

//   void _submit() async {
//     final auth = context.read<AuthProvider>();
//     setState(() => isLoading = true);

//     try {
//       if (isLogin) {
//         await auth.signInWithEmail(
//           _emailController.text.trim(),
//           _passwordController.text.trim(),
//         );
//       } else {
//         await auth.signUpWithEmail(
//           email: _emailController.text.trim(),
//           password: _passwordController.text.trim(),
//           name: _nameController.text.trim(),
//           role: selectedRole,
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Xatolik: ${e.toString()}')),
//         );
//       }
//     } finally {
//       if (mounted) setState(() => isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final auth = context.watch<AuthProvider>();

//     return Scaffold(
//       backgroundColor: const Color(0xFF090D16),
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   isLogin ? 'Xush kelibsiz!' : 'Ro\'yxatdan o\'tish',
//                   style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 24),

//                 if (!isLogin) ...[
//                   TextField(
//                     controller: _nameController,
//                     style: const TextStyle(color: Colors.white),
//                     decoration: _inputDecoration('Ism va Familiya'),
//                   ),
//                   const SizedBox(height: 16),
//                   DropdownButtonFormField<String>(
//                     dropdownColor: const Color(0xFF131B2E),
//                     initialValue: selectedRole,
//                     style: const TextStyle(color: Colors.white),
//                     decoration: _inputDecoration('Rolingiz'),
//                     items: const [
//                       DropdownMenuItem(value: 'student', child: Text('O\'quvchi')),
//                       DropdownMenuItem(value: 'teacher', child: Text('Ustoz')),
//                     ],
//                     onChanged: (val) => setState(() => selectedRole = val!),
//                   ),
//                   const SizedBox(height: 16),
//                 ],

//                 TextField(
//                   controller: _emailController,
//                   style: const TextStyle(color: Colors.white),
//                   decoration: _inputDecoration('Email'),
//                 ),
//                 const SizedBox(height: 16),

//                 TextField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   style: const TextStyle(color: Colors.white),
//                   decoration: _inputDecoration('Parol'),
//                 ),
//                 const SizedBox(height: 24),

//                 isLoading
//                     ? const CircularProgressIndicator(color: Color(0xFF5B61F6))
//                     : ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF5B61F6),
//                           minimumSize: const Size(double.infinity, 50),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         ),
//                         onPressed: _submit,
//                         child: Text(
//                           isLogin ? 'Kirish' : 'Ro\'yxatdan o\'tish',
//                           style: const TextStyle(color: Colors.white, fontSize: 16),
//                         ),
//                       ),
//                 const SizedBox(height: 16),

//                 OutlinedButton.icon(
//                   style: OutlinedButton.styleFrom(
//                     minimumSize: const Size(double.infinity, 50),
//                     side: const BorderSide(color: Colors.white24),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   icon: const Icon(Icons.g_mobiledata, color: Colors.white, size: 30),
//                   label: const Text('Google orqali kirish', style: TextStyle(color: Colors.white)),
//                   onPressed: () => auth.signInWithGoogle(role: selectedRole),
//                 ),
//                 const SizedBox(height: 16),

//                 TextButton(
//                   onPressed: () => setState(() => isLogin = !isLogin),
//                   child: Text(
//                     isLogin ? 'Akkauntingiz yo\'qmi? Ro\'yxatdan o\'ting' : 'Akkauntingiz bormi? Kirish',
//                     style: const TextStyle(color: Colors.blueAccent),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   InputDecoration _inputDecoration(String hint) {
//     return InputDecoration(
//       hintText: hint,
//       hintStyle: const TextStyle(color: Colors.grey),
//       filled: true,
//       fillColor: const Color(0xFF131B2E),
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'main_navigation_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  int _step =
      1; // 1: Tel kiritish, 2: Akkaunt tanlash/Kirish, 3: Yangi ro'yxatdan o'tish
  List<Map<String, dynamic>> _userAccounts = [];
  String _selectedRole = 'student';

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // 1-QADAM: Telefon raqamni tekshirish
  // 1-QADAM: Telefon raqamni tekshirish
  Future<void> _checkPhoneNumber() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Iltimos, telefon raqamingizni kiriting!"),
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final accounts = await authProvider.getAccountsByPhone(phone);

    setState(() {
      _userAccounts = accounts;
      if (accounts.isNotEmpty) {
        _step = 2; // Mavjud akkauntlar ro'yxati
      } else {
        _step =
            3; // Agar raqamga hali hisob ochilmagan bo'lsa, to'g'ridan-to'g'ri ro'yxatdan o'tishga o'tamiz
      }
    });
  }

  // 2-QADAM: Yangi akkaunt yaratish
  // 3-QADAM: Yangi akkaunt yaratish va telefon raqamni saqlash
  Future<void> _register() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phone = _phoneController.text
        .trim(); // Oldindan kiritilgan telefon raqam

    if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Barcha maydonlarni to'ldiring!")),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final error = await authProvider.registerWithPhoneLimit(
      phone: phone,
      name: name,
      email: email,
      password: password,
      role: _selectedRole,
    );

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Yangi hisob muvaffaqiyatli qo'shildi!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield, size: 64, color: Colors.cyanAccent),
              const SizedBox(height: 16),

              // --- 1-BOSQICH: TELEFON RAQAM KIRITISH ---
              if (_step == 1) ...[
                const Text(
                  "VEYLO ga kirish",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Davom etish uchun telefon raqamingizni kiriting",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(
                    "Telefon raqam (masalan: +998901234567)",
                    Icons.phone,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _checkPhoneNumber,
                    child: const Text(
                      "Davom etish",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],

              // --- 2-BOSQICH: MAVJUD AKKAUNTLARNI TANLASH VA KIRISH ---
              // --- 2-BOSQICH: MAVJUD AKKAUNTLARNI TANLASH VA KIRISH ---
              if (_step == 2) ...[
                Text(
                  "Akkauntni tanlang (${_userAccounts.length}/5 ta)",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ..._userAccounts.map(
                  (acc) => Card(
                    color: const Color(0xFF101B35),
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.cyanAccent,
                        child: Text(
                          acc['name'][0].toUpperCase(),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                      title: Text(
                        acc['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "${acc['email']} • (${acc['role'] == 'teacher' ? 'O\'qituvchi' : 'O\'quvchi'})",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.cyanAccent,
                      ),
                      onTap: () {
                        // Akkaunt bosilganda parolni kiritib kirish dialogi ochiladi
                        _showPasswordDialogForLogin(context, acc);
                      },
                    ),
                  ),
                ),
                if (_userAccounts.length < 5) ...[
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _step = 3; // Yangi hisob qo'shish formasi ochiladi
                      });
                    },
                    icon: const Icon(
                      Icons.add_circle,
                      color: Colors.cyanAccent,
                    ),
                    label: const Text(
                      "Yangi hisob qo'shish",
                      style: TextStyle(color: Colors.cyanAccent),
                    ),
                  ),
                ],
                TextButton(
                  onPressed: () => setState(() => _step = 1),
                  child: const Text(
                    "Boshqa telefon raqam kiritish",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],

              // --- 3-BOSQICH: YANGI RO'YXATDAN O'TISH ---
              if (_step == 3) ...[
                const Text(
                  "Yangi Akkaunt Yaratish",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Raqam: ${_phoneController.text} (Maksimum 5 ta akkaunt)",
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Ism va Familiya", Icons.person),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Email", Icons.email),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Parol", Icons.lock),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _selectedRole,
                  dropdownColor: const Color(0xFF101B35),
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Rolingiz", Icons.badge),
                  items: const [
                    DropdownMenuItem(value: 'student', child: Text("O'quvchi")),
                    DropdownMenuItem(
                      value: 'teacher',
                      child: Text("O'qituvchi"),
                    ),
                  ],
                  onChanged: (val) => setState(() => _selectedRole = val!),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _register,
                    child: const Text(
                      "Ro'yxatdan o'tish",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _step = 1),
                  child: const Text(
                    "Orqaga qaytish",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
      prefixIcon: Icon(icon, color: Colors.cyanAccent),
      filled: true,
      fillColor: const Color(0xFF101B35),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  // Mavjud akkauntga parolni kiritib kirish
  void _showPasswordDialogForLogin(
    BuildContext context,
    Map<String, dynamic> account,
  ) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF101B35),
        title: Text(
          "Kirish: ${account['name']}",
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Email: ${account['email']}",
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Parolni kiriting",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Bekor qilish",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
            onPressed: () async {
              final authProvider = context.read<AuthProvider>();
              try {
                await authProvider.signInWithEmail(
                  account['email'],
                  passwordController.text.trim(),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MainNavigationScreen(),
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Xatolik: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              "Kirish",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
