import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_blocker_provider.dart';
import '../services/app_permissions_helper.dart';

class AppBlockerScreen extends StatefulWidget {
  const AppBlockerScreen({super.key});

  @override
  State<AppBlockerScreen> createState() => _AppBlockerScreenState();
}

class _AppBlockerScreenState extends State<AppBlockerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  Future<void> _initData() async {
    final blocker = context.read<AppBlockerProvider>();
    await blocker.fetchInstalledApps();

    if (mounted) {
      final hasPermission = await AppPermissionsHelper.checkPermissions();
      if (!hasPermission && mounted) {
        _showPermissionDialog(context);
      }
    }
  }

  void _showPermissionDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF101B35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: Colors.cyanAccent),
            SizedBox(width: 8),
            Text(
              "Zaruriy Ruxsatlar",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ilovalarni haqiqatdan bloklash va kuzatish uchun quyidagi ruxsatlar kerak:",
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            SizedBox(height: 12),
            Text(
              "1. Usage Access — Qaysi ilova ochilganini aniqlash uchun.",
              style: TextStyle(color: Colors.cyanAccent, fontSize: 12),
            ),
            SizedBox(height: 6),
            Text(
              "2. Overlay — Bloklangan ilova ustiga parda tortish uchun.",
              style: TextStyle(color: Colors.cyanAccent, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Keyinroq", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await AppPermissionsHelper.requestUsageStatsPermission();
              await AppPermissionsHelper.requestOverlayPermission();
            },
            child: const Text(
              "Ruxsat berish",
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

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF101B35),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: canPop
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          'Ilovalarni Bloklash',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.security, color: Colors.cyanAccent),
            tooltip: "Ruxsatlarni tekshirish",
            onPressed: () => _showPermissionDialog(context),
          ),
        ],
      ),
      body: Consumer<AppBlockerProvider>(
        builder: (context, blocker, child) {
          if (blocker.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            );
          }

          if (blocker.apps.isEmpty) {
            return const Center(
              child: Text(
                'Ilovalar ro\'yxati bo\'sh yoki yuklanmadi',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: blocker.apps.length,
            itemBuilder: (context, index) {
              final app = blocker.apps[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF131B2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: app.isBlocked
                        ? Colors.redAccent.withValues(alpha: 0.3)
                        : Colors.transparent,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: app.isBlocked
                          ? Colors.redAccent.withValues(alpha: 0.2)
                          : Colors.indigoAccent.withValues(alpha: 0.2),
                      child: Icon(
                        app.icon,
                        color: app.isBlocked
                            ? Colors.redAccent
                            : Colors.indigoAccent,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            app.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${app.category} • Cheklov: ${app.timeLimitMinutes} m',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: app.isBlocked,
                      activeThumbColor: Colors.redAccent,
                      onChanged: (bool newValue) async {
                        final hasPermission =
                            await AppPermissionsHelper.checkPermissions();

                        if (!hasPermission) {
                          if (context.mounted) {
                            _showPermissionDialog(context);
                          }
                        } else {
                          // 1. Provider-da bloklash holatini o'zgartirish
                          await blocker.toggleBlockStatus(app.id);

                          // 2. Native servisga bloklangan paketlar ro'yxatini yuborish
                          // await AppPermissionsHelper.updateBlockedApps(blocker.blockedPackageNames);
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
