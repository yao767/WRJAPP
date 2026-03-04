import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class SuggestionPage extends StatelessWidget {
  const SuggestionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final suggestion = context.watch<AppState>().latestSuggestion;

    if (suggestion == null) {
      return const Center(
        child: Text('暂无建议，请先在主页面创建任务并点击“一键建议”'),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('当前时节综合作业建议', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('建议摘要：${suggestion.summary}'),
              const SizedBox(height: 8),
              Text('风险等级：${suggestion.riskLevel}'),
              Text('推荐运作模式：${suggestion.operationMode}'),
              Text('推荐高度：${suggestion.recommendedHeight.toStringAsFixed(1)} m'),
              Text('推荐速度：${suggestion.recommendedSpeed.toStringAsFixed(1)} m/s'),
              Text('推荐角度：${suggestion.recommendedAngle.toStringAsFixed(0)} °'),
            ],
          ),
        ),
      ),
    );
  }
}
