import 'dart:io';
import 'package:flutter/material.dart';
import '../services/permission_service.dart';
import '../theme/app_theme.dart';

class BackgroundPermissionDialog extends StatefulWidget {
  const BackgroundPermissionDialog({super.key});

  static Future<void> showIfNeeded(BuildContext context) async {
    if (!Platform.isAndroid) return;
    final shown = await PermissionService.wasOnboardingShown();
    if (shown) return;
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const BackgroundPermissionDialog(),
    );
  }

  @override
  State<BackgroundPermissionDialog> createState() =>
      _BackgroundPermissionDialogState();
}

class _BackgroundPermissionDialogState extends State<BackgroundPermissionDialog>
    with WidgetsBindingObserver {
  bool _isXiaomi = false;
  bool _batteryIgnored = false;
  bool _locationAlways = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshState();
    }
  }

  Future<void> _loadState() async {
    final results = await Future.wait([
      PermissionService.isXiaomiDevice(),
      PermissionService.isBatteryOptimizationIgnored(),
      PermissionService.isBackgroundLocationGranted(),
    ]);
    if (mounted) {
      setState(() {
        _isXiaomi = results[0];
        _batteryIgnored = results[1];
        _locationAlways = results[2];
        _loading = false;
      });
    }
  }

  Future<void> _refreshState() async {
    final results = await Future.wait([
      PermissionService.isBatteryOptimizationIgnored(),
      PermissionService.isBackgroundLocationGranted(),
    ]);
    if (mounted) {
      setState(() {
        _batteryIgnored = results[0];
        _locationAlways = results[1];
      });
    }
  }

  Future<void> _dismiss() async {
    await PermissionService.markOnboardingShown();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: _loading
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Row(
                    children: [
                      Icon(Icons.explore, color: AppTheme.primaryColor),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Activa el tracking en segundo plano',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Para que LoneWalker registre tu exploración cuando la pantalla está apagada, necesitas configurar estos permisos:',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  _PermissionStep(
                    icon: Icons.location_on,
                    title: 'Ubicación: Permitir siempre',
                    subtitle:
                        'En Permisos → Ubicación, selecciona "Permitir siempre" para que el GPS funcione en segundo plano.',
                    done: _locationAlways,
                    onTap: () async {
                      await PermissionService.openLocationSettings();
                    },
                  ),
                  const SizedBox(height: 12),
                  _PermissionStep(
                    icon: Icons.battery_charging_full,
                    title: 'Sin restricciones de batería',
                    subtitle:
                        'Permite que la app corra sin límites de consumo en segundo plano.',
                    done: _batteryIgnored,
                    onTap: () async {
                      await PermissionService.openBatterySettings();
                    },
                  ),
                  if (_isXiaomi) ...[
                    const SizedBox(height: 12),
                    _PermissionStep(
                      icon: Icons.security,
                      title: 'Inicio automático (MIUI)',
                      subtitle:
                          'Activa "Inicio automático" para LoneWalker en la app de Seguridad de Xiaomi.',
                      done: false,
                      onTap: () async {
                        await PermissionService.openAutoStartSettings();
                      },
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _dismiss,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Listo',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _PermissionStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool done;
  final VoidCallback onTap;

  const _PermissionStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: done
            ? Colors.green.withValues(alpha: 0.08)
            : Colors.grey.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              done ? Colors.green.withValues(alpha: 0.3) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : icon,
            color: done ? Colors.green : AppTheme.primaryColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          if (!done) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: const Text('Configurar',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ],
      ),
    );
  }
}
