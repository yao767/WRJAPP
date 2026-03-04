import '../models/operation_suggestion.dart';

class SuggestionService {
  OperationSuggestion generateSuggestion({
    required String crop,
    required String season,
    required String taskType,
    required double humidity,
    required double rainfall,
    required double sunshine,
  }) {
    var height = 2.5;
    var speed = 4.0;
    var angle = 35.0;
    var mode = '标准喷洒';
    var risk = '低';

    if (crop == '水稻') {
      height += 0.4;
      speed -= 0.3;
    }
    if (crop == '果树') {
      height += 1.0;
      speed -= 0.8;
      angle += 10;
    }

    if (season == '夏季') {
      speed -= 0.4;
      angle += 3;
    }
    if (season == '冬季') {
      height -= 0.3;
      speed += 0.2;
    }

    if (humidity > 80 || rainfall > 30) {
      mode = '低漂移精细喷洒';
      speed -= 0.5;
      risk = '中';
    }

    if (sunshine < 3) {
      angle -= 2;
      risk = risk == '中' ? '中高' : '中';
    }

    if (taskType == '除草') {
      speed += 0.3;
    } else if (taskType == '杀菌') {
      angle += 2;
    }

    final summary =
        '结合$currentSeasonLabel($season)的作物状态与环境因素，建议采用$mode；注意风速与湿度变化并动态调整喷幅。';

    return OperationSuggestion(
      summary: summary,
      recommendedHeight: height.clamp(1.5, 6.0),
      recommendedSpeed: speed.clamp(2.0, 7.0),
      recommendedAngle: angle.clamp(20.0, 60.0),
      operationMode: mode,
      riskLevel: risk,
    );
  }

  String get currentSeasonLabel => '当前时节';
}
