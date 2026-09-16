import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/app_blocker_service.dart';

class AppBlockerItem {
  final String id; // package_name
  final String name;
  final String category;
  final int timeLimitMinutes;
  bool isBlocked;
  final IconData icon;

  AppBlockerItem({
    required this.id,
    required this.name,
    this.category = 'Ilova',
    this.timeLimitMinutes = 0,
    this.isBlocked = false,
    this.icon = Icons.android,
  });
}

class AppBlockerProvider extends ChangeNotifier {
  List<AppBlockerItem> _apps = [];
  bool _isLoading = false;

  List<AppBlockerItem> get apps => _apps;
  bool get isLoading => _isLoading;

  AppBlockerProvider() {
    fetchInstalledApps();
  }

  // Telefongagi haqiqiy ilovalarni va saqlangan bloklash holatlarini yuklash
  Future<void> fetchInstalledApps() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> blockedPackageNames = prefs.getStringList('blocked_apps') ?? [];

      List<AppInfo> installed = await InstalledApps.getInstalledApps(
        excludeSystemApps: true,
        withIcon: true,
      );

      _apps = installed.map((app) {
        return AppBlockerItem(
          id: app.packageName,
          name: app.name,
          category: 'O\'rnatilgan ilova',
          // Agar ilova avval saqlangan ro'yxatda bo'lsa, isBlocked true bo'ladi
          isBlocked: blockedPackageNames.contains(app.packageName),
        );
      }).toList();
    } catch (e) {
      debugPrint("Ilovalarni yuklashda xatolik: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Bloklash holatini o'zgartirish va SharedPreferences'ga saqlash
  Future<void> toggleBlockStatus(String id) async {
  final index = _apps.indexWhere((app) => app.id == id);
  if (index != -1) {
    _apps[index].isBlocked = !_apps[index].isBlocked;
    notifyListeners();

    // 1. Bloklangan ilovalarning paket nomlarini yig'ish
    List<String> blockedPackageNames = _apps
        .where((app) => app.isBlocked)
        .map((app) => app.id) // agar app.id da package name (masalan com.instagram.android) bo'lsa
        .toList();

    // 2. Local xotiraga (SharedPreferences) saqlash
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('blocked_apps', blockedPackageNames);

    // 3. NATIVE ANDROID SERVISGA YUBORISH (Shu qator yetishmayotgan edi)
    if (blockedPackageNames.isNotEmpty) {
      await AppBlockerService.updateBlockedApps(blockedPackageNames);
    } else {
      await AppBlockerService.stopMonitoring();
    }
  }
}
  
}