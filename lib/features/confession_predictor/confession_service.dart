// lib/features/confession_predictor/confession_service.dart

import '../../core/models/conversation_model.dart';
import '../../core/models/user_model.dart';

/// 告白成功率预测服务
class ConfessionService {
  /// 基于训练数据预测告白成功率
  static ConfessionPrediction predictSuccessRate(UserModel user) {
    final stats = user.stats;
    final conversations = stats.totalConversations;

    if (conversations < 3) {
      return ConfessionPrediction(
        successRate: 0.15,
        confidence: 0.3,
        recommendation: '建议先完成更多基础训练再考虑告白',
        suggestedActions: ['完成至少5次基础对话训练', '提升平均好感度到60分以上'],
        optimalTiming: '需要更多练习后再评估',
        riskFactors: ['训练次数不足', '缺乏实战经验'],
      );
    }

    // 计算各项指标
    final conversationSkillScore = _calculateConversationSkill(user);
    final emotionalIntelligenceScore = _calculateEmotionalIntelligence(user);
    final consistencyScore = _calculateConsistency(user);
    final charmScore = _calculateCharmScore(user);

    // 综合计算成功率
    final rawScore = (conversationSkillScore * 0.3) +
                    (emotionalIntelligenceScore * 0.25) +
                    (consistencyScore * 0.25) +
                    (charmScore * 0.2);

    final successRate = (rawScore / 10).clamp(0.0, 0.95); // 最高95%
    final confidence = _calculateConfidence(conversations, stats.averageFavorability);

    return ConfessionPrediction(
      successRate: successRate,
      confidence: confidence,
      recommendation: _generateRecommendation(successRate),
      suggestedActions: _generateSuggestedActions(successRate, user),
      optimalTiming: _calculateOptimalTiming(successRate),
      riskFactors: _identifyRiskFactors(user),
      detailedAnalysis: ConfessionDetailedAnalysis(
        conversationSkillScore: conversationSkillScore,
        emotionalIntelligenceScore: emotionalIntelligenceScore,
        consistencyScore: consistencyScore,
        charmScore: charmScore,
        overallReadiness: _calculateOverallReadiness(successRate),
      ),
    );
  }

  /// 分析批量聊天记录
  static ConfessionPrediction analyzeBatchChatRecords(List<String> chatRecords) {
    if (chatRecords.isEmpty) {
      return ConfessionPrediction(
        successRate: 0.0,
        confidence: 0.0,
        recommendation: '请提供聊天记录进行分析',
        suggestedActions: ['上传完整的聊天记录'],
        optimalTiming: '无法评估',
        riskFactors: ['缺乏聊天记录'],
      );
    }

    final analysis = _analyzeChatRecords(chatRecords);

    return ConfessionPrediction(
      successRate: analysis.successRate,
      confidence: analysis.confidence,
      recommendation: analysis.recommendation,
      suggestedActions: analysis.suggestedActions,
      optimalTiming: analysis.optimalTiming,
      riskFactors: analysis.riskFactors,
      realChatAnalysis: analysis,
    );
  }

  /// 计算对话技巧分数
  static double _calculateConversationSkill(UserModel user) {
    final avgFavorability = user.stats.averageFavorability;
    final successRate = user.stats.successRate;

    return ((avgFavorability / 10) + (successRate * 10)) / 2;
  }

  /// 计算情商分数
  static double _calculateEmotionalIntelligence(UserModel user) {
    // 基于魅力标签中的情感型魅力
    if (user.charmTags.contains(CharmTag.emotional)) {
      return 8.0;
    } else if (user.charmTags.contains(CharmTag.caring)) {
      return 7.0;
    }
    return 5.0; // 默认分数
  }

  /// 计算一致性分数
  static double _calculateConsistency(UserModel user) {
    final conversations = user.stats.totalConversations;
    if (conversations < 5) return 4.0;

    // 假设一致性随对话次数提升
    return (conversations / 10 * 2 + 5).clamp(3.0, 9.0);
  }

  /// 计算魅力分数
  static double _calculateCharmScore(UserModel user) {
    if (user.charmTags.isEmpty) return 5.0;

    // 基于主导魅力类型
    final dominantCharm = user.charmTags.first;
    switch (dominantCharm) {
      case CharmTag.confident:
        return 8.5;
      case CharmTag.humor:
        return 8.0;
      case CharmTag.emotional:
        return 7.5;
      case CharmTag.caring:
        return 7.0;
      case CharmTag.knowledge:
        return 6.5;
      case CharmTag.rational:
        return 6.0;
    }
  }

  /// 计算置信度
  static double _calculateConfidence(int conversations, double avgFavorability) {
    final conversationConfidence = (conversations / 20).clamp(0.0, 1.0);
    final favorabilityConfidence = avgFavorability > 50 ? 0.8 : 0.4;
    return (conversationConfidence + favorabilityConfidence) / 2;
  }

