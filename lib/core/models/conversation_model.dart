// lib/core/models/conversation_model.dart

/// 对话状态枚举
enum ConversationStatus {
  active,     // 进行中
  completed,  // 已完成
  reviewed,   // 已复盘
  retried,    // 已重来
}

/// 消息数据模型
class MessageModel {
  final String id;                    // 消息ID
  final String content;               // 消息内容
  final bool isUser;                  // 是否用户消息
  final DateTime timestamp;           // 时间戳
  final int characterCount;           // 字符数量
  final double densityCoefficient;    // 密度系数

  const MessageModel({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    required this.characterCount,
    required this.densityCoefficient,
  });

  /// 从JSON创建消息对象
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      isUser: json['isUser'] ?? false,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      characterCount: json['characterCount'] ?? 0,
      densityCoefficient: (json['densityCoefficient'] ?? 1.0).toDouble(),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'characterCount': characterCount,
      'densityCoefficient': densityCoefficient,
    };
  }

  /// 复制消息对象并修改部分属性
  MessageModel copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    int? characterCount,
    double? densityCoefficient,
  }) {
    return MessageModel(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      characterCount: characterCount ?? this.characterCount,
      densityCoefficient: densityCoefficient ?? this.densityCoefficient,
    );
  }
}

/// 好感度变化点
class FavorabilityPoint {
  final int round;           // 轮数
  final int score;           // 好感度分数
  final String reason;       // 变化原因
  final DateTime timestamp;  // 时间戳

  const FavorabilityPoint({
    required this.round,
    required this.score,
    required this.reason,
    required this.timestamp,
  });

  /// 从JSON创建好感度点对象
  factory FavorabilityPoint.fromJson(Map<String, dynamic> json) {
    return FavorabilityPoint(
      round: json['round'] ?? 0,
      score: json['score'] ?? 0,
      reason: json['reason'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'round': round,
      'score': score,
      'reason': reason,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// 对话指标数据模型
class ConversationMetrics {
  final int actualRounds;                           // 实际轮数
  final int effectiveRounds;                        // 有效轮数
  final double averageCharsPerRound;                // 平均字数/轮
  final int currentFavorability;                    // 当前好感度
  final List<FavorabilityPoint> favorabilityHistory; // 好感度历史

  const ConversationMetrics({
    required this.actualRounds,
    required this.effectiveRounds,
    required this.averageCharsPerRound,
    required this.currentFavorability,
    required this.favorabilityHistory,
  });

  /// 从JSON创建对话指标对象
  factory ConversationMetrics.fromJson(Map<String, dynamic> json) {
    var historyList = json['favorabilityHistory'] as List? ?? [];
    return ConversationMetrics(
      actualRounds: json['actualRounds'] ?? 0,
      effectiveRounds: json['effectiveRounds'] ?? 0,
      averageCharsPerRound: (json['averageCharsPerRound'] ?? 0.0).toDouble(),
      currentFavorability: json['currentFavorability'] ?? 10,
      favorabilityHistory: historyList
          .map((item) => FavorabilityPoint.fromJson(item))
          .toList(),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'actualRounds': actualRounds,
      'effectiveRounds': effectiveRounds,
      'averageCharsPerRound': averageCharsPerRound,
      'currentFavorability': currentFavorability,
      'favorabilityHistory': favorabilityHistory.map((point) => point.toJson()).toList(),
    };
  }

  /// 复制对话指标对象并修改部分属性
  ConversationMetrics copyWith({
    int? actualRounds,
    int? effectiveRounds,
    double? averageCharsPerRound,
    int? currentFavorability,
    List<FavorabilityPoint>? favorabilityHistory,
  }) {
    return ConversationMetrics(
      actualRounds: actualRounds ?? this.actualRounds,
      effectiveRounds: effectiveRounds ?? this.effectiveRounds,
      averageCharsPerRound: averageCharsPerRound ?? this.averageCharsPerRound,
      currentFavorability: currentFavorability ?? this.currentFavorability,
      favorabilityHistory: favorabilityHistory ?? this.favorabilityHistory,
    );
  }

  /// 获取最近的好感度变化
  int get recentFavorabilityChange {
    if (favorabilityHistory.length < 2) return 0;
    var latest = favorabilityHistory.last.score;
    var previous = favorabilityHistory[favorabilityHistory.length - 2].score;
    return latest - previous;
  }

  /// 检查好感度是否在上升
  bool get isFavorabilityIncreasing {
    return recentFavorabilityChange > 0;
  }
}

/// 对话数据模型
class ConversationModel {
  final String id;                      // 对话ID
  final String userId;                  // 用户ID
  final String characterId;             // 角色ID
  final List<MessageModel> messages;    // 消息列表
  final ConversationStatus status;      // 对话状态
  final DateTime createdAt;             // 创建时间
  final DateTime updatedAt;             // 更新时间
  final ConversationMetrics metrics;    // 对话指标
  final String scenario;                // 对话场景

  const ConversationModel({
    required this.id,
    required this.userId,
    required this.characterId,
    required this.messages,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.metrics,
    this.scenario = 'general',
  });

  /// 创建新的对话
  factory ConversationModel.newConversation({
    required String userId,
    required String characterId,
    String scenario = 'general',
  }) {
    final now = DateTime.now();
    return ConversationModel(
      id: 'conv_${now.millisecondsSinceEpoch}',
      userId: userId,
      characterId: characterId,
      messages: [],
      status: ConversationStatus.active,
      createdAt: now,
      updatedAt: now,
      metrics: const ConversationMetrics(
        actualRounds: 0,
        effectiveRounds: 0,
        averageCharsPerRound: 0.0,
        currentFavorability: 10, // 初始好感度
        favorabilityHistory: [],
      ),
      scenario: scenario,
    );
  }

  /// 从JSON创建对话对象
  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    var messagesList = json['messages'] as List? ?? [];
    return ConversationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      characterId: json['characterId'] ?? '',
      messages: messagesList.map((item) => MessageModel.fromJson(item)).toList(),
      status: ConversationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ConversationStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      metrics: ConversationMetrics.fromJson(json['metrics'] ?? {}),
      scenario: json['scenario'] ?? 'general',
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'characterId': characterId,
      'messages': messages.map((msg) => msg.toJson()).toList(),
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metrics': metrics.toJson(),
      'scenario': scenario,
    };
  }

  /// 复制对话对象并修改部分属性
  ConversationModel copyWith({
    String? id,
    String? userId,
    String? characterId,
    List<MessageModel>? messages,
    ConversationStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    ConversationMetrics? metrics,
    String? scenario,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      characterId: characterId ?? this.characterId,
      messages: messages ?? this.messages,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metrics: metrics ?? this.metrics,
      scenario: scenario ?? this.scenario,
    );
  }

  /// 添加新消息
  ConversationModel addMessage(MessageModel message) {
    final updatedMessages = [...messages, message];
    final now = DateTime.now();

    return copyWith(
      messages: updatedMessages,
      updatedAt: now,
    );
  }

  /// 获取用户消息数量
  int get userMessageCount {
    return messages.where((msg) => msg.isUser).length;
  }

  /// 获取AI消息数量
  int get aiMessageCount {
    return messages.where((msg) => !msg.isUser).length;
  }

  /// 获取对话时长（分钟）
  int get durationInMinutes {
    if (messages.isEmpty) return 0;
    final firstMessage = messages.first.timestamp;
    final lastMessage = messages.last.timestamp;
    return lastMessage.difference(firstMessage).inMinutes;
  }

  @override
  String toString() {
    return 'ConversationModel(id: $id, messages: ${messages.length}, status: ${status.name})';
  }
}