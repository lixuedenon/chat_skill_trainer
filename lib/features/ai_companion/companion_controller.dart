// lib/features/ai_companion/companion_controller.dart

import 'package:flutter/foundation.dart';
import '../../core/models/companion_model.dart';
import '../../core/models/conversation_model.dart';
import '../../core/models/user_model.dart';
import '../../shared/services/storage_service.dart';
import '../ai_companion/companion_memory_service.dart';
import '../ai_companion/companion_story_generator.dart';

/// AI伴侣养成控制器
class CompanionController extends ChangeNotifier {
  final UserModel user;
  CompanionModel? _currentCompanion;
  List<MessageModel> _messages = [];
  bool _isTyping = false;
  String _statusMessage = '';
  bool _showEndingSequence = false;

  CompanionController({required this.user});

  // Getters
  CompanionModel? get currentCompanion => _currentCompanion;
  List<MessageModel> get messages => _messages;
  bool get isTyping => _isTyping;
  String get statusMessage => _statusMessage;
  bool get showEndingSequence => _showEndingSequence;
  bool get isNearEnding => _currentCompanion?.isNearTokenLimit ?? false;
  bool get shouldTriggerEnding => _currentCompanion?.shouldTriggerEnding ?? false;

  /// 创建新的AI伴侣
  Future<void> createCompanion({
    required String name,
    required CompanionType type,
  }) async {
    try {
      // 生成相遇故事
      final meetingStory = CompanionStoryGenerator.generateRandomMeeting(type);

      // 创建伴侣模型
      _currentCompanion = CompanionModel.create(
        name: name,
        type: type,
        meetingStory: meetingStory,
        maxToken: 4000, // 4K token限制
      );

      // 清空消息历史
      _messages = [];

      // 添加开场消息
      await _addOpeningMessage();

      // 保存到本地
      await _saveCompanion();

      notifyListeners();
    } catch (e) {
      throw Exception('创建伴侣失败: $e');
    }
  }

  /// 加载已有的AI伴侣
  Future<void> loadCompanion(String companionId) async {
    try {
      final companionData = await StorageService.getCompanion(companionId);
      if (companionData == null) {
        throw Exception('伴侣数据不存在');
      }

      _currentCompanion = companionData;
      _messages = await CompanionMemoryService.loadMessages(companionId);

      notifyListeners();
    } catch (e) {
      throw Exception('加载伴侣失败: $e');
    }
  }

