import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/conversation_model.dart';
import '../../../core/models/character_model.dart';
import '../../../core/models/user_model.dart';
import '../analysis_controller.dart';
import '../widgets/favorability_chart.dart';
import '../widgets/key_moment_card.dart';

class AnalysisDetailPage extends StatefulWidget {
  final ConversationModel conversation;
  final CharacterModel character;
  final UserModel user;

  const AnalysisDetailPage({
    Key? key,
    required this.conversation,
    required this.character,
    required this.user,
  }) : super(key: key);

  @override
  State<AnalysisDetailPage> createState() => _AnalysisDetailPageState();
}

class _AnalysisDetailPageState extends State<AnalysisDetailPage> {
  late AnalysisController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnalysisController();
    _generateAnalysis();
  }

  Future<void> _generateAnalysis() async {
    await _controller.generateAnalysis(
      conversation: widget.conversation,
      character: widget.character,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('对话分析报告'),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => _shareReport(),
            ),
          ],
        ),
        body: Consumer<AnalysisController>(
          builder: (context, controller, child) {
            if (controller.isGenerating) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('正在分析对话内容...'),
                  ],
                ),
              );
            }

            if (controller.errorMessage.isNotEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                    const SizedBox(height: 16),
                    Text(controller.errorMessage),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _generateAnalysis,
                      child: const Text('重新分析'),
                    ),
                  ],
                ),
              );
            }

            final report = controller.currentReport;
            if (report == null) return const SizedBox();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildScoreCard(report),
                const SizedBox(height: 16),
                _buildFavorabilityChart(),
                const SizedBox(height: 16),
                _buildKeyMoments(report),
                const SizedBox(height: 16),
                _buildSuggestions(report),
                const SizedBox(height: 16),
                _buildActionButtons(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildScoreCard(report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('总体得分', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('${report.finalScore}',
                 style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            Text(report.scoreGrade),
            const SizedBox(height: 8),
            Text(report.overallAssessment, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildFavorabilityChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('好感度变化', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            FavorabilityChart(favorabilityHistory: widget.conversation.metrics.favorabilityHistory),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMoments(report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('关键时刻分析', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...report.keyMoments.map((moment) => KeyMomentCard(moment: moment)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions(report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('改进建议', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ...report.suggestions.map((suggestion) => ListTile(
              leading: Icon(Icons.lightbulb_outline),
              title: Text(suggestion.title),
              subtitle: Text(suggestion.description),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _retryConversation(),
            child: const Text('重新对话'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: () => _changeCharacter(),
            child: const Text('换个角色'),
          ),
        ),
      ],
    );
  }

  void _shareReport() {
    // 分享功能
  }

  void _retryConversation() {
    Navigator.of(context).pushReplacementNamed('/chat', arguments: {
      'character': widget.character,
      'user': widget.user,
      'retry': true,
    });
  }

  void _changeCharacter() {
    Navigator.of(context).pushReplacementNamed('/character_selection', arguments: {
      'user': widget.user,
    });
  }
}