  /// 生成建议
  static String _generateRecommendation(double successRate) {
    if (successRate >= 0.8) {
      return '告白成功率很高，时机成熟，可以考虑表白';
    } else if (successRate >= 0.6) {
      return '成功率良好，建议再培养一段时间感情后表白';
    } else if (successRate >= 0.4) {
      return '成功率一般，需要进一步提升沟通技巧和魅力';
    } else {
      return '成功率较低，建议先提升基础社交能力';
    }
  }

  /// 生成建议行动
  static List<String> _generateSuggestedActions(double successRate, UserModel user) {
    final actions = <String>[];

    if (successRate < 0.4) {
      actions.add('完成更多基础对话训练');
      actions.add('重点提升${user.charmTags.isEmpty ? "综合魅力" : "除了${user.getCharmTagName(user.charmTags.first)}外的其他魅力"}');
    } else if (successRate < 0.6) {
      actions.add('练习更深层次的情感交流');
      actions.add('尝试实战训练营的高难度场景');
    } else if (successRate < 0.8) {
      actions.add('选择合适的时机和场合');
      actions.add('准备好应对各种可能的反应');
    } else {
      actions.add('保持现有的沟通风格');
      actions.add('选择一个浪漫的时机表白');
    }

    return actions;
  }

  /// 计算最佳时机
  static String _calculateOptimalTiming(double successRate) {
    if (successRate >= 0.8) {
      return '现在就是很好的时机';
    } else if (successRate >= 0.6) {
      return '建议再等1-2周培养感情';
    } else if (successRate >= 0.4) {
      return '建议先提升能力，2-4周后重新评估';
    } else {
      return '建议先进行系统训练，1-2个月后重新评估';
    }
  }

  /// 识别风险因素
  static List<String> _identifyRiskFactors(UserModel user) {
    final risks = <String>[];

    if (user.stats.totalConversations < 5) {
      risks.add('对话练习次数不足');
    }

    if (user.stats.averageFavorability < 50) {
      risks.add('平均好感度偏低');
    }

    if (user.charmTags.isEmpty) {
      risks.add('个人魅力特色不明显');
    }

    if (user.stats.successRate < 0.5) {
      risks.add('对话成功率不稳定');
    }

    return risks;
  }

  /// 分析聊天记录
  static RealChatAnalysis _analyzeChatRecords(List<String> records) {
    // 简化的聊天记录分析逻辑
    final totalMessages = records.length;
    final userInitiatedCount = _countUserInitiated(records);
    final questionCount = _countQuestions(records);
    final positiveWordCount = _countPositiveWords(records);

    final initiativeScore = totalMessages > 0 ? (userInitiatedCount / totalMessages) : 0.0;
    final engagementScore = totalMessages > 0 ? (questionCount / totalMessages) : 0.0;
    final sentimentScore = totalMessages > 0 ? (positiveWordCount / totalMessages) : 0.0;

    final compositeScore = (initiativeScore * 0.3 + engagementScore * 0.4 + sentimentScore * 0.3) * 0.9;

    return RealChatAnalysis(
      successRate: compositeScore,
      confidence: totalMessages >= 50 ? 0.8 : 0.5,
      recommendation: _generateRealChatRecommendation(compositeScore),
      suggestedActions: _generateRealChatActions(initiativeScore, engagementScore, sentimentScore),
      optimalTiming: _calculateRealChatTiming(compositeScore),
      riskFactors: _identifyRealChatRisks(initiativeScore, engagementScore, sentimentScore),
      chatMetrics: RealChatMetrics(
        totalMessages: totalMessages,
        userInitiativeRate: initiativeScore,
        questionFrequency: engagementScore,
        sentimentScore: sentimentScore,
      ),
    );
  }

  static int _countUserInitiated(List<String> records) {
    // 简单逻辑：假设用户发起的消息包含某些特征
    return records.where((msg) =>
      msg.startsWith('我') ||
      msg.contains('？') ||
      msg.contains('?')
    ).length;
  }

  static int _countQuestions(List<String> records) {
    return records.where((msg) =>
      msg.contains('？') || msg.contains('?')
    ).length;
  }

  static int _countPositiveWords(List<String> records) {
    final positiveWords = ['喜欢', '开心', '高兴', '好的', '不错', '有趣', '棒', '赞'];
    int count = 0;
    for (final record in records) {
      for (final word in positiveWords) {
        if (record.contains(word)) {
          count++;
          break; // 每条消息最多计算一次
        }
      }
    }
    return count;
  }

  static String _generateRealChatRecommendation(double score) {
    if (score >= 0.7) {
      return '基于聊天记录分析，你们的互动质量很高，告白成功率较好';
    } else if (score >= 0.5) {
      return '聊天记录显示关系发展良好，但还有提升空间';
    } else {
      return '从聊天记录看，建议先改善互动质量再考虑告白';
    }
  }

