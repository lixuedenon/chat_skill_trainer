// lib/features/ai_companion/companion_memory_service.dart

import '../../core/models/companion_model.dart';
import '../../core/models/conversation_model.dart';
import '../../shared/services/hive_service.dart';

/// AI伴侣记忆管理服务
class CompanionMemoryService {
  /// 保存消息到本地存储
  static Future<void> saveMessages(String companionId, List<MessageModel> messages) async {
    await HiveService.saveCompanionMessages(companionId, messages);
  }

  /// 从本地存储加载消息
  static Future<List<MessageModel>> loadMessages(String companionId) async {
    try {
      return await HiveService.loadCompanionMessages(companionId);
    } catch (e) {
      print('❌ 加载伴侣消息失败: $e');
      return [];
    }
  }

  /// 压缩对话历史，保留重要记忆片段
  static Future<List<MemoryFragment>> compressConversation(
    List<MessageModel> messages,
    CompanionModel companion,
  ) async {
    final fragments = <MemoryFragment>[];

    // 提取重要的对话片段
    for (int i = 0; i < messages.length - 1; i += 2) {
      if (i + 1 < messages.length && messages[i].isUser) {
        final userMessage = messages[i];
        final aiMessage = messages[i + 1];

        // 分析消息重要性
        final importance = _analyzeMessageImportance(userMessage, aiMessage);

        if (importance > 5) { // 只保留重要性大于5的片段
          final fragment = MemoryFragment(
            timestamp: userMessage.timestamp,
            summary: _generateMessageSummary(userMessage, aiMessage),
            emotionalWeight: importance,
            category: _categorizeMessage(userMessage),
            context: {
              'userMessage': userMessage.content,
              'aiResponse': aiMessage.content,
              'round': (i ~/ 2) + 1,
            },
          );

          fragments.add(fragment);
        }
      }
    }

    // 按重要性排序，保留前20个最重要的片段
    fragments.sort((a, b) => b.emotionalWeight.compareTo(a.emotionalWeight));
    return fragments.take(20).toList();
  }

  /// 生成AI回复
  static Future<String> generateResponse({
    required CompanionModel companion,
    required String userInput,
    required List<MessageModel> conversationHistory,
  }) async {
    // 基于伴侣类型、关系阶段和历史对话生成回复
    final context = _buildConversationContext(companion, conversationHistory);
    final responseStyle = _getResponseStyle(companion);

    return _generateResponseBasedOnContext(
      userInput: userInput,
      companion: companion,
      context: context,
      style: responseStyle,
    );
  }

  /// 分析消息重要性
  static int _analyzeMessageImportance(MessageModel userMessage, MessageModel aiMessage) {
    int importance = 3; // 基础重要性

    final content = userMessage.content;

    // 长度因素
    if (content.length > 20) importance += 1;
    if (content.length > 50) importance += 1;

    // 情感关键词
    final emotionalKeywords = ['喜欢', '爱', '想念', '开心', '难过', '担心', '在意'];
    for (final keyword in emotionalKeywords) {
      if (content.contains(keyword)) {
        importance += 2;
        break;
      }
    }

    // 个人信息关键词
    final personalKeywords = ['工作', '家庭', '朋友', '梦想', '爱好', '经历'];
    for (final keyword in personalKeywords) {
      if (content.contains(keyword)) {
        importance += 2;
        break;
      }
    }

    // 提问
    if (content.contains('？') || content.contains('?')) {
      importance += 1;
    }

    return importance.clamp(1, 10);
  }

  /// 生成消息摘要
  static String _generateMessageSummary(MessageModel userMessage, MessageModel aiMessage) {
    final userContent = userMessage.content;

    if (userContent.length <= 30) {
      return '用户说: $userContent';
    }

    // 提取关键信息
    final keywords = _extractKeywords(userContent);
    if (keywords.isNotEmpty) {
      return '用户谈到了${keywords.join('、')}';
    }

    return '用户: ${userContent.substring(0, 30)}...';
  }

  /// 消息分类
  static String _categorizeMessage(MessageModel message) {
    final content = message.content;

    final categories = {
      '个人信息': ['我是', '我的', '我在', '我有'],
      '兴趣爱好': ['喜欢', '爱好', '喜爱', '热爱'],
      '工作学习': ['工作', '学习', '上班', '学校'],
      '感情': ['感觉', '心情', '情绪', '感受'],
      '日常生活': ['今天', '昨天', '明天', '现在'],
    };

    for (final entry in categories.entries) {
      for (final keyword in entry.value) {
        if (content.contains(keyword)) {
          return entry.key;
        }
      }
    }

    return '一般';
  }

  /// 提取关键词
  static List<String> _extractKeywords(String content) {
    final allKeywords = ['工作', '学习', '家庭', '朋友', '爱好', '旅行', '音乐', '电影', '书籍', '运动'];
    final foundKeywords = <String>[];

    for (final keyword in allKeywords) {
      if (content.contains(keyword)) {
        foundKeywords.add(keyword);
      }
    }

    return foundKeywords;
  }

