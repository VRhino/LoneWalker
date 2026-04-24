import 'package:flutter/material.dart';
import '../../../../config/app_config.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/map_state.dart';

/// Fog of War Widget
/// Paints explored areas on a canvas overlay
class FogOfWarWidget extends StatelessWidget {
  final MapLocation userLocation;
  final List<dynamic> exploredAreas;
  final double mapZoom;
  final Size canvasSize;

  const FogOfWarWidget({
    Key? key,
    required this.userLocation,
    required this.exploredAreas,
    required this.mapZoom,
    required this.canvasSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: FogOfWarPainter(
        userLocation: userLocation,
        exploredAreas: exploredAreas,
        mapZoom: mapZoom,
      ),
      size: canvasSize,
    );
  }
}

/// Custom painter for fog of war
class FogOfWarPainter extends CustomPainter {
  final MapLocation userLocation;
  final List<dynamic> exploredAreas;
  final double mapZoom;

  FogOfWarPainter({
    required this.userLocation,
    required this.exploredAreas,
    required this.mapZoom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Paint fog of war (dark overlay)
    _paintFogOfWar(canvas, size);

    // Paint explored areas (cleared)
    _paintExploredAreas(canvas, size);

    // Paint user location marker
    _paintUserMarker(canvas, size);
  }

  void _paintFogOfWar(Canvas canvas, Size size) {
    final fogPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // Cover entire canvas with fog
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      fogPaint,
    );
  }

  void _paintExploredAreas(Canvas canvas, Size size) {
    final gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.4),
          Colors.black.withValues(alpha: 0.6),
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(
        Rect.fromCircle(
          center: const Offset(0, 0),
          radius: AppConfig.fogOfWarRadius * mapZoom,
        ),
      );

    // Draw cleared areas (circles around explored points)
    for (final area in exploredAreas) {
      if (area is Map) {
        final lat = area['latitude'] as double?;
        final lng = area['longitude'] as double?;

        if (lat != null && lng != null) {
          final offset = _latLngToOffset(lat, lng, size);
          if (offset != null) {
            // Clear fog with gradient effect
            canvas.drawCircle(
              offset,
              AppConfig.fogOfWarRadius * mapZoom,
              gradientPaint,
            );
          }
        }
      }
    }
  }

  void _paintUserMarker(Canvas canvas, Size size) {
    final offset = _latLngToOffset(
      userLocation.latitude,
      userLocation.longitude,
      size,
    );

    if (offset != null) {
      // Outer circle (light)
      canvas.drawCircle(
        offset,
        12 * mapZoom,
        Paint()
          ..color = AppTheme.primaryColor.withValues(alpha: 0.3)
          ..style = PaintingStyle.fill,
      );

      // Inner circle (solid)
      canvas.drawCircle(
        offset,
        8 * mapZoom,
        Paint()
          ..color = AppTheme.primaryColor
          ..style = PaintingStyle.fill,
      );

      // Pulse animation effect (border)
      canvas.drawCircle(
        offset,
        10 * mapZoom,
        Paint()
          ..color = AppTheme.primaryColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  /// Convert lat/lng to canvas offset (simplified)
  Offset? _latLngToOffset(double lat, double lng, Size size) {
    // This is simplified - in production, use proper map projection
    // For now, return center if coordinates match user location (approximately)
    final latDiff = (lat - userLocation.latitude).abs();
    final lngDiff = (lng - userLocation.longitude).abs();

    if (latDiff < AppDimensions.latLngMatchThreshold && lngDiff < AppDimensions.latLngMatchThreshold) {
      return Offset(size.width / 2, size.height / 2);
    }

    return null;
  }

  @override
  bool shouldRepaint(FogOfWarPainter oldDelegate) {
    return oldDelegate.userLocation != userLocation ||
        oldDelegate.exploredAreas != exploredAreas ||
        oldDelegate.mapZoom != mapZoom;
  }
}
