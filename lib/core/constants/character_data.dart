// lib/core/constants/character_data.dart

import '../models/character_model.dart';

/// 预设角色数据
class CharacterData {
  static List<CharacterModel> get allCharacters => [
    gentleGirl,
    livelyGirl,
    elegantGirl,
    sunnyBoy,
  ];

  /// 温柔女生
  static final CharacterModel gentleGirl = CharacterModel(
    id: 'gentle_girl',
    name: '温柔女生',
    description: '温和体贴，笑容如春风，眼神水润，像是邻家姐姐',
    avatar: 'assets/images/characters/gentle_girl.png',
    type: CharacterType.gentle,
    traits: const PersonalityTraits(
      independence: 60,
      strength: 70,
      rationality: 65,
      maturity: 80,
      warmth: 95,
      playfulness: 40,
      elegance: 70,
      mystery: 30,
    ),
    scenarios: ['日常聊天', '工作交流', '情感倾诉', '生活分享'],
    gender: 'female',
  );

  /// 活泼女生
  static final CharacterModel livelyGirl = CharacterModel(
    id: 'lively_girl',
    name: '活泼女生',
    description: '充满活力，表情生动，笑声清脆，如校园里的阳光少女',
    avatar: 'assets/images/characters/lively_girl.png',
    type: CharacterType.lively,
    traits: const PersonalityTraits(
      independence: 75,
      strength: 80,
      rationality: 45,
      maturity: 60,
      warmth: 85,
      playfulness: 95,
      elegance: 50,
      mystery: 20,
    ),
    scenarios: ['运动健身', '娱乐活动', '旅行分享', '兴趣爱好'],
    gender: 'female',
  );

  /// 优雅女生
  static final CharacterModel elegantGirl = CharacterModel(
    id: 'elegant_girl',
    name: '优雅女生',
    description: '气质高贵，动作轻盈，笑容淡雅，像是参加舞会的贵族小姐',
    avatar: 'assets/images/characters/elegant_girl.png',
    type: CharacterType.elegant,
    traits: const PersonalityTraits(
      independence: 85,
      strength: 75,
      rationality: 90,
      maturity: 95,
      warmth: 60,
      playfulness: 30,
      elegance: 95,
      mystery: 80,
    ),
    scenarios: ['艺术欣赏', '文化交流', '商务社交', '品味生活'],
    gender: 'female',
  );

  /// 阳光男生
  static final CharacterModel sunnyBoy = CharacterModel(
    id: 'sunny_boy',
    name: '阳光男生',
    description: '充满活力，给人温暖感，表情明亮，眼神清澈，如清晨的少年',
    avatar: 'assets/images/characters/sunny_boy.png',
    type: CharacterType.sunny,
    traits: const PersonalityTraits(
      independence: 80,
      strength: 85,
      rationality: 70,
      maturity: 75,
      warmth: 90,
      playfulness: 85,
      elegance: 60,
      mystery: 25,
    ),
    scenarios: ['运动健身', '户外活动', '创业分享', '友情交流'],
    gender: 'male',
  );

  /// 根据ID获取角色
  static CharacterModel? getCharacterById(String id) {
    try {
      return allCharacters.firstWhere((char) => char.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 获取女性角色
  static List<CharacterModel> get femaleCharacters {
    return allCharacters.where((char) => char.gender == 'female').toList();
  }

  /// 获取男性角色
  static List<CharacterModel> get maleCharacters {
    return allCharacters.where((char) => char.gender == 'male').toList();
  }

  /// 获取免费角色
  static List<CharacterModel> get freeCharacters {
    return allCharacters.where((char) => !char.isVip).toList();
  }

  /// 获取VIP角色
  static List<CharacterModel> get vipCharacters {
    return allCharacters.where((char) => char.isVip).toList();
  }
}