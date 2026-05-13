import 'dart:typed_data';
import 'package:fl_chart/fl_chart.dart';

class AnalysisResult {
  final double rollOvershoot;
  final double pitchOvershoot;
  final double yawOvershoot;
  final Map<String, Map<String, int>> recommendedPID;
  final String recommendation;
  final List<FlSpot> stepResponsePoints;

  AnalysisResult({
    required this.rollOvershoot,
    required this.pitchOvershoot,
    required this.yawOvershoot,
    required this.recommendedPID,
    required this.recommendation,
    required this.stepResponsePoints,
  });
}

class LogAnalyzer {
  /// 分析黑盒日志
  static Future<AnalysisResult> analyze(Uint8List bytes) async {
    // 模拟分析过程（实际实现需要解析 .bbl 文件）
    // 这里提供一个简化版本，实际使用时需要集成完整的解析器
    
    await Future.delayed(const Duration(seconds: 2)); // 模拟处理时间

    // 模拟数据（实际应从日志解析）
    final rollOvershoot = 12.5;
    final pitchOvershoot = 8.3;
    final yawOvershoot = 5.2;

    // 生成模拟阶跃响应曲线
    final stepResponsePoints = _generateStepResponse();

    // 根据 Overshoot 计算 PID 建议
    final recommendedPID = _calculateRecommendedPID(
      rollOvershoot,
      pitchOvershoot,
      yawOvershoot,
    );

    // 生成建议文本
    final recommendation = _generateRecommendation(
      rollOvershoot,
      pitchOvershoot,
      yawOvershoot,
    );

    return AnalysisResult(
      rollOvershoot: rollOvershoot,
      pitchOvershoot: pitchOvershoot,
      yawOvershoot: yawOvershoot,
      recommendedPID: recommendedPID,
      recommendation: recommendation,
      stepResponsePoints: stepResponsePoints,
    );
  }

  /// 生成模拟阶跃响应曲线
  static List<FlSpot> _generateStepResponse() {
    final points = <FlSpot>[];
    for (int i = 0; i <= 100; i++) {
      final t = i * 3.0; // 0-300ms
      double y;
      if (i < 10) {
        y = i / 10.0; // 上升段
      } else if (i < 20) {
        y = 1.0 + (i - 10) * 0.02; // 超调段
      } else {
        y = 1.0 + 0.2 * (1 - (i - 20) / 80.0); // 衰减段
      }
      points.add(FlSpot(t, y));
    }
    return points;
  }

  /// 根据超调计算推荐 PID
  static Map<String, Map<String, int>> _calculateRecommendedPID(
    double rollOvershoot,
    double pitchOvershoot,
    double yawOvershoot,
  ) {
    // 简化的调参逻辑
    // 实际应根据完整的阶跃响应分析
    
    return {
      'roll': {
        'P': _adjustP(45, rollOvershoot),
        'I': 30,
        'D': _adjustD(30, rollOvershoot),
        'FF': 50,
      },
      'pitch': {
        'P': _adjustP(47, pitchOvershoot),
        'I': 32,
        'D': _adjustD(32, pitchOvershoot),
        'FF': 52,
      },
      'yaw': {
        'P': _adjustP(45, yawOvershoot),
        'I': 30,
        'D': _adjustD(28, yawOvershoot),
        'FF': 60,
      },
    };
  }

  /// 调整 P 值
  static int _adjustP(int baseP, double overshoot) {
    if (overshoot > 15) {
      return baseP - 8;
    } else if (overshoot > 10) {
      return baseP - 5;
    } else if (overshoot < 5) {
      return baseP + 3;
    }
    return baseP;
  }

  /// 调整 D 值
  static int _adjustD(int baseD, double overshoot) {
    if (overshoot > 15) {
      return baseD + 10;
    } else if (overshoot > 10) {
      return baseD + 5;
    }
    return baseD;
  }

  /// 生成调参建议
  static String _generateRecommendation(
    double rollOvershoot,
    double pitchOvershoot,
    double yawOvershoot,
  ) {
    final buffer = StringBuffer();

    if (rollOvershoot > 10 || pitchOvershoot > 10 || yawOvershoot > 10) {
      buffer.writeln('⚠️ 存在明显超调，建议：');
      
      if (rollOvershoot > 10) {
        buffer.writeln('• Roll: 降 P 或加 D');
      }
      if (pitchOvershoot > 10) {
        buffer.writeln('• Pitch: 降 P 或加 D');
      }
      if (yawOvershoot > 10) {
        buffer.writeln('• Yaw: 降 P 或加 D');
      }
    } else {
      buffer.writeln('✅ 超调在合理范围内');
    }

    buffer.writeln();
    buffer.writeln('📋 调参口诀：');
    buffer.writeln('机械先行，P 打基础，D 控过冲，');
    buffer.writeln('FF 追跟随，I 保稳定，滤波最后动。');

    return buffer.toString();
  }
}