// lib/features/real_chat_assistant/real_chat_controller.dart (修复枚举值问题)

import 'package:flutter/foundation.dart';
import '../../core/models/user_model.dart';
import 'social_translator.dart';
import 'social_radar.dart';

/// 真人聊天助手控制器
class RealChatController extends ChangeNotifier {
  final UserModel? user;

  String _inputText = '';
  List<ChatSuggestion> _suggestions = [];
  SocialTranslation? _translation;
  SocialRadarAnalysis? _radarAnalysis;
  bool _isAnalyzing = false;
  bool _isScanning = false;
  bool _isGenerating = false;
  String _analysisHistory = '';
  bool _disposed = false;  // 🔥 添加销毁标志

  // 用于页面显示的数据格式
  Map<String, dynamic> _translationResult = {};
  List<Map<String, dynamic>> _radarResults = [];
  List<Map<String, dynamic>> _replySuggestions = [];

  RealChatController({this.user});

  // Getters - 匹配页面中使用的属性名
  String get inputText => _inputText;
  List<ChatSuggestion> get suggestions => _suggestions;
  SocialTranslation? get translation => _translation;
  SocialRadarAnalysis? get radarAnalysis => _radarAnalysis;
  bool get isAnalyzing => _isAnalyzing;
  bool get isScanning => _isScanning;
  bool get isGenerating => _isGenerating;
  String get analysisHistory => _analysisHistory;

  // 页面使用的格式化数据
  Map<String, dynamic> get translationResult => _translationResult;
  List<Map<String, dynamic>> get radarResults => _radarResults;
  List<Map<String, dynamic>> get replySuggestions => _replySuggestions;

  /// 翻译消息（社交翻译功能）
  Future<void> translateMessage(String message) async {
    if (message.trim().isEmpty || _disposed) return;

    _isAnalyzing = true;
    _inputText = message;
    _safeNotifyListeners();

    try {
      print('🔄 开始翻译消息: ${message.substring(0, message.length > 20 ? 20 : message.length)}...');

      // 社交翻译官：解读隐含意思
      _translation = await SocialTranslator.translateMessage(message);

      // 转换为页面显示格式
      _translationResult = {
        'surfaceMeaning': '字面意思：$message',
        'hiddenMeaning': _translation!.hiddenMeaning,
        'emotionalTone': '${_translation!.emotionalState.emoji} ${_translation!.emotionalState.displayName}',
        'suggestedResponse': _translation!.suggestedResponse,
        'confidence': _translation!.confidence,
        'analysisTime': DateTime.now().toIso8601String(),
      };

      // 更新历史记录
      _updateAnalysisHistory('翻译: ${message.substring(0, message.length > 15 ? 15 : message.length)}...');

      print('✅ 消息翻译完成');
    } catch (e) {
      print('❌ 翻译消息失败: $e');
      _translationResult = {
        'surfaceMeaning': message,
        'hiddenMeaning': '分析失败，请重试',
        'emotionalTone': '无法识别',
        'suggestedResponse': '建议直接回应',
        'confidence': 0.0,
        'error': e.toString(),
      };
    } finally {
      if (!_disposed) {
        _isAnalyzing = false;
        _safeNotifyListeners();
      }
    }
  }

