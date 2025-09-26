// lib/features/ai_companion/pages/companion_selection_page.dart (修复 UserModel.newUser 错误)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/companion_model.dart';
import '../../../core/models/user_model.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../companion_controller.dart';
import '../companion_story_generator.dart';
import 'companion_chat_page.dart';

class CompanionSelectionPage extends StatefulWidget {
  const CompanionSelectionPage({Key? key}) : super(key: key);

  @override
  State<CompanionSelectionPage> createState() => _CompanionSelectionPageState();
}

class _CompanionSelectionPageState extends State<CompanionSelectionPage> {
  CompanionController? _controller;
  String _selectedType = '';
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    print('🔵 [SelectionPage] initState 开始');
    _initializeController();
  }

  void _initializeController() async {
    print('🔵 [SelectionPage] 开始创建Controller');
    try {
      // 🔥 修复：使用正确的 UserModel.newUser 构造方法
      _controller = CompanionController(user: _createDummyUser());
      print('🔵 [SelectionPage] Controller创建成功');
      await _loadExistingCompanions();
    } catch (e) {
      print('🔴 [SelectionPage] Controller初始化失败: $e');
    }
  }

  Future<void> _loadExistingCompanions() async {
    if (_controller == null) return;

    print('🔵 [SelectionPage] 开始加载现有伴侣');
    try {
      await _controller!.loadExistingCompanions();
      print('🔵 [SelectionPage] 现有伴侣加载完成');
      setState(() {});
    } catch (e) {
      print('🔴 [SelectionPage] 加载现有伴侣失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    print('🔵 [SelectionPage] dispose 开始');
    _controller?.dispose();
    print('🔵 [SelectionPage] dispose 完成');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🔵 [SelectionPage] build 开始 - Controller状态: ${_controller != null}');

    if (_controller == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('AI伴侣养成')),
        body: const Center(
          child: LoadingIndicator(message: '初始化中...'),
        ),
      );
    }

    return ChangeNotifierProvider.value(
      value: _controller!,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('AI伴侣养成'),
          centerTitle: true,
        ),
        body: Consumer<CompanionController>(
          builder: (context, controller, child) {
            print('🔵 [SelectionPage] Consumer builder - isLoading: ${controller.isLoading}');

            if (controller.isLoading) {
              return const LoadingIndicator(message: '加载中...');
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  if (controller.existingCompanions.isNotEmpty) ...[
                    _buildExistingCompanions(controller),
                    const SizedBox(height: 32),
                  ],
                  _buildCreateNewSection(),
                  const SizedBox(height: 24),
                  _buildTypeSelection(),
                  const SizedBox(height: 32),
                  _buildCreateButton(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI伴侣养成',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 8),
        Text(
          '选择或创建一个AI伴侣，开始一段美好的虚拟恋情。每个伴侣都有独特的性格和记忆系统。',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildExistingCompanions(CompanionController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '现有伴侣',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.existingCompanions.length,
          itemBuilder: (context, index) {
            final companion = controller.existingCompanions[index];
            return _buildCompanionCard(companion);
          },
        ),
      ],
    );
  }

  Widget _buildCompanionCard(CompanionModel companion) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.7),
          child: Text(
            companion.name.isNotEmpty ? companion.name[0].toUpperCase() : 'A',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(companion.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(companion.typeName),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.favorite, size: 16, color: Colors.red[300]),
                const SizedBox(width: 4),
                Text(companion.stageName, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 16),
                Icon(Icons.schedule, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text('${companion.relationshipDays}天', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
        onTap: () => _continueWithCompanion(companion),
      ),
    );
  }

  Widget _buildCreateNewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('创建新伴侣', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          '开启一段全新的虚拟恋情，随机生成独特的相遇故事',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('选择伴侣类型', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: CompanionType.values.length,
          itemBuilder: (context, index) {
            final type = CompanionType.values[index];
            return _buildTypeCard(type);
          },
        ),
      ],
    );
  }

  Widget _buildTypeCard(CompanionType type) {
    final isSelected = _selectedType == type.name;
    final typeName = _getTypeName(type);
    final description = _getTypeDescription(type);

    return GestureDetector(
      onTap: () {
        print('🔵 [SelectionPage] 选择伴侣类型: $typeName');
        setState(() {
          _selectedType = type.name;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getTypeIcon(type),
                size: 40,
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600],
              ),
              const SizedBox(height: 8),
              Text(
                typeName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Theme.of(context).primaryColor : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _selectedType.isNotEmpty && !_isCreating ? _createNewCompanion : null,
        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
        child: _isCreating
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('创建伴侣 (开启神秘相遇)'),
      ),
    );
  }

  String _getTypeName(CompanionType type) {
    switch (type) {
      case CompanionType.gentleGirl: return '温柔女生';
      case CompanionType.livelyGirl: return '活泼女生';
      case CompanionType.elegantGirl: return '优雅女生';
      case CompanionType.mysteriousGirl: return '神秘女生';
      case CompanionType.sunnyBoy: return '阳光男生';
      case CompanionType.matureBoy: return '成熟男生';
    }
  }

  String _getTypeDescription(CompanionType type) {
    switch (type) {
      case CompanionType.gentleGirl: return '温暖体贴，细腻关怀';
      case CompanionType.livelyGirl: return '活力四射，开朗乐观';
      case CompanionType.elegantGirl: return '知性优雅，气质出众';
      case CompanionType.mysteriousGirl: return '神秘迷人，深不可测';
      case CompanionType.sunnyBoy: return '阳光温暖，积极向上';
      case CompanionType.matureBoy: return '成熟稳重，有责任感';
    }
  }

  IconData _getTypeIcon(CompanionType type) {
    switch (type) {
      case CompanionType.gentleGirl: return Icons.favorite_outline;
      case CompanionType.livelyGirl: return Icons.sports_tennis;
      case CompanionType.elegantGirl: return Icons.auto_awesome;
      case CompanionType.mysteriousGirl: return Icons.psychology;
      case CompanionType.sunnyBoy: return Icons.wb_sunny;
      case CompanionType.matureBoy: return Icons.business_center;
    }
  }

  Future<void> _createNewCompanion() async {
    print('🔵 [SelectionPage] _createNewCompanion 开始');
    setState(() {
      _isCreating = true;
    });

    try {
      final type = CompanionType.values.firstWhere((t) => t.name == _selectedType);
      print('🔵 [SelectionPage] 选中的类型: ${_getTypeName(type)}');

      print('🔵 [SelectionPage] 开始生成相遇故事');
      final meetingStory = CompanionStoryGenerator.generateRandomMeeting(type);
      print('🔵 [SelectionPage] 相遇故事生成完成: ${meetingStory.title}');

      print('🔵 [SelectionPage] 显示相遇故事对话框');
      final confirmed = await _showMeetingStoryDialog(meetingStory);
      if (!confirmed) {
        print('🔵 [SelectionPage] 用户取消了相遇故事');
        setState(() { _isCreating = false; });
        return;
      }

      print('🔵 [SelectionPage] 显示名字输入对话框');
      final name = await _showNameInputDialog();
      if (name == null || name.isEmpty) {
        print('🔵 [SelectionPage] 用户取消了名字输入');
        setState(() { _isCreating = false; });
        return;
      }

      print('🔵 [SelectionPage] 开始创建伴侣对象');
      final companion = CompanionModel.create(name: name, type: type, meetingStory: meetingStory);
      print('🔵 [SelectionPage] 伴侣对象创建完成: ${companion.id}');

      print('🔵 [SelectionPage] 调用Controller.createCompanion');
      await _controller!.createCompanion(companion: companion);
      print('🔵 [SelectionPage] Controller.createCompanion 完成');

      if (mounted) {
        setState(() {
          _isCreating = true;
        });

        print('🔵 [SelectionPage] 准备无动画跳转到聊天页面');
        Navigator.of(context).pushAndRemoveUntil(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                CompanionChatPage(companion: companion),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
          (route) => route.isFirst,
        );
        print('🔵 [SelectionPage] 无动画页面替换完成');
      }
    } catch (e) {
      print('🔴 [SelectionPage] 创建新伴侣失败: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建失败: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isCreating = false; });
      }
    }
  }

  Future<bool> _showMeetingStoryDialog(MeetingStory story) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(story.title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(story.storyText, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '这就是你们的相遇故事，要开始这段缘分吗？',
                  style: TextStyle(color: Colors.blue[700], fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('重新生成'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('开始缘分'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<String?> _showNameInputDialog() async {
    final controller = TextEditingController();
    print('🔵 [SelectionPage] 创建TextEditingController');

    try {
      final result = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('给TA起个名字'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: '输入伴侣的名字...',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                print('🔵 [SelectionPage] 用户输入名字: $value');
                Navigator.of(context).pop(value.trim());
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                print('🔵 [SelectionPage] 用户取消名字输入');
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  print('🔵 [SelectionPage] 用户输入名字: $name');
                  Navigator.of(context).pop(name);
                }
              },
              child: const Text('确定'),
            ),
          ],
        ),
      );
      print('🔵 [SelectionPage] 对话框关闭，结果: $result');
      return result;
    } finally {
      // 延迟dispose以避免过早销毁
      print('🔵 [SelectionPage] 延迟dispose TextEditingController');
      Future.delayed(const Duration(milliseconds: 100), () {
        if (controller.hasListeners) {
          print('🔵 [SelectionPage] 执行TextEditingController.dispose()');
          controller.dispose();
        }
      });
    }
  }

  void _continueWithCompanion(CompanionModel companion) {
    print('🔵 [SelectionPage] _continueWithCompanion: ${companion.name}');

    // 立即隐藏选择界面并跳转，无延迟
    setState(() {
      _isCreating = true; // 显示加载状态，隐藏选择界面
    });

    // 立即跳转，无延迟
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CompanionChatPage(companion: companion),
        transitionDuration: Duration.zero, // 禁用进入动画
        reverseTransitionDuration: Duration.zero, // 禁用退出动画
      ),
      (route) => route.isFirst, // 移除到首页为止
    );
    print('🔵 [SelectionPage] 继续伴侣无动画跳转完成');
  }

  /// 🔥 修复：使用正确的 UserModel.newUser 构造方法
  UserModel _createDummyUser() {
    return UserModel.newUser(
      id: 'temp_user_${DateTime.now().millisecondsSinceEpoch}',
      username: 'temp_user',
      email: 'temp@example.com',
    );
  }
}