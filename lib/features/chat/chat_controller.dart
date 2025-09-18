// lib/features/chat/chat_controller.dart

import 'package:flutter/foundation.dart';
import '../../core/models/character_model.dart';
import '../../core/models/conversation_model.dart';
import '../../core/models/user_model.dart';
import '../../core/utils/text_analyzer.dart';
import '../../core/utils/round_calculator.dart';
import '../../shared/services/mock_ai_service.dart';
import '../../shared/services/storage_service.dart';
import '../../shared/services/billing_service.dart';

/// 聊天控制器 - 管理聊天页面的所有状态和业务逻辑
class ChatController extends ChangeNotifier {
  // 基础属性
  final CharacterModel character;
  final UserModel initialUser;

  // 状态属性
  UserModel _currentUser;
  ConversationModel _currentConversation;
  bool _isTyping = false;
  String _statusMessage = '';
  RoundStatus _lastRoundStatus = RoundStatus.early;

  // 构造函数
  ChatController({
    required this.character,
    required UserModel currentUser,
  }) : initialUser = currentUser,
       _currentUser = currentUser,
       _currentConversation = ConversationModel.newConversation(
         userId: currentUser.id,
         characterId: character.id,
       );

  // Getter 属性
  UserModel get currentUser => _currentUser;
  ConversationModel get currentConversation => _currentConversation;
  List<MessageModel> get messages => _currentConversation.messages;
  bool get isTyping => _isTyping;
  String get statusMessage => _statusMessage;

  // 计算属性
  int get actualRounds => _currentConversation.userMessageCount;
  int get effectiveRounds => TextAnalyzer.calculateEffectiveRounds(messages);
  double get averageCharsPerRound => _currentConversation.metrics.averageCharsPerRound;
  int get currentFavorability => _currentConversation.metrics.currentFavorability;
  List<FavorabilityPoint> get favorabilityHistory => _currentConversation.metrics.favorabilityHistory;

  RoundStatus get roundStatus {
    return RoundCalculator.getRoundStatus(effectiveRounds);
  }

  bool get canSendMessage => !_isTyping &&
                           _currentUser.credits > 0 &&
                           effectiveRounds < RoundCalculator.MAX_ROUNDS;

  bool get canEndConversation => messages.length >= 10; // 至少5轮对话后才能结束

