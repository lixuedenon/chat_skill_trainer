// lib/features/settings/pages/settings_page.dart (修复版)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../settings_controller.dart';
import '../../../core/utils/theme_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late SettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SettingsController();
    _controller.loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('设置'),
          centerTitle: true,
        ),
        body: Consumer<SettingsController>(
          builder: (context, controller, child) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildThemeSection(controller),
                    const SizedBox(height: 24),
                    _buildGeneralSection(controller),
                    const SizedBox(height: 24),
                    _buildAboutSection(),
                    // 底部安全空间
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildThemeSection(SettingsController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('主题设置', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...AppThemeType.values.map((theme) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: controller.currentTheme == theme
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300]!,
                  width: controller.currentTheme == theme ? 2 : 1,
                ),
                color: controller.currentTheme == theme
                    ? Theme.of(context).primaryColor.withOpacity(0.1)
                    : null,
              ),
              child: RadioListTile<AppThemeType>(
                title: Text(ThemeManager.getThemeName(theme)),
                subtitle: Text(ThemeManager.getThemeDescription(theme)),
                value: theme,
                groupValue: controller.currentTheme,
                onChanged: (value) async {
                  if (value != null) {
                    // 立即应用主题
                    await controller.setTheme(value);
                    // 重启应用以应用新主题
                    _restartApp();
                  }
                },
                secondary: CircleAvatar(
                  backgroundColor: ThemeManager.getThemePreviewColor(theme),
                  radius: 12,
                ),
              ),
            )),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '选择主题后会自动应用',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSection(SettingsController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('通用设置', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('音效'),
              subtitle: const Text('开启聊天音效'),
              value: controller.soundEnabled,
              onChanged: controller.setSoundEnabled,
              secondary: const Icon(Icons.volume_up),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('通知'),
              subtitle: const Text('接收应用通知'),
              value: controller.notificationEnabled,
              onChanged: controller.setNotificationEnabled,
              secondary: const Icon(Icons.notifications),
            ),
            const Divider(),
            ListTile(
              title: const Text('语言'),
              subtitle: const Text('中文'),
              trailing: const Icon(Icons.arrow_forward_ios),
              leading: const Icon(Icons.language),
              onTap: () => _showLanguageDialog(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('关于', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('版本信息'),
              subtitle: const Text('1.0.0'),
              leading: const Icon(Icons.info),
              onTap: () => _showAboutDialog(),
            ),
            const Divider(),
            ListTile(
              title: const Text('用户协议'),
              leading: const Icon(Icons.description),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showUserAgreement(),
            ),
            const Divider(),
            ListTile(
              title: const Text('隐私政策'),
              leading: const Icon(Icons.privacy_tip),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _showPrivacyPolicy(),
            ),
          ],
        ),
      ),
    );
  }

  // 重启应用以应用新主题
  void _restartApp() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('主题已更改'),
        content: const Text('主题设置已保存，请重启应用以完全应用新主题。'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 返回主页
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择语言'),
        content: const Text('暂时只支持中文'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: '聊天技能训练师',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.chat_bubble_outline,
        size: 48,
        color: Theme.of(context).primaryColor,
      ),
      children: [
        const Text('通过AI对话练习，提升你的社交沟通能力'),
      ],
    );
  }

  void _showUserAgreement() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('用户协议'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1. 服务条款'),
              SizedBox(height: 8),
              Text('本应用为聊天技能训练工具，旨在帮助用户提升社交沟通能力。'),
              SizedBox(height: 16),
              Text('2. 用户责任'),
              SizedBox(height: 8),
              Text('用户应当合理使用本应用功能，不得用于违法违规目的。'),
              SizedBox(height: 16),
              Text('3. 隐私保护'),
              SizedBox(height: 8),
              Text('我们重视用户隐私，详细信息请查看隐私政策。'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隐私政策'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('1. 信息收集'),
              SizedBox(height: 8),
              Text('我们仅收集必要的用户信息以提供服务。'),
              SizedBox(height: 16),
              Text('2. 信息使用'),
              SizedBox(height: 8),
              Text('收集的信息仅用于改进服务质量，不会用于其他目的。'),
              SizedBox(height: 16),
              Text('3. 信息保护'),
              SizedBox(height: 8),
              Text('我们采用安全措施保护用户信息不被滥用。'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}