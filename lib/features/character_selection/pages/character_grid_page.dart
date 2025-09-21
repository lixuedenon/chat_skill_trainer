// lib/features/character_selection/pages/character_grid_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/user_model.dart';
import '../character_controller.dart';
import '../widgets/character_card.dart';

class CharacterGridPage extends StatelessWidget {
  final UserModel currentUser;

  const CharacterGridPage({
    Key? key,
    required this.currentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CharacterController(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('选择聊天角色'),
          centerTitle: true,
        ),
        body: Consumer<CharacterController>(
          builder: (context, controller, child) {
            if (controller.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: controller.characters.length,
                itemBuilder: (context, index) {
                  final character = controller.characters[index];
                  return CharacterCard(
                    character: character,
                    onTap: () => _startChat(context, character),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  void _startChat(BuildContext context, character) {
    // 修复：使用正确的路由路径
    Navigator.of(context).pushNamed(
      '/basic_chat',  // ✅ 修正为正确的路由路径
      arguments: {
        'character': character,
        'user': currentUser,
      },
    );
  }
}