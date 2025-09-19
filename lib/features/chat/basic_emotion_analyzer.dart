// lib/features/chat/basic_emotion_analyzer.dart

import '../../core/models/conversation_model.dart';
import '../../core/models/character_model.dart';

/// 基础情感分析器 - 生成情感轨迹报告
class BasicEmotionAnalyzer {
  /// 分析单轮对话的情感变化
  static EmotionalTurningPoint analyzeRound({
    required MessageModel userMessage,
    required MessageModel aiResponse,
    required int roundNumber,
    required int favorabilityBefore,
    required int favorabilityAfter,
  }) {
    final change = favorabilityAfter - favorabilityBefore;
    final changeType = _determineChangeType(change);

    return EmotionalTurningPoint(
      minute: roundNumber * 2, // 假设每轮对话2分钟
      roundNumber: roundNumber,
      scoreBefore: favorabilityBefore,
      scoreAfter: favorabilityAfter,
      scoreChange: change,
      userMessage: userMessage.content,
      aiResponse: aiResponse.content,
      changeType: changeType,
      reason: _generateChangeReason(userMessage.content, change, changeType),
      learningPoint: _generateLearningPoint(userMessage.content, change, changeType),
      timestamp: userMessage.timestamp,
    );
  }

  /// 生成完整的情感轨迹报告
  static EmotionalTrajectoryReport generateTrajectoryReport(
    ConversationModel conversation,
    CharacterModel character,
  ) {
    final turningPoints = <EmotionalTurningPoint>[];
    final messages = conversation.messages;
    final favorabilityHistory = conversation.metrics.favorabilityHistory;

    // 分析每轮对话的情感变化
    for (int i = 0; i < messages.length - 1; i += 2) {
      if (i + 1 < messages.length && messages[i].isUser) {
        final userMessage = messages[i];
        final aiMessage = messages[i + 1];
        final roundNumber = (i ~/ 2) + 1;

        // 获取好感度变化
        int favorabilityBefore = 10; // 默认初始值
        int favorabilityAfter = 10;

        if (favorabilityHistory.isNotEmpty) {
          final beforePoint = favorabilityHistory
              .where((p) => p.round < roundNumber)
              .lastOrNull;
          final afterPoint = favorabilityHistory
              .where((p) => p.round == roundNumber)
              .firstOrNull;

          favorabilityBefore = beforePoint?.score ?? 10;
          favorabilityAfter = afterPoint?.score ?? favorabilityBefore;
        }

        final turningPoint = analyzeRound(
          userMessage: userMessage,
          aiResponse: aiMessage,
          roundNumber: roundNumber,
          favorabilityBefore: favorabilityBefore,
          favorabilityAfter: favorabilityAfter,
        );

        turningPoints.add(turningPoint);
      }
    }

    return EmotionalTrajectoryReport(
      conversationId: conversation.id,
      characterId: character.id,
      characterName: character.name,
      totalDuration: conversation.durationInMinutes,
      initialScore: 10,
      finalScore: conversation.metrics.currentFavorability,
      totalGain: conversation.metrics.currentFavorability - 10,
      turningPoints: turningPoints,
      overallAssessment: _generateOverallAssessment(
        conversation.metrics.currentFavorability,
        turningPoints.length,
        character,
      ),
      keyInsights: _generateKeyInsights(turningPoints, character),
      createdAt: DateTime.now(),
    );
  }

  /// 确定情感变化类型
  static EmotionalChangeType _determineChangeType(int change) {
    if (change >= 8) return EmotionalChangeType.breakthrough;
    if (change >= 3) return EmotionalChangeType.positive;
    if (change >= -2) return EmotionalChangeType.neutral;
    if (change >= -5) return EmotionalChangeType.negative;
    return EmotionalChangeType.critical;
  }

  /// 生成变化原因
  static String _generateChangeReason(String userMessage, int change, EmotionalChangeType type) {
    final keywords = _extractKeywords(userMessage);

    switch (type) {
      case EmotionalChangeType.breakthrough:
        return '你的回应非常恰当，${keywords.isNotEmpty ? '特别是提到"${keywords.first}"' : '展现了高情商'}';
      case EmotionalChangeType.positive:
        return '${keywords.isNotEmpty ? '你对"${keywords.first}"的关注' : '你的表达方式'}让她感到被理解';
      case EmotionalChangeType.neutral:
        return '对话进展平稳，${keywords.isNotEmpty ? '关于"${keywords.first}"的话题' : '你的回应'}比较中性';
      case EmotionalChangeType.negative:
        return '${keywords.isNotEmpty ? '"${keywords.first}"这个话题' : '你的回应方式'}可能让她有些不适';
      case EmotionalChangeType.critical:
        return '这次回应明显降低了好感度，需要注意表达方式';
    }
  }

  /// 生成学习要点
  static String _generateLearningPoint(String userMessage, int change, EmotionalChangeType type) {
    switch (type) {
      case EmotionalChangeType.breakthrough:
        return '保持这种回应方式，继续展现你的魅力';
      case EmotionalChangeType.positive:
        return '这种积极的交流方式很好，可以多使用';
      case EmotionalChangeType.neutral:
        return '可以尝试更深入的话题或表达更多关心';
      case EmotionalChangeType.negative:
        return '需要调整表达方式，多考虑对方的感受';
      case EmotionalChangeType.critical:
        return '避免类似的表达方式，学习更合适的回应';
    }
  }

