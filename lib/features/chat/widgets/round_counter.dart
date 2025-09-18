// 2. lib/features/chat/widgets/round_counter.dart (修复导入路径)

import 'package:flutter/material.dart';
import '../../../core/utils/round_calculator.dart';

class RoundCounter extends StatelessWidget {
  final int actualRounds;
  final int effectiveRounds;
  final RoundStatus status;
  final double averageCharsPerRound;

  const RoundCounter({
    Key? key,
    required this.actualRounds,
    required this.effectiveRounds,
    required this.status,
    required this.averageCharsPerRound,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = RoundCalculator.calculateProgress(effectiveRounds);
    final statusColor = _getStatusColor(status);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.chat_bubble_outline, size: 16, color: statusColor),
              const SizedBox(width: 4),
              Text('轮数进度', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const Spacer(),
              Text('$effectiveRounds/${RoundCalculator.MAX_ROUNDS}',
                   style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: statusColor)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            minHeight: 4,
          ),
          const SizedBox(height: 4),
          Text(
            RoundCalculator.getPhaseDescription(effectiveRounds),
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(RoundStatus status) {
    switch (status) {
      case RoundStatus.early:
        return Colors.green;
      case RoundStatus.perfect:
        return Colors.blue;
      case RoundStatus.acceptable:
        return Colors.orange;
      case RoundStatus.warning:
        return Colors.red;
      case RoundStatus.forcedEnd:
        return Colors.purple;
    }
  }
}