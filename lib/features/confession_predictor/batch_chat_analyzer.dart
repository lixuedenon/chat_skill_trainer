// lib/features/confession_predictor/batch_chat_analyzer.dart

/// 批量聊天记录分析器
class BatchChatAnalyzer {
  /// 分析批量聊天记录
  static Future<BatchAnalysisResult> analyzeChatRecords({
    required List<String> messages,
    required String relationshipType,
  }) async {
    if (messages.isEmpty) {
      return BatchAnalysisResult.empty();
    }

    // 预处理消息
    final processedMessages = _preprocessMessages(messages);

    // 执行各项分析
    final basicStats = _calculateBasicStats(processedMessages);
    final initiativeAnalysis = _analyzeInitiative(processedMessages);
    final emotionalAnalysis = _analyzeEmotionalPattern(processedMessages);
    final conversationFlow = _analyzeConversationFlow(processedMessages);
    final timePattern = _analyzeTimePattern(processedMessages);
    final topicAnalysis = _analyzeTopics(processedMessages);

    // 计算综合告白成功率
    final confessionRate = _calculateConfessionSuccessRate(
      basicStats,
      initiativeAnalysis,
      emotionalAnalysis,
      conversationFlow,
    );

    return BatchAnalysisResult(
      totalMessages: messages.length,
      basicStats: basicStats,
      initiativeAnalysis: initiativeAnalysis,
      emotionalAnalysis: emotionalAnalysis,
      conversationFlow: conversationFlow,
      timePattern: timePattern,
      topicAnalysis: topicAnalysis,
      confessionSuccessRate: confessionRate,
      analysisDate: DateTime.now(),
    );
  }

  /// 预处理消息
  static List<ProcessedMessage> _preprocessMessages(List<String> rawMessages) {
    final processed = <ProcessedMessage>[];

    for (int i = 0; i < rawMessages.length; i++) {
      final message = rawMessages[i].trim();
      if (message.isEmpty) continue;

      final isUserMessage = _detectUserMessage(message, i);

      processed.add(ProcessedMessage(
        content: message,
        isUser: isUserMessage,
        index: i,
        wordCount: message.length,
        hasQuestion: message.contains('?') || message.contains('？'),
        sentiment: _calculateMessageSentiment(message),
      ));
    }

    return processed;
  }

  /// 检测是否为用户消息
  static bool _detectUserMessage(String message, int index) {
    // 简单规则：奇数索引为用户消息，偶数为对方消息
    // 实际应用中可能需要更复杂的检测逻辑
    return index % 2 == 0;
  }

  /// 计算基础统计数据
  static BasicChatStats _calculateBasicStats(List<ProcessedMessage> messages) {
    final userMessages = messages.where((m) => m.isUser).toList();
    final otherMessages = messages.where((m) => !m.isUser).toList();

    return BasicChatStats(
      totalMessages: messages.length,
      userMessageCount: userMessages.length,
      otherMessageCount: otherMessages.length,
      averageUserMessageLength: userMessages.isNotEmpty
          ? userMessages.map((m) => m.wordCount).reduce((a, b) => a + b) / userMessages.length
          : 0,
      averageOtherMessageLength: otherMessages.isNotEmpty
          ? otherMessages.map((m) => m.wordCount).reduce((a, b) => a + b) / otherMessages.length
          : 0,
      questionCount: messages.where((m) => m.hasQuestion).length,
    );
  }

  /// 分析主动性
  static InitiativeAnalysis _analyzeInitiative(List<ProcessedMessage> messages) {
    int conversationStarts = 0;
    int userStarts = 0;

    // 简化分析：查看谁更多发起话题
    for (int i = 0; i < messages.length - 1; i++) {
      // 如果连续的消息来自同一人，可能表示主动性
      if (messages[i].isUser && messages[i + 1].isUser) {
        userStarts++;
      }

      // 统计对话开始（假设第一条消息是开始）
      if (i == 0 || (i > 0 && !messages[i - 1].isUser && messages[i].isUser)) {
        conversationStarts++;
        if (messages[i].isUser) {
          userStarts++;
        }
      }
    }

    final initiativeScore = conversationStarts > 0 ? userStarts / conversationStarts : 0.5;

    return InitiativeAnalysis(
      totalConversationStarts: conversationStarts,
      userInitiatedCount: userStarts,
      initiativeScore: initiativeScore,
      doubleMessageCount: userStarts, // 连续发送消息次数
      level: _getInitiativeLevel(initiativeScore),
    );
  }