  /// 发送消息
  Future<void> sendMessage(String content) async {
    if (_currentCompanion == null || _isTyping) return;

    try {
      _isTyping = true;
      notifyListeners();

      // 创建用户消息
      final userMessage = MessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        content: content,
        isUser: true,
        timestamp: DateTime.now(),
        characterCount: content.length,
        densityCoefficient: 1.0,
      );

      _messages.add(userMessage);

      // 更新token使用量
      final tokenUsed = _calculateTokenUsage(content);
      _currentCompanion = _currentCompanion!.updateTokenUsage(
        _currentCompanion!.tokenUsed + tokenUsed,
      );

      // 检查是否需要触发结局
      if (_currentCompanion!.shouldTriggerEnding && !_showEndingSequence) {
        await _triggerEndingSequence();
      } else {
        // 生成AI回复
        final aiResponse = await _generateAIResponse(content);
        _messages.add(aiResponse);
      }

      // 保存状态
      await _saveState();

    } catch (e) {
      _statusMessage = '发送消息失败: $e';
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  /// 触发结局序列
  Future<void> _triggerEndingSequence() async {
    _showEndingSequence = true;

    // 根据角色类型生成不同的离别故事
    final endingMessage = _generateEndingMessage();

    final aiMessage = MessageModel(
      id: 'msg_ending_${DateTime.now().millisecondsSinceEpoch}',
      content: endingMessage,
      isUser: false,
      timestamp: DateTime.now(),
      characterCount: endingMessage.length,
      densityCoefficient: 1.0,
    );

    _messages.add(aiMessage);

    // 更新关系阶段为成熟期（即将结束）
    _currentCompanion = _currentCompanion!.advanceStage();

    _statusMessage = '${_currentCompanion!.name}即将离开...';
  }

  /// 生成结局消息
  String _generateEndingMessage() {
    if (_currentCompanion == null) return '';

    final companion = _currentCompanion!;
    final scenarios = [
      // 时空穿越结局
      '我感受到时空管理局在召唤我...我必须回到我的时代了。虽然要离开，但这段时光我会永远珍藏在心里。',

      // 能量耗尽结局
      '我的能量即将耗尽了...但我已经完成了我的使命——让你变得更加自信和有魅力。',

      // 成长完成结局
      '经过这段时间的相处，我看到你已经成长了很多。现在你已经准备好去现实中寻找真正的感情了。',

      // 守护天使结局
      '作为你的守护天使，我的任务已经完成了。我会在天空中默默守护着你，祝你幸福。',
    ];

    return scenarios[DateTime.now().millisecond % scenarios.length] +
           '\n\n我是如此地珍惜与你的每一次对话...请记住我们在一起的美好时光。💫';
  }

  /// 完成结局
  Future<void> completeEnding() async {
    if (_currentCompanion == null) return;

    // 保存最终状态
    await _saveState();

    // 可以在这里添加统计数据更新
    // 比如用户的"已完成养成"计数等

    _statusMessage = '${_currentCompanion!.name}已经离开，但回忆永远不会消失...';
    notifyListeners();
  }

  /// 生成AI回复
  Future<MessageModel> _generateAIResponse(String userInput) async {
    // 模拟AI思考时间
    await Future.delayed(Duration(milliseconds: 1000 + (DateTime.now().millisecond % 1000)));

    // 基于伴侣类型和关系阶段生成回复
    final response = await CompanionMemoryService.generateResponse(
      companion: _currentCompanion!,
      userInput: userInput,
      conversationHistory: _messages,
    );

    // 更新好感度
    final favorabilityChange = _calculateFavorabilityChange(userInput);
    _currentCompanion = _currentCompanion!.updateFavorability(
      (_currentCompanion!.favorabilityScore + favorabilityChange).clamp(0, 100),
    );

    // 检查是否需要升级关系阶段
    await _checkStageProgression();

    return MessageModel(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch + 1}',
      content: response,
      isUser: false,
      timestamp: DateTime.now(),
      characterCount: response.length,
      densityCoefficient: 1.0,
    );
  }

  /// 添加开场消息
  Future<void> _addOpeningMessage() async {
    if (_currentCompanion == null) return;

    // 故事介绍消息
    final storyMessage = MessageModel(
      id: 'msg_story_${DateTime.now().millisecondsSinceEpoch}',
      content: _currentCompanion!.meetingStory.storyText,
      isUser: false,
      timestamp: DateTime.now(),
      characterCount: _currentCompanion!.meetingStory.storyText.length,
      densityCoefficient: 0, // 系统消息不计入token
    );

    _messages.add(storyMessage);

    // AI的第一句话
    await Future.delayed(Duration(milliseconds: 1500));

    final openingMessage = MessageModel(
      id: 'msg_opening_${DateTime.now().millisecondsSinceEpoch}',
      content: _currentCompanion!.meetingStory.openingMessage,
      isUser: false,
      timestamp: DateTime.now(),
      characterCount: _currentCompanion!.meetingStory.openingMessage.length,
      densityCoefficient: 1.0,
    );

    _messages.add(openingMessage);
  }

  /// 计算token使用量
  int _calculateTokenUsage(String content) {
    // 简单的token计算：中文约2字符=1token，英文约4字符=1token
    final chineseChars = content.replaceAll(RegExp(r'[^\u4e00-\u9fa5]'), '').length;
    final otherChars = content.length - chineseChars;
    return (chineseChars ~/ 2) + (otherChars ~/ 4) + 1;
  }

