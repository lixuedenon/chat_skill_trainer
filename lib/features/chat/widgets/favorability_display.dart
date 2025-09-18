// lib/features/chat/widgets/favorability_display.dart

import 'package:flutter/material.dart';
import '../../../core/models/conversation_model.dart';
import '../../../core/models/character_model.dart';
import '../../../core/utils/theme_manager.dart';

class FavorabilityDisplay extends StatelessWidget {
  final int currentFavorability;
  final List<FavorabilityPoint> favorabilityHistory;
  final CharacterModel character;

  const FavorabilityDisplay({
    Key? key,
    required this.currentFavorability,
    required this.favorabilityHistory,
    required this.character,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favorabilityColor = ThemeManager.getFavorabilityColor(
      currentFavorability,
      ThemeManager.currentTheme,
    );
    final recentChange = _getRecentChange();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: favorabilityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: favorabilityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 好感度标题和数值
          Row(
            children: [
              Icon(
                _getFavorabilityIcon(currentFavorability),
                color: favorabilityColor,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '好感度',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const Spacer(),
              Text(
                '$currentFavorability',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: favorabilityColor,
                ),
              ),
              if (recentChange != 0) ...[
                const SizedBox(width: 4),
                _buildChangeIndicator(recentChange),
              ],
            ],
          ),

          const SizedBox(height: 6),

          // 好感度进度条
          _buildFavorabilityBar(favorabilityColor),

          const SizedBox(height: 4),

          // 好感度等级描述
          Text(
            _getFavorabilityDescription(currentFavorability),
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建好感度进度条
  Widget _buildFavorabilityBar(Color favorabilityColor) {
    final progress = (currentFavorability / 100.0).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(favorabilityColor),
                minHeight: 6,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 10,
                color: favorabilityColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '冷淡',
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[500],
              ),
            ),
            Text(
              '喜欢',
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建变化指示器
  Widget _buildChangeIndicator(int change) {
    final isPositive = change > 0;
    final color = isPositive ? Colors.green[600] : Colors.red[600];
    final icon = isPositive ? Icons.arrow_upward : Icons.arrow_downward;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color!.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 12,
          ),
          Text(
            '${change.abs()}',
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// 获取最近的好感度变化
  int _getRecentChange() {
    if (favorabilityHistory.length < 2) return 0;

    final latest = favorabilityHistory.last;
    final previous = favorabilityHistory[favorabilityHistory.length - 2];

    return latest.score - previous.score;
  }

  /// 根据好感度获取图标
  IconData _getFavorabilityIcon(int favorability) {
    if (favorability >= 80) {
      return Icons.favorite;
    } else if (favorability >= 60) {
      return Icons.favorite_border;
    } else if (favorability >= 40) {
      return Icons.sentiment_satisfied;
    } else if (favorability >= 20) {
      return Icons.sentiment_neutral;
    } else {
      return Icons.sentiment_dissatisfied;
    }
  }

  /// 获取好感度描述
  String _getFavorabilityDescription(int favorability) {
    if (favorability >= 80) {
      return '${character.name}很喜欢你';
    } else if (favorability >= 60) {
      return '${character.name}对你有好感';
    } else if (favorability >= 40) {
      return '${character.name}觉得你不错';
    } else if (favorability >= 20) {
      return '${character.name}对你印象一般';
    } else {
      return '${character.name}对你还不太了解';
    }
  }
}