  /// 生成总体评价
  static String _generateOverallAssessment(int finalScore, int totalRounds, CharacterModel character) {
    final improvement = finalScore - 10;

    if (improvement >= 50) {
      return '表现优秀！你和${character.name}的对话非常成功，展现了很好的沟通技巧。';
    } else if (improvement >= 30) {
      return '表现良好！你成功提升了${character.name}对你的好感，还有继续进步的空间。';
    } else if (improvement >= 10) {
      return '表现不错，你和${character.name}建立了基本的好感，可以尝试更深入的交流。';
    } else if (improvement >= 0) {
      return '表现一般，虽然没有降低好感度，但需要更多练习来提升沟通效果。';
    } else {
      return '需要改进，建议多练习基础的沟通技巧，注意对方的反应和感受。';
    }
  }

  /// 生成关键洞察
  static List<String> _generateKeyInsights(List<EmotionalTurningPoint> turningPoints, CharacterModel character) {
    final insights = <String>[];

    // 分析最成功的时刻
    final bestMoments = turningPoints
        .where((p) => p.scoreChange >= 5)
        .toList()
      ..sort((a, b) => b.scoreChange.compareTo(a.scoreChange));

    if (bestMoments.isNotEmpty) {
      insights.add('最成功的时刻：${bestMoments.first.reason}');
    }

    // 分析需要改进的地方
    final worstMoments = turningPoints
        .where((p) => p.scoreChange < 0)
        .toList()
      ..sort((a, b) => a.scoreChange.compareTo(b.scoreChange));

    if (worstMoments.isNotEmpty) {
      insights.add('需要注意：${worstMoments.first.reason}');
    }

    // 基于角色特点的建议
    insights.add(_getCharacterSpecificInsight(character, turningPoints));

    return insights;
  }

  /// 获取角色特定的洞察
  static String _getCharacterSpecificInsight(CharacterModel character, List<EmotionalTurningPoint> turningPoints) {
    switch (character.type) {
      case CharacterType.gentle:
        return '${character.name}重视温暖和理解，继续展现你的关心和体贴';
      case CharacterType.lively:
        return '${character.name}喜欢有趣的话题，可以多分享一些有趣的经历';
      case CharacterType.elegant:
        return '${character.name}重视有深度的交流，尝试讨论更有内涵的话题';
      default:
        return '继续保持真诚的交流方式，了解对方的兴趣和想法';
    }
  }

  /// 提取关键词
  static List<String> _extractKeywords(String message) {
    final keywords = <String>[];
    final commonKeywords = ['工作', '爱好', '家庭', '朋友', '旅行', '电影', '音乐', '书籍'];

    for (final keyword in commonKeywords) {
      if (message.contains(keyword)) {
        keywords.add(keyword);
      }
    }

    return keywords;
  }
}

/// 情感转折点
class EmotionalTurningPoint {
  final int minute;              // 发生时间（分钟）
  final int roundNumber;         // 轮数
  final int scoreBefore;         // 变化前分数
  final int scoreAfter;          // 变化后分数
  final int scoreChange;         // 分数变化
  final String userMessage;     // 用户消息
  final String aiResponse;       // AI回应
  final EmotionalChangeType changeType; // 变化类型
  final String reason;           // 变化原因
  final String learningPoint;    // 学习要点
  final DateTime timestamp;      // 时间戳

  const EmotionalTurningPoint({
    required this.minute,
    required this.roundNumber,
    required this.scoreBefore,
    required this.scoreAfter,
    required this.scoreChange,
    required this.userMessage,
    required this.aiResponse,
    required this.changeType,
    required this.reason,
    required this.learningPoint,
    required this.timestamp,
  });

  bool get isPositive => scoreChange > 0;
  bool get isSignificant => scoreChange.abs() >= 5;
}

/// 情感变化类型
enum EmotionalChangeType {
  breakthrough, // 突破性进展 (+8以上)
  positive,     // 积极变化 (+3到+7)
  neutral,      // 中性变化 (-2到+2)
  negative,     // 消极变化 (-5到-3)
  critical,     // 严重下降 (-5以下)
}

/// 情感轨迹报告
class EmotionalTrajectoryReport {
  final String conversationId;
  final String characterId;
  final String characterName;
  final int totalDuration;            // 总时长（分钟）
  final int initialScore;             // 初始分数
  final int finalScore;               // 最终分数
  final int totalGain;                // 总提升
  final List<EmotionalTurningPoint> turningPoints; // 转折点列表
  final String overallAssessment;     // 总体评价
  final List<String> keyInsights;     // 关键洞察
  final DateTime createdAt;

  const EmotionalTrajectoryReport({
    required this.conversationId,
    required this.characterId,
    required this.characterName,
    required this.totalDuration,
    required this.initialScore,
    required this.finalScore,
    required this.totalGain,
    required this.turningPoints,
    required this.overallAssessment,
    required this.keyInsights,
    required this.createdAt,
  });

  /// 获取最佳时刻
  EmotionalTurningPoint? get bestMoment {
    if (turningPoints.isEmpty) return null;
    return turningPoints.reduce((a, b) => a.scoreChange > b.scoreChange ? a : b);
  }

  /// 获取最需要改进的时刻
  EmotionalTurningPoint? get worstMoment {
    if (turningPoints.isEmpty) return null;
    return turningPoints.reduce((a, b) => a.scoreChange < b.scoreChange ? a : b);
  }

  /// 获取等级
  String get scoreGrade {
    if (finalScore >= 80) return 'S级 - 出色表现';
    if (finalScore >= 70) return 'A级 - 优秀表现';
    if (finalScore >= 60) return 'B级 - 良好表现';
    if (finalScore >= 50) return 'C级 - 一般表现';
    return 'D级 - 需要努力';
  }
}

// 扩展方法
extension ListExtension<T> on List<T> {
  T? get lastOrNull => isEmpty ? null : last;
  T? get firstOrNull => isEmpty ? null : first;
}