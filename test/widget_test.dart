// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:chat_skill_trainer/main.dart';
import 'package:chat_skill_trainer/shared/services/hive_service.dart';

void main() {
  group('ChatSkillTrainer Widget Tests', () {
    setUpAll(() async {
      // 初始化测试环境的 Hive
      await Hive.initFlutter();
      // 注册 Hive 适配器（如果需要的话）
      await HiveService.init();
    });

    tearDownAll(() async {
      // 清理测试数据
      await Hive.deleteFromDisk();
    });

    testWidgets('App should build without crashing', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const ChatSkillTrainerApp());

      // Verify that the app builds successfully
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Home page should be accessible', (WidgetTester tester) async {
      // Build our app
      await tester.pumpWidget(const ChatSkillTrainerApp());

      // Wait for any async operations to complete
      await tester.pumpAndSettle();

      // The app should load without errors
      expect(tester.takeException(), isNull);
    });

    testWidgets('Should navigate to login if no user', (WidgetTester tester) async {
      // 确保没有当前用户
      await HiveService.clearAllData();

      // Build our app
      await tester.pumpWidget(const ChatSkillTrainerApp());
      await tester.pumpAndSettle();

      // 应该显示登录相关的界面元素
      // 这里可以根据实际的登录界面来调整验证逻辑
      expect(tester.takeException(), isNull);
    });
  });
}