  /// 扫描社交信号（社交雷达功能）
  Future<void> scanSocialSignals(String content) async {
    if (content.trim().isEmpty || _disposed) return;

    _isScanning = true;
    _safeNotifyListeners();

    try {
      print('🔄 开始扫描社交信号...');

      // 社交雷达：识别关键信息
      _radarAnalysis = await SocialRadar.analyzeMessage(content);

      // 转换为页面显示格式
      _radarResults = [];

      // 添加机会信号
      for (final opportunity in _radarAnalysis!.opportunities) {
        _radarResults.add({
          'type': 'positive',
          'title': _getOpportunityTitle(opportunity.type),
          'description': opportunity.explanation,
          'intensity': _getPriorityText(opportunity.priority),
          'suggestedAction': opportunity.suggestedResponse,
          'priority': opportunity.priority.index,
        });
      }

      // 添加警告信号
      for (final warning in _radarAnalysis!.warnings) {
        _radarResults.add({
          'type': 'negative',
          'title': _getWarningTitle(warning.type),
          'description': warning.explanation,
          'intensity': _getSeverityText(warning.severity),
          'severity': warning.severity.index,
        });
      }

      // 添加关键信息
      for (final info in _radarAnalysis!.keyInformation) {
        _radarResults.add({
          'type': 'neutral',
          'title': _getInfoTitle(info.type),
          'description': '发现：${info.content}',
          'intensity': _getImportanceText(info.importance),
          'importance': info.importance.index,
        });
      }

      // 按重要性排序
      _radarResults.sort((a, b) {
        final aScore = _getSignalScore(a);
        final bScore = _getSignalScore(b);
        return bScore.compareTo(aScore);
      });

      // 更新历史记录
      _updateAnalysisHistory('雷达扫描: ${content.substring(0, content.length > 15 ? 15 : content.length)}...');

      print('✅ 社交信号扫描完成，发现${_radarResults.length}个信号');
    } catch (e) {
      print('❌ 扫描信号失败: $e');
      _radarResults = [{
        'type': 'neutral',
        'title': '扫描失败',
        'description': '无法分析内容，请检查输入',
        'intensity': '低',
        'error': e.toString(),
      }];
    } finally {
      if (!_disposed) {
        _isScanning = false;
        _safeNotifyListeners();
      }
    }
  }

  /// 计算信号重要性分数（用于排序）
  int _getSignalScore(Map<String, dynamic> signal) {
    switch (signal['type']) {
      case 'positive':
        return 10 + (signal['priority'] as int? ?? 0) * 3;
      case 'negative':
        return 15 + (signal['severity'] as int? ?? 0) * 4;
      case 'neutral':
        return 5 + (signal['importance'] as int? ?? 0) * 2;
      default:
        return 0;
    }
  }

  /// 生成回复建议
  Future<void> generateReplySuggestions(String context) async {
    if (context.trim().isEmpty || _disposed) return;

    _isGenerating = true;
    _safeNotifyListeners();

    try {
      print('🔄 开始生成回复建议...');

      // 生成建议
      _suggestions = await _generateReplySuggestions(context);

      // 转换为页面显示格式
      _replySuggestions = _suggestions.map((suggestion) => {
        'style': suggestion.type.displayName,
        'styleIcon': suggestion.type.icon,
        'message': suggestion.text,
        'explanation': suggestion.explanation,
        'confidence': suggestion.confidence,
        'priority': _getConfidencePriority(suggestion.confidence),
      }).toList();

      // 按置信度排序
      _replySuggestions.sort((a, b) =>
        (b['confidence'] as double).compareTo(a['confidence'] as double));

      // 更新历史记录
      _updateAnalysisHistory('生成建议: ${context.substring(0, context.length > 15 ? 15 : context.length)}...');

      print('✅ 回复建议生成完成，共${_suggestions.length}条');
    } catch (e) {
      print('❌ 生成建议失败: $e');
      _replySuggestions = [{
        'style': '通用',
        'styleIcon': '💬',
        'message': '谢谢你的分享，我很认同你的看法',
        'explanation': '安全的通用回复',
        'confidence': 0.5,
        'priority': 'low',
        'error': e.toString(),
      }];
    } finally {
      if (!_disposed) {
        _isGenerating = false;
        _safeNotifyListeners();
      }
    }
  }

  /// 根据置信度获取优先级标签
  String _getConfidencePriority(double confidence) {
    if (confidence >= 0.8) return 'high';
    if (confidence >= 0.6) return 'medium';
    return 'low';
  }

  /// 分析对方消息（原有方法，保持兼容性）
  Future<void> analyzeMessage(String message) async {
    await translateMessage(message);
  }

  /// 🔥 组合分析（同时进行翻译和雷达扫描）
  Future<void> performCompleteAnalysis(String content) async {
    if (content.trim().isEmpty || _disposed) return;

    try {
      print('🔄 开始完整分析...');

      // 并发执行翻译和雷达扫描
      await Future.wait([
        translateMessage(content),
        scanSocialSignals(content),
      ]);

      // 基于分析结果生成建议
      await generateReplySuggestions(content);

      print('✅ 完整分析完成');
    } catch (e) {
      print('❌ 完整分析失败: $e');
    }
  }