  static List<String> _generateRealChatActions(double initiative, double engagement, double sentiment) {
    final actions = <String>[];

    if (initiative < 0.3) {
      actions.add('增加主动发起话题的频率');
    }
    if (engagement < 0.2) {
      actions.add('多提问显示对她的关心和兴趣');
    }
    if (sentiment < 0.3) {
      actions.add('使用更积极正面的表达方式');
    }
    if (actions.isEmpty) {
      actions.add('保持现有的良好互动模式');
    }

    return actions;
  }

  static String _calculateRealChatTiming(double score) {
    if (score >= 0.7) {
      return '时机较为成熟，可以考虑在合适的场合表白';
    } else if (score >= 0.5) {
      return '建议再观察1-2周，继续提升互动质量';
    } else {
      return '建议先改善聊天互动，至少1个月后再评估';
    }
  }

  static List<String> _identifyRealChatRisks(double initiative, double engagement, double sentiment) {
    final risks = <String>[];

    if (initiative < 0.2) risks.add('主动性不足，可能显得不够在意');
    if (engagement < 0.15) risks.add('互动深度不够，关系可能停留在表面');
    if (sentiment < 0.2) risks.add('情感表达不够积极，可能给人距离感');

    return risks;
  }

  static ReadinessLevel _calculateOverallReadiness(double successRate) {
    if (successRate >= 0.8) return ReadinessLevel.ready;
    if (successRate >= 0.6) return ReadinessLevel.nearReady;
    if (successRate >= 0.4) return ReadinessLevel.developing;
    return ReadinessLevel.needsWork;
  }
}

/// 告白预测结果
class ConfessionPrediction {
  final double successRate;           // 成功率 (0-1)
  final double confidence;            // 置信度 (0-1)
  final String recommendation;        // 建议
  final List<String> suggestedActions; // 建议行动
  final String optimalTiming;         // 最佳时机
  final List<String> riskFactors;     // 风险因素
  final ConfessionDetailedAnalysis? detailedAnalysis; // 详细分析
  final RealChatAnalysis? realChatAnalysis; // 真实聊天分析

  const ConfessionPrediction({
    required this.successRate,
    required this.confidence,
    required this.recommendation,
    required this.suggestedActions,
    required this.optimalTiming,
    required this.riskFactors,
    this.detailedAnalysis,
    this.realChatAnalysis,
  });

  /// 获取成功率等级
  String get successRateGrade {
    if (successRate >= 0.8) return 'S级 - 极高成功率';
    if (successRate >= 0.6) return 'A级 - 高成功率';
    if (successRate >= 0.4) return 'B级 - 中等成功率';
    if (successRate >= 0.2) return 'C级 - 较低成功率';
    return 'D级 - 低成功率';
  }

  /// 获取成功率百分比文本
  String get successRatePercentage {
    return '${(successRate * 100).toInt()}%';
  }

  /// 获取置信度等级
  String get confidenceLevel {
    if (confidence >= 0.8) return '高置信度';
    if (confidence >= 0.5) return '中等置信度';
    return '低置信度';
  }
}

/// 详细分析数据
class ConfessionDetailedAnalysis {
  final double conversationSkillScore;    // 对话技巧分数
  final double emotionalIntelligenceScore; // 情商分数
  final double consistencyScore;          // 一致性分数
  final double charmScore;               // 魅力分数
  final ReadinessLevel overallReadiness; // 整体准备度

  const ConfessionDetailedAnalysis({
    required this.conversationSkillScore,
    required this.emotionalIntelligenceScore,
    required this.consistencyScore,
    required this.charmScore,
    required this.overallReadiness,
  });
}

/// 真实聊天分析
class RealChatAnalysis {
  final double successRate;
  final double confidence;
  final String recommendation;
  final List<String> suggestedActions;
  final String optimalTiming;
  final List<String> riskFactors;
  final RealChatMetrics chatMetrics;

  const RealChatAnalysis({
    required this.successRate,
    required this.confidence,
    required this.recommendation,
    required this.suggestedActions,
    required this.optimalTiming,
    required this.riskFactors,
    required this.chatMetrics,
  });
}

/// 真实聊天指标
class RealChatMetrics {
  final int totalMessages;           // 总消息数
  final double userInitiativeRate;   // 用户主动率
  final double questionFrequency;    // 提问频率
  final double sentimentScore;       // 情感分数

  const RealChatMetrics({
    required this.totalMessages,
    required this.userInitiativeRate,
    required this.questionFrequency,
    required this.sentimentScore,
  });
}

/// 准备度等级
enum ReadinessLevel {
  needsWork,    // 需要努力
  developing,   // 发展中
  nearReady,    // 接近准备好
  ready,        // 已准备好
}