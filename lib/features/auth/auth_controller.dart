// lib/features/auth/auth_controller.dart (更新 - 使用HiveService)

import 'package:flutter/foundation.dart';
import '../../core/models/user_model.dart';
import '../../shared/services/hive_service.dart';  // 🔥 替代 StorageService

class AuthController extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';
  bool _disposed = false;  // 🔥 添加销毁标志

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  Future<void> initializeAuth() async {
    if (_disposed) return;

    try {
      print('🔄 开始初始化用户认证...');

      // 🔥 使用HiveService获取当前用户
      _currentUser = HiveService.getCurrentUser();

      if (_currentUser != null) {
        print('✅ 发现已登录用户: ${_currentUser!.username}');

        // 🔥 更新最后登录时间
        _currentUser = _currentUser!.updateLastLogin();
        await HiveService.saveCurrentUser(_currentUser!);
      } else {
        print('ℹ️ 未发现已登录用户');
      }

      _safeNotifyListeners();
    } catch (e) {
      print('❌ 初始化认证失败: $e');
      // 初始化失败时不抛出异常，保持应用可用
      _currentUser = null;
      _safeNotifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    if (_disposed) return false;

    // 输入验证
    if (username.trim().isEmpty || password.trim().isEmpty) {
      _errorMessage = '用户名和密码不能为空';
      _safeNotifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = '';
    _safeNotifyListeners();

    try {
      print('🔄 开始登录验证: $username');

      // 模拟网络请求延迟
      await Future.delayed(const Duration(milliseconds: 800));

      // 🔥 支持多种演示账号登录
      final validCredentials = [
        {'username': 'a', 'password': '1'},
        {'username': 'demo', 'password': '123456'},
        {'username': 'test', 'password': 'test'},
      ];

      final isValidLogin = validCredentials.any((cred) =>
          cred['username'] == username && cred['password'] == password);

      if (isValidLogin) {
        print('✅ 登录验证通过: $username');

        // 🔥 检查是否已存在该用户
        final existingUserId = 'user_$username';
        UserModel? existingUser = HiveService.getUser(existingUserId);

        if (existingUser != null) {
          // 更新现有用户的最后登录时间
          _currentUser = existingUser.updateLastLogin();
          print('✅ 更新现有用户: ${_currentUser!.username}');
        } else {
          // 创建新用户
          _currentUser = UserModel.newUser(
            id: existingUserId,
            username: username,
            email: '$username@example.com',
          );
          print('✅ 创建新用户: ${_currentUser!.username}');
        }

        // 🔥 使用HiveService保存用户数据
        await HiveService.saveCurrentUser(_currentUser!);
        await HiveService.saveUser(_currentUser!);  // 同时保存到用户库

        print('🎉 登录成功: ${_currentUser!.username}');
        return true;

      } else {
        _errorMessage = '用户名或密码错误';
        print('❌ 登录失败: 凭据无效');
        return false;
      }

    } catch (e) {
      _errorMessage = '登录失败: ${e.toString()}';
      print('❌ 登录过程异常: $e');
      return false;
    } finally {
      if (!_disposed) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  Future<bool> register(String username, String email, String password) async {
    if (_disposed) return false;

    // 输入验证
    if (username.trim().isEmpty || email.trim().isEmpty || password.trim().isEmpty) {
      _errorMessage = '所有字段都必须填写';
      _safeNotifyListeners();
      return false;
    }

    // 简单的邮箱格式验证
    if (!email.contains('@') || !email.contains('.')) {
      _errorMessage = '邮箱格式不正确';
      _safeNotifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = '';
    _safeNotifyListeners();

    try {
      print('🔄 开始用户注册: $username');

      // 模拟网络请求延迟
      await Future.delayed(const Duration(milliseconds: 1200));

      // 🔥 检查用户名是否已存在
      final userId = 'user_$username';
      final existingUser = HiveService.getUser(userId);

      if (existingUser != null) {
        _errorMessage = '用户名已存在，请选择其他用户名';
        print('❌ 注册失败: 用户名已存在');
        return false;
      }

      // 创建新用户
      _currentUser = UserModel.newUser(
        id: userId,
        username: username,
        email: email,
      );

      // 🔥 使用HiveService保存用户数据
      await HiveService.saveCurrentUser(_currentUser!);
      await HiveService.saveUser(_currentUser!);

      print('🎉 注册成功: ${_currentUser!.username}');
      return true;

    } catch (e) {
      _errorMessage = '注册失败: ${e.toString()}';
      print('❌ 注册过程异常: $e');
      return false;
    } finally {
      if (!_disposed) {
        _isLoading = false;
        _safeNotifyListeners();
      }
    }
  }

  Future<void> logout() async {
    if (_disposed) return;

    try {
      print('🔄 开始用户登出...');

      if (_currentUser != null) {
        print('👋 用户登出: ${_currentUser!.username}');
      }

      // 🔥 清除当前用户数据
      _currentUser = null;
      await HiveService.clearCurrentUser();

      print('✅ 登出完成');
      _safeNotifyListeners();

    } catch (e) {
      print('❌ 登出失败: $e');
      // 即使清除失败，也要重置本地状态
      _currentUser = null;
      _safeNotifyListeners();
    }
  }

  /// 🔥 更新用户信息
  Future<bool> updateUser(UserModel updatedUser) async {
    if (_disposed) return false;

    try {
      print('🔄 更新用户信息: ${updatedUser.username}');

      _currentUser = updatedUser;

      // 🔥 同时更新两个位置的用户数据
      await HiveService.saveCurrentUser(_currentUser!);
      await HiveService.saveUser(_currentUser!);

      _safeNotifyListeners();

      print('✅ 用户信息更新成功');
      return true;

    } catch (e) {
      print('❌ 更新用户信息失败: $e');
      _errorMessage = '更新用户信息失败: ${e.toString()}';
      _safeNotifyListeners();
      return false;
    }
  }

  /// 🔥 增加用户积分
  Future<bool> addCredits(int amount) async {
    if (_disposed || _currentUser == null) return false;

    try {
      print('🔄 增加用户积分: +$amount');

      final updatedUser = _currentUser!.addCredits(amount);
      return await updateUser(updatedUser);

    } catch (e) {
      print('❌ 增加积分失败: $e');
      return false;
    }
  }

  /// 🔥 消耗用户积分
  Future<bool> consumeCredits(int amount) async {
    if (_disposed || _currentUser == null) return false;

    try {
      if (!_currentUser!.hasEnoughCredits(amount)) {
        _errorMessage = '积分不足，需要$amount积分，当前只有${_currentUser!.credits}积分';
        _safeNotifyListeners();
        return false;
      }

      print('🔄 消耗用户积分: -$amount');

      final updatedUser = _currentUser!.consumeCredits(amount);
      return await updateUser(updatedUser);

    } catch (e) {
      print('❌ 消耗积分失败: $e');
      return false;
    }
  }

  /// 🔥 添加对话历史
  Future<bool> addConversationHistory(String conversationId) async {
    if (_disposed || _currentUser == null) return false;

    try {
      print('🔄 添加对话历史: $conversationId');

      final updatedUser = _currentUser!.addConversationHistory(conversationId);
      return await updateUser(updatedUser);

    } catch (e) {
      print('❌ 添加对话历史失败: $e');
      return false;
    }
  }

  /// 🔥 获取用户统计信息
  Map<String, dynamic> getUserStats() {
    if (_currentUser == null) {
      return {
        'isLoggedIn': false,
        'error': '用户未登录',
      };
    }

    return {
      'isLoggedIn': true,
      'username': _currentUser!.username,
      'email': _currentUser!.email,
      'credits': _currentUser!.credits,
      'level': _currentUser!.userLevel.level,
      'experience': _currentUser!.userLevel.experience,
      'totalConversations': _currentUser!.stats.totalConversations,
      'successfulConversations': _currentUser!.stats.successfulConversations,
      'averageFavorability': _currentUser!.stats.averageFavorability,
      'isVip': _currentUser!.isVipUser,
      'charmTags': _currentUser!.charmTagNames,
      'createdAt': _currentUser!.createdAt.toIso8601String(),
      'lastLoginAt': _currentUser!.lastLoginAt.toIso8601String(),
    };
  }

  void clearError() {
    if (_disposed) return;

    _errorMessage = '';
    _safeNotifyListeners();
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
    print('🔄 AuthController 销毁中...');
    _disposed = true;

    // 清理所有引用
    _currentUser = null;
    _errorMessage = '';
    _isLoading = false;

    super.dispose();
    print('✅ AuthController 销毁完成');
  }

  // ========== 🔥 高级功能 ==========

  /// 🔥 重置用户数据（保留基本信息）
  Future<bool> resetUserProgress() async {
    if (_disposed || _currentUser == null) return false;

    try {
      print('🔄 重置用户进度...');

      // 创建重置后的用户数据
      final resetUser = UserModel.newUser(
        id: _currentUser!.id,
        username: _currentUser!.username,
        email: _currentUser!.email,
      ).copyWith(
        createdAt: _currentUser!.createdAt,  // 保留注册时间
        isVipUser: _currentUser!.isVipUser,  // 保留VIP状态
        preferences: _currentUser!.preferences,  // 保留用户偏好
      );

      return await updateUser(resetUser);

    } catch (e) {
      print('❌ 重置用户进度失败: $e');
      return false;
    }
  }

  /// 🔥 切换VIP状态（开发测试用）
  Future<bool> toggleVipStatus() async {
    if (_disposed || _currentUser == null) return false;

    try {
      print('🔄 切换VIP状态...');

      final updatedUser = _currentUser!.copyWith(
        isVipUser: !_currentUser!.isVipUser,
      );

      return await updateUser(updatedUser);

    } catch (e) {
      print('❌ 切换VIP状态失败: $e');
      return false;
    }
  }

  /// 🔥 导出用户数据
  Future<Map<String, dynamic>?> exportUserData() async {
    if (_disposed || _currentUser == null) return null;

    try {
      print('🔄 导出用户数据: ${_currentUser!.username}');

      final exportData = await HiveService.exportUserData(_currentUser!.id);

      print('✅ 用户数据导出完成');
      return exportData;

    } catch (e) {
      print('❌ 导出用户数据失败: $e');
      return null;
    }
  }

  /// 🔥 验证登录状态
  bool validateAuthState() {
    if (_disposed) return false;

    // 检查内存中的用户状态
    if (_currentUser == null) return false;

    // 检查存储中的用户状态
    final storedUser = HiveService.getCurrentUser();
    if (storedUser == null) {
      // 存储中没有用户，清除内存状态
      _currentUser = null;
      _safeNotifyListeners();
      return false;
    }

    // 检查用户ID是否一致
    if (_currentUser!.id != storedUser.id) {
      // 用户ID不一致，更新内存状态
      _currentUser = storedUser;
      _safeNotifyListeners();
    }

    return true;
  }
}