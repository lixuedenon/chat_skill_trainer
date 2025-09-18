// lib/features/character_selection/pages/character_detail_page.dart

import 'package:flutter/material.dart';
import '../../../core/models/character_model.dart';
import '../../../core/models/user_model.dart';

class CharacterDetailPage extends StatelessWidget {
  final CharacterModel character;
  final UserModel currentUser;

  const CharacterDetailPage({
    Key? key,
    required this.character,
    required this.currentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(character.name),
        actions: [
          if (character.isVip)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'VIP',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildCharacterProfile(),
                const SizedBox(height: 24),
                _buildPersonalityTraits(),
                const SizedBox(height: 24),
                _buildScenarios(),
              ],
            ),
          ),
          _buildStartChatButton(context),
        ],
      ),
    );
  }

  Widget _buildCharacterProfile() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[200],
              ),
              child: const Icon(Icons.person, size: 60),
            ),
            const SizedBox(height: 16),
            Text(
              character.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                character.typeName,
                style: TextStyle(color: Colors.blue[700]),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              character.description,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalityTraits() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '性格特征',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTraitBar('温暖度', character.traits.warmth),
            _buildTraitBar('独立性', character.traits.independence),
            _buildTraitBar('理性度', character.traits.rationality),
            _buildTraitBar('成熟度', character.traits.maturity),
            _buildTraitBar('优雅度', character.traits.elegance),
            _buildTraitBar('俏皮度', character.traits.playfulness),
          ],
        ),
      ),
    );
  }

  Widget _buildTraitBar(String trait, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(trait),
              Text('$value%'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getTraitColor(value),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTraitColor(int value) {
    if (value >= 80) return Colors.green;
    if (value >= 60) return Colors.blue;
    if (value >= 40) return Colors.orange;
    return Colors.red;
  }

  Widget _buildScenarios() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '适用场景',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: character.scenarios.map((scenario) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(scenario),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartChatButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: character.isVip && !currentUser.isVipUser
              ? () => _showVipRequiredDialog(context)
              : () => _startChat(context),
          child: Text(
            character.isVip && !currentUser.isVipUser
                ? '升级VIP开始聊天'
                : '开始聊天',
          ),
        ),
      ),
    );
  }

  void _startChat(BuildContext context) {
    Navigator.of(context).pushNamed(
      '/chat',
      arguments: {
        'character': character,
        'user': currentUser,
      },
    );
  }

  void _showVipRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('VIP专享角色'),
        content: const Text('此角色需要VIP会员才能使用，是否升级为VIP？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed('/billing');
            },
            child: const Text('升级VIP'),
          ),
        ],
      ),
    );
  }
}