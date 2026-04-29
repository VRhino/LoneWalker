package com.example.lonewalker

import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun onResume() {
        super.onResume()
        if (hasLocationPermission()) {
            startTrackingService()
        }
    }

    private fun hasLocationPermission(): Boolean {
        val fine = checkSelfPermission(android.Manifest.permission.ACCESS_FINE_LOCATION)
        val coarse = checkSelfPermission(android.Manifest.permission.ACCESS_COARSE_LOCATION)
        return fine == PackageManager.PERMISSION_GRANTED || coarse == PackageManager.PERMISSION_GRANTED
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "lonewalker/notifications"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "startTracking" -> {
                    startTrackingService()
                    result.success(null)
                }
                "stopTracking" -> {
                    stopService(Intent(this, LoneWalkerForegroundService::class.java))
                    result.success(null)
                }
                "isXiaomiDevice" -> {
                    result.success(Build.MANUFACTURER.equals("Xiaomi", ignoreCase = true))
                }
                "isBatteryOptimizationIgnored" -> {
                    val pm = getSystemService(PowerManager::class.java)
                    result.success(pm.isIgnoringBatteryOptimizations(packageName))
                }
                "openBatterySettings" -> {
                    try {
                        startActivity(
                            Intent(Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS).apply {
                                data = Uri.parse("package:$packageName")
                            }
                        )
                        result.success(null)
                    } catch (e: Exception) {
                        startActivity(Intent(Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS))
                        result.success(null)
                    }
                }
                "openAutoStartSettings" -> {
                    try {
                        startActivity(Intent().apply {
                            component = ComponentName(
                                "com.miui.securitycenter",
                                "com.miui.permcenter.autostart.AutoStartManagementActivity"
                            )
                        })
                        result.success(null)
                    } catch (e: Exception) {
                        startActivity(
                            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                                data = Uri.parse("package:$packageName")
                            }
                        )
                        result.success(null)
                    }
                }
                "isBackgroundLocationGranted" -> {
                    val granted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        checkSelfPermission(android.Manifest.permission.ACCESS_BACKGROUND_LOCATION) ==
                            PackageManager.PERMISSION_GRANTED
                    } else {
                        true
                    }
                    result.success(granted)
                }
                "openLocationSettings" -> {
                    startActivity(
                        Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                            data = Uri.parse("package:$packageName")
                        }
                    )
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun startTrackingService() {
        try {
            val intent = Intent(this, LoneWalkerForegroundService::class.java)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                startForegroundService(intent)
            } else {
                startService(intent)
            }
            Log.d("MainActivity", "LoneWalkerForegroundService started")
        } catch (e: Exception) {
            Log.e("MainActivity", "Failed to start tracking service: ${e.message}", e)
        }
    }
}
