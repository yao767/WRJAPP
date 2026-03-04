class OperationSuggestion {
  const OperationSuggestion({
    required this.summary,
    required this.recommendedHeight,
    required this.recommendedSpeed,
    required this.recommendedAngle,
    required this.operationMode,
    required this.riskLevel,
  });

  final String summary;
  final double recommendedHeight;
  final double recommendedSpeed;
  final double recommendedAngle;
  final String operationMode;
  final String riskLevel;
}
