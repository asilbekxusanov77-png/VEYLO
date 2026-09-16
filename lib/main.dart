import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'firebase_options.dart';

import 'providers/chat_provider.dart';
import 'providers/schedule_provider.dart';
import 'providers/sos_provider.dart';
import 'providers/tts_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/app_blocker_provider.dart';
import 'services/notification_service.dart';

import 'providers/student_tracking_provider.dart';

import 'screens/home_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/role_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => AppBlockerProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => SosProvider()),
        ChangeNotifierProvider(create: (_) => TtsProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StudentTrackingProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Assistant',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF090D16),
      ),
      home: const AuthGate(),
    );
  }
}

/// Kirish holatiga qarab to'g'ri ekranga yo'naltiradi:
/// 1. Tizimga kirilmagan -> AuthScreen
/// 2. Kirilgan, lekin rol tanlanmagan -> RoleSelectionScreen
/// 3. Kirilgan va rol bor -> HomeScreen
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF090D16),
            body: Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
          );
        }

        if (!snapshot.hasData) {
          return const AuthScreen();
        }

        return const _RoleGate();
      },
    );
  }
}

class _RoleGate extends StatefulWidget {
  const _RoleGate();

  @override
  State<_RoleGate> createState() => _RoleGateState();
}

class _RoleGateState extends State<_RoleGate> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final auth = context.read<AuthProvider>();
    if (auth.role == null && auth.currentUser != null) {
      await auth.fetchUserData(auth.currentUser!.uid);
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFF090D16),
        body: Center(child: CircularProgressIndicator(color: Colors.cyanAccent)),
      );
    }

    final role = context.watch<AuthProvider>().role;
    return role == null ? const RoleSelectionScreen() : const HomeScreen();
  }
}