  /// 生成回复建议
  Future<List<ChatSuggestion>> _generateReplySuggestions(String message) async {
    final suggestions = <ChatSuggestion>[];

    try {
      // 基于翻译结果生成建议
      if (_translation != null) {
        suggestions.addAll(_generateBasedOnTranslation(_translation!));
      }

      // 基于雷达分析生成建议
      if (_radarAnalysis != null) {
        suggestions.addAll(_generateBasedOnRadar(_radarAnalysis!));
      }

      // 通用建议
      suggestions.addAll(_generateGenericSuggestions(message));

      // 去重并排序
      return _deduplicateAndSort(suggestions);
    } catch (e) {
      print('❌ 生成回复建议过程中出错: $e');
      return _getFallbackSuggestions();
    }
  }

  /// 获取备用建议
  List<ChatSuggestion> _getFallbackSuggestions() {
    return [
      const ChatSuggestion(
        text: '我明白你的意思，这确实值得思考',
        type: SuggestionType.thoughtful,
        confidence: 0.6,
        explanation: '通用的理解性回复',
      ),
      const ChatSuggestion(
        text: '听起来很有意思，能详细说说吗？',
        type: SuggestionType.engaging,
        confidence: 0.7,
        explanation: '鼓励对方继续分享',
      ),
      const ChatSuggestion(
        text: '我也有类似的感受',
        type: SuggestionType.sharing,
        confidence: 0.5,
        explanation: '表示共鸣的回复',
      ),
    ];
  }

  /// 基于翻译结果生成建议 - 🔥 修复枚举值问题
  List<ChatSuggestion> _generateBasedOnTranslation(SocialTranslation translation) {
    final suggestions = <ChatSuggestion>[];

    try {
      switch (translation.emotionalState) {
        case EmotionalState.seeking_attention:
          suggestions.add(const ChatSuggestion(
            text: '我注意到了，告诉我更多吧',
            type: SuggestionType.caring,
            confidence: 0.9,
            explanation: '她在寻求关注，给予积极回应',
          ));
          break;
        case EmotionalState.testing:
          suggestions.add(const ChatSuggestion(
            text: '我理解你的想法，让我们开诚布公地聊聊',
            type: SuggestionType.honest,
            confidence: 0.85,
            explanation: '这是测试，诚实回应最好',
          ));
          break;
        case EmotionalState.upset:
          suggestions.add(const ChatSuggestion(
            text: '我能感受到你的心情，需要我陪陪你吗？',
            type: SuggestionType.supportive,
            confidence: 0.9,
            explanation: '她情绪不好，提供情感支持',
          ));
          break;
        case EmotionalState.playful:
          suggestions.add(const ChatSuggestion(
            text: '看到你开心我也很高兴！',
            type: SuggestionType.sharing,
            confidence: 0.8,
            explanation: '分享她的快乐情绪',
          ));
          break;
        case EmotionalState.neutral:
          suggestions.add(const ChatSuggestion(
            text: '这个话题很有意思，我们可以深入聊聊',
            type: SuggestionType.engaging,
            confidence: 0.85,
            explanation: '保持对话继续的通用回复',
          ));
          break;
      }
    } catch (e) {
      print('❌ 基于翻译结果生成建议时出错: $e');
    }

    return suggestions;
  }