  /// 分析情感模式
  static EmotionalAnalysis _analyzeEmotionalPattern(List<ProcessedMessage> messages) {
    final userMessages = messages.where((m) => m.isUser).toList();
    final otherMessages = messages.where((m) => !m.isUser).toList();

    final userAvgSentiment = userMessages.isNotEmpty
        ? userMessages.map((m) => m.sentiment).reduce((a, b) => a + b) / userMessages.length
        : 0.0;

    final otherAvgSentiment = otherMessages.isNotEmpty
        ? otherMessages.map((m) => m.sentiment).reduce((a, b) => a + b) / otherMessages.length
        : 0.0;

    // 分析情感波动
    final emotionalVariability = _calculateEmotionalVariability(messages);

    return EmotionalAnalysis(
      userAverageSentiment: userAvgSentiment,
      otherAverageSentiment: otherAvgSentiment,
      emotionalVariability: emotionalVariability,
      positiveInteractionRatio: _calculatePositiveRatio(messages),
      emotionalSync: _calculateEmotionalSync(userMessages, otherMessages),
    );
  }

  /// 分析对话流程
  static ConversationFlow _analyzeConversationFlow(List<ProcessedMessage> messages) {
    int questionResponsePairs = 0;
    int topicChanges = 0;
    double averageResponseTime = 0; // 这里简化处理，实际需要时间戳

    // 分析问答对
    for (int i = 0; i < messages.length - 1; i++) {
      if (messages[i].hasQuestion && !messages[i + 1].hasQuestion) {
        questionResponsePairs++;
      }
    }

    // 简化的话题变化检测（基于关键词变化）
    topicChanges = _estimateTopicChanges(messages);

    return ConversationFlow(
      questionResponsePairs: questionResponsePairs,
      topicChanges: topicChanges,
      averageResponseTime: averageResponseTime,
      conversationDepth: _calculateConversationDepth(messages),
      engagementLevel: _calculateEngagementLevel(messages),
    );
  }

  /// 分析时间模式
  static TimePattern _analyzeTimePattern(List<ProcessedMessage> messages) {
    // 这里简化处理，实际需要真实的时间戳数据
    return const TimePattern(
      totalDuration: Duration(hours: 1), // 假设数据
      averageGapBetweenMessages: Duration(minutes: 5),
      longestGap: Duration(hours: 2),
      peakActivityTime: '晚上8-10点',
      consistencyScore: 0.7,
    );
  }

  /// 分析话题
  static TopicAnalysis _analyzeTopics(List<ProcessedMessage> messages) {
    final topicKeywords = <String, int>{};

    // 简化的话题识别
    const topics = {
      '工作': ['工作', '上班', '同事', '老板', '项目'],
      '生活': ['吃饭', '睡觉', '购物', '家里', '朋友'],
      '兴趣': ['电影', '音乐', '书', '游戏', '旅行'],
      '感情': ['喜欢', '爱', '想念', '开心', '难过'],
    };

    for (final message in messages) {
      for (final topic in topics.entries) {
        for (final keyword in topic.value) {
          if (message.content.contains(keyword)) {
            topicKeywords[topic.key] = (topicKeywords[topic.key] ?? 0) + 1;
            break;
          }
        }
      }
    }

    return TopicAnalysis(
      mainTopics: topicKeywords,
      topicDiversity: topicKeywords.length.toDouble(),
      personalTopicRatio: _calculatePersonalTopicRatio(topicKeywords),
    );
  }

  /// 计算告白成功率
  static double _calculateConfessionSuccessRate(
    BasicChatStats basicStats,
    InitiativeAnalysis initiative,
    EmotionalAnalysis emotional,
    ConversationFlow flow,
  ) {
    // 综合评分算法
    double score = 0;

    // 基础交流质量 (30%)
    final basicScore = (basicStats.averageUserMessageLength / 50).clamp(0, 1) * 0.3;
    score += basicScore;

    // 主动性得分 (25%)
    final initiativeScore = initiative.initiativeScore * 0.25;
    score += initiativeScore;

    // 情感和谐度 (25%)
    final emotionalScore = (emotional.positiveInteractionRatio + emotional.emotionalSync) / 2 * 0.25;
    score += emotionalScore;

    // 对话深度 (20%)
    final depthScore = (flow.conversationDepth / 10).clamp(0, 1) * 0.2;
    score += depthScore;

    return score.clamp(0, 1);
  }

