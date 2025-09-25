// lib/core/models/hive_models.dart (Hive数据模型适配器)

import 'package:hive/hive.dart';
import 'user_model.dart';
import 'conversation_model.dart';
import 'analysis_model.dart';
import 'companion_model.dart';

/// 🔥 Hive类型适配器注册 - 必须在使用前注册所有数据类型

class HiveTypeIds {
  // 🔥 为每个数据类型分配唯一ID（0-223）
  static const int userModel = 0;
  static const int conversationModel = 1;
  static const int messageModel = 2;
  static const int analysisReport = 3;
  static const int companionModel = 4;
  static const int memoryFragment = 5;
  static const int keyMoment = 6;
  static const int suggestion = 7;
  static const int personalStrengths = 8;
  static const int personalWeaknesses = 9;
  static const int conversationMetrics = 10;
  static const int favorabilityPoint = 11;
  static const int meetingStory = 12;
  static const int userLevel = 13;
  static const int userStats = 14;
  static const int userPreferences = 15;
}

/// 🔥 Hive适配器注册服务
class HiveAdapterService {
  static bool _isRegistered = false;

  /// 注册所有Hive适配器 - 必须在Hive.init()之后调用
  static void registerAdapters() {
    if (_isRegistered) return;

    try {
      print('🔄 开始注册Hive适配器...');

      // 注册枚举适配器
      Hive.registerAdapter(CharmTagAdapter());
      Hive.registerAdapter(EmotionalStateAdapter());
      Hive.registerAdapter(MomentTypeAdapter());
      Hive.registerAdapter(SuggestionTypeAdapter());
      Hive.registerAdapter(CompanionTypeAdapter());
      Hive.registerAdapter(MeetingScenarioAdapter());
      Hive.registerAdapter(RelationshipStageAdapter());
      Hive.registerAdapter(ConversationStatusAdapter());

      // 注册数据模型适配器
      Hive.registerAdapter(UserModelAdapter());
      Hive.registerAdapter(ConversationModelAdapter());
      Hive.registerAdapter(MessageModelAdapter());
      Hive.registerAdapter(AnalysisReportAdapter());
      Hive.registerAdapter(CompanionModelAdapter());
      Hive.registerAdapter(MemoryFragmentAdapter());
      Hive.registerAdapter(KeyMomentAdapter());
      Hive.registerAdapter(SuggestionAdapter());
      Hive.registerAdapter(PersonalStrengthsAdapter());
      Hive.registerAdapter(PersonalWeaknessesAdapter());
      Hive.registerAdapter(ConversationMetricsAdapter());
      Hive.registerAdapter(FavorabilityPointAdapter());
      Hive.registerAdapter(MeetingStoryAdapter());
      Hive.registerAdapter(UserLevelAdapter());
      Hive.registerAdapter(UserStatsAdapter());
      Hive.registerAdapter(UserPreferencesAdapter());

      _isRegistered = true;
      print('✅ 所有Hive适配器注册完成!');
    } catch (e) {
      print('❌ Hive适配器注册失败: $e');
      rethrow;
    }
  }

  /// 检查是否已注册
  static bool get isRegistered => _isRegistered;
}

// 🔥 枚举适配器 - 让Hive能够存储枚举类型

class CharmTagAdapter extends TypeAdapter<CharmTag> {
  @override
  final int typeId = 100;

  @override
  CharmTag read(BinaryReader reader) {
    return CharmTag.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, CharmTag obj) {
    writer.writeByte(obj.index);
  }
}

class EmotionalStateAdapter extends TypeAdapter<EmotionalState> {
  @override
  final int typeId = 101;

  @override
  EmotionalState read(BinaryReader reader) {
    return EmotionalState.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, EmotionalState obj) {
    writer.writeByte(obj.index);
  }
}

class MomentTypeAdapter extends TypeAdapter<MomentType> {
  @override
  final int typeId = 102;

  @override
  MomentType read(BinaryReader reader) {
    return MomentType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, MomentType obj) {
    writer.writeByte(obj.index);
  }
}

class SuggestionTypeAdapter extends TypeAdapter<SuggestionType> {
  @override
  final int typeId = 103;

  @override
  SuggestionType read(BinaryReader reader) {
    return SuggestionType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, SuggestionType obj) {
    writer.writeByte(obj.index);
  }
}

class CompanionTypeAdapter extends TypeAdapter<CompanionType> {
  @override
  final int typeId = 104;

  @override
  CompanionType read(BinaryReader reader) {
    return CompanionType.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, CompanionType obj) {
    writer.writeByte(obj.index);
  }
}

