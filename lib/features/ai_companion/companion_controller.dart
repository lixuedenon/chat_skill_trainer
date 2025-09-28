// lib/features/ai_companion/companion_controller.dart (修复null check错误版本)

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../../core/models/companion_model.dart';
import '../../core/models/conversation_model.dart';
import '../../core/models/user_model.dart';
import '../../shared/services/hive_service.dart';  // 🔥 替代 StorageService
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
  bool _disposed = false;  // 🔥 添加销毁标志

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
    if (_disposed) return;

    _isLoading = true;
    print('🟡 即将调用notifyListeners - loadExistingCompanions方法开始');
    _safeNotifyListeners();
    print('🟢 notifyListeners调用完成 - loadExistingCompanions方法开始');

    try {
      // 🔥 使用HiveService替代StorageService
      _existingCompanions = HiveService.getCompanions();
      print('✅ 成功加载 ${_existingCompanions.length} 个AI伴侣');
    } catch (e) {
      print('❌ 加载伴侣列表失败: $e');
      _statusMessage = '加载伴侣列表失败: ${e.toString()}';
      _existingCompanions = []; // 确保有默认值
    } finally {
      if (!_disposed) {
        _isLoading = false;
        print('🟡 即将调用notifyListeners - loadExistingCompanions方法结束');
        _safeNotifyListeners();
        print('🟢 notifyListeners调用完成 - loadExistingCompanions方法结束');
      }
    }
  }

  Future<void> initializeCompanion(CompanionModel companion) async {
    if (_disposed) return;

    _isLoading = true;
    _currentCompanion = companion;
    print('🟡 即将调用notifyListeners - initializeCompanion方法开始');
    _safeNotifyListeners();
    print('🟢 notifyListeners调用完成 - initializeCompanion方法开始');

    try {
      // 🔥 使用HiveService加载消息
      _messages = await HiveService.loadCompanionMessages(companion.id);
      print('✅ 成功加载 ${_messages.length} 条消息');

      if (_messages.isEmpty) {
        await _addOpeningMessage();
      }
    } catch (e) {
      print('❌ 初始化伴侣失败: $e');
      _statusMessage = '初始化失败: ${e.toString()}';
      _messages = []; // 确保有默认值
    } finally {
      if (!_disposed) {
        _isLoading = false;
        print('🟡 即将调用notifyListeners - initializeCompanion方法结束');
        _safeNotifyListeners();
        print('🟢 notifyListeners调用完成 - initializeCompanion方法结束');
      }
    }
  }

  Future<void> createCompanion({
    String? name,
    CompanionType? type,
    CompanionModel? companion,
  }) async {
    if (_disposed) return;

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

      // 🔥 使用HiveService保存伴侣
      await HiveService.saveCompanion(newCompanion);
      print('✅ 成功保存新伴侣: ${newCompanion.name}');

      _existingCompanions.insert(0, newCompanion);
      _currentCompanion = newCompanion;
      _messages = [];
      await _addOpeningMessage();

      print('🟡 即将调用notifyListeners - createCompanion方法（延迟）');
      if (!_disposed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _safeNotifyListeners();
          print('🟢 notifyListeners调用完成 - createCompanion方法（延迟）');
        });
      }
    } catch (e) {
      print('❌ 创建伴侣失败: $e');
      throw Exception('创建伴侣失败: ${e.toString()}');
    }
  }

  Future<void> loadCompanion(String companionId) async {
    if (_disposed) return;

    try {
      // 🔥 使用HiveService获取伴侣数据
      final companionData = HiveService.getCompanion(companionId);
      if (companionData == null) {
        throw Exception('伴侣数据不存在: $companionId');
      }

      _currentCompanion = companionData;
      // 🔥 使用HiveService加载消息
      _messages = await HiveService.loadCompanionMessages(companionId);
      print('✅ 成功加载伴侣: ${companionData.name}, ${_messages.length}条消息');

      print('🟡 即将调用notifyListeners - loadCompanion方法（延迟）');
      if (!_disposed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _safeNotifyListeners();
          print('🟢 notifyListeners调用完成 - loadCompanion方法（延迟）');
        });
      }
    } catch (e) {
      print('❌ 加载伴侣失败: $e');
      throw Exception('加载伴侣失败: $e');
    }
  }

  Future<void> sendMessage(String content) async {
    if (_currentCompanion == null || _isTyping || _disposed) return;

    try {
      _isTyping = true;
      print('🟡 即将调用notifyListeners - sendMessage方法开始');
      _safeNotifyListeners();
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
      print('❌ 发送消息失败: $e');
      _statusMessage = '发送消息失败: $e';
    } finally {
      if (!_disposed) {
        _isTyping = false;
        print('🟡 即将调用notifyListeners - sendMessage方法结束');
        _safeNotifyListeners();
        print('🟢 notifyListeners调用完成 - sendMessage方法结束');
      }
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
    if (_currentCompanion == null || _disposed) return;
    await _saveState();
    _statusMessage = '${_currentCompanion!.name}已经离开，但回忆永远不会消失...';
    _safeNotifyListeners();
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

  /// 🔥 修复：增强安全性的状态保存方法
  Future<void> _saveState() async {
    final companion = _currentCompanion; // 获取当前引用
    if (companion == null || _disposed) return;

    try {
      await HiveService.saveCompanion(companion);
      await HiveService.saveCompanionMessages(companion.id, _messages);
    } catch (e) {
      print('❌ 保存状态失败: $e');
    }
  }

  /// 🔥 修复：简化并增强安全性的伴侣保存方法
  Future<void> _saveCompanion() async {
    final companion = _currentCompanion; // 安全获取引用
    if (companion == null || _disposed) return;

    try {
      await HiveService.saveCompanion(companion);
    } catch (e) {
      print('❌ 保存伴侣失败: $e');
    }
  }

  Future<void> deleteCompanion(String companionId) async {
    if (_disposed) return;

    try {
      print('🔄 开始删除伴侣: $companionId');

      // 🔥 使用HiveService删除伴侣和相关消息
      await HiveService.deleteCompanion(companionId);
      print('✅ 成功删除伴侣和相关数据');

      _existingCompanions.removeWhere((c) => c.id == companionId);

      if (_currentCompanion?.id == companionId) {
        _currentCompanion = null;
        _messages.clear();
      }

      _safeNotifyListeners();
    } catch (e) {
      print('❌ 删除伴侣失败: $e');
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
    if (_currentCompanion == null || _disposed) return;

    final companionType = _currentCompanion!.type;
    final companionName = _currentCompanion!.name;

    await createCompanion(name: companionName, type: companionType);
  }

  void clearError() {
    if (_disposed) return;

    _statusMessage = '';
    _safeNotifyListeners();
  }

  /// 🔥 安全的通知监听器方法
  void _safeNotifyListeners() {
    if (!_disposed && hasListeners) {
      notifyListeners();
    }
  }

  /// 🔥 修复：优化dispose方法，防止null check错误
  @override
  void dispose() {
    print('🔄 CompanionController 销毁中...');
    _disposed = true;

    // 🔥 修复：先保存当前状态，再清理引用
    final companionToSave = _currentCompanion; // 保存引用
    if (companionToSave != null) {
      // 异步保存，但不等待完成，避免dispose过程中的阻塞
      HiveService.saveCompanion(companionToSave).catchError((e) {
        print('❌ 销毁时保存状态失败: $e');
      });

      // 如果有消息也保存
      if (_messages.isNotEmpty) {
        HiveService.saveCompanionMessages(companionToSave.id, _messages).catchError((e) {
          print('❌ 销毁时保存消息失败: $e');
        });
      }
    }

    // 立即清理所有引用，防止后续访问
    _currentCompanion = null;
    _existingCompanions.clear();
    _messages.clear();
    _statusMessage = '';
    _isLoading = false;
    _isTyping = false;
    _showEndingSequence = false;

    super.dispose();
    print('✅ CompanionController 销毁完成');
  }

  // ========== 🔥 附加的便民方法 ==========

  /// 🔥 获取用户的所有伴侣统计信息
  Future<Map<String, dynamic>> getCompanionStats() async {
    if (_disposed) return {};

    try {
      final companions = HiveService.getCompanions();

      final stats = {
        'totalCompanions': companions.length,
        'companionsByType': <String, int>{},
        'companionsByStage': <String, int>{},
        'totalMessages': 0,
        'averageFavorability': 0.0,
        'companionsNearEnding': 0,
      };

      if (companions.isNotEmpty) {
        // 按类型分组
        for (final companion in companions) {
          final typeName = companion.typeName;
          final companionsByType = stats['companionsByType'] as Map<String, int>;
          companionsByType[typeName] = (companionsByType[typeName] ?? 0) + 1;

          // 按阶段分组
          final stageName = companion.stageName;
          final companionsByStage = stats['companionsByStage'] as Map<String, int>;
          companionsByStage[stageName] = (companionsByStage[stageName] ?? 0) + 1;

          // 统计接近结局的伴侣
          if (companion.isNearTokenLimit) {
            stats['companionsNearEnding'] = (stats['companionsNearEnding'] as int) + 1;
          }
        }

        // 计算总消息数和平均好感度
        int totalMessages = 0;
        int totalFavorability = 0;

        for (final companion in companions) {
          final messages = await HiveService.loadCompanionMessages(companion.id);
          totalMessages += messages.length;
          totalFavorability += companion.favorabilityScore;
        }

        stats['totalMessages'] = totalMessages;
        stats['averageFavorability'] = totalFavorability / companions.length;
      }

      return stats;
    } catch (e) {
      print('❌ 获取伴侣统计信息失败: $e');
      return {};
    }
  }

  /// 🔥 批量删除所有伴侣（重置功能）
  Future<bool> deleteAllCompanions() async {
    if (_disposed) return false;

    try {
      print('🔄 开始删除所有伴侣...');

      final companions = List<CompanionModel>.from(_existingCompanions);

      for (final companion in companions) {
        await HiveService.deleteCompanion(companion.id);
      }

      _existingCompanions.clear();
      _currentCompanion = null;
      _messages.clear();

      _safeNotifyListeners();
      print('✅ 成功删除所有伴侣');
      return true;

    } catch (e) {
      print('❌ 删除所有伴侣失败: $e');
      return false;
    }
  }

  /// 🔥 导出伴侣数据
  Future<Map<String, dynamic>?> exportCompanionData(String companionId) async {
    if (_disposed) return null;

    try {
      final companion = HiveService.getCompanion(companionId);
      if (companion == null) return null;

      final messages = await HiveService.loadCompanionMessages(companionId);

      return {
        'companion': companion.toJson(),
        'messages': messages.map((m) => m.toJson()).toList(),
        'exportedAt': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };

    } catch (e) {
      print('❌ 导出伴侣数据失败: $e');
      return null;
    }
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