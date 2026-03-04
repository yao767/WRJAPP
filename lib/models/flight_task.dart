import 'dart:convert';

class FlightTask {
  FlightTask({
    required this.taskType,
    required this.crop,
    required this.season,
    required this.takeoffMode,
    required this.operationMode,
    required this.landingMode,
    required this.height,
    required this.speed,
    required this.angle,
    required this.updatedAt,
  });

  final String taskType;
  final String crop;
  final String season;
  final String takeoffMode;
  final String operationMode;
  final String landingMode;
  final double height;
  final double speed;
  final double angle;
  final DateTime updatedAt;

  FlightTask copyWith({
    String? taskType,
    String? crop,
    String? season,
    String? takeoffMode,
    String? operationMode,
    String? landingMode,
    double? height,
    double? speed,
    double? angle,
    DateTime? updatedAt,
  }) {
    return FlightTask(
      taskType: taskType ?? this.taskType,
      crop: crop ?? this.crop,
      season: season ?? this.season,
      takeoffMode: takeoffMode ?? this.takeoffMode,
      operationMode: operationMode ?? this.operationMode,
      landingMode: landingMode ?? this.landingMode,
      height: height ?? this.height,
      speed: speed ?? this.speed,
      angle: angle ?? this.angle,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taskType': taskType,
      'crop': crop,
      'season': season,
      'takeoffMode': takeoffMode,
      'operationMode': operationMode,
      'landingMode': landingMode,
      'height': height,
      'speed': speed,
      'angle': angle,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FlightTask.fromMap(Map<String, dynamic> map) {
    return FlightTask(
      taskType: map['taskType'] as String,
      crop: map['crop'] as String,
      season: map['season'] as String,
      takeoffMode: map['takeoffMode'] as String,
      operationMode: map['operationMode'] as String,
      landingMode: map['landingMode'] as String,
      height: (map['height'] as num).toDouble(),
      speed: (map['speed'] as num).toDouble(),
      angle: (map['angle'] as num).toDouble(),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory FlightTask.fromJson(String source) =>
      FlightTask.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