class MeetingScenarioAdapter extends TypeAdapter<MeetingScenario> {
  @override
  final int typeId = 105;

  @override
  MeetingScenario read(BinaryReader reader) {
    return MeetingScenario.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, MeetingScenario obj) {
    writer.writeByte(obj.index);
  }
}

class RelationshipStageAdapter extends TypeAdapter<RelationshipStage> {
  @override
  final int typeId = 106;

  @override
  RelationshipStage read(BinaryReader reader) {
    return RelationshipStage.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, RelationshipStage obj) {
    writer.writeByte(obj.index);
  }
}

class ConversationStatusAdapter extends TypeAdapter<ConversationStatus> {
  @override
  final int typeId = 107;

  @override
  ConversationStatus read(BinaryReader reader) {
    return ConversationStatus.values[reader.readByte()];
  }

  @override
  void write(BinaryWriter writer, ConversationStatus obj) {
    writer.writeByte(obj.index);
  }
}

// 🔥 数据模型适配器 - 自动生成的适配器类

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = HiveTypeIds.userModel;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      username: fields[1] as String,
      email: fields[2] as String,
      createdAt: fields[3] as DateTime,
      lastLoginAt: fields[4] as DateTime,
      credits: fields[5] as int,
      charmTags: (fields[6] as List).cast<CharmTag>(),
      userLevel: fields[7] as UserLevel,
      stats: fields[8] as UserStats,
      preferences: fields[9] as UserPreferences,
      isVipUser: fields[10] as bool,
      conversationHistory: (fields[11] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.lastLoginAt)
      ..writeByte(5)
      ..write(obj.credits)
      ..writeByte(6)
      ..write(obj.charmTags)
      ..writeByte(7)
      ..write(obj.userLevel)
      ..writeByte(8)
      ..write(obj.stats)
      ..writeByte(9)
      ..write(obj.preferences)
      ..writeByte(10)
      ..write(obj.isVipUser)
      ..writeByte(11)
      ..write(obj.conversationHistory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConversationModelAdapter extends TypeAdapter<ConversationModel> {
  @override
  final int typeId = HiveTypeIds.conversationModel;

  @override
  ConversationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConversationModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      characterId: fields[2] as String,
      messages: (fields[3] as List).cast<MessageModel>(),
      status: fields[4] as ConversationStatus,
      createdAt: fields[5] as DateTime,
      updatedAt: fields[6] as DateTime,
      metrics: fields[7] as ConversationMetrics,
      scenario: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ConversationModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.characterId)
      ..writeByte(3)
      ..write(obj.messages)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt)
      ..writeByte(7)
      ..write(obj.metrics)
      ..writeByte(8)
      ..write(obj.scenario);
  }
}

class MessageModelAdapter extends TypeAdapter<MessageModel> {
  @override
  final int typeId = HiveTypeIds.messageModel;

  @override
  MessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageModel(
      id: fields[0] as String,
      content: fields[1] as String,
      isUser: fields[2] as bool,
      timestamp: fields[3] as DateTime,
      characterCount: fields[4] as int,
      densityCoefficient: fields[5] as double,
    );
  }

  @override
  void write(BinaryWriter writer, MessageModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.isUser)
      ..writeByte(3)
      ..write(obj.timestamp)
      ..writeByte(4)
      ..write(obj.characterCount)
      ..writeByte(5)
      ..write(obj.densityCoefficient);
  }
}

// 🔥 其他适配器类的简化实现
class AnalysisReportAdapter extends TypeAdapter<AnalysisReport> {
  @override
  final int typeId = HiveTypeIds.analysisReport;

  @override
  AnalysisReport read(BinaryReader reader) {
    return AnalysisReport.fromJson(Map<String, dynamic>.from(reader.read()));
  }

  @override
  void write(BinaryWriter writer, AnalysisReport obj) {
    writer.write(obj.toJson());
  }
}

class CompanionModelAdapter extends TypeAdapter<CompanionModel> {
  @override
  final int typeId = HiveTypeIds.companionModel;

  @override
  CompanionModel read(BinaryReader reader) {
    return CompanionModel.fromJson(Map<String, dynamic>.from(reader.read()));
  }

  @override
  void write(BinaryWriter writer, CompanionModel obj) {
    writer.write(obj.toJson());
  }
}

class MemoryFragmentAdapter extends TypeAdapter<MemoryFragment> {
  @override
  final int typeId = HiveTypeIds.memoryFragment;

