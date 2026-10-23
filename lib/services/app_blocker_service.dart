import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class AppBlockerService {
  static const MethodChannel _channel = MethodChannel('uz.bato.veylo/app_blocker');

  // Service-ni ishga tushirish hamda bloklanadigan paketlarni yuborish
  static Future<void> updateBlockedApps(List<String> packageNames) async {
    try {
      await _channel.invokeMethod('startMonitoring', {
        'blockedPackages': packageNames,
      });
    } on PlatformException catch (e) {
      debugPrint("App Blocker Native Error: ${e.message}");
    }
  }

  // Servisni to'xtatish
  static Future<void> stopMonitoring() async {
    try {
      await _channel.invokeMethod('stopMonitoring');
    } on PlatformException catch (e) {
      debugPrint("App Blocker Native Error: ${e.message}");
    }
  }
}