  /// 基于雷达分析生成建议
  List<ChatSuggestion> _generateBasedOnRadar(SocialRadarAnalysis radar) {
    final suggestions = <ChatSuggestion>[];

    try {
      for (final opportunity in radar.opportunities) {
        switch (opportunity.type) {
          case OpportunityType.show_care:
            suggestions.add(ChatSuggestion(
              text: '${opportunity.suggestedResponse}，你还好吗？',
              type: SuggestionType.caring,
              confidence: 0.8,
              explanation: opportunity.explanation,
            ));
            break;
          case OpportunityType.ask_question:
            suggestions.add(ChatSuggestion(
              text: opportunity.suggestedResponse,
              type: SuggestionType.engaging,
              confidence: 0.75,
              explanation: opportunity.explanation,
            ));
            break;
          case OpportunityType.share_experience:
            suggestions.add(ChatSuggestion(
              text: opportunity.suggestedResponse,
              type: SuggestionType.sharing,
              confidence: 0.7,
              explanation: opportunity.explanation,
            ));
            break;
          case OpportunityType.emotional_support:
            suggestions.add(ChatSuggestion(
              text: opportunity.suggestedResponse,
              type: SuggestionType.supportive,
              confidence: 0.85,
              explanation: opportunity.explanation,
            ));
            break;
          case OpportunityType.future_plan:
            suggestions.add(ChatSuggestion(
              text: opportunity.suggestedResponse,
              type: SuggestionType.romantic,
              confidence: 0.75,
              explanation: opportunity.explanation,
            ));
            break;
        }
      }
    } catch (e) {
      print('❌ 基于雷达分析生成建议时出错: $e');
    }

    return suggestions;
  }

  /// 生成通用建议
  List<ChatSuggestion> _generateGenericSuggestions(String message) {
    final suggestions = <ChatSuggestion>[];

    try {
      // 如果包含问号，生成回答建议
      if (message.contains('?') || message.contains('？')) {
        suggestions.add(const ChatSuggestion(
          text: '让我想想...[根据具体问题回答]',
          type: SuggestionType.thoughtful,
          confidence: 0.6,
          explanation: '对问题进行思考后回答',
        ));
      }

      // 如果提到负面情绪，生成安慰建议
      final negativeWords = ['累', '烦', '难过', '生气', '郁闷', '不开心', '难受'];
      if (negativeWords.any((word) => message.contains(word))) {
        suggestions.add(const ChatSuggestion(
          text: '辛苦了，需要我做些什么吗？',
          type: SuggestionType.supportive,
          confidence: 0.8,
          explanation: '对方情绪不好，提供支持',
        ));
      }

      // 如果提到正面情绪，生成共鸣建议
      final positiveWords = ['开心', '高兴', '兴奋', '棒', '好', '不错'];
      if (positiveWords.any((word) => message.contains(word))) {
        suggestions.add(const ChatSuggestion(
          text: '真为你高兴！分享一下是什么让你这么开心？',
          type: SuggestionType.sharing,
          confidence: 0.75,
          explanation: '分享对方的快乐',
        ));
      }

      // 如果消息较短，建议深入了解
      if (message.length < 10) {
        suggestions.add(const ChatSuggestion(
          text: '能告诉我更多细节吗？我很想了解',
          type: SuggestionType.engaging,
          confidence: 0.65,
          explanation: '鼓励对方详细分享',
        ));
      }

      // 默认建议
      suggestions.add(const ChatSuggestion(
        text: '我明白你的意思，让我们继续聊聊这个话题',
        type: SuggestionType.engaging,
        confidence: 0.5,
        explanation: '保持对话继续的通用回复',
      ));
    } catch (e) {
      print('❌ 生成通用建议时出错: $e');
    }

    return suggestions;
  }

  /// 去重并排序建议
  List<ChatSuggestion> _deduplicateAndSort(List<ChatSuggestion> suggestions) {
    try {
      // 去重（基于文本内容）
      final uniqueSuggestions = <ChatSuggestion>[];
      final seenTexts = <String>{};

      for (final suggestion in suggestions) {
        if (!seenTexts.contains(suggestion.text)) {
          uniqueSuggestions.add(suggestion);
          seenTexts.add(suggestion.text);
        }
      }

      // 按置信度排序，取前5个
      uniqueSuggestions.sort((a, b) => b.confidence.compareTo(a.confidence));
      return uniqueSuggestions.take(5).toList();
    } catch (e) {
      print('❌ 排序建议时出错: $e');
      return suggestions.take(5).toList();
    }
  }

  /// 🔥 更新分析历史 - 修复缺失的方法
  void _updateAnalysisHistory(String message) {
    try {
      final timestamp = DateTime.now().toString().substring(11, 16);
      _analysisHistory += '[$timestamp] $message\n';

      // 保持历史记录在合理长度
      final lines = _analysisHistory.split('\n');
      if (lines.length > 50) {
        _analysisHistory = lines.sublist(lines.length - 50).join('\n');
      }
    } catch (e) {
      print('❌ 更新分析历史时出错: $e');
    }
  }

