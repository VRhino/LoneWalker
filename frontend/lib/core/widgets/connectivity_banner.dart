import 'package:flutter/material.dart';

import '../services/connectivity_service.dart';

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      initialData: ConnectivityService.instance.isOnline,
      stream: ConnectivityService.instance.isOnlineStream,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;
        if (isOnline) return const SizedBox.shrink();

        return Container(
          width: double.infinity,
          color: Colors.red.shade700,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Sin conexión — exploraciones guardadas localmente',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
