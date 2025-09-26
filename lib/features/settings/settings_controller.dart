// lib/features/settings/settings_controller.dart

import 'package:flutter/foundation.dart';
import '../../core/utils/theme_manager.dart';
import '../../shared/services/hive_service.dart';

/// 设置控制器
class SettingsController extends ChangeNotifier {
  AppThemeType _currentTheme = AppThemeType.young;
  bool _soundEnabled = true;
  bool _notificationEnabled = true;
  String _language = 'zh';
  bool _disposed = false;

  // Getters
  AppThemeType get currentTheme => _currentTheme;

  bool get soundEnabled => _soundEnabled;

  bool get notificationEnabled => _notificationEnabled;

  String get language => _language;

  /// 初始化设置
  Future<void> loadSettings() async {
    if (_disposed) return;

    try {
      // 使用HiveService加载主题设置
      final themeString = HiveService.getAppTheme();
      _currentTheme = _parseThemeType(themeString);

      // 从HiveService加载其他设置
      _soundEnabled = HiveService.getData('sound_enabled') ?? true;
      _notificationEnabled =
          HiveService.getData('notification_enabled') ?? true;
      _language = HiveService.getData('language') ?? 'zh';

      if (!_disposed) {
        notifyListeners();
      }
      print('✅ 设置加载完成');
    } catch (e) {
      print('❌ 加载设置失败: $e');
    }
  }

  /// 设置主题
  Future<void> setTheme(AppThemeType theme) async {
    if (_disposed || _currentTheme == theme) return;

    try {
      _currentTheme = theme;
      ThemeManager.setTheme(theme);

      // 使用HiveService保存主题
      await HiveService.saveAppTheme(theme.name);

      if (!_disposed) {
        notifyListeners();
      }
      print('✅ 主题已设置为: ${theme.name}');
    } catch (e) {
      print('❌ 设置主题失败: $e');
    }
  }

  /// 设置声音开关
  Future<void> setSoundEnabled(bool enabled) async {
    if (_disposed || _soundEnabled == enabled) return;

    try {
      _soundEnabled = enabled;

      // 使用HiveService保存设置
      await HiveService.saveData('sound_enabled', enabled);

      if (!_disposed) {
        notifyListeners();
      }
      print('✅ 声音设置已更新: $enabled');
    } catch (e) {
      print('❌ 设置声音开关失败: $e');
    }
  }

  /// 设置通知开关
  Future<void> setNotificationEnabled(bool enabled) async {
    if (_disposed || _notificationEnabled == enabled) return;

    try {
      _notificationEnabled = enabled;

      // 使用HiveService保存设置
      await HiveService.saveData('notification_enabled', enabled);

      if (!_disposed) {
        notifyListeners();
      }
      print('✅ 通知设置已更新: $enabled');
    } catch (e) {
      print('❌ 设置通知开关失败: $e');
    }
  }

  /// 设置语言
  Future<void> setLanguage(String language) async {
    if (_disposed || _language == language) return;

    try {
      _language = language;

      // 使用HiveService保存设置
      await HiveService.saveData('language', language);

      if (!_disposed) {
        notifyListeners();
      }
      print('✅ 语言已设置为: $language');
    } catch (e) {
      print('❌ 设置语言失败: $e');
    }
  }

  /// 重置所有设置
  Future<void> resetSettings() async {
    if (_disposed) return;

    try {
      _currentTheme = AppThemeType.young;
      _soundEnabled = true;
      _notificationEnabled = true;
      _language = 'zh';

      // 使用HiveService保存重置后的设置
      await Future.wait([
        HiveService.saveAppTheme(_currentTheme.name),
        HiveService.saveData('sound_enabled', _soundEnabled),
        HiveService.saveData('notification_enabled', _notificationEnabled),
        HiveService.saveData('language', _language),
      ]);

      if (!_disposed) {
        notifyListeners();
      }
      print('✅ 设置已重置');
    } catch (e) {
      print('❌ 重置设置失败: $e');
    }
  }

  /// 获取设置摘要
  Map<String, dynamic> getSettingsSummary() {
    return {
      'theme': _currentTheme.name,
      'themeName': ThemeManager.getThemeName(_currentTheme),
      'soundEnabled': _soundEnabled,
      'notificationEnabled': _notificationEnabled,
      'language': _language,
      'languageName': _getLanguageName(_language),
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  /// 导出设置
  Future<Map<String, dynamic>> exportSettings() async {
    try {
      return {
        'settings': getSettingsSummary(),
        'exportedAt': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      };
    } catch (e) {
      print('❌ 导出设置失败: $e');
      return {'error': e.toString()};
    }
  }

  /// 导入设置
  Future<bool> importSettings(Map<String, dynamic> settingsData) async {
    if (_disposed) return false;

    try {
      final settings = settingsData['settings'];
      if (settings == null) return false;

      // 应用导入的设置
      if (settings['theme'] != null) {
        final theme = _parseThemeType(settings['theme']);
        await setTheme(theme);
      }

      if (settings['soundEnabled'] != null) {
        await setSoundEnabled(settings['soundEnabled']);
      }

      if (settings['notificationEnabled'] != null) {
        await setNotificationEnabled(settings['notificationEnabled']);
      }

      if (settings['language'] != null) {
        await setLanguage(settings['language']);
      }

      print('✅ 设置导入完成');
      return true;
    } catch (e) {
      print('❌ 导入设置失败: $e');
      return false;
    }
  }

  /// 解析主题类型
  AppThemeType _parseThemeType(String themeString) {
    switch (themeString) {
      case 'business':
        return AppThemeType.business;
      case 'cute':
        return AppThemeType.cute;
      case 'young':
      default:
        return AppThemeType.young;
    }
  }

  /// 获取语言名称
  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'zh':
        return '中文';
      case 'en':
        return 'English';
      case 'ja':
        return '日本語';
      default:
        return '中文';
    }
  }

  /// 获取可用主题列表
  List<Map<String, dynamic>> getAvailableThemes() {
    return AppThemeType.values.map((theme) =>
    {
      'type': theme,
      'name': ThemeManager.getThemeName(theme),
      'description': ThemeManager.getThemeDescription(theme),
      'previewColor': ThemeManager.getThemePreviewColor(theme),
      'isSelected': theme == _currentTheme,
    }).toList();
  }

  /// 获取可用语言列表
  List<Map<String, String>> getAvailableLanguages() {
    return [
      {'code': 'zh', 'name': '中文'},
      {'code': 'en', 'name': 'English'},
      {'code': 'ja', 'name': '日本語'},
    ];
  }

  /// 安全的通知监听器
  void _safeNotifyListeners() {
    if (!_disposed && hasListeners) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    print('🔄 SettingsController 销毁中...');
    _disposed = true;
    super.dispose();
    print('✅ SettingsController 销毁完成');
  }
}