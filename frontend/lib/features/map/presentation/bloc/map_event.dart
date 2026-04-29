import 'package:equatable/equatable.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class InitMapEvent extends MapEvent {
  const InitMapEvent();
}

class UpdateLocationEvent extends MapEvent {
  final double latitude;
  final double longitude;
  final double accuracy;
  final double speed;

  const UpdateLocationEvent({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.speed,
  });

  @override
  List<Object?> get props => [latitude, longitude, accuracy, speed];
}

class LoadFogEvent extends MapEvent {
  final double latitude;
  final double longitude;
  final double radius;

  const LoadFogEvent({
    required this.latitude,
    required this.longitude,
    required this.radius,
  });

  @override
  List<Object?> get props => [latitude, longitude, radius];
}

class LoadProgressEvent extends MapEvent {
  const LoadProgressEvent();
}

class RefreshMapEvent extends MapEvent {
  const RefreshMapEvent();
}

class ToggleExplorationSendingEvent extends MapEvent {
  final bool isEnabled;
  const ToggleExplorationSendingEvent({required this.isEnabled});

  @override
  List<Object?> get props => [isEnabled];
}