  @override
  MemoryFragment read(BinaryReader reader) {
    return MemoryFragment.fromJson(Map<String, dynamic>.from(reader.read()));
  }

  @override
  void write(BinaryWriter writer, MemoryFragment obj) {
    writer.write(obj.toJson());
  }
}

class KeyMomentAdapter extends TypeAdapter<KeyMoment> {
  @override
  final int typeId = HiveTypeIds.keyMoment;

  @override
  KeyMoment read(BinaryReader reader) {
    return KeyMoment.fromJson(Map<String, dynamic>.from(reader.read()));
  }

  @override
  void write(BinaryWriter writer, KeyMoment obj) {
    writer.write(obj.toJson());
  }
}

class SuggestionAdapter extends TypeAdapter<Suggestion> {
  @override
  final int typeId = HiveTypeIds.suggestion;

  @override
  Suggestion read(BinaryReader reader) {
    return Suggestion.fromJson(Map<String, dynamic>.from(reader.read()));
  }

  @override
  void write(BinaryWriter writer, Suggestion obj) {
    writer.write(obj.toJson());
  }
}

class PersonalStrengthsAdapter extends TypeAdapter<PersonalStrengths> {
  @override
  final int typeId = HiveTypeIds.personalStrengths;

  @override
  PersonalStrengths read(BinaryReader reader) {
    return PersonalStrengths.fromJson(Map<String, dynamic>.from(reader.read()));
  }

  @override
  void write(BinaryWriter writer, PersonalStrengths obj) {
    writer.write(obj.toJson());
  }
}

class PersonalWeaknessesAdapter extends TypeAdapter<PersonalWeaknesses> {
  @override
  final int typeId = HiveTypeIds.personalWeaknesses;

  @override
  PersonalWeaknesses read(BinaryReader reader) {
    return PersonalWeaknesses.fromJson(Map<String, dynamic>.from(reader.read()));
  }

  @override
  void write(BinaryWriter writer, PersonalWeaknesses obj) {
    writer.write(obj.toJson());
  }
}

class ConversationMetricsAdapter extends TypeAdapter<ConversationMetrics> {
  @override
  final int typeId = HiveTypeIds.conversationMetrics;

  @override
  ConversationMetrics read(BinaryReader reader) {
    return ConversationMetrics.fromJson(Map<String, dynamic>.from(reader.read()));
  }

  @override
  void write(BinaryWriter writer, ConversationMetrics obj) {
    writer.write(obj.toJson());
  }
}

class FavorabilityPointAdapter extends TypeAdapter<FavorabilityPoint> {
  @override
  final int typeId = HiveTypeIds.favorabilityPoint;

  @override
  FavorabilityPoint read(BinaryReader reader) {
    return FavorabilityPoint.fromJson(Map<String, dynamic>.from(reader.read()));
  }

  @override
  void write(BinaryWriter writer, FavorabilityPoint obj) {
    writer.write(obj.toJson());
  }
}

class MeetingStoryAdapter extends TypeAdapter<MeetingStory> {
  @override
  final int typeId = HiveTypeIds.meetingStory;

  @override
  MeetingStory read(BinaryReader reader) {
    return MeetingStory.fromJson(Map<String, dynamic>.from(reader.read()));
  }

  @override
  void write(BinaryWriter writer, MeetingStory obj) {
    writer.write(obj.toJson());
  }
}

class UserLevelAdapter extends TypeAdapter<UserLevel> {
  @override
  final int typeId = HiveTypeIds.userLevel;

  @override
  UserLevel read(BinaryReader reader) {
    return UserLevel.fromJson(Map<String, dynamic>.from(reader.read()));
  }

  @override
  void write(BinaryWriter writer, UserLevel obj) {
    writer.write(obj.toJson());
  }
}

class UserStatsAdapter extends TypeAdapter<UserStats> {
  @override
  final int typeId = HiveTypeIds.userStats;

  @override
  UserStats read(BinaryReader reader) {
    return UserStats.fromJson(Map<String, dynamic>.from(reader.read()));
  }

  @override
  void write(BinaryWriter writer, UserStats obj) {
    writer.write(obj.toJson());
  }
}

class UserPreferencesAdapter extends TypeAdapter<UserPreferences> {
  @override
  final int typeId = HiveTypeIds.userPreferences;

  @override
  UserPreferences read(BinaryReader reader) {
    return UserPreferences.fromJson(Map<String, dynamic>.from(reader.read()));
  }

  @override
  void write(BinaryWriter writer, UserPreferences obj) {
    writer.write(obj.toJson());
  }
}