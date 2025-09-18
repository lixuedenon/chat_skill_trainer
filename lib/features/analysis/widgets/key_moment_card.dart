// lib/features/analysis/widgets/key_moment_card.dart

import 'package:flutter/material.dart';
import '../../../core/models/analysis_model.dart';

class KeyMomentCard extends StatelessWidget {
  final KeyMoment moment;

  const KeyMomentCard({
    Key? key,
    required this.moment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTypeColor(moment.type),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    moment.typeName,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const Spacer(),
                Text('第${moment.round}轮', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('原始回复:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red[700])),
                  const SizedBox(height: 4),
                  Text(moment.originalMessage),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('建议改为:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[700])),
                  const SizedBox(height: 4),
                  Text(moment.improvedMessage),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              moment.explanation,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeColor(MomentType type) {
    switch (type) {
      case MomentType.breakthrough:
        return Colors.green;
      case MomentType.perfectResponse:
        return Colors.blue;
      case MomentType.missedOpportunity:
        return Colors.orange;
      case MomentType.mistake:
        return Colors.red;
    }
  }
}