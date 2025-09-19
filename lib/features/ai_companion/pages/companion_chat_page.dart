// lib/features/ai_companion/pages/companion_chat_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/companion_model.dart';
import '../../../core/models/conversation_model.dart';
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
  late CompanionController _controller;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = CompanionController();
    _controller.initializeCompanion(widget.companion);
    _controller.addListener(_onCompanionUpdate);
  }

  void _onCompanionUpdate() {
    if (_controller.messages.isNotEmpty) {
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
    _controller.removeListener(_onCompanionUpdate);
    _controller.dispose();
    _scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
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
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: widget.companion.avatar.isNotEmpty
                ? AssetImage(widget.companion.avatar)
                : null,
            backgroundColor: Colors.grey[300],
            child: widget.companion.avatar.isEmpty
                ? const Icon(Icons.person, color: Colors.white)
                : null,
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
                Text(
                  widget.companion.typeName,
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
        Consumer<CompanionController>(
          builder: (context, controller, child) {
            return IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showCompanionInfo(controller.currentCompanion),
              tooltip: '伴侣信息',
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Consumer<CompanionController>(
        builder: (context, controller, child) {
          final companion = controller.currentCompanion;
          if (companion == null) return const SizedBox();

          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatusItem(
                      '关系阶段',
                      companion.stageName,
                      Icons.favorite,
                    ),
                  ),
                  Expanded(
                    child: _buildStatusItem(
                      'Token使用',
                      '${companion.tokenUsed}/${companion.maxToken}',
                      Icons.memory,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (companion.isNearTokenLimit)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber,
                           color: Colors.orange[700], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Token即将用完，即将触发离别剧情',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).primaryColor),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    return Consumer<CompanionController>(
      builder: (context, controller, child) {
        if (controller.isLoading && controller.messages.isEmpty) {
          return const LoadingIndicator(message: '正在加载记忆...');
        }

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
                character: _createCharacterFromCompanion(widget.companion),
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
            backgroundImage: widget.companion.avatar.isNotEmpty
                ? AssetImage(widget.companion.avatar)
                : null,
            backgroundColor: Colors.grey[200],
            child: widget.companion.avatar.isEmpty
                ? const Icon(Icons.person, size: 40, color: Colors.grey)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            '开始和${widget.companion.name}的故事',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              widget.companion.meetingStory.storyText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
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
          backgroundImage: widget.companion.avatar.isNotEmpty
              ? AssetImage(widget.companion.avatar)
              : null,
          backgroundColor: Colors.grey[200],
          child: widget.companion.avatar.isEmpty
              ? const Icon(Icons.person, size: 16)
              : null,
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
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
      child: Consumer<CompanionController>(
        builder: (context, controller, child) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: '和${widget.companion.name}聊聊...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    maxLines: null,
                    onSubmitted: (_) => _sendMessage(controller),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: controller.canSendMessage
                      ? () => _sendMessage(controller)
                      : null,
                  icon: controller.isTyping
                      ? const SmallLoadingIndicator()
                      : const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _sendMessage(CompanionController controller) async {
    final message = _textController.text.trim();
    if (message.isEmpty) return;

    _textController.clear();

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

  void _showCompanionInfo(CompanionModel? companion) {
    if (companion == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(companion.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('类型: ${companion.typeName}'),
            const SizedBox(height: 8),
            Text('关系阶段: ${companion.stageName}'),
            const SizedBox(height: 8),
            Text('相处天数: ${companion.relationshipDays}天'),
            const SizedBox(height: 8),
            Text('记忆片段: ${companion.memories.length}个'),
            const SizedBox(height: 8),
            Text('Token使用: ${companion.tokenUsed}/${companion.maxToken}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  // 临时转换函数，将CompanionModel转换为CharacterModel以复用MessageBubble
  dynamic _createCharacterFromCompanion(CompanionModel companion) {
    return {
      'name': companion.name,
      'avatar': companion.avatar,
      'typeName': companion.typeName,
    };
  }
}