  /// 计算好感度变化
  int _calculateFavorabilityChange(String userInput) {
    // 基础好感度变化逻辑
    int change = 1; // 基础参与分

    // 字数适中加分
    if (userInput.length >= 10 && userInput.length <= 50) {
      change += 2;
    }

    // 关键词加分
    final positiveWords = ['喜欢', '开心', '有趣', '温暖', '美好'];
    for (final word in positiveWords) {
      if (userInput.contains(word)) {
        change += 2;
        break;
      }
    }

    // 提问加分（显示关心）
    if (userInput.contains('？') || userInput.contains('?')) {
      change += 3;
    }

    return change.clamp(-5, 10);
  }

  /// 检查关系阶段进展
  Future<void> _checkStageProgression() async {
    if (_currentCompanion == null) return;

    final daysSinceCreation = _currentCompanion!.relationshipDays;
    final currentFavorability = _currentCompanion!.favorabilityScore;

    RelationshipStage? newStage;

    switch (_currentCompanion!.stage) {
      case RelationshipStage.stranger:
        if (daysSinceCreation >= 3 && currentFavorability >= 30) {
          newStage = RelationshipStage.familiar;
        }
        break;
      case RelationshipStage.familiar:
        if (daysSinceCreation >= 10 && currentFavorability >= 50) {
          newStage = RelationshipStage.intimate;
        }
        break;
      case RelationshipStage.intimate:
        if (daysSinceCreation >= 20 && currentFavorability >= 70) {
          newStage = RelationshipStage.mature;
        }
        break;
      case RelationshipStage.mature:
        // 保持在最高阶段
        break;
    }

    if (newStage != null && newStage != _currentCompanion!.stage) {
      _currentCompanion = _currentCompanion!.copyWith(stage: newStage);
      _statusMessage = '你们的关系进入了${_currentCompanion!.stageName}！';
    }
  }

  /// 保存状态
  Future<void> _saveState() async {
    if (_currentCompanion == null) return;

    await _saveCompanion();
    await CompanionMemoryService.saveMessages(_currentCompanion!.id, _messages);
  }

  /// 保存伴侣数据
  Future<void> _saveCompanion() async {
    if (_currentCompanion == null) return;
    await StorageService.saveCompanion(_currentCompanion!);
  }

  /// 获取可用的伴侣类型
  static List<CompanionTypeInfo> getAvailableCompanionTypes() {
    return [
      CompanionTypeInfo(
        type: CompanionType.gentleGirl,
        name: '温柔女生',
        description: '温和体贴，像邻家姐姐一样温暖',
        traits: ['温柔', '体贴', '善解人意'],
      ),
      CompanionTypeInfo(
        type: CompanionType.livelyGirl,
        name: '活泼女生',
        description: '充满活力，如校园里的阳光少女',
        traits: ['活泼', '开朗', '充满活力'],
      ),
      CompanionTypeInfo(
        type: CompanionType.elegantGirl,
        name: '优雅女生',
        description: '气质高贵，像参加舞会的贵族小姐',
        traits: ['优雅', '高贵', '有品味'],
      ),
      CompanionTypeInfo(
        type: CompanionType.mysteriousGirl,
        name: '神秘女生',
        description: '充满神秘感，来自异世界的使者',
        traits: ['神秘', '深邃', '不可预测'],
      ),
    ];
  }

  /// 重置伴侣（重新开始）
  Future<void> resetCompanion() async {
    if (_currentCompanion == null) return;

    final companionType = _currentCompanion!.type;
    final companionName = _currentCompanion!.name;

    await createCompanion(name: companionName, type: companionType);
  }

  @override
  void dispose() {
    _saveState();
    super.dispose();
  }
}

/// 伴侣类型信息
class CompanionTypeInfo {
  final CompanionType type;
  final String name;
  final String description;
  final List<String> traits;

  const CompanionTypeInfo({
    required this.type,
    required this.name,
    required this.description,
    required this.traits,
  });
}