  /// 发送消息
  Future<void> sendMessage(String content) async {
    if (!canSendMessage) {
      throw Exception('当前无法发送消息');
    }

    try {
      // 检查字数限制
      if (content.length > 50) {
        throw Exception('消息长度不能超过50字');
      }

      // 消耗对话次数
      _currentUser = await BillingService.consumeCredits(_currentUser, 1);

      // 创建用户消息
      final userMessage = MessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        content: content,
        isUser: true,
        timestamp: DateTime.now(),
        characterCount: content.length,
        densityCoefficient: TextAnalyzer.calculateDensityCoefficient(content.length),
      );

      // 添加用户消息到对话
      _currentConversation = _currentConversation.addMessage(userMessage);

      // 更新状态
      _isTyping = true;
      _updateStatusMessage();
      notifyListeners();

      // 获取AI回复
      final aiResponse = await MockAIService.generateResponse(
        userInput: content,
        characterId: character.id,
        currentRound: actualRounds,
        conversationHistory: messages,
        currentFavorability: currentFavorability,
      );

      // 创建AI消息
      final aiMessage = MessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch + 1}',
        content: aiResponse.message,
        isUser: false,
        timestamp: aiResponse.responseTime,
        characterCount: aiResponse.message.length,
        densityCoefficient: 1.0, // AI消息不计入密度
      );

      // 添加AI消息到对话
      _currentConversation = _currentConversation.addMessage(aiMessage);

      // 更新好感度
      await _updateFavorability(aiResponse.favorabilityChange, content);

      // 更新对话指标
      await _updateConversationMetrics();

      // 保存对话到本地
      await StorageService.saveConversation(_currentConversation);

    } catch (e) {
      // 发送失败时回滚用户credits
      if (_currentUser.credits < initialUser.credits) {
        _currentUser = await BillingService.addCredits(_currentUser, 1, '消息发送失败回滚');
      }
      rethrow;
    } finally {
      _isTyping = false;
      _updateStatusMessage();
      notifyListeners();
    }
  }

  /// 更新好感度
  Future<void> _updateFavorability(int change, String reason) async {
    final newFavorability = (currentFavorability + change).clamp(0, 100);

    final favorabilityPoint = FavorabilityPoint(
      round: actualRounds,
      score: newFavorability,
      reason: reason,
      timestamp: DateTime.now(),
    );

    final updatedHistory = [...favorabilityHistory, favorabilityPoint];
    final updatedMetrics = _currentConversation.metrics.copyWith(
      currentFavorability: newFavorability,
      favorabilityHistory: updatedHistory,
    );

    _currentConversation = _currentConversation.copyWith(
      metrics: updatedMetrics,
      updatedAt: DateTime.now(),
    );
  }

  /// 更新对话指标
  Future<void> _updateConversationMetrics() async {
    final userMessages = messages.where((m) => m.isUser).toList();
    final totalChars = userMessages.fold<int>(0, (sum, msg) => sum + msg.characterCount);
    final avgCharsPerRound = userMessages.isNotEmpty ? totalChars / userMessages.length : 0.0;

    final updatedMetrics = _currentConversation.metrics.copyWith(
      actualRounds: actualRounds,
      effectiveRounds: effectiveRounds,
      averageCharsPerRound: avgCharsPerRound,
    );

    _currentConversation = _currentConversation.copyWith(
      metrics: updatedMetrics,
    );
  }

  /// 更新状态消息
  void _updateStatusMessage() {
    final currentStatus = roundStatus;

    // 检查是否需要显示提示
    if (RoundCalculator.shouldShowPrompt(effectiveRounds, _lastRoundStatus)) {
      _statusMessage = RoundCalculator.getStatusMessage(currentStatus);
      _lastRoundStatus = currentStatus;
    } else if (_statusMessage.isNotEmpty && currentStatus != _lastRoundStatus) {
      // 状态改变时清除消息
      _statusMessage = '';
      _lastRoundStatus = currentStatus;
    }

    // 检查是否需要充值提醒
    if (BillingService.shouldShowTopUpReminder(_currentUser)) {
      _statusMessage = BillingService.getTopUpSuggestion(_currentUser);
    }
  }

  /// 结束对话
  Future<void> endConversation() async {
    if (!canEndConversation) {
      throw Exception('对话轮数不足，无法结束');
    }

    try {
      // 更新对话状态为已完成
      _currentConversation = _currentConversation.copyWith(
        status: ConversationStatus.completed,
        updatedAt: DateTime.now(),
      );

      // 保存对话
      await StorageService.saveConversation(_currentConversation);

      // 更新用户对话历史
      _currentUser = _currentUser.addConversationHistory(_currentConversation.id);
      await StorageService.updateCurrentUser(_currentUser);

      notifyListeners();
    } catch (e) {
      throw Exception('结束对话失败: ${e.toString()}');
    }
  }

  /// 获取对话改进建议（为复盘页面准备）
  List<String> getImprovementSuggestions() {
    final suggestions = <String>[];

    // 分析最后几条用户消息
    final recentUserMessages = messages
        .where((m) => m.isUser)
        .toList()
        .reversed
        .take(5)
        .toList();

    for (final message in recentUserMessages) {
      final messageSuggestions = MockAIService.generateImprovementSuggestions(
        message.content,
        character.id,
        0, // 这里需要实际的好感度变化数据
      );
      suggestions.addAll(messageSuggestions);
    }

    // 去重并限制数量
    return suggestions.toSet().take(5).toList();
  }

  /// 获取对话统计信息
  Map<String, dynamic> getConversationStats() {
    return {
      'totalMessages': messages.length,
      'userMessages': messages.where((m) => m.isUser).length,
      'aiMessages': messages.where((m) => !m.isUser).length,
      'averageMessageLength': messages.isNotEmpty
          ? messages.map((m) => m.characterCount).reduce((a, b) => a + b) / messages.length
          : 0.0,
      'conversationDuration': _currentConversation.durationInMinutes,
      'finalFavorability': currentFavorability,
      'favorabilityGain': currentFavorability - 10, // 初始好感度为10
    };
  }

  /// 重置对话（用于重来功能）
  Future<void> resetConversation() async {
    _currentConversation = ConversationModel.newConversation(
      userId: _currentUser.id,
      characterId: character.id,
    );
    _isTyping = false;
    _statusMessage = '';
    _lastRoundStatus = RoundStatus.early;

    notifyListeners();
  }

  /// 从已有对话继续（用于重来功能）
  void continueFromConversation(ConversationModel conversation) {
    _currentConversation = conversation;
    _updateStatusMessage();
    notifyListeners();
  }

  @override
  void dispose() {
    // 自动保存对话状态
    if (messages.isNotEmpty) {
      StorageService.saveConversation(_currentConversation);
    }
    super.dispose();
  }
}