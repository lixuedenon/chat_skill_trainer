// lib/core/models/companion_model.dart

/// AI伴侣类型枚举
enum CompanionType {
  gentleGirl,     // 温柔女生
  livelyGirl,     // 活泼女生
  elegantGirl,    // 优雅女生
  mysteriousGirl, // 神秘女生
  sunnyBoy,       // 阳光男生
  matureBoy,      // 成熟男生
}

/// 相遇场景枚举
enum MeetingScenario {
  library,        // 图书馆偶遇
  rainyNight,     // 雨夜邂逅
  coffeeMistake,  // 咖啡厅拿错杯子
  lostPet,        // 帮忙找宠物
  bookstore,      // 书店同本书
  elevator,       // 电梯故障
  stargazing,     // 天台看星星
  timeTraveler,   // 时空穿越者
  angel,          // 守护天使
  dreamWalker,    // 梦境行者
}

/// 关系发展阶段
enum RelationshipStage {
  stranger,       // 陌生期 (1-2周)
  familiar,       // 熟悉期 (2-4周)
  intimate,       // 亲密期 (1-2月)
  mature,         // 成熟期 (准备结束)
}

/// 相遇故事数据模型
class MeetingStory {
  final MeetingScenario scenario;     // 相遇场景类型
  final String title;                 // 故事标题
  final String storyText;            // 故事文本
  final String openingMessage;       // 开场消息
  final Map<String, dynamic> details; // 场景细节参数

  const MeetingStory({
    required this.scenario,
    required this.title,
    required this.storyText,
    required this.openingMessage,
    this.details = const {},
  });

  /// 从JSON创建对象
  factory MeetingStory.fromJson(Map<String, dynamic> json) {
    return MeetingStory(
      scenario: MeetingScenario.values.firstWhere(
        (e) => e.name == json['scenario'],
        orElse: () => MeetingScenario.library,
      ),
      title: json['title'] ?? '',
      storyText: json['storyText'] ?? '',
      openingMessage: json['openingMessage'] ?? '',
      details: Map<String, dynamic>.from(json['details'] ?? {}),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'scenario': scenario.name,
      'title': title,
      'storyText': storyText,
      'openingMessage': openingMessage,
      'details': details,
    };
  }
}

/// 记忆片段
class MemoryFragment {
  final DateTime timestamp;          // 时间戳
  final String summary;             // 记忆摘要
  final int emotionalWeight;        // 情感重要性(1-10)
  final String category;            // 分类(兴趣/工作/感情等)
  final Map<String, dynamic> context; // 上下文信息

  const MemoryFragment({
    required this.timestamp,
    required this.summary,
    required this.emotionalWeight,
    required this.category,
    this.context = const {},
  });

