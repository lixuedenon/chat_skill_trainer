// lib/features/ai_companion/pages/companion_chat_page.dart (完全移除闪烁版)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/companion_model.dart';
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
  late CompanionController _controller; // 改为 late，不再需要判空
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print('🟢 [ChatPage] initState 开始');
    print('🟢 [ChatPage] 传入的companion: ${widget.companion}');
    print('🟢 [ChatPage] companion ID: ${widget.companion.id}');

    // 关键修改：同步创建Controller，不再延迟
    _controller = CompanionController(user: _createDummyUser());
    _controller.addListener(_onCompanionUpdate);
    print('🟢 [ChatPage] Controller同步创建完成');

    // 异步初始化数据，但不影响界面显示
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeCompanionData();
      }
    });
  }

  Future<void> _initializeCompanionData() async {
    print('🟢 [ChatPage] _initializeCompanionData 开始');
    try {
      await _controller.loadCompanion(widget.companion.id);
      print('🟢 [ChatPage] loadCompanion 成功');
    } catch (e) {
      print('🔴 [ChatPage] loadCompanion 失败: $e');
      try {
        await _controller.initializeCompanion(widget.companion);
        print('🟢 [ChatPage] initializeCompanion 成功');
      } catch (e2) {
        print('🔴 [ChatPage] initializeCompanion 也失败: $e2');
      }
    }
  }

  void _onCompanionUpdate() {
    if (!mounted) {
      print('🔴 [ChatPage] _onCompanionUpdate: Widget已销毁');
      return;
    }

    print('🟢 [ChatPage] _onCompanionUpdate 触发 - messages数量: ${_controller.messages.length}');
    if (_controller.messages.isNotEmpty) {
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
    _controller.removeListener(_onCompanionUpdate);
    _controller.dispose();
    _scrollController.dispose();
    _textController.dispose();
    print('🟢 [ChatPage] dispose 完成');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('🟢 [ChatPage] build 开始 - 直接构建主界面');

    // 关键修改：直接显示聊天界面，不再有加载状态判断
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
                Text(
                  widget.companion.stageName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
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
            if (controller.isNearEnding) {
              return IconButton(
                icon: const Icon(Icons.warning, color: Colors.orange),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('即将结束'),
                      content: const Text('对话即将结束，请珍惜剩下的时光...'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('知道了'),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'delete':
                _showDeleteDialog();
                break;
              case 'reset':
                _showResetDialog();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'reset',
              child: Row(
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('重新开始'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('删除伴侣', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBar() {
    return Consumer<CompanionController>(
      builder: (context, controller, child) {
        if (controller.statusMessage.isNotEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            color: Colors.blue[50],
            child: Text(
              controller.statusMessage,
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMessagesList() {
    return Consumer<CompanionController>(
      builder: (context, controller, child) {
        // 如果正在加载数据且没有消息，显示简单的加载提示
        if (controller.messages.isEmpty && controller.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在准备对话...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        // 如果没有消息但不在加载，显示欢迎信息
        if (controller.messages.isEmpty) {
          return const Center(
            child: Text(
              '开始你们的对话吧...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          );
        }

        // 显示消息列表
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: controller.messages.length,
          itemBuilder: (context, index) {
            final message = controller.messages[index];
            return MessageBubble(
              message: message,
              character: _createCharacterFromCompanion(widget.companion),
            );
          },
        );
      },
    );
  }

  Widget _buildInputArea() {
    return Consumer<CompanionController>(
      builder: (context, controller, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  enabled: controller.canSendMessage && !controller.showEndingSequence,
                  decoration: InputDecoration(
                    hintText: controller.showEndingSequence
                        ? '对话已结束...'
                        : '输入你想说的话...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (text) {
                    if (text.trim().isNotEmpty && controller.canSendMessage) {
                      _sendMessage(controller);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              if (controller.isTyping)
                const SizedBox(
                  width: 40,
                  height: 40,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else
                IconButton(
                  onPressed: controller.canSendMessage && !controller.showEndingSequence
                      ? () => _sendMessage(controller)
                      : null,
                  icon: const Icon(Icons.send),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _sendMessage(CompanionController controller) {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      controller.sendMessage(text);
      _textController.clear();
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除伴侣'),
        content: Text('确定要删除 ${widget.companion.name} 吗？这个操作无法撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _controller.deleteCompanion(widget.companion.id);
                if (mounted) {
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('删除失败: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重新开始'),
        content: Text('确定要重新开始与 ${widget.companion.name} 的对话吗？之前的聊天记录将被清除。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _controller.resetCompanion();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('重新开始成功')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('重置失败: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  UserModel _createDummyUser() {
    return UserModel.newUser(
      id: 'temp_user_${DateTime.now().millisecondsSinceEpoch}',
      username: 'temp_user',
      email: 'temp@example.com',
    );
  }

  CharacterModel _createCharacterFromCompanion(CompanionModel companion) {
    return CharacterModel(
      id: 'companion_char_${companion.id}',
      name: companion.name,
      description: companion.typeName,
      avatar: companion.avatar,
      type: _getCharacterTypeFromCompanionType(companion.type),
      traits: PersonalityTraits(
        independence: 50,
        strength: 50,
        rationality: 50,
        maturity: 50,
        warmth: 70, // AI伴侣通常比较温暖
        playfulness: 60,
        elegance: 50,
        mystery: 40,
      ),
      scenarios: ['companion'],
      gender: _getGenderFromCompanionType(companion.type),
    );
  }

  CharacterType _getCharacterTypeFromCompanionType(CompanionType companionType) {
    switch (companionType) {
      case CompanionType.gentleGirl:
        return CharacterType.gentle;
      case CompanionType.livelyGirl:
        return CharacterType.lively;
      case CompanionType.elegantGirl:
        return CharacterType.elegant;
      case CompanionType.mysteriousGirl:
        return CharacterType.wise;
      case CompanionType.sunnyBoy:
        return CharacterType.sunny;
      case CompanionType.matureBoy:
        return CharacterType.mature;
    }
  }

  String _getGenderFromCompanionType(CompanionType companionType) {
    switch (companionType) {
      case CompanionType.gentleGirl:
      case CompanionType.livelyGirl:
      case CompanionType.elegantGirl:
      case CompanionType.mysteriousGirl:
        return 'female';
      case CompanionType.sunnyBoy:
      case CompanionType.matureBoy:
        return 'male';
    }
  }
}