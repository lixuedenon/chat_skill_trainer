// lib/core/models/user_model.dart

/// 用户魅力标签枚举
enum CharmTag {
  knowledge,    // 知识型魅力
  humor,        // 幽默型魅力
  emotional,    // 情感型魅力
  rational,     // 理性型魅力
  caring,       // 关怀型魅力
  confident,    // 自信型魅力
}

/// 用户等级模型
class UserLevel {
  final int level;           // 用户等级
  final String title;        // 等级称号
  final int experience;      // 经验值
  final int nextLevelExp;    // 下一级所需经验

  const UserLevel({
    required this.level,
    required this.title,
    required this.experience,
    required this.nextLevelExp,
  });

  /// 从JSON创建用户等级对象
  factory UserLevel.fromJson(Map<String, dynamic> json) {
    return UserLevel(
      level: json['level'] ?? 1,
      title: json['title'] ?? '新手',
      experience: json['experience'] ?? 0,
      nextLevelExp: json['nextLevelExp'] ?? 100,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'title': title,
      'experience': experience,
      'nextLevelExp': nextLevelExp,
    };
  }

  /// 获取进度百分比
  double get progressPercentage {
    if (nextLevelExp == 0) return 1.0;
    return experience / nextLevelExp;
  }
}

/// 用户统计数据模型
class UserStats {
  final int totalConversations;     // 总对话次数
  final int successfulConversations; // 成功对话次数
  final double averageFavorability; // 平均好感度
  final int totalRounds;           // 总轮数
  final int highestFavorability;   // 最高好感度
  final Map<String, int> characterInteractions; // 与各角色的互动次数

  const UserStats({
    required this.totalConversations,
    required this.successfulConversations,
    required this.averageFavorability,
    required this.totalRounds,
    required this.highestFavorability,
    required this.characterInteractions,
  });

  /// 从JSON创建用户统计对象
  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalConversations: json['totalConversations'] ?? 0,
      successfulConversations: json['successfulConversations'] ?? 0,
      averageFavorability: (json['averageFavorability'] ?? 0.0).toDouble(),
      totalRounds: json['totalRounds'] ?? 0,
      highestFavorability: json['highestFavorability'] ?? 0,
      characterInteractions: Map<String, int>.from(json['characterInteractions'] ?? {}),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'totalConversations': totalConversations,
      'successfulConversations': successfulConversations,
      'averageFavorability': averageFavorability,
      'totalRounds': totalRounds,
      'highestFavorability': highestFavorability,
      'characterInteractions': characterInteractions,
    };
  }

  /// 获取成功率
  double get successRate {
    if (totalConversations == 0) return 0.0;
    return successfulConversations / totalConversations;
  }

  /// 获取平均轮数
  double get averageRounds {
    if (totalConversations == 0) return 0.0;
    return totalRounds / totalConversations;
  }
}

/// 用户偏好设置模型
class UserPreferences {
  final String language;        // 语言偏好
  final String themeMode;       // 主题模式 light/dark/system
  final bool soundEnabled;      // 音效开关
  final bool notificationEnabled; // 通知开关
  final List<String> favoriteCharacters; // 收藏角色列表

  const UserPreferences({
    this.language = 'zh',
    this.themeMode = 'system',
    this.soundEnabled = true,
    this.notificationEnabled = true,
    this.favoriteCharacters = const [],
  });

  /// 从JSON创建用户偏好对象
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      language: json['language'] ?? 'zh',
      themeMode: json['themeMode'] ?? 'system',
      soundEnabled: json['soundEnabled'] ?? true,
      notificationEnabled: json['notificationEnabled'] ?? true,
      favoriteCharacters: List<String>.from(json['favoriteCharacters'] ?? []),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'themeMode': themeMode,
      'soundEnabled': soundEnabled,
      'notificationEnabled': notificationEnabled,
      'favoriteCharacters': favoriteCharacters,
    };
  }

  /// 复制偏好设置并修改部分属性
  UserPreferences copyWith({
    String? language,
    String? themeMode,
    bool? soundEnabled,
    bool? notificationEnabled,
    List<String>? favoriteCharacters,
  }) {
    return UserPreferences(
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      favoriteCharacters: favoriteCharacters ?? this.favoriteCharacters,
    );
  }
}

