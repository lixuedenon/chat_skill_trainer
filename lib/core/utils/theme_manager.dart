// lib/core/utils/theme_manager.dart (完全修复版 - 移除CardTheme问题)

import 'package:flutter/material.dart';

/// 主题类型枚举
enum AppThemeType {
  young,     // 年轻化
  business,  // 商务化
  cute,      // 可爱风
}

/// 主题管理器
class ThemeManager {
  static AppThemeType _currentTheme = AppThemeType.young;

  /// 获取当前主题类型
  static AppThemeType get currentTheme => _currentTheme;

  /// 设置主题类型
  static void setTheme(AppThemeType theme) {
    _currentTheme = theme;
  }

  /// 获取对应的主题数据
  static ThemeData getThemeData(AppThemeType themeType, Brightness brightness) {
    switch (themeType) {
      case AppThemeType.young:
        return _buildYoungTheme(brightness);
      case AppThemeType.business:
        return _buildBusinessTheme(brightness);
      case AppThemeType.cute:
        return _buildCuteTheme(brightness);
    }
  }

  /// 年轻化主题
  static ThemeData _buildYoungTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      brightness: brightness,
      primarySwatch: Colors.purple,
      primaryColor: isDark ? Colors.purple[300] : Colors.purple[600],
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.purple,
        brightness: brightness,
      ).copyWith(
        secondary: Colors.pinkAccent,
        surface: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      ),

      // 应用栏主题
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? Colors.purple[800] : Colors.purple[600],
        foregroundColor: Colors.white,
        elevation: 2,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.purple[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.purple[600]!, width: 2),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF2D2D2D) : Colors.purple[50],
      ),

      // 文本主题
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white60 : Colors.black54,
        ),
      ),
    );
  }

  /// 商务化主题
  static ThemeData _buildBusinessTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      brightness: brightness,
      primarySwatch: Colors.blue,
      primaryColor: isDark ? Colors.blue[300] : Colors.blue[800],
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
        brightness: brightness,
      ).copyWith(
        secondary: Colors.grey[600],
        surface: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      ),

      // 应用栏主题
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? Colors.blue[800] : Colors.blue[900],
        foregroundColor: Colors.white,
        elevation: 1,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF2D2D2D) : Colors.grey[50],
      ),

      // 文本主题
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white60 : Colors.black54,
        ),
      ),
    );
  }

  /// 可爱风主题
  static ThemeData _buildCuteTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      brightness: brightness,
      primarySwatch: Colors.pink,
      primaryColor: isDark ? Colors.pink[300] : Colors.pink[400],
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.pink,
        brightness: brightness,
      ).copyWith(
        secondary: Colors.orange[300],
        surface: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      ),

      // 应用栏主题
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? Colors.pink[700] : Colors.pink[400],
        foregroundColor: Colors.white,
        elevation: 3,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // 按钮主题
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink[400],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        ),
      ),

      // 输入框主题
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.pink[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.pink[400]!, width: 2),
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF2D2D2D) : Colors.pink[25],
      ),

      // 文本主题
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : Colors.black87,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : Colors.black87,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: isDark ? Colors.white70 : Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white60 : Colors.black54,
        ),
      ),
    );
  }

  /// 获取主题名称
  static String getThemeName(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.young:
        return '年轻活力';
      case AppThemeType.business:
        return '商务专业';
      case AppThemeType.cute:
        return '可爱甜美';
    }
  }

  /// 获取主题描述
  static String getThemeDescription(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.young:
        return '紫色主调，充满活力的年轻化设计';
      case AppThemeType.business:
        return '蓝色主调，简洁专业的商务风格';
      case AppThemeType.cute:
        return '粉色主调，温暖可爱的甜美风格';
    }
  }

  /// 获取主题预览颜色
  static Color getThemePreviewColor(AppThemeType themeType) {
    switch (themeType) {
      case AppThemeType.young:
        return Colors.purple[600]!;
      case AppThemeType.business:
        return Colors.blue[800]!;
      case AppThemeType.cute:
        return Colors.pink[400]!;
    }
  }

  /// 获取聊天气泡颜色
  static Color getUserBubbleColor(AppThemeType themeType, bool isDark) {
    switch (themeType) {
      case AppThemeType.young:
        return isDark ? Colors.purple[700]! : Colors.purple[100]!;
      case AppThemeType.business:
        return isDark ? Colors.blue[700]! : Colors.blue[50]!;
      case AppThemeType.cute:
        return isDark ? Colors.pink[700]! : Colors.pink[50]!;
    }
  }

  static Color getAiBubbleColor(AppThemeType themeType, bool isDark) {
    switch (themeType) {
      case AppThemeType.young:
        return isDark ? Colors.grey[700]! : Colors.grey[200]!;
      case AppThemeType.business:
        return isDark ? Colors.grey[600]! : Colors.grey[100]!;
      case AppThemeType.cute:
        return isDark ? Colors.grey[700]! : Colors.orange[50]!;
    }
  }

  /// 获取好感度颜色
  static Color getFavorabilityColor(int favorability, AppThemeType themeType) {
    if (favorability >= 70) {
      switch (themeType) {
        case AppThemeType.young:
          return Colors.purple[600]!;
        case AppThemeType.business:
          return Colors.blue[600]!;
        case AppThemeType.cute:
          return Colors.pink[400]!;
      }
    } else if (favorability >= 50) {
      return Colors.orange[400]!;
    } else if (favorability >= 30) {
      return Colors.yellow[600]!;
    } else {
      return Colors.red[400]!;
    }
  }
}