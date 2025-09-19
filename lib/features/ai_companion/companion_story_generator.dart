// lib/features/ai_companion/companion_story_generator.dart

import 'dart:math';
import '../../core/models/companion_model.dart';

/// AI伴侣相遇故事生成器
class CompanionStoryGenerator {
  static final Random _random = Random();

  /// 故事模板数据库
  static const Map<MeetingScenario, List<StoryTemplate>> _storyTemplates = {
    MeetingScenario.library: [
      StoryTemplate(
        title: '书中的邂逅',
        storyText: '你正在图书馆查资料，一本书突然从高层书架上掉下来，差点砸到你。你抬头看见一个女孩正红着脸道歉...',
        openingMessage: '对不起对不起！我够不到那本书，没想到会掉下来...你没事吧？',
      ),
      StoryTemplate(
        title: '安静的角落',
        storyText: '图书馆里人很多，你找到一个安静的角落准备看书。刚坐下，发现对面已经有人了...',
        openingMessage: '这个位置有人坐吗？我可以坐这里吗？',
      ),
    ],
    MeetingScenario.rainyNight: [
      StoryTemplate(
        title: '雨夜邂逅',
        storyText: '突然下起了暴雨，你没带伞，只能在便利店门口避雨。这时，一个声音从身后传来...',
        openingMessage: '雨下得好大呀...你也没带伞吗？要不我们一起等等？',
      ),
    ],
    MeetingScenario.coffeeMistake: [
      StoryTemplate(
        title: '咖啡的错误',
        storyText: '咖啡厅里，你刚拿到咖啡准备离开，突然有人拍了拍你的肩膀...',
        openingMessage: '不好意思，我觉得我们的咖啡拿错了...你的应该是拿铁吧？',
      ),
    ],
    MeetingScenario.timeTraveler: [
      StoryTemplate(
        title: '时空的访客',
        storyText: '深夜时分，你在天台看星星，突然一道光闪过，一个声音说...',
        openingMessage: '不好意思，传送有点偏差...你能看见我说明你很特别呢。我来自2050年。',
      ),
    ],
    MeetingScenario.angel: [
      StoryTemplate(
        title: '守护天使',
        storyText: '你遇到了一些麻烦，正在困扰中。突然，一个温柔的声音响起...',
        openingMessage: '我感受到了你的困扰...让我来帮助你吧，我是你的守护天使。',
      ),
    ],
  };

  /// 生成随机相遇故事
  static MeetingStory generateRandomMeeting(CompanionType type) {
    // 根据角色类型选择合适的场景
    final availableScenarios = _getAvailableScenariosForType(type);
    final selectedScenario = availableScenarios[_random.nextInt(availableScenarios.length)];

    final templates = _storyTemplates[selectedScenario] ?? [];
    if (templates.isEmpty) {
      return _getDefaultStory(selectedScenario, type);
    }

    final selectedTemplate = templates[_random.nextInt(templates.length)];

    return MeetingStory(
      scenario: selectedScenario,
      title: selectedTemplate.title,
      storyText: _personalizeStoryText(selectedTemplate.storyText, type),
      openingMessage: _personalizeOpeningMessage(selectedTemplate.openingMessage, type),
      details: {
        'generatedAt': DateTime.now().toIso8601String(),
        'companionType': type.name,
      },
    );
  }

  /// 根据角色类型获取可用场景
  static List<MeetingScenario> _getAvailableScenariosForType(CompanionType type) {
    switch (type) {
      case CompanionType.gentleGirl:
        return [MeetingScenario.library, MeetingScenario.rainyNight, MeetingScenario.coffeeMistake];
      case CompanionType.livelyGirl:
        return [MeetingScenario.coffeeMistake, MeetingScenario.rainyNight];
      case CompanionType.elegantGirl:
        return [MeetingScenario.library, MeetingScenario.coffeeMistake];
      case CompanionType.mysteriousGirl:
        return [MeetingScenario.timeTraveler, MeetingScenario.angel, MeetingScenario.library];
      case CompanionType.sunnyBoy:
        return [MeetingScenario.coffeeMistake, MeetingScenario.rainyNight];
      case CompanionType.matureBoy:
        return [MeetingScenario.library, MeetingScenario.coffeeMistake];
    }
  }

  /// 个性化故事文本
  static String _personalizeStoryText(String baseText, CompanionType type) {
    // 根据角色类型调整故事描述
    switch (type) {
      case CompanionType.gentleGirl:
        return baseText.replaceAll('女孩', '温柔的女孩');
      case CompanionType.livelyGirl:
        return baseText.replaceAll('女孩', '活泼的女孩');
      case CompanionType.elegantGirl:
        return baseText.replaceAll('女孩', '优雅的女孩');
      case CompanionType.mysteriousGirl:
        return baseText.replaceAll('女孩', '神秘的女孩');
      case CompanionType.sunnyBoy:
        return baseText.replaceAll('女孩', '阳光的男孩');
      case CompanionType.matureBoy:
        return baseText.replaceAll('女孩', '成熟的男生');
    }
  }

  /// 个性化开场消息
  static String _personalizeOpeningMessage(String baseMessage, CompanionType type) {
    switch (type) {
      case CompanionType.gentleGirl:
        return baseMessage + ' 我叫...嗯，你可以叫我小柔。';
      case CompanionType.livelyGirl:
        return baseMessage + ' 我是小晴！很高兴认识你！';
      case CompanionType.elegantGirl:
        return baseMessage + ' 我是雅琳，很高兴认识您。';
      case CompanionType.mysteriousGirl:
        return baseMessage + ' 叫我月影就好...';
      case CompanionType.sunnyBoy:
        return baseMessage + ' 我是阿阳，很高兴遇到你！';
      case CompanionType.matureBoy:
        return baseMessage + ' 我是文轩，请多指教。';
    }
  }

  /// 获取默认故事（当没有模板时使用）
  static MeetingStory _getDefaultStory(MeetingScenario scenario, CompanionType type) {
    return MeetingStory(
      scenario: scenario,
      title: '意外的相遇',
      storyText: '在一个平凡的日子里，你们意外地相遇了...',
      openingMessage: '你好，很高兴认识你。',
      details: {'isDefault': true},
    );
  }

  /// 根据场景生成随机细节
  static Map<String, dynamic> generateScenarioDetails(MeetingScenario scenario) {
    switch (scenario) {
      case MeetingScenario.library:
        final books = ['文学', '历史', '心理学', '哲学', '艺术'];
        return {
          'bookType': books[_random.nextInt(books.length)],
          'floor': _random.nextInt(3) + 1,
          'timeOfDay': _random.nextBool() ? 'afternoon' : 'evening',
        };
      case MeetingScenario.rainyNight:
        return {
          'rainIntensity': _random.nextBool() ? 'heavy' : 'moderate',
          'temperature': '凉爽',
          'shelter': _random.nextBool() ? '便利店' : '咖啡厅',
        };
      case MeetingScenario.coffeeMistake:
        final coffees = ['拿铁', '卡布奇诺', '美式', '摩卡'];
        return {
          'yourCoffee': coffees[_random.nextInt(coffees.length)],
          'theirCoffee': coffees[_random.nextInt(coffees.length)],
          'timeOfDay': _random.nextBool() ? 'morning' : 'afternoon',
        };
      default:
        return {};
    }
  }
}

/// 故事模板
class StoryTemplate {
  final String title;
  final String storyText;
  final String openingMessage;

  const StoryTemplate({
    required this.title,
    required this.storyText,
    required this.openingMessage,
  });
}