/// 用户数据模型
class UserModel {
  final String id;                        // 用户ID
  final String username;                  // 用户名
  final String email;                     // 邮箱
  final DateTime createdAt;               // 创建时间
  final DateTime lastLoginAt;             // 最后登录时间
  final int credits;                      // 剩余对话次数
  final List<CharmTag> charmTags;         // 魅力标签
  final UserLevel userLevel;              // 用户等级
  final UserStats stats;                  // 统计数据
  final UserPreferences preferences;       // 偏好设置
  final bool isVipUser;                   // 是否VIP用户
  final List<String> conversationHistory; // 对话历史ID列表

  const UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.lastLoginAt,
    this.credits = 100,
    this.charmTags = const [],
    required this.userLevel,
    required this.stats,
    required this.preferences,
    this.isVipUser = false,
    this.conversationHistory = const [],
  });

  /// 创建新用户
  factory UserModel.newUser({
    required String id,
    required String username,
    required String email,
  }) {
    final now = DateTime.now();
    return UserModel(
      id: id,
      username: username,
      email: email,
      createdAt: now,
      lastLoginAt: now,
      credits: 100, // 新用户赠送100次对话
      charmTags: [],
      userLevel: const UserLevel(
        level: 1,
        title: '聊天新手',
        experience: 0,
        nextLevelExp: 100,
      ),
      stats: const UserStats(
        totalConversations: 0,
        successfulConversations: 0,
        averageFavorability: 0.0,
        totalRounds: 0,
        highestFavorability: 0,
        characterInteractions: {},
      ),
      preferences: const UserPreferences(),
      isVipUser: false,
      conversationHistory: [],
    );
  }

  /// 从JSON创建用户对象
  factory UserModel.fromJson(Map<String, dynamic> json) {
    var charmTagsList = json['charmTags'] as List? ?? [];
    var historyList = json['conversationHistory'] as List? ?? [];

    return UserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] ?? DateTime.now().toIso8601String()),
      credits: json['credits'] ?? 100,
      charmTags: charmTagsList.map((tag) => CharmTag.values.firstWhere(
        (e) => e.name == tag,
        orElse: () => CharmTag.knowledge,
      )).toList(),
      userLevel: UserLevel.fromJson(json['userLevel'] ?? {}),
      stats: UserStats.fromJson(json['stats'] ?? {}),
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
      isVipUser: json['isVipUser'] ?? false,
      conversationHistory: List<String>.from(historyList),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'credits': credits,
      'charmTags': charmTags.map((tag) => tag.name).toList(),
      'userLevel': userLevel.toJson(),
      'stats': stats.toJson(),
      'preferences': preferences.toJson(),
      'isVipUser': isVipUser,
      'conversationHistory': conversationHistory,
    };
  }

  /// 复制用户对象并修改部分属性
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    int? credits,
    List<CharmTag>? charmTags,
    UserLevel? userLevel,
    UserStats? stats,
    UserPreferences? preferences,
    bool? isVipUser,
    List<String>? conversationHistory,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      credits: credits ?? this.credits,
      charmTags: charmTags ?? this.charmTags,
      userLevel: userLevel ?? this.userLevel,
      stats: stats ?? this.stats,
      preferences: preferences ?? this.preferences,
      isVipUser: isVipUser ?? this.isVipUser,
      conversationHistory: conversationHistory ?? this.conversationHistory,
    );
  }

  /// 消耗对话次数
  UserModel consumeCredits(int amount) {
    final newCredits = (credits - amount).clamp(0, double.infinity).toInt();
    return copyWith(credits: newCredits);
  }

  /// 增加对话次数
  UserModel addCredits(int amount) {
    return copyWith(credits: credits + amount);
  }

  /// 更新最后登录时间
  UserModel updateLastLogin() {
    return copyWith(lastLoginAt: DateTime.now());
  }

  /// 添加对话历史
  UserModel addConversationHistory(String conversationId) {
    final newHistory = [...conversationHistory, conversationId];
    return copyWith(conversationHistory: newHistory);
  }

  /// 检查是否有足够的对话次数
  bool hasEnoughCredits(int required) {
    return credits >= required;
  }

  /// 获取魅力标签的中文名称
  String getCharmTagName(CharmTag tag) {
    switch (tag) {
      case CharmTag.knowledge:
        return '知识型魅力';
      case CharmTag.humor:
        return '幽默型魅力';
      case CharmTag.emotional:
        return '情感型魅力';
      case CharmTag.rational:
        return '理性型魅力';
      case CharmTag.caring:
        return '关怀型魅力';
      case CharmTag.confident:
        return '自信型魅力';
    }
  }

  /// 获取所有魅力标签的中文名称
  List<String> get charmTagNames {
    return charmTags.map((tag) => getCharmTagName(tag)).toList();
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, level: ${userLevel.level}, credits: $credits)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}