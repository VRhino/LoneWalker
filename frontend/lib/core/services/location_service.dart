import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  LocationService._internal();
  static final LocationService instance = LocationService._internal();

  // Permite subclases para testing
  // ignore: prefer_const_constructors_in_immutables
  LocationService.forTesting();

  StreamSubscription<Position>? _sub;
  final _controller = StreamController<Position>.broadcast();

  Stream<Position> get positionStream => _controller.stream;

  bool get isTracking => _sub != null;

  Future<bool> requestPermission() async {
    // Android 13+: solicitar permiso de notificaciones para el foreground service
    if (Platform.isAndroid) {
      await Permission.notification.request();
    }

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    return perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;
  }

  static const _channel = MethodChannel('lonewalker/notifications');

  void startTracking() {
    if (_sub != null) return;
    if (Platform.isAndroid) {
      _channel.invokeMethod('startTracking').catchError((_) {});
    }
    runZonedGuarded(() {
      _sub = Geolocator.getPositionStream(
        locationSettings: _buildLocationSettings(),
      ).listen(
        _controller.add,
        onError: (_) {},
        cancelOnError: false,
      );
    }, (error, stack) {});
  }

  void stopTracking() {
    _sub?.cancel();
    _sub = null;
    if (Platform.isAndroid) {
      _channel.invokeMethod('stopTracking').catchError((_) {});
    }
  }

  LocationSettings _buildLocationSettings() {
    if (Platform.isAndroid) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        intervalDuration: const Duration(seconds: 5),
      );
    }
    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.fitness,
        distanceFilter: 10,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );
  }
}