  /// 计算消息情感值
  static double _calculateMessageSentiment(String message) {
    const positiveWords = ['好', '喜欢', '开心', '哈哈', '棒', '赞'];
    const negativeWords = ['不好', '难过', '烦', '累', '讨厌', '糟糕'];

    int positive = 0, negative = 0;

    for (final word in positiveWords) {
      if (message.contains(word)) positive++;
    }
    for (final word in negativeWords) {
      if (message.contains(word)) negative++;
    }

    if (positive + negative == 0) return 0.0;
    return (positive - negative) / (positive + negative);
  }

  /// 其他辅助方法
  static InitiativeLevel _getInitiativeLevel(double score) {
    if (score >= 0.7) return InitiativeLevel.high;
    if (score >= 0.4) return InitiativeLevel.medium;
    return InitiativeLevel.low;
  }

  static double _calculateEmotionalVariability(List<ProcessedMessage> messages) {
    if (messages.length < 2) return 0;

    double variance = 0;
    final avgSentiment = messages.map((m) => m.sentiment).reduce((a, b) => a + b) / messages.length;

    for (final message in messages) {
      variance += (message.sentiment - avgSentiment) * (message.sentiment - avgSentiment);
    }

    return variance / messages.length;
  }

  static double _calculatePositiveRatio(List<ProcessedMessage> messages) {
    final positiveCount = messages.where((m) => m.sentiment > 0).length;
    return messages.isNotEmpty ? positiveCount / messages.length : 0;
  }

  static double _calculateEmotionalSync(List<ProcessedMessage> userMessages, List<ProcessedMessage> otherMessages) {
    if (userMessages.isEmpty || otherMessages.isEmpty) return 0.5;

    final userAvg = userMessages.map((m) => m.sentiment).reduce((a, b) => a + b) / userMessages.length;
    final otherAvg = otherMessages.map((m) => m.sentiment).reduce((a, b) => a + b) / otherMessages.length;

    return 1 - (userAvg - otherAvg).abs();
  }

  static int _estimateTopicChanges(List<ProcessedMessage> messages) {
    // 简化的话题变化估算
    return (messages.length / 10).ceil();
  }

  static double _calculateConversationDepth(List<ProcessedMessage> messages) {
    final avgLength = messages.isNotEmpty
        ? messages.map((m) => m.wordCount).reduce((a, b) => a + b) / messages.length
        : 0;
    return (avgLength / 10).clamp(0, 10);
  }

  static double _calculateEngagementLevel(List<ProcessedMessage> messages) {
    final questionRatio = messages.where((m) => m.hasQuestion).length / messages.length;
    return questionRatio.clamp(0, 1);
  }

  static double _calculatePersonalTopicRatio(Map<String, int> topics) {
    final personalTopics = (topics['生活'] ?? 0) + (topics['感情'] ?? 0);
    final totalTopics = topics.values.fold(0, (sum, count) => sum + count);
    return totalTopics > 0 ? personalTopics / totalTopics : 0;
  }
}

/// 批量分析结果
class BatchAnalysisResult {
  final int totalMessages;
  final BasicChatStats basicStats;
  final InitiativeAnalysis initiativeAnalysis;
  final EmotionalAnalysis emotionalAnalysis;
  final ConversationFlow conversationFlow;
  final TimePattern timePattern;
  final TopicAnalysis topicAnalysis;
  final double confessionSuccessRate;
  final DateTime analysisDate;

  const BatchAnalysisResult({
    required this.totalMessages,
    required this.basicStats,
    required this.initiativeAnalysis,
    required this.emotionalAnalysis,
    required this.conversationFlow,
    required this.timePattern,
    required this.topicAnalysis,
    required this.confessionSuccessRate,
    required this.analysisDate,
  });

  factory BatchAnalysisResult.empty() {
    return BatchAnalysisResult(
      totalMessages: 0,
      basicStats: BasicChatStats.empty(),
      initiativeAnalysis: InitiativeAnalysis.empty(),
      emotionalAnalysis: EmotionalAnalysis.empty(),
      conversationFlow: ConversationFlow.empty(),
      timePattern: TimePattern.empty(),
      topicAnalysis: TopicAnalysis.empty(),
      confessionSuccessRate: 0.0,
      analysisDate: DateTime.now(),
    );
  }
}

