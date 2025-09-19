// lib/features/chat/basic_charm_tracker.dart

import '../../core/models/conversation_model.dart';
import '../../core/models/user_model.dart';

/// 基础魅力追踪器 - 分析和更新用户的个人魅力标签
class BasicCharmTracker {
  /// 分析对话并更新用户魅力标签
  static Future<UserModel> updateCharmProfile(
    UserModel user,
    ConversationModel conversation,
  ) async {
    final analysis = _analyzeConversation(conversation);
    final updatedCharmTags = _updateCharmTags(user.charmTags, analysis);

    return user.copyWith(charmTags: updatedCharmTags);
  }

  /// 生成魅力成长报告
  static CharmGrowthReport generateGrowthReport(
    UserModel user,
    List<ConversationModel> recentConversations,
  ) {
    final currentProfile = _analyzeUserProfile(user, recentConversations);

    return CharmGrowthReport(
      userId: user.id,
      dominantCharmType: _getDominantCharmType(user.charmTags),
      charmScores: _calculateCharmScores(recentConversations),
      growthTrends: _analyzeGrowthTrends(recentConversations),
      personalizedAdvice: _generatePersonalizedAdvice(currentProfile),
      nextTrainingFocus: _getNextTrainingFocus(currentProfile),
      reportDate: DateTime.now(),
    );
  }

  /// 分析单次对话的魅力表现
  static ConversationCharmAnalysis _analyzeConversation(ConversationModel conversation) {
    final userMessages = conversation.messages.where((m) => m.isUser).toList();
    final analysis = ConversationCharmAnalysis();

    for (final message in userMessages) {
      final messageAnalysis = _analyzeMessage(message);
      analysis.merge(messageAnalysis);
    }

    analysis.calculateAverages(userMessages.length);
    return analysis;
  }

  /// 分析单条消息的魅力特征
  static MessageCharmFeatures _analyzeMessage(MessageModel message) {
    final content = message.content;
    final features = MessageCharmFeatures();

    // 知识型魅力检测
    features.knowledgeScore += _detectKnowledgeElements(content);

    // 幽默型魅力检测
    features.humorScore += _detectHumorElements(content);

    // 情感型魅力检测
    features.emotionalScore += _detectEmotionalElements(content);

    // 理性型魅力检测
    features.rationalScore += _detectRationalElements(content);

    // 关怀型魅力检测
    features.caringScore += _detectCaringElements(content);

    // 自信型魅力检测
    features.confidentScore += _detectConfidentElements(content);

    return features;
  }

  /// 检测知识型魅力元素
  static double _detectKnowledgeElements(String content) {
    final knowledgeKeywords = ['了解', '知道', '研究', '学习', '经验', '专业', '技术', '理论'];
    return _calculateKeywordScore(content, knowledgeKeywords);
  }

  /// 检测幽默型魅力元素
  static double _detectHumorElements(String content) {
    final humorKeywords = ['哈哈', '好笑', '有趣', '搞笑', '幽默'];
    final humorSymbols = ['😄', '😂', '😆', '🤣'];
    return _calculateKeywordScore(content, humorKeywords + humorSymbols);
  }

  /// 检测情感型魅力元素
  static double _detectEmotionalElements(String content) {
    final emotionalKeywords = ['感受', '心情', '理解', '感动', '温暖', '开心', '难过', '激动'];
    return _calculateKeywordScore(content, emotionalKeywords);
  }

  /// 检测理性型魅力元素
  static double _detectRationalElements(String content) {
    final rationalKeywords = ['分析', '逻辑', '原因', '因为', '所以', '客观', '理性', '思考'];
    return _calculateKeywordScore(content, rationalKeywords);
  }

  /// 检测关怀型魅力元素
  static double _detectCaringElements(String content) {
    final caringKeywords = ['关心', '照顾', '帮助', '支持', '陪伴', '担心', '在意', '保护'];
    final questionMarks = content.split('?').length + content.split('？').length - 2;
    return _calculateKeywordScore(content, caringKeywords) + (questionMarks * 0.5);
  }

  /// 检测自信型魅力元素
  static double _detectConfidentElements(String content) {
    final confidentKeywords = ['我觉得', '我认为', '我相信', '肯定', '确定', '绝对', '一定'];
    return _calculateKeywordScore(content, confidentKeywords);
  }

  /// 计算关键词得分
  static double _calculateKeywordScore(String content, List<String> keywords) {
    double score = 0;
    for (final keyword in keywords) {
      if (content.contains(keyword)) {
        score += 1.0;
      }
    }
    return score;
  }

  /// 更新魅力标签
  static List<CharmTag> _updateCharmTags(List<CharmTag> currentTags, ConversationCharmAnalysis analysis) {
    final tagScores = <CharmTag, double>{
      CharmTag.knowledge: analysis.averageKnowledgeScore,
      CharmTag.humor: analysis.averageHumorScore,
      CharmTag.emotional: analysis.averageEmotionalScore,
      CharmTag.rational: analysis.averageRationalScore,
      CharmTag.caring: analysis.averageCaringScore,
      CharmTag.confident: analysis.averageConfidentScore,
    };

    // 按分数排序，取前3个作为主要魅力标签
    final sortedTags = tagScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedTags.take(3).where((entry) => entry.value > 0.5).map((entry) => entry.key).toList();
  }

