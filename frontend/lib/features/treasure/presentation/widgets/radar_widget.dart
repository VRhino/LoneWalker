import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/treasure_model.dart';

class RadarWidget extends StatefulWidget {
  final List<RadarTreasureModel> treasures;
  final double userLatitude;
  final double userLongitude;
  final VoidCallback? onTreasureTap;

  const RadarWidget({
    Key? key,
    required this.treasures,
    required this.userLatitude,
    required this.userLongitude,
    this.onTreasureTap,
  }) : super(key: key);

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
            width: 300,
            height: 300,
            child: CustomPaint(
              painter: RadarPainter(
                treasures: widget.treasures,
                heading: heading,
                proximityPercents: widget.treasures
                    .map((t) => t.proximityPercent)
                    .toList(),
              ),
              child: _buildTreasureMarkers(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTreasureMarkers() {
    const radarRadius = 150.0;
    const maxDistance = 1000.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        ...widget.treasures.map((treasure) {
          final angle = (treasure.bearingDegrees - heading) * (3.14159 / 180);
          final distance = treasure.distanceMeters;
          final radarDist = (distance / maxDistance) * radarRadius;

          final x = radarDist * Math.sin(angle);
          final y = -radarDist * Math.cos(angle);

          final color = _getColorForRarity(treasure.rarity, treasure.proximityPercent);

          return Positioned(
            left: 150 + x - 12,
            top: 150 + y - 12,
            child: GestureDetector(
              onTap: widget.onTreasureTap,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.5),
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
        }).toList(),
        // North indicator
        Positioned(
          top: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.7),
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

  Color _getColorForRarity(TreasureRarity rarity, double proximityPercent) {
    Color baseColor;

    switch (rarity) {
      case TreasureRarity.common:
        baseColor = Colors.grey[400]!;
        break;
      case TreasureRarity.uncommon:
        baseColor = Colors.green;
        break;
      case TreasureRarity.rare:
        baseColor = Colors.blue;
        break;
      case TreasureRarity.epic:
        baseColor = Colors.purple;
        break;
      case TreasureRarity.legendary:
        baseColor = Colors.orange;
        break;
    }

    // Interpolate between blue (cold) and red (hot) based on proximity
    if (proximityPercent < 50) {
      // Cold colors (blue)
      return Color.lerp(Colors.blue, Colors.cyan, proximityPercent / 50)!;
    } else {
      // Hot colors (red)
      return Color.lerp(Colors.yellow, Colors.red, (proximityPercent - 50) / 50)!;
    }
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
    final baseRadius = 150.0;

    // Draw background
    canvas.drawCircle(
      center,
      baseRadius,
      Paint()
        ..color = Colors.grey[900]!.withOpacity(0.8)
        ..style = PaintingStyle.fill,
    );

    // Draw concentric circles
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(
        center,
        baseRadius * (i / 3),
        Paint()
          ..color = Colors.grey[700]!.withOpacity(0.3)
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
      final angle = angles[i] * (3.14159 / 180);
      final offset = Offset(
        center.dx + radius * Math.sin(angle),
        center.dy - radius * Math.cos(angle),
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
        offset - Offset(textPainter.width / 2, textPainter.height / 2),
      );
    }
  }

  void _drawCompassRose(Canvas canvas, Offset center, double radius, double heading) {
    final angle = heading * (3.14159 / 180);

    // North arrow
    final northEnd = Offset(
      center.dx + (radius - 20) * Math.sin(angle),
      center.dy - (radius - 20) * Math.cos(angle),
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
      center.dx - (radius - 20) * Math.sin(angle),
      center.dy + (radius - 20) * Math.cos(angle),
    );

    canvas.drawLine(
      center,
      southEnd,
      Paint()
        ..color = Colors.red.withOpacity(0.5)
        ..strokeWidth = 2,
    );
  }

  void _drawGridLines(Canvas canvas, Offset center, double radius) {
    const gridLines = 8;

    for (int i = 0; i < gridLines; i++) {
      final angle = (i * 360 / gridLines) * (3.14159 / 180);

      final start = Offset(
        center.dx + radius * Math.sin(angle),
        center.dy - radius * Math.cos(angle),
      );

      final end = Offset(
        center.dx - radius * Math.sin(angle),
        center.dy + radius * Math.cos(angle),
      );

      canvas.drawLine(
        start,
        end,
        Paint()
          ..color = Colors.grey[700]!.withOpacity(0.2)
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

class Math {
  static double sin(double x) => math.sin(x);
  static double cos(double x) => math.cos(x);
}

import 'dart:math' as math;
