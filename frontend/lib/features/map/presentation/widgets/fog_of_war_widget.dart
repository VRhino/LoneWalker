import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../config/app_config.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/map_state.dart';

class FogOfWarWidget extends StatefulWidget {
  final MapLocation userLocation;
  final List<ExploredArea> exploredAreas;
  final double mapZoom;
  final GoogleMapController? mapController;
  final ChangeNotifier cameraNotifier;

  const FogOfWarWidget({
    super.key,
    required this.userLocation,
    required this.exploredAreas,
    required this.mapZoom,
    required this.mapController,
    required this.cameraNotifier,
  });

  @override
  State<FogOfWarWidget> createState() => _FogOfWarWidgetState();
}

class _FogOfWarWidgetState extends State<FogOfWarWidget> {
  List<Offset?> _exploredOffsets = [];
  Offset? _userOffset;

  @override
  void initState() {
    super.initState();
    widget.cameraNotifier.addListener(_computeOffsets);
    _computeOffsets();
  }

  @override
  void didUpdateWidget(FogOfWarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cameraNotifier != widget.cameraNotifier) {
      oldWidget.cameraNotifier.removeListener(_computeOffsets);
      widget.cameraNotifier.addListener(_computeOffsets);
    }
    if (oldWidget.mapController != widget.mapController ||
        oldWidget.exploredAreas != widget.exploredAreas ||
        oldWidget.userLocation != widget.userLocation ||
        oldWidget.mapZoom != widget.mapZoom) {
      _computeOffsets();
    }
  }

  @override
  void dispose() {
    widget.cameraNotifier.removeListener(_computeOffsets);
    super.dispose();
  }

  Future<void> _computeOffsets() async {
    final ctrl = widget.mapController;
    if (ctrl == null || !mounted) return;

    final ratio = MediaQuery.of(context).devicePixelRatio;
    final offsets = <Offset?>[];

    for (final area in widget.exploredAreas) {
      try {
        final sc = await ctrl.getScreenCoordinate(
          LatLng(area.latitude, area.longitude),
        );
        offsets.add(Offset(sc.x / ratio, sc.y / ratio));
      } catch (_) {
        offsets.add(null);
      }
    }

    Offset? userOff;
    try {
      final sc = await ctrl.getScreenCoordinate(
        LatLng(widget.userLocation.latitude, widget.userLocation.longitude),
      );
      userOff = Offset(sc.x / ratio, sc.y / ratio);
    } catch (_) {}

    if (mounted) {
      setState(() {
        _exploredOffsets = offsets;
        _userOffset = userOff;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: FogOfWarPainter(
          exploredOffsets: _exploredOffsets,
          userOffset: _userOffset,
          fogRadius: AppConfig.fogOfWarRadius * (widget.mapZoom / 15.0),
        ),
        size: Size.infinite,
      ),
    );
  }
}

class FogOfWarPainter extends CustomPainter {
  final List<Offset?> exploredOffsets;
  final Offset? userOffset;
  final double fogRadius;

  FogOfWarPainter({
    required this.exploredOffsets,
    required this.userOffset,
    required this.fogRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.black.withValues(alpha: 0.6),
    );

    final clearPaint = Paint()..blendMode = BlendMode.dstOut;
    for (final offset in exploredOffsets) {
      if (offset != null) {
        canvas.drawCircle(offset, fogRadius, clearPaint);
      }
    }

    if (userOffset != null) {
      canvas.drawCircle(userOffset!, fogRadius, clearPaint);
    }

    canvas.restore();

    _paintUserMarker(canvas);
  }

  void _paintUserMarker(Canvas canvas) {
    final offset = userOffset;
    if (offset == null) return;

    canvas.drawCircle(
      offset,
      12,
      Paint()
        ..color = AppTheme.primaryColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      offset,
      8,
      Paint()
        ..color = AppTheme.primaryColor
        ..style = PaintingStyle.fill,
    );

    canvas.drawCircle(
      offset,
      10,
      Paint()
        ..color = AppTheme.primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(FogOfWarPainter oldDelegate) {
    return oldDelegate.exploredOffsets != exploredOffsets ||
        oldDelegate.userOffset != userOffset ||
        oldDelegate.fogRadius != fogRadius;
  }
}
