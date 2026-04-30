import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final instance = ConnectivityService._();
  ConnectivityService._();

  final _connectivity = Connectivity();
  final _controller = StreamController<bool>.broadcast();

  bool _isOnline = true;

  bool get isOnline => _isOnline;
  Stream<bool> get isOnlineStream => _controller.stream;

  Future<void> initialize() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = results.any((r) => r != ConnectivityResult.none);

    _connectivity.onConnectivityChanged.listen((results) {
      final nowOnline = results.any((r) => r != ConnectivityResult.none);
      if (nowOnline != _isOnline) {
        _isOnline = nowOnline;
        _controller.add(_isOnline);
      }
    });
  }

  void dispose() => _controller.close();
}
