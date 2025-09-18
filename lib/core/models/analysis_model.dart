// lib/core/models/analysis_model.dart

/// 关键时刻类型枚举
enum MomentType {
  breakthrough,       // 突破时刻
  mistake,           // 失误时刻
  missedOpportunity, // 错失机会
  perfectResponse,   // 完美回应
}

/// 建议类型枚举
enum SuggestionType {
  emotionalIntelligence, // 情商建议
  conversationSkills,    // 对话技巧
  timing,               // 时机把握
  topicSelection,       // 话题选择
}

/// 关键时刻数据模型
class KeyMoment {
  final int round;                  // 发生轮数
  final String originalMessage;     // 原始消息
  final String improvedMessage;     // 改进后消息
  final int scoreChange;           // 分数变化
  final String explanation;        // 解释说明
  final MomentType type;           // 时刻类型
  final DateTime timestamp;       // 时间戳

  const KeyMoment({
    required this.round,
    required this.originalMessage,
    required this.improvedMessage,
    required this.scoreChange,
    required this.explanation,
    required this.type,
    required this.timestamp,
  });

  /// 从JSON创建关键时刻对象
  factory KeyMoment.fromJson(Map<String, dynamic> json) {
    return KeyMoment(
      round: json['round'] ?? 0,
      originalMessage: json['originalMessage'] ?? '',
      improvedMessage: json['improvedMessage'] ?? '',
      scoreChange: json['scoreChange'] ?? 0,
      explanation: json['explanation'] ?? '',
      type: MomentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MomentType.mistake,
      ),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'round': round,
      'originalMessage': originalMessage,
      'improvedMessage': improvedMessage,
      'scoreChange': scoreChange,
      'explanation': explanation,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// 获取时刻类型的中文名称
  String get typeName {
    switch (type) {
      case MomentType.breakthrough:
        return '突破时刻';
      case MomentType.mistake:
        return '失误时刻';
      case MomentType.missedOpportunity:
        return '错失机会';
      case MomentType.perfectResponse:
        return '完美回应';
    }
  }

  /// 获取时刻类型的颜色
  String get typeColor {
    switch (type) {
      case MomentType.breakthrough:
        return '#4CAF50'; // 绿色
      case MomentType.perfectResponse:
        return '#2196F3'; // 蓝色
      case MomentType.missedOpportunity:
        return '#FF9800'; // 橙色
      case MomentType.mistake:
        return '#F44336'; // 红色
    }
  }

  /// 是否为正面时刻
  bool get isPositive {
    return type == MomentType.breakthrough || type == MomentType.perfectResponse;
  }
}

/// 改进建议数据模型
class Suggestion {
  final String title;              // 建议标题
  final String description;        // 详细描述
  final String example;           // 示例
  final SuggestionType type;      // 建议类型
  final int priority;             // 优先级(1-5)

  const Suggestion({
    required this.title,
    required this.description,
    required this.example,
    required this.type,
    this.priority = 3,
  });

  /// 从JSON创建建议对象
  factory Suggestion.fromJson(Map<String, dynamic> json) {
    return Suggestion(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      example: json['example'] ?? '',
      type: SuggestionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SuggestionType.conversationSkills,
      ),
      priority: json['priority'] ?? 3,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'example': example,
      'type': type.name,
      'priority': priority,
    };
  }

  /// 获取建议类型的中文名称
  String get typeName {
    switch (type) {
      case SuggestionType.emotionalIntelligence:
        return '情商提升';
      case SuggestionType.conversationSkills:
        return '对话技巧';
      case SuggestionType.timing:
        return '时机把握';
      case SuggestionType.topicSelection:
        return '话题选择';
    }
  }

  /// 获取优先级文本
  String get priorityText {
    switch (priority) {
      case 5:
        return '非常重要';
      case 4:
        return '重要';
      case 3:
        return '一般';
      case 2:
        return '较低';
      case 1:
        return '很低';
      default:
        return '一般';
    }
  }
}

