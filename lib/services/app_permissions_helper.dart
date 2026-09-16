import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:permission_handler/permission_handler.dart';

class AppPermissionsHelper {
  // 1. Overlay (System Alert Window) ruxsatini so'rash
  static Future<void> requestOverlayPermission() async {
    if (!Platform.isAndroid) return;

    final status = await Permission.systemAlertWindow.status;
    if (!status.isGranted) {
      try {
        const intent = AndroidIntent(
          action: 'android.settings.action.MANAGE_OVERLAY_PERMISSION',
        );
        await intent.launch();
      } catch (e) {
        // Agar maxsus sozlama ochilmasa, umumiy ilova sozlamalariga yo'naltiramiz
        await openAppSettings();
      }
    }
  }

  // 2. Usage Access ruxsatini xavfsiz so'rash (Crash bo'lmasligi uchun try-catch qo'shildi)
  static Future<void> requestUsageStatsPermission() async {
    if (!Platform.isAndroid) return;

    try {
      const intent = AndroidIntent(
        action: 'android.settings.ACTION_USAGE_ACCESS_SETTINGS',
      );
      await intent.launch();
    } catch (e) {
      try {
        // Agar to'g'ridan-to'g'ri intent ochilmasa, umumiy Android sozlamalarini ochish
        const fallbackIntent = AndroidIntent(
          action: 'android.settings.SETTINGS',
        );
        await fallbackIntent.launch();
      } catch (_) {
        await openAppSettings();
      }
    }
  }

  // 3. Ruxsatlar holatini tekshirish
  static Future<bool> checkPermissions() async {
    if (!Platform.isAndroid) return true;

    // Overlay ruxsatini tekshirish
    final overlayGranted = await Permission.systemAlertWindow.isGranted;

    return overlayGranted;
  }
}