/// 数据类定义
class ProcessedMessage {
  final String content;
  final bool isUser;
  final int index;
  final int wordCount;
  final bool hasQuestion;
  final double sentiment;

  const ProcessedMessage({
    required this.content,
    required this.isUser,
    required this.index,
    required this.wordCount,
    required this.hasQuestion,
    required this.sentiment,
  });
}

class BasicChatStats {
  final int totalMessages;
  final int userMessageCount;
  final int otherMessageCount;
  final double averageUserMessageLength;
  final double averageOtherMessageLength;
  final int questionCount;

  const BasicChatStats({
    required this.totalMessages,
    required this.userMessageCount,
    required this.otherMessageCount,
    required this.averageUserMessageLength,
    required this.averageOtherMessageLength,
    required this.questionCount,
  });

  factory BasicChatStats.empty() => const BasicChatStats(
    totalMessages: 0,
    userMessageCount: 0,
    otherMessageCount: 0,
    averageUserMessageLength: 0,
    averageOtherMessageLength: 0,
    questionCount: 0,
  );
}

class InitiativeAnalysis {
  final int totalConversationStarts;
  final int userInitiatedCount;
  final double initiativeScore;
  final int doubleMessageCount;
  final InitiativeLevel level;

  const InitiativeAnalysis({
    required this.totalConversationStarts,
    required this.userInitiatedCount,
    required this.initiativeScore,
    required this.doubleMessageCount,
    required this.level,
  });

  factory InitiativeAnalysis.empty() => const InitiativeAnalysis(
    totalConversationStarts: 0,
    userInitiatedCount: 0,
    initiativeScore: 0,
    doubleMessageCount: 0,
    level: InitiativeLevel.low,
  );
}

class EmotionalAnalysis {
  final double userAverageSentiment;
  final double otherAverageSentiment;
  final double emotionalVariability;
  final double positiveInteractionRatio;
  final double emotionalSync;

  const EmotionalAnalysis({
    required this.userAverageSentiment,
    required this.otherAverageSentiment,
    required this.emotionalVariability,
    required this.positiveInteractionRatio,
    required this.emotionalSync,
  });

  factory EmotionalAnalysis.empty() => const EmotionalAnalysis(
    userAverageSentiment: 0,
    otherAverageSentiment: 0,
    emotionalVariability: 0,
    positiveInteractionRatio: 0,
    emotionalSync: 0,
  );
}

class ConversationFlow {
  final int questionResponsePairs;
  final int topicChanges;
  final double averageResponseTime;
  final double conversationDepth;
  final double engagementLevel;

  const ConversationFlow({
    required this.questionResponsePairs,
    required this.topicChanges,
    required this.averageResponseTime,
    required this.conversationDepth,
    required this.engagementLevel,
  });

  factory ConversationFlow.empty() => const ConversationFlow(
    questionResponsePairs: 0,
    topicChanges: 0,
    averageResponseTime: 0,
    conversationDepth: 0,
    engagementLevel: 0,
  );
}

class TimePattern {
  final Duration totalDuration;
  final Duration averageGapBetweenMessages;
  final Duration longestGap;
  final String peakActivityTime;
  final double consistencyScore;

  const TimePattern({
    required this.totalDuration,
    required this.averageGapBetweenMessages,
    required this.longestGap,
    required this.peakActivityTime,
    required this.consistencyScore,
  });

  factory TimePattern.empty() => const TimePattern(
    totalDuration: Duration.zero,
    averageGapBetweenMessages: Duration.zero,
    longestGap: Duration.zero,
    peakActivityTime: '',
    consistencyScore: 0,
  );
}

class TopicAnalysis {
  final Map<String, int> mainTopics;
  final double topicDiversity;
  final double personalTopicRatio;

  const TopicAnalysis({
    required this.mainTopics,
    required this.topicDiversity,
    required this.personalTopicRatio,
  });

  factory TopicAnalysis.empty() => const TopicAnalysis(
    mainTopics: {},
    topicDiversity: 0,
    personalTopicRatio: 0,
  );
}

enum InitiativeLevel { low, medium, high }