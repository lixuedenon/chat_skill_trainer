// lib/features/analysis/widgets/favorability_chart.dart

import 'package:flutter/material.dart';
import '../../../core/models/conversation_model.dart';

class FavorabilityChart extends StatelessWidget {
  final List<FavorabilityPoint> favorabilityHistory;

  const FavorabilityChart({
    Key? key,
    required this.favorabilityHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (favorabilityHistory.isEmpty) {
      return const Center(
        child: Text('暂无好感度数据'),
      );
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      child: CustomPaint(
        painter: FavorabilityChartPainter(favorabilityHistory),
        size: const Size.fromHeight(200),
      ),
    );
  }
}

class FavorabilityChartPainter extends CustomPainter {
  final List<FavorabilityPoint> data;

  FavorabilityChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final maxScore = 100;
    final minScore = 0;

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final y = size.height - ((data[i].score - minScore) / (maxScore - minScore)) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // 绘制数据点
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = Colors.blue);
    }

    canvas.drawPath(path, paint);

    // 绘制网格线
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    for (int i = 0; i <= 5; i++) {
      final y = (i / 5) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}