/// 个人强项数据模型
class PersonalStrengths {
  final List<String> topSkills;        // 顶级技能
  final Map<String, double> skillScores; // 技能分数
  final String dominantStyle;          // 主导风格

  const PersonalStrengths({
    required this.topSkills,
    required this.skillScores,
    required this.dominantStyle,
  });

  /// 从JSON创建个人强项对象
  factory PersonalStrengths.fromJson(Map<String, dynamic> json) {
    return PersonalStrengths(
      topSkills: List<String>.from(json['topSkills'] ?? []),
      skillScores: Map<String, double>.from(
        (json['skillScores'] ?? {}).map((key, value) => MapEntry(key, value.toDouble())),
      ),
      dominantStyle: json['dominantStyle'] ?? '平衡型',
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'topSkills': topSkills,
      'skillScores': skillScores,
      'dominantStyle': dominantStyle,
    };
  }

  /// 获取最强技能
  String get strongestSkill {
    if (skillScores.isEmpty) return '暂无数据';
    var maxEntry = skillScores.entries.reduce(
      (current, next) => current.value > next.value ? current : next,
    );
    return maxEntry.key;
  }

  /// 获取平均分数
  double get averageScore {
    if (skillScores.isEmpty) return 0.0;
    return skillScores.values.reduce((a, b) => a + b) / skillScores.length;
  }
}

/// 个人弱项数据模型
class PersonalWeaknesses {
  final List<String> weakAreas;        // 薄弱领域
  final Map<String, double> areaScores; // 领域分数
  final List<String> improvementPlan;  // 改进计划

  const PersonalWeaknesses({
    required this.weakAreas,
    required this.areaScores,
    required this.improvementPlan,
  });

  /// 从JSON创建个人弱项对象
  factory PersonalWeaknesses.fromJson(Map<String, dynamic> json) {
    return PersonalWeaknesses(
      weakAreas: List<String>.from(json['weakAreas'] ?? []),
      areaScores: Map<String, double>.from(
        (json['areaScores'] ?? {}).map((key, value) => MapEntry(key, value.toDouble())),
      ),
      improvementPlan: List<String>.from(json['improvementPlan'] ?? []),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'weakAreas': weakAreas,
      'areaScores': areaScores,
      'improvementPlan': improvementPlan,
    };
  }

  /// 获取最需要改进的领域
  String get mostNeededImprovement {
    if (areaScores.isEmpty) return '暂无数据';
    var minEntry = areaScores.entries.reduce(
      (current, next) => current.value < next.value ? current : next,
    );
    return minEntry.key;
  }
}

/// 分析报告数据模型
class AnalysisReport {
  final String id;                     // 报告ID
  final String conversationId;         // 对话ID
  final String userId;                 // 用户ID
  final int finalScore;               // 最终分数
  final List<KeyMoment> keyMoments;   // 关键时刻列表
  final List<Suggestion> suggestions; // 建议列表
  final PersonalStrengths strengths;  // 个人强项
  final PersonalWeaknesses weaknesses; // 个人弱项
  final List<String> nextTrainingFocus; // 下次训练重点
  final DateTime createdAt;           // 创建时间
  final String overallAssessment;     // 总体评价

  const AnalysisReport({
    required this.id,
    required this.conversationId,
    required this.userId,
    required this.finalScore,
    required this.keyMoments,
    required this.suggestions,
    required this.strengths,
    required this.weaknesses,
    required this.nextTrainingFocus,
    required this.createdAt,
    required this.overallAssessment,
  });

  /// 创建新的分析报告
  factory AnalysisReport.create({
    required String conversationId,
    required String userId,
    required int finalScore,
    required List<KeyMoment> keyMoments,
    required List<Suggestion> suggestions,
    required PersonalStrengths strengths,
    required PersonalWeaknesses weaknesses,
    required List<String> nextTrainingFocus,
    required String overallAssessment,
  }) {
    final now = DateTime.now();
    return AnalysisReport(
      id: 'analysis_${now.millisecondsSinceEpoch}',
      conversationId: conversationId,
      userId: userId,
      finalScore: finalScore,
      keyMoments: keyMoments,
      suggestions: suggestions,
      strengths: strengths,
      weaknesses: weaknesses,
      nextTrainingFocus: nextTrainingFocus,
      createdAt: now,
      overallAssessment: overallAssessment,
    );
  }

