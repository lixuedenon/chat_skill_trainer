// lib/features/real_chat_assistant/social_radar.dart

/// 社交雷达 - 识别对话中的关键信息点
class SocialRadar {
  /// 分析消息中的社交机会
  static Future<SocialRadarAnalysis> analyzeMessage(String message) async {
    // 模拟分析时间
    await Future.delayed(Duration(milliseconds: 600));

    return _performAnalysis(message);
  }

  /// 执行雷达分析
  static SocialRadarAnalysis _performAnalysis(String message) {
    final opportunities = _identifyOpportunities(message);
    final warnings = _identifyWarnings(message);
    final keyInfo = _extractKeyInformation(message);
    final sentiment = _analyzeSentiment(message);

    return SocialRadarAnalysis(
      message: message,
      opportunities: opportunities,
      warnings: warnings,
      keyInformation: keyInfo,
      sentimentScore: sentiment,
      analysisTime: DateTime.now(),
    );
  }

  /// 识别社交机会
  static List<SocialOpportunity> _identifyOpportunities(String message) {
    final opportunities = <SocialOpportunity>[];
    final lowerMessage = message.toLowerCase();

    // 关心机会
    final careKeywords = ['累', '忙', '辛苦', '不舒服', '头疼', '感冒'];
    for (final keyword in careKeywords) {
      if (lowerMessage.contains(keyword)) {
        opportunities.add(SocialOpportunity(
          type: OpportunityType.show_care,
          keyword: keyword,
          explanation: '她提到了"$keyword"，这是表达关心的好时机',
          suggestedResponse: '听起来你很$keyword',
          priority: OpportunityPriority.high,
        ));
        break; // 避免重复
      }
    }

    // 兴趣话题机会
    final interestKeywords = ['喜欢', '爱好', '最近在', '刚看了', '听了'];
    for (final keyword in interestKeywords) {
      if (lowerMessage.contains(keyword)) {
        opportunities.add(SocialOpportunity(
          type: OpportunityType.ask_question,
          keyword: keyword,
          explanation: '她分享了个人兴趣，可以深入了解',
          suggestedResponse: '这个听起来很有趣，能具体说说吗？',
          priority: OpportunityPriority.medium,
        ));
        break;
      }
    }

    // 经历分享机会
    final experienceKeywords = ['今天', '昨天', '刚才', '刚刚', '刚'];
    for (final keyword in experienceKeywords) {
      if (lowerMessage.contains(keyword)) {
        opportunities.add(SocialOpportunity(
          type: OpportunityType.share_experience,
          keyword: keyword,
          explanation: '她分享了近期经历，可以回应或分享类似经历',
          suggestedResponse: '我也有过类似的经历',
          priority: OpportunityPriority.medium,
        ));
        break;
      }
    }

    // 情感共鸣机会
    final emotionKeywords = ['开心', '高兴', '难过', '郁闷', '激动', '紧张'];
    for (final keyword in emotionKeywords) {
      if (lowerMessage.contains(keyword)) {
        opportunities.add(SocialOpportunity(
          type: OpportunityType.emotional_support,
          keyword: keyword,
          explanation: '她表达了情感，这是深入交流的机会',
          suggestedResponse: '我能理解你的感受',
          priority: OpportunityPriority.high,
        ));
        break;
      }
    }

    // 未来计划机会
    final planKeywords = ['打算', '准备', '想要', '计划', '要去'];
    for (final keyword in planKeywords) {
      if (lowerMessage.contains(keyword)) {
        opportunities.add(SocialOpportunity(
          type: OpportunityType.future_plan,
          keyword: keyword,
          explanation: '她提到了未来计划，可以表达兴趣或支持',
          suggestedResponse: '这个计划不错，需要什么帮助吗？',
          priority: OpportunityPriority.low,
        ));
        break;
      }
    }

    return opportunities;
  }

  /// 识别对话警告
  static List<SocialWarning> _identifyWarnings(String message) {
    final warnings = <SocialWarning>[];
    final lowerMessage = message.toLowerCase();

    // 冷淡信号
    final coldSignals = ['哦', '嗯', '好吧', 'ok', '知道了'];
    for (final signal in coldSignals) {
      if (message.trim() == signal) {
        warnings.add(SocialWarning(
          type: WarningType.cold_response,
          signal: signal,
          explanation: '回复较为冷淡，可能对话题不感兴趣',
          suggestion: '尝试换个话题或询问她的想法',
          severity: WarningSeverity.medium,
        ));
        break;
      }
    }

    // 不耐烦信号
    final impatientSignals = ['算了', '随便', '不想说了', '没意思'];
    for (final signal in impatientSignals) {
      if (lowerMessage.contains(signal)) {
        warnings.add(SocialWarning(
          type: WarningType.impatient,
          signal: signal,
          explanation: '显示出不耐烦情绪，需要调整交流方式',
          suggestion: '给她一些空间，或者道歉并转换话题',
          severity: WarningSeverity.high,
        ));
        break;
      }
    }

    // 距离感信号
    final distanceSignals = ['不用了', '不需要', '我自己来', '不麻烦你'];
    for (final signal in distanceSignals) {
      if (lowerMessage.contains(signal)) {
        warnings.add(SocialWarning(
          type: WarningType.keeping_distance,
          signal: signal,
          explanation: '可能在保持距离，避免过于主动',
          suggestion: '尊重她的空间，保持适度的关心',
          severity: WarningSeverity.low,
        ));
        break;
      }
    }

    return warnings;
  }

