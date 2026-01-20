import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class NetworkMonitorService extends ChangeNotifier {
  static final NetworkMonitorService _instance = NetworkMonitorService._internal();
  factory NetworkMonitorService() => _instance;
  NetworkMonitorService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  Future<void> init() async {
    // Initial check
    final results = await _connectivity.checkConnectivity();
    _updateState(results);

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen(_updateState);
  }

  void _updateState(List<ConnectivityResult> results) {
    // Disable network monitoring in debug mode
    if (kDebugMode) {
      if (_isConnected != false) {
        _isConnected = false;
        notifyListeners();
      }
      return;
    }

    // We consider it "connected" if any result is NOT none
    final connected = results.any((result) => result != ConnectivityResult.none);

    if (_isConnected != connected) {
      _isConnected = connected;
      notifyListeners();
      if (kDebugMode) {
        print('Network status changed: connected = $_isConnected');
      }
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
