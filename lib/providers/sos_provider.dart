import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class SosProvider extends ChangeNotifier {
  final List<String> _numbers = ['+998901234567', '+998912345678'];
  bool _isSending = false;

  List<String> get numbers => _numbers;
  bool get isSending => _isSending;

  void addNumber(String number) {
    if (number.isNotEmpty && !_numbers.contains(number)) {
      _numbers.add(number);
      notifyListeners();
    }
  }

  void removeNumber(int index) {
    _numbers.removeAt(index);
    notifyListeners();
  }

  Future<void> triggerSos(BuildContext context) async {
    if (_numbers.isEmpty) return;

    _isSending = true;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Joylashuv xizmati (GPS) o\'chirilgan.';
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Joylashuvga ruxsat berilmadi.';
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw 'Joylashuv ruxsatnomasi doimiy rad etilgan.';
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      String mapUrl = "https://maps.google.com/?q=${position.latitude},${position.longitude}";
      String message = "FAVQULODDA XABAR! Mening lokatsiyam: $mapUrl";

      final Uri phoneUri = Uri(scheme: 'tel', path: _numbers.first);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }

      final Uri smsUri = Uri(
        scheme: 'sms',
        path: _numbers.join(','),
        queryParameters: {'body': message},
      );
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('SOS Xatosi: $e')),
        );
      }
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }
}