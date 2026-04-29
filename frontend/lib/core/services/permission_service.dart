import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionService {
  static const _channel = MethodChannel('lonewalker/notifications');
  static const _prefKey = 'bg_permission_onboarding_shown';

  static Future<bool> isXiaomiDevice() async {
    if (!Platform.isAndroid) return false;
    return await _channel.invokeMethod<bool>('isXiaomiDevice') ?? false;
  }

  static Future<bool> isBatteryOptimizationIgnored() async {
    if (!Platform.isAndroid) return true;
    return await _channel.invokeMethod<bool>('isBatteryOptimizationIgnored') ??
        false;
  }

  static Future<void> openBatterySettings() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod('openBatterySettings');
  }

  static Future<void> openAutoStartSettings() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod('openAutoStartSettings');
  }

  static Future<bool> isBackgroundLocationGranted() async {
    if (!Platform.isAndroid) return true;
    return await _channel.invokeMethod<bool>('isBackgroundLocationGranted') ??
        false;
  }

  static Future<void> openLocationSettings() async {
    if (!Platform.isAndroid) return;
    await _channel.invokeMethod('openLocationSettings');
  }

  static Future<bool> wasOnboardingShown() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  static Future<void> markOnboardingShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
  }
}