  /// 获取主导魅力类型
  static CharmTag _getDominantCharmType(List<CharmTag> charmTags) {
    if (charmTags.isEmpty) return CharmTag.knowledge;
    return charmTags.first;
  }

  /// 计算各项魅力分数
  static Map<CharmTag, double> _calculateCharmScores(List<ConversationModel> conversations) {
    final scores = <CharmTag, double>{
      CharmTag.knowledge: 0,
      CharmTag.humor: 0,
      CharmTag.emotional: 0,
      CharmTag.rational: 0,
      CharmTag.caring: 0,
      CharmTag.confident: 0,
    };

    if (conversations.isEmpty) return scores;

    for (final conversation in conversations) {
      final analysis = _analyzeConversation(conversation);
      scores[CharmTag.knowledge] = (scores[CharmTag.knowledge]! + analysis.averageKnowledgeScore);
      scores[CharmTag.humor] = (scores[CharmTag.humor]! + analysis.averageHumorScore);
      scores[CharmTag.emotional] = (scores[CharmTag.emotional]! + analysis.averageEmotionalScore);
      scores[CharmTag.rational] = (scores[CharmTag.rational]! + analysis.averageRationalScore);
      scores[CharmTag.caring] = (scores[CharmTag.caring]! + analysis.averageCaringScore);
      scores[CharmTag.confident] = (scores[CharmTag.confident]! + analysis.averageConfidentScore);
    }

    // 计算平均值并转换为0-10分制
    for (final key in scores.keys) {
      scores[key] = (scores[key]! / conversations.length) * 2; // 乘2转换为0-10分制
      scores[key] = scores[key]!.clamp(0, 10);
    }

    return scores;
  }

  /// 分析成长趋势
  static Map<CharmTag, GrowthTrend> _analyzeGrowthTrends(List<ConversationModel> conversations) {
    final trends = <CharmTag, GrowthTrend>{};

    if (conversations.length < 2) {
      for (final tag in CharmTag.values) {
        trends[tag] = GrowthTrend.stable;
      }
      return trends;
    }

    // 比较最近的对话和之前的对话
    final recentScores = _calculateCharmScores([conversations.last]);
    final previousScores = _calculateCharmScores(conversations.take(conversations.length - 1).toList());

    for (final tag in CharmTag.values) {
      final recent = recentScores[tag] ?? 0;
      final previous = previousScores[tag] ?? 0;
      final difference = recent - previous;

      if (difference > 0.5) {
        trends[tag] = GrowthTrend.improving;
      } else if (difference < -0.5) {
        trends[tag] = GrowthTrend.declining;
      } else {
        trends[tag] = GrowthTrend.stable;
      }
    }

    return trends;
  }

  /// 生成个性化建议
  static List<String> _generatePersonalizedAdvice(UserCharmProfile profile) {
    final advice = <String>[];
    final scores = profile.charmScores;

    // 基于最强项的建议
    final strongestTag = scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    advice.add(_getStrengthAdvice(strongestTag));

    // 基于最弱项的建议
    final weakestTag = scores.entries.reduce((a, b) => a.value < b.value ? a : b).key;
    if (scores[weakestTag]! < 3) {
      advice.add(_getImprovementAdvice(weakestTag));
    }

    // 基于整体平衡的建议
    final averageScore = scores.values.reduce((a, b) => a + b) / scores.length;
    if (averageScore < 5) {
      advice.add('建议多进行基础对话训练，全面提升沟通技巧');
    }

    return advice;
  }

  /// 获取优势建议
  static String _getStrengthAdvice(CharmTag strongestTag) {
    switch (strongestTag) {
      case CharmTag.knowledge:
        return '你的知识型魅力很突出，继续在对话中分享有价值的见解和经验';
      case CharmTag.humor:
        return '你很有幽默感，继续用适当的幽默活跃气氛，但要注意场合';
      case CharmTag.emotional:
        return '你的情感表达能力很强，继续用真诚的情感连接建立深层关系';
      case CharmTag.rational:
        return '你的理性分析能力很好，继续用逻辑思维解决问题和引导对话';
      case CharmTag.caring:
        return '你很会关心别人，继续展现你的体贴和温暖，这是很珍贵的品质';
      case CharmTag.confident:
        return '你很有自信，继续保持这种积极的态度，但也要注意倾听对方';
    }
  }

  /// 获取改进建议
  static String _getImprovementAdvice(CharmTag weakestTag) {
    switch (weakestTag) {
      case CharmTag.knowledge:
        return '可以在对话中多分享一些你了解的知识或经验，展现你的见识';
      case CharmTag.humor:
        return '适当加入一些轻松的话题或俏皮的表达，让对话更有趣';
      case CharmTag.emotional:
        return '尝试更多地表达自己的感受，或者关注对方的情绪状态';
      case CharmTag.rational:
        return '在讨论问题时可以多一些逻辑分析，展现你的思考能力';
      case CharmTag.caring:
        return '多问一些关心对方的问题，比如"你累吗？""你觉得怎么样？"';
      case CharmTag.confident:
        return '可以更坚定地表达自己的观点，相信自己的想法和判断';
    }
  }

