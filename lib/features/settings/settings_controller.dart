// lib/features/settings/settings_controller.dart

import 'package:flutter/foundation.dart';
import '../../core/utils/theme_manager.dart';
import '../../shared/services/storage_service.dart';

class SettingsController extends ChangeNotifier {
  AppThemeType _currentTheme = AppThemeType.young;
  bool _soundEnabled = true;
  bool _notificationEnabled = true;
  String _language = 'zh';

  AppThemeType get currentTheme => _currentTheme;
  bool get soundEnabled => _soundEnabled;
  bool get notificationEnabled => _notificationEnabled;
  String get language => _language;

  Future<void> loadSettings() async {
    try {
      final themeString = await StorageService.getAppTheme();
      _currentTheme = _parseThemeType(themeString);

      // 加载其他设置
      // _soundEnabled = await StorageService.getSoundEnabled();
      // _notificationEnabled = await StorageService.getNotificationEnabled();
      // _language = await StorageService.getLanguage();

      notifyListeners();
    } catch (e) {
      debugPrint('加载设置失败: $e');
    }
  }

  Future<void> setTheme(AppThemeType theme) async {
    _currentTheme = theme;
    ThemeManager.setTheme(theme);
    await StorageService.saveAppTheme(theme.name);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    // await StorageService.saveSoundEnabled(enabled);
    notifyListeners();
  }

  Future<void> setNotificationEnabled(bool enabled) async {
    _notificationEnabled = enabled;
    // await StorageService.saveNotificationEnabled(enabled);
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _language = language;
    // await StorageService.saveLanguage(language);
    notifyListeners();
  }

  AppThemeType _parseThemeType(String themeString) {
    switch (themeString) {
      case 'business': return AppThemeType.business;
      case 'cute': return AppThemeType.cute;
      default: return AppThemeType.young;
    }
  }
}