  factory MemoryFragment.fromJson(Map<String, dynamic> json) {
    return MemoryFragment(
      timestamp: DateTime.parse(json['timestamp']),
      summary: json['summary'] ?? '',
      emotionalWeight: json['emotionalWeight'] ?? 1,
      category: json['category'] ?? 'general',
      context: Map<String, dynamic>.from(json['context'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'summary': summary,
      'emotionalWeight': emotionalWeight,
      'category': category,
      'context': context,
    };
  }
}

/// AI伴侣数据模型
class CompanionModel {
  final String id;                    // 伴侣ID
  final String name;                  // 伴侣姓名
  final CompanionType type;           // 伴侣类型
  final String avatar;                // 头像路径
  final MeetingStory meetingStory;    // 相遇背景故事
  final List<MemoryFragment> memories; // 压缩的记忆片段
  final RelationshipStage stage;      // 关系发展阶段
  final int tokenUsed;               // 已使用token数量
  final int maxToken;                // 最大token限制
  final DateTime createdAt;          // 创建时间
  final DateTime lastChatAt;         // 最后聊天时间
  final int favorabilityScore;       // 好感度分数
  final Map<String, dynamic> personality; // 个性特征

  const CompanionModel({
    required this.id,
    required this.name,
    required this.type,
    required this.avatar,
    required this.meetingStory,
    required this.memories,
    required this.stage,
    required this.tokenUsed,
    required this.maxToken,
    required this.createdAt,
    required this.lastChatAt,
    this.favorabilityScore = 10,
    this.personality = const {},
  });

  /// 创建新的AI伴侣
  factory CompanionModel.create({
    required String name,
    required CompanionType type,
    required MeetingStory meetingStory,
    int maxToken = 4000, // 默认4K token限制
  }) {
    final now = DateTime.now();
    return CompanionModel(
      id: 'companion_${now.millisecondsSinceEpoch}',
      name: name,
      type: type,
      avatar: _getAvatarForType(type),
      meetingStory: meetingStory,
      memories: [],
      stage: RelationshipStage.stranger,
      tokenUsed: 0,
      maxToken: maxToken,
      createdAt: now,
      lastChatAt: now,
      favorabilityScore: 10,
      personality: _getPersonalityForType(type),
    );
  }

  /// 从JSON创建对象
  factory CompanionModel.fromJson(Map<String, dynamic> json) {
    var memoriesList = json['memories'] as List? ?? [];

    return CompanionModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: CompanionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CompanionType.gentleGirl,
      ),
      avatar: json['avatar'] ?? '',
      meetingStory: MeetingStory.fromJson(json['meetingStory'] ?? {}),
      memories: memoriesList.map((item) => MemoryFragment.fromJson(item)).toList(),
      stage: RelationshipStage.values.firstWhere(
        (e) => e.name == json['stage'],
        orElse: () => RelationshipStage.stranger,
      ),
      tokenUsed: json['tokenUsed'] ?? 0,
      maxToken: json['maxToken'] ?? 4000,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastChatAt: DateTime.parse(json['lastChatAt'] ?? DateTime.now().toIso8601String()),
      favorabilityScore: json['favorabilityScore'] ?? 10,
      personality: Map<String, dynamic>.from(json['personality'] ?? {}),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'avatar': avatar,
      'meetingStory': meetingStory.toJson(),
      'memories': memories.map((memory) => memory.toJson()).toList(),
      'stage': stage.name,
      'tokenUsed': tokenUsed,
      'maxToken': maxToken,
      'createdAt': createdAt.toIso8601String(),
      'lastChatAt': lastChatAt.toIso8601String(),
      'favorabilityScore': favorabilityScore,
      'personality': personality,
    };
  }

