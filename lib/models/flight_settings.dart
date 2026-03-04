import 'dart:convert';

class FlightSettings {
  const FlightSettings({
    required this.workMode,
    required this.height,
    required this.speed,
    required this.angle,
  });

  final String workMode;
  final double height;
  final double speed;
  final double angle;

  static const defaults = FlightSettings(
    workMode: '标准模式',
    height: 2.5,
    speed: 4.0,
    angle: 35.0,
  );

  FlightSettings copyWith({
    String? workMode,
    double? height,
    double? speed,
    double? angle,
  }) {
    return FlightSettings(
      workMode: workMode ?? this.workMode,
      height: height ?? this.height,
      speed: speed ?? this.speed,
      angle: angle ?? this.angle,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'workMode': workMode,
      'height': height,
      'speed': speed,
      'angle': angle,
    };
  }

  factory FlightSettings.fromMap(Map<String, dynamic> map) {
    return FlightSettings(
      workMode: map['workMode'] as String,
      height: (map['height'] as num).toDouble(),
      speed: (map['speed'] as num).toDouble(),
      angle: (map['angle'] as num).toDouble(),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory FlightSettings.fromJson(String source) =>
      FlightSettings.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
