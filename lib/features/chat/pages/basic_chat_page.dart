// lib/features/chat/pages/basic_chat_page.dart (修复停止聊天跳转)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/character_model.dart';
import '../../../core/models/conversation_model.dart';
import '../../../core/models/user_model.dart';
import '../../../core/utils/theme_manager.dart';
import '../widgets/message_bubble.dart';
import '../widgets/round_counter.dart';
import '../widgets/chat_input.dart';
import '../widgets/favorability_display.dart';
import '../basic_chat_controller.dart';

class ChatPage extends StatefulWidget {
  final CharacterModel character;
  final UserModel currentUser;

  const ChatPage({
    Key? key,
    required this.character,
    required this.currentUser,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  late ChatController _chatController;
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fadeAnimationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _chatController = ChatController(
      character: widget.character,
      currentUser: widget.currentUser,
    );

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimationController.forward();
    _chatController.addListener(_onChatUpdate);
  }

  void _onChatUpdate() {
    if (_chatController.messages.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _chatController.removeListener(_onChatUpdate);
    _chatController.dispose();
    _scrollController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _chatController,
      child: Scaffold(
        appBar: _buildAppBar(),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildStatusBar(),
              Expanded(child: _buildMessagesList()),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey[300],
            child: widget.character.avatar.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.character.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.character.typeName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Consumer<ChatController>(
          builder: (context, controller, child) {
            return IconButton(
              icon: const Icon(Icons.stop_circle_outlined),
              onPressed: controller.canEndConversation
                  ? () => _showEndConversationDialog()
                  : null,
              tooltip: '结束对话',
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Consumer<ChatController>(
        builder: (context, controller, child) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: FavorabilityDisplay(
                      currentFavorability: controller.currentFavorability,
                      favorabilityHistory: controller.favorabilityHistory,
                      character: widget.character,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RoundCounter(
                      actualRounds: controller.actualRounds,
                      effectiveRounds: controller.effectiveRounds,
                      status: controller.roundStatus,
                      averageCharsPerRound: controller.averageCharsPerRound,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMessagesList() {
    return Consumer<ChatController>(
      builder: (context, controller, child) {
        if (controller.messages.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16),
          itemCount: controller.messages.length + (controller.isTyping ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.messages.length && controller.isTyping) {
              return _buildTypingIndicator();
            }

            final message = controller.messages[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MessageBubble(
                message: message,
                character: widget.character,
                showAvatar: !message.isUser,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey[200],
            child: const Icon(Icons.person, size: 40, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            '开始和${widget.character.name}聊天吧！',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            widget.character.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.grey[200],
          child: const Icon(Icons.person, size: 16),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: ThemeManager.getAiBubbleColor(
              ThemeManager.currentTheme,
              Theme.of(context).brightness == Brightness.dark,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '正在思考...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Consumer<ChatController>(
        builder: (context, controller, child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.statusMessage.isNotEmpty)
                _buildStatusMessage(controller.statusMessage),
              ChatInput(
                onSendMessage: (message) => _sendMessage(message, controller),
                enabled: controller.canSendMessage,
                maxLength: 50,
                remainingCredits: widget.currentUser.credits,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusMessage(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange[700],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.orange[700],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String message, ChatController controller) async {
    try {
      await controller.sendMessage(message);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('发送失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showEndConversationDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('结束对话'),
        content: const Text('确定要结束当前对话吗？结束后可以查看分析报告。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );

    if (result == true) {
      await _endConversation();
    }
  }

  // 最终修复：使用正确的路由名称
  Future<void> _endConversation() async {
    try {
      // 显示加载对话框
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('正在生成分析报告...'),
            ],
          ),
        ),
      );

      await _chatController.endConversation();

      if (mounted) {
        // 关闭加载对话框
        Navigator.of(context).pop();

        // 修复：使用app_routes.dart中正确配置的路由名称
        Navigator.of(context).pushReplacementNamed(
          '/analysis_detail',  // 注意：这里是下划线，不是驼峰
          arguments: {
            'conversation': _chatController.currentConversation,
            'character': widget.character,
            'user': widget.currentUser,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        // 关闭加载对话框
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('结束对话失败: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}