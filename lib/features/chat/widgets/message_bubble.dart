// lib/features/chat/widgets/message_bubble.dart

import 'package:flutter/material.dart';
import '../../../core/models/conversation_model.dart';
import '../../../core/models/character_model.dart';
import '../../../core/utils/theme_manager.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final CharacterModel character;
  final bool showAvatar;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.character,
    this.showAvatar = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentTheme = ThemeManager.currentTheme;

    return Row(
      mainAxisAlignment: message.isUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // AI头像
        if (!message.isUser && showAvatar)
          _buildAvatar(),

        // 消息内容
        Flexible(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            margin: EdgeInsets.only(
              left: message.isUser ? 60 : (showAvatar ? 8 : 0),
              right: message.isUser ? 0 : 60,
            ),
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // 消息气泡
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? ThemeManager.getUserBubbleColor(currentTheme, isDark)
                        : ThemeManager.getAiBubbleColor(currentTheme, isDark),
                    borderRadius: BorderRadius.circular(20).copyWith(
                      bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 消息文本
                      Text(
                        message.content,
                        style: TextStyle(
                          fontSize: 15,
                          color: message.isUser
                              ? (isDark ? Colors.white : Colors.black87)
                              : (isDark ? Colors.white : Colors.black87),
                          height: 1.4,
                        ),
                      ),

                      // 消息统计信息（调试模式显示）
                      if (_isDebugMode())
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '字数: ${message.characterCount} | 系数: ${message.densityCoefficient.toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // 时间戳
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 用户头像占位符
        if (message.isUser)
          _buildUserAvatar(),
      ],
    );
  }

  /// 构建AI头像
  Widget _buildAvatar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: CircleAvatar(
        radius: 16,
        backgroundImage: character.avatar.isNotEmpty
            ? AssetImage(character.avatar)
            : null,
        backgroundColor: Colors.grey[300],
        child: character.avatar.isEmpty
            ? Icon(
                Icons.person,
                size: 20,
                color: Colors.grey[600],
              )
            : null,
      ),
    );
  }

  /// 构建用户头像
  Widget _buildUserAvatar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20, left: 8),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: ThemeManager.getThemePreviewColor(ThemeManager.currentTheme),
        child: const Icon(
          Icons.person,
          size: 20,
          color: Colors.white,
        ),
      ),
    );
  }

  /// 格式化时间显示
  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else {
      return '${timestamp.month}/${timestamp.day} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  /// 检查是否为调试模式
  bool _isDebugMode() {
    // 在开发环境中显示调试信息
    bool debugMode = false;
    assert(debugMode = true); // 仅在debug模式下为true
    return debugMode;
  }
}