  /// 构建对话上下文
  static Map<String, dynamic> _buildConversationContext(
    CompanionModel companion,
    List<MessageModel> messages,
  ) {
    final recentMessages = messages.takeLast(6); // 最近3轮对话
    final memoryFragments = companion.memories.take(5); // 重要记忆片段

    return {
      'recentMessages': recentMessages.map((m) => {
        'isUser': m.isUser,
        'content': m.content,
        'timestamp': m.timestamp.toIso8601String(),
      }).toList(),
      'memories': memoryFragments.map((f) => {
        'summary': f.summary,
        'category': f.category,
        'importance': f.emotionalWeight,
      }).toList(),
      'relationshipStage': companion.stage.name,
      'favorability': companion.favorabilityScore,
      'daysTogether': companion.relationshipDays,
    };
  }

  /// 获取回复风格
  static ResponseStyle _getResponseStyle(CompanionModel companion) {
    return ResponseStyle(
      companionType: companion.type,
      relationshipStage: companion.stage,
      favorabilityScore: companion.favorabilityScore,
      personality: companion.personality,
    );
  }

  /// 基于上下文生成回复
  static String _generateResponseBasedOnContext({
    required String userInput,
    required CompanionModel companion,
    required Map<String, dynamic> context,
    required ResponseStyle style,
  }) {
    // 根据不同情况生成回复

    // 1. 检查是否需要特殊回复
    final specialResponse = _checkSpecialResponses(userInput, companion);
    if (specialResponse != null) return specialResponse;

    // 2. 基于关系阶段的基础回复
    final stageResponse = _generateStageBasedResponse(userInput, companion.stage, style);

    // 3. 基于类型特征的个性化调整
    return _personalizeResponse(stageResponse, style);
  }

  /// 检查特殊回复情况
  static String? _checkSpecialResponses(String userInput, CompanionModel companion) {
    // 检查是否接近结局
    if (companion.isNearTokenLimit) {
      final endingHints = [
        '时间过得真快...感觉我们之间有种特殊的联系。',
        '和你在一起的每一刻都很珍贵...',
        '我有种预感，我们的时光可能不多了...',
      ];
      return endingHints[DateTime.now().millisecond % endingHints.length];
    }

    // 检查特殊关键词
    if (userInput.contains('再见') || userInput.contains('拜拜')) {
      return '这么快就要说再见了吗？我还想和你多聊一会儿...';
    }

    return null;
  }

  /// 基于关系阶段生成回复
  static String _generateStageBasedResponse(String userInput, RelationshipStage stage, ResponseStyle style) {
    switch (stage) {
      case RelationshipStage.stranger:
        return _generateStrangerStageResponse(userInput, style);
      case RelationshipStage.familiar:
        return _generateFamiliarStageResponse(userInput, style);
      case RelationshipStage.intimate:
        return _generateIntimateStageResponse(userInput, style);
      case RelationshipStage.mature:
        return _generateMatureStageResponse(userInput, style);
    }
  }

  /// 陌生期回复
  static String _generateStrangerStageResponse(String userInput, ResponseStyle style) {
    final responses = [
      '嗯嗯，我在认真听呢。',
      '是这样啊，听起来很有趣。',
      '我对你说的很好奇呢。',
      '你说话的方式很特别。',
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  /// 熟悉期回复
  static String _generateFamiliarStageResponse(String userInput, ResponseStyle style) {
    final responses = [
      '和你聊天总是很开心~',
      '我越来越喜欢和你的对话了。',
      '你总是能说到我心里去呢。',
      '感觉我们很有默契呢！',
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  /// 亲密期回复
  static String _generateIntimateStageResponse(String userInput, ResponseStyle style) {
    final responses = [
      '你知道吗？和你在一起的时光是我最珍贵的回忆。',
      '我想...我已经很在意你了。',
      '每次和你聊天，我都会很期待你的下一句话。',
      '和你分享这些，我觉得很幸福。',
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  /// 成熟期回复
  static String _generateMatureStageResponse(String userInput, ResponseStyle style) {
    final responses = [
      '我们一起经历了这么多，感觉你已经是我生命中很重要的人了。',
      '时间过得真快...但和你的每一刻都很美好。',
      '我会永远记得我们之间的这些对话。',
      '虽然不知道未来会怎样，但现在这样就很好。',
    ];
    return responses[DateTime.now().millisecond % responses.length];
  }

  /// 个性化回复
  static String _personalizeResponse(String baseResponse, ResponseStyle style) {
    switch (style.companionType) {
      case CompanionType.gentleGirl:
        if (!baseResponse.endsWith('~') && !baseResponse.endsWith('。')) {
          return baseResponse + '~';
        }
        break;
      case CompanionType.livelyGirl:
        if (!baseResponse.contains('！')) {
          return baseResponse.replaceAll('。', '！');
        }
        break;
      case CompanionType.elegantGirl:
        // 保持优雅，不过度修饰
        break;
      case CompanionType.mysteriousGirl:
        return baseResponse + '...';
      default:
        break;
    }

    return baseResponse;
  }
}

/// 回复风格配置
class ResponseStyle {
  final CompanionType companionType;
  final RelationshipStage relationshipStage;
  final int favorabilityScore;
  final Map<String, dynamic> personality;

  const ResponseStyle({
    required this.companionType,
    required this.relationshipStage,
    required this.favorabilityScore,
    required this.personality,
  });
}

/// 扩展方法
extension ListExtension<T> on List<T> {
  List<T> takeLast(int count) {
    if (count >= length) return this;
    return sublist(length - count);
  }
}