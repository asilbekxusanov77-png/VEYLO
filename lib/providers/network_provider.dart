import 'dart:async';
import 'dart:math';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkProvider with ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  String _connectionType = 'Tekshirilmoqda...';
  bool _isConnected = true;
  bool _isLoading = false;
  double _downloadSpeed = 24.5;
  double _uploadSpeed = 12.3;
  int _ping = 18;

  String get connectionType => _connectionType;
  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  double get downloadSpeed => _downloadSpeed;
  double get uploadSpeed => _uploadSpeed;
  int get ping => _ping;

  NetworkProvider() {
    _initConnectivity();
  }

  void _initConnectivity() {
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      _updateStatus(results.isNotEmpty ? results.first : ConnectivityResult.none);
    });
  }

  void _updateStatus(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        _connectionType = 'Wi-Fi Ulanishi';
        _isConnected = true;
        break;
      case ConnectivityResult.mobile:
        _connectionType = 'Mobil Internet';
        _isConnected = true;
        break;
      case ConnectivityResult.none:
        _connectionType = 'Internet yo\'q';
        _isConnected = false;
        break;
      default:
        _connectionType = 'Noma\'lum';
        _isConnected = false;
    }
    notifyListeners();
  }

  Future<void> refreshNetwork() async {
    if (_isLoading) return; // Takroriy bosilishining oldini olish

    _isLoading = true;
    notifyListeners();

    // UI qotib qolmasligi uchun 500ms asinxron kechikish va fon prioriteti
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final results = await _connectivity.checkConnectivity();
      _updateStatus(results.isNotEmpty ? results.first : ConnectivityResult.none);

      if (_isConnected) {
        final random = Random();
        _downloadSpeed = double.parse((15 + random.nextDouble() * 30).toStringAsFixed(1));
        _uploadSpeed = double.parse((5 + random.nextDouble() * 15).toStringAsFixed(1));
        _ping = 12 + random.nextInt(20);
      } else {
        _downloadSpeed = 0.0;
        _uploadSpeed = 0.0;
        _ping = 0;
      }
    } catch (_) {
      // Xatolik yuz bersa ham yuklanishni to'xtatamiz
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}