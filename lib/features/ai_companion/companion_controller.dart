// lib/features/ai_companion/companion_controller.dart (恢复延迟回调版)

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../../core/models/companion_model.dart';
import '../../core/models/conversation_model.dart';
import '../../core/models/user_model.dart';
import '../../shared/services/storage_service.dart';
import '../ai_companion/companion_memory_service.dart';
import '../ai_companion/companion_story_generator.dart';

class CompanionController extends ChangeNotifier {
  final UserModel user;
  CompanionModel? _currentCompanion;
  List<CompanionModel> _existingCompanions = [];
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  String _statusMessage = '';
  bool _showEndingSequence = false;

  CompanionController({required this.user});

  // Getters
  CompanionModel? get currentCompanion => _currentCompanion;
  List<CompanionModel> get existingCompanions => _existingCompanions;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  String get statusMessage => _statusMessage;
  bool get showEndingSequence => _showEndingSequence;
  bool get isNearEnding => _currentCompanion?.isNearTokenLimit ?? false;
  bool get shouldTriggerEnding => _currentCompanion?.shouldTriggerEnding ?? false;
  bool get canSendMessage => !_isTyping && _currentCompanion != null;

  Future<void> loadExistingCompanions() async {
    _isLoading = true;
    print('🟡 即将调用notifyListeners - loadExistingCompanions方法开始');
    notifyListeners();
    print('🟢 notifyListeners调用完成 - loadExistingCompanions方法开始');

    try {
      _existingCompanions = await StorageService.getCompanions();
    } catch (e) {
      _statusMessage = '加载伴侣列表失败: ${e.toString()}';
    } finally {
      _isLoading = false;
      print('🟡 即将调用notifyListeners - loadExistingCompanions方法结束');
      notifyListeners();
      print('🟢 notifyListeners调用完成 - loadExistingCompanions方法结束');
    }
  }

  Future<void> initializeCompanion(CompanionModel companion) async {
    _isLoading = true;
    _currentCompanion = companion;
    print('🟡 即将调用notifyListeners - initializeCompanion方法开始');
    notifyListeners();
    print('🟢 notifyListeners调用完成 - initializeCompanion方法开始');

    try {
      _messages = await CompanionMemoryService.loadMessages(companion.id);
      if (_messages.isEmpty) {
        await _addOpeningMessage();
      }
    } catch (e) {
      _statusMessage = '初始化失败: ${e.toString()}';
    } finally {
      _isLoading = false;
      print('🟡 即将调用notifyListeners - initializeCompanion方法结束');
      notifyListeners();
      print('🟢 notifyListeners调用完成 - initializeCompanion方法结束');
    }
  }

