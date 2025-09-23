// lib/features/auth/auth_controller.dart (修改登录信息)

import 'package:flutter/foundation.dart';
import '../../core/models/user_model.dart';
import '../../shared/services/storage_service.dart';

class AuthController extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  Future<void> initializeAuth() async {
    try {
      _currentUser = await StorageService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      debugPrint('初始化认证失败: $e');
    }
  }

  Future<bool> login(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      _errorMessage = '用户名和密码不能为空';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1)); // 模拟网络请求

      // 修改：简化登录验证，支持 a/1 和原来的 demo/123456
      if ((username == 'a' && password == '1') ||
          (username == 'demo' && password == '123456')) {
        _currentUser = UserModel.newUser(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          username: username,
          email: '$username@example.com',
        );

        await StorageService.saveCurrentUser(_currentUser!);
        return true;
      } else {
        _errorMessage = '用户名或密码错误';
        return false;
      }
    } catch (e) {
      _errorMessage = '登录失败: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String username, String email, String password) async {
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _errorMessage = '所有字段都必须填写';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2)); // 模拟网络请求

      _currentUser = UserModel.newUser(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        username: username,
        email: email,
      );

      await StorageService.saveCurrentUser(_currentUser!);
      return true;
    } catch (e) {
      _errorMessage = '注册失败: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    await StorageService.clearCurrentUser();
    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}