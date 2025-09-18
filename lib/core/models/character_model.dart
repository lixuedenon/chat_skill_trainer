// lib/core/models/character_model.dart

/// 角色类型枚举
enum CharacterType {
  gentle,     // 温柔
  lively,     // 活泼
  elegant,    // 优雅
  playful,    // 俏皮
  resilient,  // 坚韧
  shy,        // 娇羞
  wise,       // 聪慧
  cold,       // 冷艳
  sunny,      // 阳光(男)
  mature,     // 成熟(男)
}

/// 性格特征数据模型
class PersonalityTraits {
  final int independence;    // 独立性 0-100
  final int strength;       // 坚强度 0-100
  final int rationality;    // 理性度 0-100
  final int maturity;       // 成熟度 0-100
  final int warmth;         // 温暖度 0-100
  final int playfulness;    // 俏皮度 0-100
  final int elegance;       // 优雅度 0-100
  final int mystery;        // 神秘感 0-100

  const PersonalityTraits({
    required this.independence,
    required this.strength,
    required this.rationality,
    required this.maturity,
    required this.warmth,
    required this.playfulness,
    required this.elegance,
    required this.mystery,
  });

  /// 从JSON创建对象
  factory PersonalityTraits.fromJson(Map<String, dynamic> json) {
    return PersonalityTraits(
      independence: json['independence'] ?? 50,
      strength: json['strength'] ?? 50,
      rationality: json['rationality'] ?? 50,
      maturity: json['maturity'] ?? 50,
      warmth: json['warmth'] ?? 50,
      playfulness: json['playfulness'] ?? 50,
      elegance: json['elegance'] ?? 50,
      mystery: json['mystery'] ?? 50,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'independence': independence,
      'strength': strength,
      'rationality': rationality,
      'maturity': maturity,
      'warmth': warmth,
      'playfulness': playfulness,
      'elegance': elegance,
      'mystery': mystery,
    };
  }
}

/// 角色数据模型
class CharacterModel {
  final String id;                    // 角色ID
  final String name;                  // 角色名称
  final String description;           // 角色描述
  final String avatar;                // 头像路径
  final CharacterType type;           // 角色类型
  final PersonalityTraits traits;     // 性格特征
  final List<String> scenarios;       // 适用场景
  final bool isVip;                   // 是否VIP角色
  final String gender;                // 性别 "male" / "female"

  const CharacterModel({
    required this.id,
    required this.name,
    required this.description,
    required this.avatar,
    required this.type,
    required this.traits,
    required this.scenarios,
    this.isVip = false,
    required this.gender,
  });

  /// 从JSON创建角色对象
  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      avatar: json['avatar'] ?? '',
      type: CharacterType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CharacterType.gentle,
      ),
      traits: PersonalityTraits.fromJson(json['traits'] ?? {}),
      scenarios: List<String>.from(json['scenarios'] ?? []),
      isVip: json['isVip'] ?? false,
      gender: json['gender'] ?? 'female',
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'avatar': avatar,
      'type': type.name,
      'traits': traits.toJson(),
      'scenarios': scenarios,
      'isVip': isVip,
      'gender': gender,
    };
  }

  /// 获取角色类型的中文名称
  String get typeName {
    switch (type) {
      case CharacterType.gentle:
        return '温柔';
      case CharacterType.lively:
        return '活泼';
      case CharacterType.elegant:
        return '优雅';
      case CharacterType.playful:
        return '俏皮';
      case CharacterType.resilient:
        return '坚韧';
      case CharacterType.shy:
        return '娇羞';
      case CharacterType.wise:
        return '聪慧';
      case CharacterType.cold:
        return '冷艳';
      case CharacterType.sunny:
        return '阳光';
      case CharacterType.mature:
        return '成熟';
    }
  }

  /// 复制角色对象并修改部分属性
  CharacterModel copyWith({
    String? id,
    String? name,
    String? description,
    String? avatar,
    CharacterType? type,
    PersonalityTraits? traits,
    List<String>? scenarios,
    bool? isVip,
    String? gender,
  }) {
    return CharacterModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      avatar: avatar ?? this.avatar,
      type: type ?? this.type,
      traits: traits ?? this.traits,
      scenarios: scenarios ?? this.scenarios,
      isVip: isVip ?? this.isVip,
      gender: gender ?? this.gender,
    );
  }

  @override
  String toString() {
    return 'CharacterModel(id: $id, name: $name, type: $typeName, gender: $gender)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CharacterModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}