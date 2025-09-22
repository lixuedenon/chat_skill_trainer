// lib/features/ai_companion/pages/companion_chat_page.dart (完整调试版)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/companion_model.dart';
import '../../../core/models/conversation_model.dart';
import '../../../core/models/character_model.dart';
import '../../../core/models/user_model.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../companion_controller.dart';
import '../../chat/widgets/message_bubble.dart';

class CompanionChatPage extends StatefulWidget {
  final CompanionModel companion;

  const CompanionChatPage({
    Key? key,
    required this.companion,
  }) : super(key: key);

  @override
  State<CompanionChatPage> createState() => _CompanionChatPageState();
}

class _CompanionChatPageState extends State<CompanionChatPage> {
  CompanionController? _controller;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    print('🟢 [ChatPage] initState 开始');
    print('🟢 [ChatPage] 传入的companion: ${widget.companion}');
    print('🟢 [ChatPage] companion ID: ${widget.companion.id}');

    // 延迟整个初始化过程到frame完成后
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🟢 [ChatPage] PostFrameCallback 执行');
      if (mounted) {
        _initializeController();
      } else {
        print('🔴 [ChatPage] Widget已经被销毁，跳过初始化');
      }
    });
  }

  void _initializeController() async {
    print('🟢 [ChatPage] _initializeController 开始');
    try {
      print('🟢 [ChatPage] 开始创建CompanionController');
      _controller = CompanionController(user: _createDummyUser());
      print('🟢 [ChatPage] CompanionController 创建成功');

      _controller!.addListener(_onCompanionUpdate);
      print('🟢 [ChatPage] 监听器添加成功');

      setState(() {
        _isInitialized = true;
      });
      print('🟢 [ChatPage] 设置_isInitialized = true');

      _initializeCompanion();
      print('🟢 [ChatPage] Controller初始化完成');
    } catch (e) {
      print('🔴 [ChatPage] Controller初始化错误: $e');
      print('🔴 [ChatPage] 错误堆栈: ${StackTrace.current}');
    }
  }

  void _initializeCompanion() async {
    if (_controller == null) {
      print('🔴 [ChatPage] _initializeCompanion: Controller为null');
      return;
    }

    print('🟢 [ChatPage] _initializeCompanion 开始');
    try {
      print('🟢 [ChatPage] 调用 _controller.loadCompanion');
      await _controller!.loadCompanion(widget.companion.id);
      print('🟢 [ChatPage] loadCompanion 成功');
    } catch (e) {
      print('🔴 [ChatPage] loadCompanion 失败: $e');
      print('🟢 [ChatPage] 尝试初始化伴侣');
      try {
        await _controller!.initializeCompanion(widget.companion);
        print('🟢 [ChatPage] initializeCompanion 成功');
      } catch (e2) {
        print('🔴 [ChatPage] initializeCompanion 也失败: $e2');
      }
    }
  }

  void _onCompanionUpdate() {
    if (!mounted || _controller == null) {
      print('🔴 [ChatPage] _onCompanionUpdate: Widget已销毁或Controller为null');
      return;
    }

    print('🟢 [ChatPage] _onCompanionUpdate 触发 - messages数量: ${_controller!.messages.length}');
    if (_controller!.messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToBottom();
        }
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      print('🟢 [ChatPage] 滚动到底部');
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    print('🟢 [ChatPage] dispose 开始');
    if (_controller != null) {
      _controller!.removeListener(_onCompanionUpdate);
      _controller!.dispose();
      print('🟢 [ChatPage] Controller disposed');
    }
    _scrollController.dispose();
    _textController.dispose();
    print('🟢 [ChatPage] dispose 完成');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🟢 [ChatPage] build 开始 - 初始化状态: $_isInitialized');

    // 如果未初始化，显示加载界面
    if (!_isInitialized || _controller == null) {
      print('🟢 [ChatPage] 显示加载界面');
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.companion.name),
        ),
        body: const Center(
          child: LoadingIndicator(message: '正在初始化...'),
        ),
      );
    }

    print('🟢 [ChatPage] 构建主界面');
    try {
      return ChangeNotifierProvider.value(
        value: _controller!,
        child: Scaffold(
          appBar: _buildAppBar(),
          body: Column(
            children: [
              _buildStatusBar(),
              Expanded(child: _buildMessagesList()),
              _buildInputArea(),
            ],
          ),
        ),
      );
    } catch (e) {
      print('🔴 [ChatPage] build 方法错误: $e');
      return Scaffold(
        appBar: AppBar(title: const Text('错误')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('页面构建错误: $e'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  print('🟢 [ChatPage] 用户点击返回按钮');
                  Navigator.of(context).pop();
                },
                child: const Text('返回'),
              ),
            ],
          ),
        ),
      );
    }
  }

  PreferredSizeWidget _buildAppBar() {
    print('🟢 [ChatPage] _buildAppBar');
    return AppBar(
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.7),
            child: Text(
              widget.companion.name.isNotEmpty
                  ? widget.companion.name[0].toUpperCase()
                  : 'A',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.companion.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),