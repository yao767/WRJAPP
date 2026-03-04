import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('护花使者——植保无人机适配系统', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('版本：0.1.0 MVP'),
          Text('联系方式：support@guardian-app.local'),
          SizedBox(height: 10),
          Text('使用说明：'),
          Text('1. 登录后在主页面点击“+”添加飞行任务。'),
          Text('2. 配置任务类型、飞行参数与环境因子。'),
          Text('3. 点击“一键建议”获取当前时节综合作业建议。'),
          Text('4. 在设置页面进行全局参数与蓝牙连接。'),
          SizedBox(height: 12),
          Text('说明：当前飞控协议尚未接入，已预留连接与参数下发接口。'),
        ],
      ),
    );
  }
}