  /// 🔥 辅助方法：获取机会标题
  String _getOpportunityTitle(OpportunityType type) {
    switch (type) {
      case OpportunityType.show_care:
        return '关心机会';
      case OpportunityType.ask_question:
        return '提问机会';
      case OpportunityType.share_experience:
        return '分享机会';
      case OpportunityType.emotional_support:
        return '情感支持机会';
      case OpportunityType.future_plan:
        return '未来计划机会';
    }
  }

  /// 🔥 辅助方法：获取警告标题
  String _getWarningTitle(WarningType type) {
    switch (type) {
      case WarningType.cold_response:
        return '冷淡回应';
      case WarningType.impatient:
        return '不耐烦信号';
      case WarningType.keeping_distance:
        return '保持距离';
    }
  }

  /// 🔥 辅助方法：获取信息标题
  String _getInfoTitle(InfoType type) {
    switch (type) {
      case InfoType.time:
        return '时间信息';
      case InfoType.location:
        return '地点信息';
      case InfoType.people:
        return '人物信息';
      case InfoType.activity:
        return '活动信息';
    }
  }

  /// 🔥 辅助方法：获取优先级文本
  String _getPriorityText(OpportunityPriority priority) {
    switch (priority) {
      case OpportunityPriority.high:
        return '高';
      case OpportunityPriority.medium:
        return '中';
      case OpportunityPriority.low:
        return '低';
    }
  }

  /// 🔥 辅助方法：获取严重性文本
  String _getSeverityText(WarningSeverity severity) {
    switch (severity) {
      case WarningSeverity.high:
        return '高风险';
      case WarningSeverity.medium:
        return '中风险';
      case WarningSeverity.low:
        return '低风险';
    }
  }

  /// 🔥 辅助方法：获取重要性文本
  String _getImportanceText(ImportanceLevel importance) {
    switch (importance) {
      case ImportanceLevel.high:
        return '重要';
      case ImportanceLevel.medium:
        return '一般';
      case ImportanceLevel.low:
        return '次要';
    }
  }

  /// 清空输入和结果
  void clearInput() {
    if (_disposed) return;

    _inputText = '';
    _suggestions.clear();
    _translation = null;
    _radarAnalysis = null;
    _translationResult.clear();
    _radarResults.clear();
    _replySuggestions.clear();
    _safeNotifyListeners();
  }

  /// 清空历史记录
  void clearHistory() {
    if (_disposed) return;

    _analysisHistory = '';
    _safeNotifyListeners();
  }

  /// 🔥 清空所有数据
  void clearAllData() {
    if (_disposed) return;

    clearInput();
    clearHistory();
    print('✅ 聊天助手数据已清空');
  }

  /// 🔥 获取使用统计
  Map<String, dynamic> getUsageStats() {
    try {
      final lines = _analysisHistory.split('\n').where((line) => line.isNotEmpty).toList();
      final today = DateTime.now().toString().substring(0, 10);

      final todayLines = lines.where((line) => line.contains(today)).toList();

      // 按类型统计
      final translationCount = lines.where((line) => line.contains('翻译:')).length;
      final scanCount = lines.where((line) => line.contains('雷达扫描:')).length;
      final suggestionCount = lines.where((line) => line.contains('生成建议:')).length;

      return {
        'totalAnalyses': lines.length,
        'todayAnalyses': todayLines.length,
        'translationCount': translationCount,
        'scanCount': scanCount,
        'suggestionCount': suggestionCount,
        'averageConfidence': _suggestions.isNotEmpty
            ? _suggestions.map((s) => s.confidence).reduce((a, b) => a + b) / _suggestions.length
            : 0.0,
        'lastUsed': lines.isNotEmpty ? 'recent' : 'never',
      };
    } catch (e) {
      print('❌ 获取使用统计时出错: $e');
      return {'error': e.toString()};
    }
  }