  /// 从JSON创建分析报告对象
  factory AnalysisReport.fromJson(Map<String, dynamic> json) {
    var keyMomentsList = json['keyMoments'] as List? ?? [];
    var suggestionsList = json['suggestions'] as List? ?? [];
    var trainingFocusList = json['nextTrainingFocus'] as List? ?? [];

    return AnalysisReport(
      id: json['id'] ?? '',
      conversationId: json['conversationId'] ?? '',
      userId: json['userId'] ?? '',
      finalScore: json['finalScore'] ?? 0,
      keyMoments: keyMomentsList.map((item) => KeyMoment.fromJson(item)).toList(),
      suggestions: suggestionsList.map((item) => Suggestion.fromJson(item)).toList(),
      strengths: PersonalStrengths.fromJson(json['strengths'] ?? {}),
      weaknesses: PersonalWeaknesses.fromJson(json['weaknesses'] ?? {}),
      nextTrainingFocus: List<String>.from(trainingFocusList),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      overallAssessment: json['overallAssessment'] ?? '',
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'userId': userId,
      'finalScore': finalScore,
      'keyMoments': keyMoments.map((moment) => moment.toJson()).toList(),
      'suggestions': suggestions.map((suggestion) => suggestion.toJson()).toList(),
      'strengths': strengths.toJson(),
      'weaknesses': weaknesses.toJson(),
      'nextTrainingFocus': nextTrainingFocus,
      'createdAt': createdAt.toIso8601String(),
      'overallAssessment': overallAssessment,
    };
  }

  /// 复制分析报告对象并修改部分属性
  AnalysisReport copyWith({
    String? id,
    String? conversationId,
    String? userId,
    int? finalScore,
    List<KeyMoment>? keyMoments,
    List<Suggestion>? suggestions,
    PersonalStrengths? strengths,
    PersonalWeaknesses? weaknesses,
    List<String>? nextTrainingFocus,
    DateTime? createdAt,
    String? overallAssessment,
  }) {
    return AnalysisReport(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      userId: userId ?? this.userId,
      finalScore: finalScore ?? this.finalScore,
      keyMoments: keyMoments ?? this.keyMoments,
      suggestions: suggestions ?? this.suggestions,
      strengths: strengths ?? this.strengths,
      weaknesses: weaknesses ?? this.weaknesses,
      nextTrainingFocus: nextTrainingFocus ?? this.nextTrainingFocus,
      createdAt: createdAt ?? this.createdAt,
      overallAssessment: overallAssessment ?? this.overallAssessment,
    );
  }

  /// 获取等级评价
  String get scoreGrade {
    if (finalScore >= 90) return 'S级 - 出色';
    if (finalScore >= 80) return 'A级 - 优秀';
    if (finalScore >= 70) return 'B级 - 良好';
    if (finalScore >= 60) return 'C级 - 及格';
    return 'D级 - 需要努力';
  }

  /// 获取正面时刻数量
  int get positiveNegativeCount {
    return keyMoments.where((moment) => moment.isPositive).length;
  }

  /// 获取负面时刻数量
  int get negativeMomentCount {
    return keyMoments.where((moment) => !moment.isPositive).length;
  }

  /// 获取高优先级建议
  List<Suggestion> get highPrioritySuggestions {
    return suggestions.where((suggestion) => suggestion.priority >= 4).toList();
  }

  /// 获取建议总数
  int get totalSuggestionCount => suggestions.length;

  /// 获取关键时刻总数
  int get totalKeyMomentCount => keyMoments.length;

  @override
  String toString() {
    return 'AnalysisReport(id: $id, score: $finalScore, moments: ${keyMoments.length}, suggestions: ${suggestions.length})';
  }
}