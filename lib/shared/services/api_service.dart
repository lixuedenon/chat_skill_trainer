// lib/shared/services/api_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';

/// API服务接口
class ApiService {
  static const String _baseUrl = 'https://api.chatskilltrainer.com';
  static const Duration _timeout = Duration(seconds: 30);

  /// 发送POST请求
  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    try {
      // 模拟网络请求
      await Future.delayed(const Duration(seconds: 1));

      // 模拟不同的响应
      switch (endpoint) {
        case '/auth/login':
          return _mockLoginResponse(data);
        case '/auth/register':
          return _mockRegisterResponse(data);
        case '/chat/send':
          return _mockChatResponse(data);
        case '/analysis/generate':
          return _mockAnalysisResponse(data);
        case '/companion/create':
          return _mockCompanionResponse(data);
        case '/combat/submit':
          return _mockCombatResponse(data);
        case '/confession/predict':
          return _mockConfessionResponse(data);
        case '/assistant/translate':
          return _mockTranslateResponse(data);
        case '/assistant/scan':
          return _mockScanResponse(data);
        case '/assistant/suggest':
          return _mockSuggestResponse(data);
        default:
          throw ApiException('未知的接口: $endpoint');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('网络请求失败: ${e.toString()}');
    }
  }

  /// 发送GET请求
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      switch (endpoint) {
        case '/user/profile':
          return _mockUserProfileResponse();
        case '/characters/list':
          return _mockCharactersResponse();
        case '/companions/list':
          return _mockCompanionsResponse();
        case '/combat/scenarios':
          return _mockScenariosResponse();
        default:
          throw ApiException('未知的接口: $endpoint');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('网络请求失败: ${e.toString()}');
    }
  }

  /// 上传文件
  static Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    String filePath, {
    Map<String, String>? fields,
    Map<String, String>? headers,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      return {
        'success': true,
        'data': {
          'fileId': 'file_${DateTime.now().millisecondsSinceEpoch}',
          'url': 'https://example.com/uploads/file.jpg',
          'size': 1024 * 500, // 500KB
        },
        'message': '文件上传成功',
      };
    } catch (e) {
      throw ApiException('文件上传失败: ${e.toString()}');
    }
  }

  // ============ 模拟响应方法 ============

  static Map<String, dynamic> _mockLoginResponse(Map<String, dynamic>? data) {
    final username = data?['username'] ?? '';
    final password = data?['password'] ?? '';

    if (username == 'demo' && password == '123456') {
      return {
        'success': true,
        'data': {
          'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
          'user': {
            'id': 'user_demo',
            'username': username,
            'email': '$username@example.com',
            'credits': 100,
            'isVip': false,
          },
        },
        'message': '登录成功',
      };
    } else {
      throw ApiException('用户名或密码错误');
    }
  }

  static Map<String, dynamic> _mockRegisterResponse(Map<String, dynamic>? data) {
    return {
      'success': true,
      'data': {
        'token': 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        'user': {
          'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
          'username': data?['username'] ?? 'user',
          'email': data?['email'] ?? 'user@example.com',
          'credits': 100,
          'isVip': false,
        },
      },
      'message': '注册成功',
    };
  }

  static Map<String, dynamic> _mockChatResponse(Map<String, dynamic>? data) {
    final userMessage = data?['message'] ?? '';
    final characterId = data?['characterId'] ?? 'gentle_girl';

    // 模拟不同角色的回复风格
    String aiResponse;
    int favorabilityChange;

    switch (characterId) {
      case 'gentle_girl':
        aiResponse = '你说得对呢，我也这样觉得~';
        favorabilityChange = 3;
        break;
      case 'lively_girl':
        aiResponse = '哈哈，你真有趣！我喜欢和你聊天！';
        favorabilityChange = 5;
        break;
      case 'elegant_girl':
        aiResponse = '这确实是个值得深思的话题。';
        favorabilityChange = 2;
        break;
      default:
        aiResponse = '嗯，我明白你的意思。';
        favorabilityChange = 1;
    }

    return {
      'success': true,
      'data': {
        'message': aiResponse,
        'favorabilityChange': favorabilityChange,
        'timestamp': DateTime.now().toIso8601String(),
        'characterId': characterId,
      },
    };
  }

  static Map<String, dynamic> _mockAnalysisResponse(Map<String, dynamic>? data) {
    return {
      'success': true,
      'data': {
        'score': 75,
        'grade': 'B级 - 良好',
        'keyMoments': [
          {
            'round': 3,
            'type': 'breakthrough',
            'description': '成功建立了话题连接',
            'improvement': '可以进一步深入这个话题',
          },
          {
            'round': 7,
            'type': 'mistake',
            'description': '回复过于简短',
            'improvement': '增加更多个人感受的表达',
          },
        ],
        'suggestions': [
          {
            'title': '增加提问频率',
            'description': '适当的提问可以显示你对对方的关心',
            'priority': 4,
          },
          {
            'title': '丰富表达方式',
            'description': '使用更多情感词汇来增强表达效果',
            'priority': 3,
          },
        ],
        'nextFocus': ['情感表达', '话题延续'],
      },
    };
  }

  static Map<String, dynamic> _mockCompanionResponse(Map<String, dynamic>? data) {
    return {
      'success': true,
      'data': {
        'companionId': 'companion_${DateTime.now().millisecondsSinceEpoch}',
        'meetingStory': {
          'title': '图书馆的邂逅',
          'content': '在安静的图书馆里，你们因为同一本书而相遇...',
          'openingMessage': '不好意思，请问这本书你看完了吗？',
        },
      },
    };
  }

  static Map<String, dynamic> _mockCombatResponse(Map<String, dynamic>? data) {
    final isCorrect = data?['selectedOption'] == data?['correctOption'];

    return {
      'success': true,
      'data': {
        'correct': isCorrect,
        'score': isCorrect ? 10 : 0,
        'explanation': isCorrect
            ? '回答正确！这确实是最佳的应对方式。'
            : '这个回答可能不是最佳选择，建议考虑更好的方式。',
        'nextScenario': 'routine_002',
      },
    };
  }

  static Map<String, dynamic> _mockConfessionResponse(Map<String, dynamic>? data) {
    return {
      'success': true,
      'data': {
        'successRate': 68.5,
        'confidence': 'medium',
        'factors': {
          'communication': 7.2,
          'emotional_connection': 6.8,
          'timing': 5.9,
          'mutual_interest': 7.5,
        },
        'recommendations': [
          '建议在轻松的环境下表达心意',
          '可以先通过共同兴趣话题增进了解',
          '选择合适的时机很重要',
        ],
        'optimalTiming': '2-3周后',
      },
    };
  }

  static Map<String, dynamic> _mockTranslateResponse(Map<String, dynamic>? data) {
    final message = data?['message'] ?? '';

    return {
      'success': true,
      'data': {
        'originalMessage': message,
        'surfaceMeaning': '字面意思的解释',
        'hiddenMeaning': '可能的潜在含义',
        'emotionalTone': '友好但保持距离',
        'suggestedResponse': '建议的回复方式',
        'confidence': 0.85,
      },
    };
  }

  static Map<String, dynamic> _mockScanResponse(Map<String, dynamic>? data) {
    return {
      'success': true,
      'data': {
        'signals': [
          {
            'type': 'interest',
            'title': '兴趣信号',
            'description': '对方主动询问你的兴趣爱好',
            'intensity': '中等',
            'confidence': 0.7,
          },
          {
            'type': 'positive',
            'title': '积极回应',
            'description': '回复速度较快，用词积极',
            'intensity': '强',
            'confidence': 0.8,
          },
        ],
      },
    };
  }

  static Map<String, dynamic> _mockSuggestResponse(Map<String, dynamic>? data) {
    return {
      'success': true,
      'data': {
        'suggestions': [
          {
            'style': '幽默风趣',
            'message': '哈哈，看来我们想到一块去了！',
            'explanation': '用幽默的方式回应，增加聊天的轻松感',
            'confidence': 0.8,
          },
          {
            'style': '真诚关心',
            'message': '听起来你今天心情不错呢，有什么开心的事吗？',
            'explanation': '表现出对对方的关心，延续话题',
            'confidence': 0.9,
          },
          {
            'style': '分享经历',
            'message': '我之前也遇到过类似的情况，当时...',
            'explanation': '通过分享个人经历来增进了解',
            'confidence': 0.7,
          },
        ],
      },
    };
  }

  static Map<String, dynamic> _mockUserProfileResponse() {
    return {
      'success': true,
      'data': {
        'id': 'user_demo',
        'username': 'demo',
        'email': 'demo@example.com',
        'credits': 95,
        'level': 3,
        'experience': 150,
        'nextLevelExp': 200,
        'stats': {
          'totalConversations': 12,
          'averageFavorability': 72.5,
          'highestScore': 88,
        },
      },
    };
  }

  static Map<String, dynamic> _mockCharactersResponse() {
    return {
      'success': true,
      'data': [
        {
          'id': 'gentle_girl',
          'name': '温柔女生',
          'type': 'gentle',
          'avatar': 'assets/images/characters/gentle_girl.png',
          'isVip': false,
        },
        {
          'id': 'lively_girl',
          'name': '活泼女生',
          'type': 'lively',
          'avatar': 'assets/images/characters/lively_girl.png',
          'isVip': false,
        },
      ],
    };
  }

  static Map<String, dynamic> _mockCompanionsResponse() {
    return {
      'success': true,
      'data': [
        {
          'id': 'companion_1',
          'name': '小雨',
          'type': 'gentleGirl',
          'stage': 'familiar',
          'relationshipDays': 15,
          'tokenUsed': 1200,
          'maxToken': 4000,
        },
      ],
    };
  }

  static Map<String, dynamic> _mockScenariosResponse() {
    return {
      'success': true,
      'data': [
        {
          'id': 'routine_001',
          'title': '探底测试',
          'category': 'antiRoutine',
          'difficulty': 'medium',
          'completed': false,
        },
        {
          'id': 'crisis_001',
          'title': '说错话补救',
          'category': 'crisisHandling',
          'difficulty': 'hard',
          'completed': true,
        },
      ],
    };
  }

  /// 检查网络连接
  static Future<bool> checkConnection() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取API版本信息
  static Future<String> getApiVersion() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      return '1.0.0';
    } catch (e) {
      return 'unknown';
    }
  }

  /// 上传用户反馈
  static Future<bool> submitFeedback({
    required String content,
    String? category,
    int? rating,
  }) async {
    try {
      await Future.delayed(const Duration(seconds: 1));

      if (kDebugMode) {
        print('反馈内容: $content');
        print('分类: $category');
        print('评分: $rating');
      }

      return true;
    } catch (e) {
      throw ApiException('提交反馈失败: ${e.toString()}');
    }
  }

  /// 获取系统公告
  static Future<List<Map<String, dynamic>>> getAnnouncements() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      return [
        {
          'id': 'announce_1',
          'title': '新功能上线通知',
          'content': 'AI伴侣养成功能现已上线，快来体验吧！',
          'type': 'feature',
          'createdAt': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
        },
        {
          'id': 'announce_2',
          'title': '系统维护通知',
          'content': '系统将于今晚12点进行维护，预计持续2小时。',
          'type': 'maintenance',
          'createdAt': DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
        },
      ];
    } catch (e) {
      throw ApiException('获取公告失败: ${e.toString()}');
    }
  }
}

/// API异常类
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  const ApiException(
    this.message, {
    this.statusCode,
    this.details,
  });

  @override
  String toString() {
    return 'ApiException: $message${statusCode != null ? ' (状态码: $statusCode)' : ''}';
  }
}

/// API响应模型
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
      message: json['message'],
      statusCode: json['statusCode'],
    );
  }
}