  /// 提取关键信息
  static List<KeyInformation> _extractKeyInformation(String message) {
    final keyInfo = <KeyInformation>[];

    // 时间信息
    final timePattern = RegExp(r'(\d{1,2}点|\d{1,2}:\d{2}|今天|昨天|明天|周\w+)');
    final timeMatches = timePattern.allMatches(message);
    for (final match in timeMatches) {
      keyInfo.add(KeyInformation(
        type: InfoType.time,
        content: match.group(0)!,
        importance: ImportanceLevel.medium,
        context: '时间相关信息',
      ));
    }

    // 地点信息
    final locationKeywords = ['在', '去', '从', '到'];
    for (final keyword in locationKeywords) {
      final index = message.indexOf(keyword);
      if (index != -1 && index + 3 < message.length) {
        final location = message.substring(index, index + 6);
        keyInfo.add(KeyInformation(
          type: InfoType.location,
          content: location,
          importance: ImportanceLevel.medium,
          context: '地点相关信息',
        ));
        break;
      }
    }

    // 人物信息
    final peopleKeywords = ['朋友', '同事', '家人', '爸妈', '姐妹'];
    for (final keyword in peopleKeywords) {
      if (message.contains(keyword)) {
        keyInfo.add(KeyInformation(
          type: InfoType.people,
          content: keyword,
          importance: ImportanceLevel.high,
          context: '提到了重要的人',
        ));
        break;
      }
    }

    // 活动信息
    final activityKeywords = ['看电影', '吃饭', '购物', '运动', '旅行', '工作'];
    for (final keyword in activityKeywords) {
      if (message.contains(keyword)) {
        keyInfo.add(KeyInformation(
          type: InfoType.activity,
          content: keyword,
          importance: ImportanceLevel.medium,
          context: '活动相关信息',
        ));
        break;
      }
    }

    return keyInfo;
  }

  /// 分析情感倾向
  static double _analyzeSentiment(String message) {
    const positiveWords = ['开心', '高兴', '喜欢', '爱', '好', '棒', '赞', '哈哈'];
    const negativeWords = ['难过', '生气', '烦', '累', '不好', '讨厌', '糟糕', '失望'];

    int positiveCount = 0;
    int negativeCount = 0;

    for (final word in positiveWords) {
      if (message.contains(word)) positiveCount++;
    }

    for (final word in negativeWords) {
      if (message.contains(word)) negativeCount++;
    }

    if (positiveCount + negativeCount == 0) return 0.0; // 中性

    return (positiveCount - negativeCount) / (positiveCount + negativeCount);
  }
}

/// 社交雷达分析结果
class SocialRadarAnalysis {
  final String message;
  final List<SocialOpportunity> opportunities;
  final List<SocialWarning> warnings;
  final List<KeyInformation> keyInformation;
  final double sentimentScore; // -1到1，负数为消极，正数为积极
  final DateTime analysisTime;

  const SocialRadarAnalysis({
    required this.message,
    required this.opportunities,
    required this.warnings,
    required this.keyInformation,
    required this.sentimentScore,
    required this.analysisTime,
  });

  /// 获取情感倾向描述
  String get sentimentDescription {
    if (sentimentScore > 0.3) return '积极正面';
    if (sentimentScore < -0.3) return '消极负面';
    return '情感中性';
  }

  /// 获取总体风险等级
  WarningSeverity get overallRiskLevel {
    if (warnings.any((w) => w.severity == WarningSeverity.high)) {
      return WarningSeverity.high;
    }
    if (warnings.any((w) => w.severity == WarningSeverity.medium)) {
      return WarningSeverity.medium;
    }
    return WarningSeverity.low;
  }

  /// 获取优先机会
  List<SocialOpportunity> get priorityOpportunities {
    final sorted = List<SocialOpportunity>.from(opportunities);
    sorted.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    return sorted.take(3).toList();
  }
}

/// 社交机会
class SocialOpportunity {
  final OpportunityType type;
  final String keyword;
  final String explanation;
  final String suggestedResponse;
  final OpportunityPriority priority;

  const SocialOpportunity({
    required this.type,
    required this.keyword,
    required this.explanation,
    required this.suggestedResponse,
    required this.priority,
  });
}

/// 社交警告
class SocialWarning {
  final WarningType type;
  final String signal;
  final String explanation;
  final String suggestion;
  final WarningSeverity severity;

  const SocialWarning({
    required this.type,
    required this.signal,
    required this.explanation,
    required this.suggestion,
    required this.severity,
  });
}

/// 关键信息
class KeyInformation {
  final InfoType type;
  final String content;
  final ImportanceLevel importance;
  final String context;

  const KeyInformation({
    required this.type,
    required this.content,
    required this.importance,
    required this.context,
  });
}

/// 机会类型
enum OpportunityType {
  show_care,           // 表达关心
  ask_question,        // 提出问题
  share_experience,    // 分享经历
  emotional_support,   // 情感支持
  future_plan,         // 未来计划
}

/// 机会优先级
enum OpportunityPriority {
  low,
  medium,
  high,
}

/// 警告类型
enum WarningType {
  cold_response,       // 冷淡回应
  impatient,          // 不耐烦
  keeping_distance,   // 保持距离
}

/// 警告严重程度
enum WarningSeverity {
  low,
  medium,
  high,
}

/// 信息类型
enum InfoType {
  time,       // 时间
  location,   // 地点
  people,     // 人物
  activity,   // 活动
}

/// 重要程度
enum ImportanceLevel {
  low,
  medium,
  high,
}