  /// 🔥 导出分析数据
  Map<String, dynamic> exportAnalysisData() {
    try {
      return {
        'analysisHistory': _analysisHistory,
        'currentTranslation': _translationResult,
        'currentRadarResults': _radarResults,
        'currentSuggestions': _replySuggestions,
        'usageStats': getUsageStats(),
        'exportedAt': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };
    } catch (e) {
      print('❌ 导出分析数据时出错: $e');
      return {'error': e.toString()};
    }
  }

  /// 🔥 批量分析多条消息
  Future<List<Map<String, dynamic>>> batchAnalyzeMessages(List<String> messages) async {
    if (_disposed || messages.isEmpty) return [];

    final results = <Map<String, dynamic>>[];

    try {
      print('🔄 开始批量分析 ${messages.length} 条消息...');

      for (int i = 0; i < messages.length; i++) {
        final message = messages[i];
        if (message.trim().isEmpty) continue;

        // 执行完整分析
        await performCompleteAnalysis(message);

        // 保存结果
        results.add({
          'index': i,
          'message': message,
          'translation': Map<String, dynamic>.from(_translationResult),
          'radarResults': List<Map<String, dynamic>>.from(_radarResults),
          'suggestions': List<Map<String, dynamic>>.from(_replySuggestions),
          'analyzedAt': DateTime.now().toIso8601String(),
        });

        // 短暂延迟，避免过快处理
        if (i < messages.length - 1) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      print('✅ 批量分析完成，处理了 ${results.length} 条消息');
    } catch (e) {
      print('❌ 批量分析失败: $e');
    }

    return results;
  }

  /// 🔥 安全的通知监听器方法
  void _safeNotifyListeners() {
    if (!_disposed && hasListeners) {
      notifyListeners();
    }
  }

  /// 🔥 重写dispose方法，确保资源释放
  @override
  void dispose() {
    print('🔄 RealChatController 销毁中...');
    _disposed = true;

    // 清理所有引用
    _inputText = '';
    _suggestions.clear();
    _translation = null;
    _radarAnalysis = null;
    _translationResult.clear();
    _radarResults.clear();
    _replySuggestions.clear();
    _analysisHistory = '';
    _isAnalyzing = false;
    _isScanning = false;
    _isGenerating = false;

    super.dispose();
    print('✅ RealChatController 销毁完成');
  }
}

/// 🔥 聊天建议类 - 完整定义
class ChatSuggestion {
  final String text;              // 建议文本
  final SuggestionType type;      // 建议类型
  final double confidence;        // 置信度
  final String explanation;       // 解释说明

  const ChatSuggestion({
    required this.text,
    required this.type,
    required this.confidence,
    required this.explanation,
  });

  @override
  String toString() {
    return 'ChatSuggestion(text: $text, type: ${type.name}, confidence: $confidence)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatSuggestion && other.text == text;
  }

  @override
  int get hashCode => text.hashCode;
}

/// 🔥 建议类型枚举 - 完整定义
enum SuggestionType {
  caring,         // 关心型
  honest,         // 诚实型
  supportive,     // 支持型
  engaging,       // 互动型
  sharing,        // 分享型
  thoughtful,     // 深思型
  playful,        // 俏皮型
  romantic,       // 浪漫型
}

/// 🔥 建议类型扩展 - 完整定义
extension SuggestionTypeExtension on SuggestionType {
  String get displayName {
    switch (this) {
      case SuggestionType.caring:
        return '关心型';
      case SuggestionType.honest:
        return '诚实型';
      case SuggestionType.supportive:
        return '支持型';
      case SuggestionType.engaging:
        return '互动型';
      case SuggestionType.sharing:
        return '分享型';
      case SuggestionType.thoughtful:
        return '深思型';
      case SuggestionType.playful:
        return '俏皮型';
      case SuggestionType.romantic:
        return '浪漫型';
    }
  }

  String get icon {
    switch (this) {
      case SuggestionType.caring:
        return '💝';
      case SuggestionType.honest:
        return '💯';
      case SuggestionType.supportive:
        return '🤝';
      case SuggestionType.engaging:
        return '💬';
      case SuggestionType.sharing:
        return '🎯';
      case SuggestionType.thoughtful:
        return '🤔';
      case SuggestionType.playful:
        return '😄';
      case SuggestionType.romantic:
        return '💕';
    }
  }
}