  /// 复制对象并修改部分属性
  CompanionModel copyWith({
    String? id,
    String? name,
    CompanionType? type,
    String? avatar,
    MeetingStory? meetingStory,
    List<MemoryFragment>? memories,
    RelationshipStage? stage,
    int? tokenUsed,
    int? maxToken,
    DateTime? createdAt,
    DateTime? lastChatAt,
    int? favorabilityScore,
    Map<String, dynamic>? personality,
  }) {
    return CompanionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      avatar: avatar ?? this.avatar,
      meetingStory: meetingStory ?? this.meetingStory,
      memories: memories ?? this.memories,
      stage: stage ?? this.stage,
      tokenUsed: tokenUsed ?? this.tokenUsed,
      maxToken: maxToken ?? this.maxToken,
      createdAt: createdAt ?? this.createdAt,
      lastChatAt: lastChatAt ?? this.lastChatAt,
      favorabilityScore: favorabilityScore ?? this.favorabilityScore,
      personality: personality ?? this.personality,
    );
  }

  /// 获取类型对应的中文名称
  String get typeName {
    switch (type) {
      case CompanionType.gentleGirl:
        return '温柔女生';
      case CompanionType.livelyGirl:
        return '活泼女生';
      case CompanionType.elegantGirl:
        return '优雅女生';
      case CompanionType.mysteriousGirl:
        return '神秘女生';
      case CompanionType.sunnyBoy:
        return '阳光男生';
      case CompanionType.matureBoy:
        return '成熟男生';
    }
  }

  /// 获取关系阶段的中文名称
  String get stageName {
    switch (stage) {
      case RelationshipStage.stranger:
        return '陌生期';
      case RelationshipStage.familiar:
        return '熟悉期';
      case RelationshipStage.intimate:
        return '亲密期';
      case RelationshipStage.mature:
        return '成熟期';
    }
  }

  /// 检查是否接近token限制
  bool get isNearTokenLimit => tokenUsed >= (maxToken * 0.8);

  /// 检查是否应该触发结局
  bool get shouldTriggerEnding => tokenUsed >= (maxToken * 0.95);

  /// 获取关系持续天数
  int get relationshipDays {
    return DateTime.now().difference(createdAt).inDays;
  }

  /// 添加记忆片段
  CompanionModel addMemory(MemoryFragment memory) {
    final updatedMemories = [...memories, memory];

    // 限制记忆片段数量，保留最重要的
    if (updatedMemories.length > 20) {
      updatedMemories.sort((a, b) => b.emotionalWeight.compareTo(a.emotionalWeight));
      updatedMemories.removeRange(15, updatedMemories.length);
    }

    return copyWith(memories: updatedMemories);
  }

  /// 更新token使用量
  CompanionModel updateTokenUsage(int newTokenUsed) {
    return copyWith(
      tokenUsed: newTokenUsed,
      lastChatAt: DateTime.now(),
    );
  }

  /// 更新好感度
  CompanionModel updateFavorability(int newScore) {
    return copyWith(favorabilityScore: newScore.clamp(0, 100));
  }

  /// 进入下一个关系阶段
  CompanionModel advanceStage() {
    final nextStage = switch (stage) {
      RelationshipStage.stranger => RelationshipStage.familiar,
      RelationshipStage.familiar => RelationshipStage.intimate,
      RelationshipStage.intimate => RelationshipStage.mature,
      RelationshipStage.mature => RelationshipStage.mature, // 保持在最高阶段
    };

    return copyWith(stage: nextStage);
  }

  /// 获取类型对应的头像路径
  static String _getAvatarForType(CompanionType type) {
    switch (type) {
      case CompanionType.gentleGirl:
        return 'assets/images/companions/gentle_girl.png';
      case CompanionType.livelyGirl:
        return 'assets/images/companions/lively_girl.png';
      case CompanionType.elegantGirl:
        return 'assets/images/companions/elegant_girl.png';
      case CompanionType.mysteriousGirl:
        return 'assets/images/companions/mysterious_girl.png';
      case CompanionType.sunnyBoy:
        return 'assets/images/companions/sunny_boy.png';
      case CompanionType.matureBoy:
        return 'assets/images/companions/mature_boy.png';
    }
  }

  /// 获取类型对应的个性特征
  static Map<String, dynamic> _getPersonalityForType(CompanionType type) {
    switch (type) {
      case CompanionType.gentleGirl:
        return {'warmth': 95, 'patience': 90, 'understanding': 85};
      case CompanionType.livelyGirl:
        return {'energy': 95, 'humor': 85, 'spontaneity': 90};
      case CompanionType.elegantGirl:
        return {'sophistication': 95, 'intelligence': 90, 'grace': 85};
      case CompanionType.mysteriousGirl:
        return {'mystery': 95, 'depth': 90, 'intrigue': 85};
      case CompanionType.sunnyBoy:
        return {'optimism': 95, 'energy': 90, 'reliability': 85};
      case CompanionType.matureBoy:
        return {'wisdom': 95, 'stability': 90, 'leadership': 85};
    }
  }

  @override
  String toString() {
    return 'CompanionModel(id: $id, name: $name, type: $typeName, stage: $stageName)';
  }
}