  /// 获取下次训练重点
  static List<String> _getNextTrainingFocus(UserCharmProfile profile) {
    final focus = <String>[];
    final scores = profile.charmScores;

    // 找到分数最低的两项作为训练重点
    final sortedScores = scores.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    for (final entry in sortedScores.take(2)) {
      if (entry.value < 5) {
        focus.add(_getTrainingFocus(entry.key));
      }
    }

    if (focus.isEmpty) {
      focus.add('继续保持现有的沟通风格，尝试更高难度的社交场景');
    }

    return focus;
  }

  /// 获取训练重点描述
  static String _getTrainingFocus(CharmTag tag) {
    switch (tag) {
      case CharmTag.knowledge:
        return '知识型魅力训练 - 学习在对话中恰当地分享知识和见解';
      case CharmTag.humor:
        return '幽默感训练 - 练习适当的幽默表达和轻松话题';
      case CharmTag.emotional:
        return '情感表达训练 - 学习更好地表达和感知情感';
      case CharmTag.rational:
        return '理性思维训练 - 练习逻辑分析和理性讨论';
      case CharmTag.caring:
        return '关怀能力训练 - 学习更好地关心和理解他人';
      case CharmTag.confident:
        return '自信表达训练 - 练习坚定而不傲慢的自我表达';
    }
  }

  /// 分析用户档案
  static UserCharmProfile _analyzeUserProfile(UserModel user, List<ConversationModel> conversations) {
    return UserCharmProfile(
      charmScores: _calculateCharmScores(conversations),
      dominantCharmType: _getDominantCharmType(user.charmTags),
      growthTrends: _analyzeGrowthTrends(conversations),
    );
  }
}

/// 对话魅力分析结果
class ConversationCharmAnalysis {
  double totalKnowledgeScore = 0;
  double totalHumorScore = 0;
  double totalEmotionalScore = 0;
  double totalRationalScore = 0;
  double totalCaringScore = 0;
  double totalConfidentScore = 0;

  double averageKnowledgeScore = 0;
  double averageHumorScore = 0;
  double averageEmotionalScore = 0;
  double averageRationalScore = 0;
  double averageCaringScore = 0;
  double averageConfidentScore = 0;

  void merge(MessageCharmFeatures features) {
    totalKnowledgeScore += features.knowledgeScore;
    totalHumorScore += features.humorScore;
    totalEmotionalScore += features.emotionalScore;
    totalRationalScore += features.rationalScore;
    totalCaringScore += features.caringScore;
    totalConfidentScore += features.confidentScore;
  }

  void calculateAverages(int messageCount) {
    if (messageCount == 0) return;

    averageKnowledgeScore = totalKnowledgeScore / messageCount;
    averageHumorScore = totalHumorScore / messageCount;
    averageEmotionalScore = totalEmotionalScore / messageCount;
    averageRationalScore = totalRationalScore / messageCount;
    averageCaringScore = totalCaringScore / messageCount;
    averageConfidentScore = totalConfidentScore / messageCount;
  }
}

/// 消息魅力特征
class MessageCharmFeatures {
  double knowledgeScore = 0;
  double humorScore = 0;
  double emotionalScore = 0;
  double rationalScore = 0;
  double caringScore = 0;
  double confidentScore = 0;
}

/// 用户魅力档案
class UserCharmProfile {
  final Map<CharmTag, double> charmScores;
  final CharmTag dominantCharmType;
  final Map<CharmTag, GrowthTrend> growthTrends;

  const UserCharmProfile({
    required this.charmScores,
    required this.dominantCharmType,
    required this.growthTrends,
  });
}

/// 魅力成长报告
class CharmGrowthReport {
  final String userId;
  final CharmTag dominantCharmType;
  final Map<CharmTag, double> charmScores;
  final Map<CharmTag, GrowthTrend> growthTrends;
  final List<String> personalizedAdvice;
  final List<String> nextTrainingFocus;
  final DateTime reportDate;

  const CharmGrowthReport({
    required this.userId,
    required this.dominantCharmType,
    required this.charmScores,
    required this.growthTrends,
    required this.personalizedAdvice,
    required this.nextTrainingFocus,
    required this.reportDate,
  });

  /// 获取总体魅力分数
  double get overallCharmScore {
    return charmScores.values.reduce((a, b) => a + b) / charmScores.length;
  }

  /// 获取魅力等级
  String get charmLevel {
    final score = overallCharmScore;
    if (score >= 8) return 'S级魅力达人';
    if (score >= 7) return 'A级魅力高手';
    if (score >= 6) return 'B级魅力新星';
    if (score >= 5) return 'C级魅力学徒';
    return 'D级魅力新手';
  }
}

/// 成长趋势枚举
enum GrowthTrend {
  improving,  // 提升中
  stable,     // 稳定
  declining,  // 下降中
}