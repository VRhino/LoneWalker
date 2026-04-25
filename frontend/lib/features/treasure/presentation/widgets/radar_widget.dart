import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../config/app_config.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../data/models/treasure_model.dart';
import '../utils/treasure_rarity_colors.dart';

class RadarWidget extends StatefulWidget {
  final List<RadarTreasureModel> treasures;
  final double userLatitude;
  final double userLongitude;
  final void Function(RadarTreasureModel)? onTreasureTap;

  const RadarWidget({
    super.key,
    required this.treasures,
    required this.userLatitude,
    required this.userLongitude,
    this.onTreasureTap,
  });

  @override
  State<RadarWidget> createState() => _RadarWidgetState();
}

class _RadarWidgetState extends State<RadarWidget> {
  late Stream<Position> positionStream;
  double heading = 0;

  @override
  void initState() {
    super.initState();
    _initHeadingStream();
  }

  void _initHeadingStream() {
    positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Position>(
      stream: positionStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final position = snapshot.data!;
          heading = position.heading;
        }

        return Center(
          child: SizedBox(
            width: AppDimensions.radarWidgetSize,
            height: AppDimensions.radarWidgetSize,
            child: CustomPaint(
              painter: RadarPainter(
                treasures: widget.treasures,
                heading: heading,
                proximityPercents:
                    widget.treasures.map((t) => t.proximityPercent).toList(),
              ),
              child: _buildTreasureMarkers(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTreasureMarkers() {
    const radarRadius = AppDimensions.radarBaseRadius;
    const maxDistance = AppConfig.radarDisplayRadiusMeters;

    return Stack(
      alignment: Alignment.center,
      children: [
        ...widget.treasures.map((treasure) {
          final angle = (treasure.bearingDegrees - heading) * (math.pi / 180);
          final distance = treasure.distanceMeters;
          final radarDist = (distance / maxDistance) * radarRadius;

          final x = radarDist * math.sin(angle);
          final y = -radarDist * math.cos(angle);

          final color =
              TreasureRarityColors.proximityColor(treasure.proximityPercent);

          return Positioned(
            left: radarRadius + x - AppDimensions.radarMarkerOffset,
            top: radarRadius + y - AppDimensions.radarMarkerOffset,
            child: GestureDetector(
              onTap: widget.onTreasureTap != null
                  ? () => widget.onTreasureTap!(treasure)
                  : null,
              child: Container(
                width: AppDimensions.radarMarkerSize,
                height: AppDimensions.radarMarkerSize,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    treasure.title[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
        // North indicator
        Positioned(
          top: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'N',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class RadarPainter extends CustomPainter {
  final List<RadarTreasureModel> treasures;
  final double heading;
  final List<double> proximityPercents;

  RadarPainter({
    required this.treasures,
    required this.heading,
    required this.proximityPercents,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const baseRadius = AppDimensions.radarBaseRadius;

    // Draw background
    canvas.drawCircle(
      center,
      baseRadius,
      Paint()
        ..color = Colors.grey[900]!.withValues(alpha: 0.8)
        ..style = PaintingStyle.fill,
    );

    // Draw concentric circles
    for (int i = 1; i <= AppDimensions.radarConcentricCircleCount; i++) {
      canvas.drawCircle(
        center,
        baseRadius * (i / AppDimensions.radarConcentricCircleCount),
        Paint()
          ..color = Colors.grey[700]!.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    // Draw cardinal directions
    _drawCardinalDirections(canvas, center, baseRadius);

    // Draw compass rose (rotation indicator)
    _drawCompassRose(canvas, center, baseRadius, heading);

    // Draw grid lines
    _drawGridLines(canvas, center, baseRadius);
  }

  void _drawCardinalDirections(Canvas canvas, Offset center, double radius) {
    const directions = ['N', 'E', 'S', 'W'];
    const angles = [0, 90, 180, 270];

    for (int i = 0; i < 4; i++) {
      final angle = angles[i] * (math.pi / 180);
      final offset = Offset(
        center.dx + radius * math.sin(angle),
        center.dy - radius * math.cos(angle),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        offset - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  void _drawCompassRose(
      Canvas canvas, Offset center, double radius, double heading) {
    final angle = heading * (math.pi / 180);
    final arrowRadius = radius - AppDimensions.radarCompassArrowInset;

    // North arrow
    final northEnd = Offset(
      center.dx + arrowRadius * math.sin(angle),
      center.dy - arrowRadius * math.cos(angle),
    );

    canvas.drawLine(
      center,
      northEnd,
      Paint()
        ..color = Colors.red
        ..strokeWidth = 3,
    );

    // South indicator
    final southEnd = Offset(
      center.dx - arrowRadius * math.sin(angle),
      center.dy + arrowRadius * math.cos(angle),
    );

    canvas.drawLine(
      center,
      southEnd,
      Paint()
        ..color = Colors.red.withValues(alpha: 0.5)
        ..strokeWidth = 2,
    );
  }

  void _drawGridLines(Canvas canvas, Offset center, double radius) {
    const gridLines = AppDimensions.radarGridLineCount;

    for (int i = 0; i < gridLines; i++) {
      final angle = (i * 360 / gridLines) * (math.pi / 180);

      final start = Offset(
        center.dx + radius * math.sin(angle),
        center.dy - radius * math.cos(angle),
      );

      final end = Offset(
        center.dx - radius * math.sin(angle),
        center.dy + radius * math.cos(angle),
      );

      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = Colors.grey[700]!.withValues(alpha: 0.2)
          ..strokeWidth = 0.5,
      );
    }
  }

  @override
  bool shouldRepaint(RadarPainter oldDelegate) {
    return oldDelegate.heading != heading ||
        oldDelegate.treasures.length != treasures.length ||
        oldDelegate.proximityPercents != proximityPercents;
  }
}