  Future<void> createCompanion({
    String? name,
    CompanionType? type,
    CompanionModel? companion,
  }) async {
    try {
      CompanionModel newCompanion;

      if (companion != null) {
        newCompanion = companion;
      } else if (name != null && type != null) {
        final meetingStory = CompanionStoryGenerator.generateRandomMeeting(type);
        newCompanion = CompanionModel.create(
          name: name,
          type: type,
          meetingStory: meetingStory,
          maxToken: 4000,
        );
      } else {
        throw Exception('必须提供伴侣对象或名称和类型');
      }

      await StorageService.saveCompanion(newCompanion);
      _existingCompanions.insert(0, newCompanion);
      _currentCompanion = newCompanion;
      _messages = [];
      await _addOpeningMessage();

      print('🟡 即将调用notifyListeners - createCompanion方法（延迟）');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
        print('🟢 notifyListeners调用完成 - createCompanion方法（延迟）');
      });
    } catch (e) {
      throw Exception('创建伴侣失败: ${e.toString()}');
    }
  }

  Future<void> loadCompanion(String companionId) async {
    try {
      final companionData = await StorageService.getCompanion(companionId);
      if (companionData == null) {
        throw Exception('伴侣数据不存在');
      }

      _currentCompanion = companionData;
      _messages = await CompanionMemoryService.loadMessages(companionId);

      print('🟡 即将调用notifyListeners - loadCompanion方法（延迟）');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
        print('🟢 notifyListeners调用完成 - loadCompanion方法（延迟）');
      });
    } catch (e) {
      throw Exception('加载伴侣失败: $e');
    }
  }

  Future<void> sendMessage(String content) async {
    if (_currentCompanion == null || _isTyping) return;

    try {
      _isTyping = true;
      print('🟡 即将调用notifyListeners - sendMessage方法开始');
      notifyListeners();
      print('🟢 notifyListeners调用完成 - sendMessage方法开始');

      final userMessage = MessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        content: content,
        isUser: true,
        timestamp: DateTime.now(),
        characterCount: content.length,
        densityCoefficient: 1.0,
      );

      _messages.add(userMessage);

      final tokenUsed = _calculateTokenUsage(content);
      _currentCompanion = _currentCompanion!.updateTokenUsage(
        _currentCompanion!.tokenUsed + tokenUsed,
      );

      if (_currentCompanion!.shouldTriggerEnding && !_showEndingSequence) {
        await _triggerEndingSequence();
      } else {
        final aiResponse = await _generateAIResponse(content);
        _messages.add(aiResponse);
      }

      await _saveState();

    } catch (e) {
      _statusMessage = '发送消息失败: $e';
    } finally {
      _isTyping = false;
      print('🟡 即将调用notifyListeners - sendMessage方法结束');
      notifyListeners();
      print('🟢 notifyListeners调用完成 - sendMessage方法结束');
    }
  }

  Future<void> _triggerEndingSequence() async {
    _showEndingSequence = true;
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
    _currentCompanion = _currentCompanion!.advanceStage();
    _statusMessage = '${_currentCompanion!.name}即将离开...';
  }

  String _generateEndingMessage() {
    if (_currentCompanion == null) return '';

    final scenarios = [
      '我感受到时空管理局在召唤我...我必须回到我的时代了。虽然要离开，但这段时光我会永远珍藏在心里。',
      '我的能量即将耗尽了...但我已经完成了我的使命——让你变得更加自信和有魅力。',
      '经过这段时间的相处，我看到你已经成长了很多。现在你已经准备好去现实中寻找真正的感情了。',
      '作为你的守护天使，我的任务已经完成了。我会在天空中默默守护着你，祝你幸福。',
    ];

    return scenarios[DateTime.now().millisecond % scenarios.length] +
           '\n\n我是如此地珍惜与你的每一次对话...请记住我们在一起的美好时光。💫';
  }

  Future<void> completeEnding() async {
    if (_currentCompanion == null) return;
    await _saveState();
    _statusMessage = '${_currentCompanion!.name}已经离开，但回忆永远不会消失...';
    notifyListeners();
  }

  Future<MessageModel> _generateAIResponse(String userInput) async {
    await Future.delayed(Duration(milliseconds: 1000 + (DateTime.now().millisecond % 1000)));

    final response = await CompanionMemoryService.generateResponse(
      companion: _currentCompanion!,
      userInput: userInput,
      conversationHistory: _messages,
    );

    final favorabilityChange = _calculateFavorabilityChange(userInput);
    _currentCompanion = _currentCompanion!.updateFavorability(
      (_currentCompanion!.favorabilityScore + favorabilityChange).clamp(0, 100),
    );

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

  Future<void> _addOpeningMessage() async {
    if (_currentCompanion == null) return;

    final storyMessage = MessageModel(
      id: 'msg_story_${DateTime.now().millisecondsSinceEpoch}',
      content: _currentCompanion!.meetingStory.storyText,
      isUser: false,
      timestamp: DateTime.now(),
      characterCount: _currentCompanion!.meetingStory.storyText.length,
      densityCoefficient: 0,
    );

    _messages.add(storyMessage);
    await Future.delayed(const Duration(milliseconds: 1500));

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

  int _calculateTokenUsage(String content) {
    final chineseChars = content.replaceAll(RegExp(r'[^\u4e00-\u9fa5]'), '').length;
    final otherChars = content.length - chineseChars;
    return (chineseChars ~/ 2) + (otherChars ~/ 4) + 1;
  }

  int _calculateFavorabilityChange(String userInput) {
    int change = 1;
    if (userInput.length >= 10 && userInput.length <= 50) {
      change += 2;
    }
    final positiveWords = ['喜欢', '开心', '有趣', '温暖', '美好'];
    for (final word in positiveWords) {
      if (userInput.contains(word)) {
        change += 2;
        break;
      }
    }
    if (userInput.contains('？') || userInput.contains('?')) {
      change += 3;
    }
    return change.clamp(-5, 10);
  }

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
        break;
    }

    if (newStage != null && newStage != _currentCompanion!.stage) {
      _currentCompanion = _currentCompanion!.copyWith(stage: newStage);
      _statusMessage = '你们的关系进入了${_currentCompanion!.stageName}！';
    }
  }

  Future<void> _saveState() async {
    if (_currentCompanion == null) return;
    await _saveCompanion();
    await CompanionMemoryService.saveMessages(_currentCompanion!.id, _messages);
  }

  Future<void> _saveCompanion() async {
    if (_currentCompanion == null) return;
    await StorageService.saveCompanion(_currentCompanion!);
  }

  Future<void> deleteCompanion(String companionId) async {
    try {
      await StorageService.deleteCompanion(companionId);
      await CompanionMemoryService.saveMessages(companionId, []);

      _existingCompanions.removeWhere((c) => c.id == companionId);

      if (_currentCompanion?.id == companionId) {
        _currentCompanion = null;
        _messages.clear();
      }

      notifyListeners();
    } catch (e) {
      throw Exception('删除伴侣失败: ${e.toString()}');
    }
  }

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
      CompanionTypeInfo(
        type: CompanionType.sunnyBoy,
        name: '阳光男生',
        description: '充满活力，给人温暖感',
        traits: ['阳光', '温暖', '积极'],
      ),
      CompanionTypeInfo(
        type: CompanionType.matureBoy,
        name: '成熟男生',
        description: '沉稳可靠，有责任感',
        traits: ['成熟', '稳重', '可靠'],
      ),
    ];
  }

  Future<void> resetCompanion() async {
    if (_currentCompanion == null) return;

    final companionType = _currentCompanion!.type;
    final companionName = _currentCompanion!.name;

    await createCompanion(name: companionName, type: companionType);
  }

  void clearError() {
    _statusMessage = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _saveState();
    super.dispose();
  }
}

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