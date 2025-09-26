// lib/shared/services/scenario_service.dart (修复版 - 适配异步加载和完善导入)

import '../../core/constants/scenario_data.dart';
import '../../features/anti_pua/anti_pua_scenarios.dart';

/// 场景管理服务 - 统一管理各种训练场景
class ScenarioService {
  // 🔥 缓存已加载的场景数据，避免重复异步加载
  static Map<String, List<CombatScenario>>? _combatScenariosCache;
  static bool _isCombatScenariosLoaded = false;

  /// 🔥 获取实战训练场景（异步版本）
  static Future<List<CombatScenario>> getCombatScenarios(String category) async {
    try {
      // 如果尚未加载，先加载场景数据
      if (!_isCombatScenariosLoaded) {
        await _loadCombatScenarios();
      }

      return _combatScenariosCache?[category] ?? [];
    } catch (e) {
      print('❌ 获取实战训练场景失败: $e');
      return [];
    }
  }

  /// 🔥 私有方法：加载实战场景数据
  static Future<void> _loadCombatScenarios() async {
    try {
      print('🔄 加载实战训练场景数据...');

      // 🔥 使用ScenarioData的异步加载方法
      _combatScenariosCache = await ScenarioData.loadScenarios();
      _isCombatScenariosLoaded = true;

      print('✅ 实战训练场景加载完成，共${_combatScenariosCache?.length ?? 0}个类别');
    } catch (e) {
      print('❌ 加载实战训练场景失败: $e');
      _combatScenariosCache = {};
      _isCombatScenariosLoaded = true; // 即使失败也标记为已加载，避免重复尝试
    }
  }

  /// 🔥 同步版本（向后兼容）- 如果数据已加载则同步返回，否则返回空列表
  static List<CombatScenario> getCombatScenariosSync(String category) {
    if (_isCombatScenariosLoaded && _combatScenariosCache != null) {
      return _combatScenariosCache![category] ?? [];
    }

    print('⚠️ 场景数据未加载，建议使用异步方法 getCombatScenarios()');
    return [];
  }

  /// 获取反PUA训练场景 - 修复方法
  static List<AntiPUAScenario> getAntiPUAScenarios(String category) {
    try {
      return AntiPUAScenariosData.getScenariosByCategory(category);
    } catch (e) {
      print('❌ 获取反PUA场景失败: $e');
      return [];
    }
  }

  /// 🔥 获取随机实战场景（异步版本）
  static Future<CombatScenario?> getRandomCombatScenario() async {
    try {
      if (!_isCombatScenariosLoaded) {
        await _loadCombatScenarios();
      }

      final allScenarios = <CombatScenario>[];
      if (_combatScenariosCache != null) {
        for (final scenarioList in _combatScenariosCache!.values) {
          allScenarios.addAll(scenarioList);
        }
      }

      if (allScenarios.isEmpty) {
        print('⚠️ 没有可用的实战场景');
        return null;
      }

      final randomIndex = DateTime.now().millisecond % allScenarios.length;
      return allScenarios[randomIndex];
    } catch (e) {
      print('❌ 获取随机实战场景失败: $e');
      return null;
    }
  }

  /// 🔥 获取所有可用的实战训练分类（异步版本）
  static Future<List<String>> getAvailableCombatCategories() async {
    try {
      if (!_isCombatScenariosLoaded) {
        await _loadCombatScenarios();
      }

      return _combatScenariosCache?.keys.toList() ?? [];
    } catch (e) {
      print('❌ 获取实战训练分类失败: $e');
      return [];
    }
  }

  /// 获取所有可用的反PUA训练分类
  static List<String> getAvailableAntiPUACategories() {
    try {
      return AntiPUAScenariosData.scenarios.keys.toList();
    } catch (e) {
      print('❌ 获取反PUA训练分类失败: $e');
      return [];
    }
  }

  /// 🔥 根据用户水平推荐场景（异步版本）
  static Future<List<CombatScenario>> getRecommendedScenarios(int userLevel) async {
    try {
      if (userLevel <= 2) {
        return await getCombatScenarios('anti_routine');
      } else if (userLevel <= 5) {
        return await getCombatScenarios('crisis_handling');
      } else {
        return await getCombatScenarios('high_difficulty');
      }
    } catch (e) {
      print('❌ 获取推荐场景失败: $e');
      return [];
    }
  }

  /// 🔥 验证场景数据完整性（异步版本）
  static Future<bool> validateScenarioData() async {
    try {
      print('🔄 验证场景数据完整性...');

      // 检查实战场景数据完整性
      if (!_isCombatScenariosLoaded) {
        await _loadCombatScenarios();
      }

      if (_combatScenariosCache != null) {
        for (final scenarios in _combatScenariosCache!.values) {
          for (final scenario in scenarios) {
            if (scenario.id.isEmpty ||
                scenario.title.isEmpty ||
                scenario.options.isEmpty) {
              print('❌ 发现无效的实战场景: ${scenario.id}');
              return false;
            }
          }
        }
      }

      // 检查反PUA场景数据完整性
      for (final scenarios in AntiPUAScenariosData.scenarios.values) {
        for (final scenario in scenarios) {
          if (scenario.id.isEmpty ||
              scenario.puaTactic.isEmpty ||
              scenario.counterStrategies.isEmpty) {
            print('❌ 发现无效的反PUA场景: ${scenario.id}');
            return false;
          }
        }
      }

      print('✅ 场景数据完整性验证通过');
      return true;
    } catch (e) {
      print('❌ 场景数据完整性验证失败: $e');
      return false;
    }
  }

  /// 🔥 新增：获取随机反PUA场景
  static AntiPUAScenario? getRandomAntiPUAScenario([String? category]) {
    try {
      return AntiPUAScenariosData.getRandomScenario(category);
    } catch (e) {
      print('❌ 获取随机反PUA场景失败: $e');
      return null;
    }
  }

  /// 🔥 新增：根据ID获取反PUA场景
  static AntiPUAScenario? getAntiPUAScenarioById(String id) {
    try {
      return AntiPUAScenariosData.getScenarioById(id);
    } catch (e) {
      print('❌ 根据ID获取反PUA场景失败: $e');
      return null;
    }
  }

  /// 🔥 新增：获取所有反PUA场景
  static List<AntiPUAScenario> getAllAntiPUAScenarios() {
    try {
      return AntiPUAScenariosData.getAllScenarios();
    } catch (e) {
      print('❌ 获取所有反PUA场景失败: $e');
      return [];
    }
  }

  /// 🔥 新增：根据用户水平推荐反PUA场景
  static List<AntiPUAScenario> getRecommendedAntiPUAScenarios(int userLevel) {
    try {
      if (userLevel <= 2) {
        return getAntiPUAScenarios('recognition').take(2).toList();
      } else if (userLevel <= 5) {
        return getAntiPUAScenarios('counter_strategies').take(2).toList();
      } else {
        return getAntiPUAScenarios('self_protection').take(2).toList();
      }
    } catch (e) {
      print('❌ 获取推荐反PUA场景失败: $e');
      return [];
    }
  }

  /// 🔥 新增：根据ID获取实战场景（异步版本）
  static Future<CombatScenario?> getCombatScenarioById(String id) async {
    try {
      if (!_isCombatScenariosLoaded) {
        await _loadCombatScenarios();
      }

      if (_combatScenariosCache != null) {
        for (final scenarios in _combatScenariosCache!.values) {
          for (final scenario in scenarios) {
            if (scenario.id == id) {
              return scenario;
            }
          }
        }
      }

      print('⚠️ 未找到ID为 $id 的实战场景');
      return null;
    } catch (e) {
      print('❌ 根据ID获取实战场景失败: $e');
      return null;
    }
  }

  /// 🔥 新增：获取场景统计信息
  static Future<Map<String, dynamic>> getScenarioStats() async {
    try {
      if (!_isCombatScenariosLoaded) {
        await _loadCombatScenarios();
      }

      // 实战场景统计
      int totalCombatScenarios = 0;
      final combatCategoriesCount = <String, int>{};

      if (_combatScenariosCache != null) {
        for (final entry in _combatScenariosCache!.entries) {
          final categoryName = entry.key;
          final scenarios = entry.value;
          combatCategoriesCount[categoryName] = scenarios.length;
          totalCombatScenarios += scenarios.length;
        }
      }

      // 反PUA场景统计
      int totalAntiPUAScenarios = 0;
      final antiPUACategoriesCount = <String, int>{};

      for (final entry in AntiPUAScenariosData.scenarios.entries) {
        final categoryName = entry.key;
        final scenarios = entry.value;
        antiPUACategoriesCount[categoryName] = scenarios.length;
        totalAntiPUAScenarios += scenarios.length;
      }

      return {
        'combat': {
          'total': totalCombatScenarios,
          'categories': combatCategoriesCount.length,
          'byCategory': combatCategoriesCount,
        },
        'antiPUA': {
          'total': totalAntiPUAScenarios,
          'categories': antiPUACategoriesCount.length,
          'byCategory': antiPUACategoriesCount,
        },
        'overall': {
          'totalScenarios': totalCombatScenarios + totalAntiPUAScenarios,
          'totalCategories': combatCategoriesCount.length + antiPUACategoriesCount.length,
          'isLoaded': _isCombatScenariosLoaded,
        }
      };
    } catch (e) {
      print('❌ 获取场景统计失败: $e');
      return {};
    }
  }

  /// 🔥 新增：按标签搜索场景
  static Future<List<CombatScenario>> searchCombatScenariosByTag(String tag) async {
    try {
      if (!_isCombatScenariosLoaded) {
        await _loadCombatScenarios();
      }

      final matchedScenarios = <CombatScenario>[];

      if (_combatScenariosCache != null) {
        for (final scenarios in _combatScenariosCache!.values) {
          for (final scenario in scenarios) {
            if (scenario.tags.contains(tag)) {
              matchedScenarios.add(scenario);
            }
          }
        }
      }

      print('✅ 标签"$tag"搜索完成，找到${matchedScenarios.length}个场景');
      return matchedScenarios;
    } catch (e) {
      print('❌ 按标签搜索场景失败: $e');
      return [];
    }
  }

  /// 🔥 新增：重新加载场景数据
  static Future<void> reloadScenarios() async {
    try {
      print('🔄 重新加载场景数据...');

      _isCombatScenariosLoaded = false;
      _combatScenariosCache = null;

      // 清理ScenarioData的缓存
      ScenarioData.clearCache();

      await _loadCombatScenarios();
      print('✅ 场景数据重新加载完成');
    } catch (e) {
      print('❌ 重新加载场景数据失败: $e');
    }
  }

  /// 🔥 新增：预加载所有场景数据
  static Future<void> preloadAllScenarios() async {
    try {
      print('🔄 预加载所有场景数据...');

      await _loadCombatScenarios();

      // 反PUA场景已经是静态数据，无需预加载
      final antiPUACount = getAllAntiPUAScenarios().length;

      print('✅ 场景数据预加载完成');
      print('   - 实战场景: ${_combatScenariosCache?.values.fold<int>(0, (sum, list) => sum + list.length) ?? 0} 个');
      print('   - 反PUA场景: $antiPUACount 个');
    } catch (e) {
      print('❌ 预加载场景数据失败: $e');
    }
  }

  /// 🔥 新增：检查场景数据是否已加载
  static bool get isCombatScenariosLoaded => _isCombatScenariosLoaded;

  /// 🔥 新增：获取缓存状态
  static Map<String, dynamic> getCacheStatus() {
    return {
      'combatScenariosLoaded': _isCombatScenariosLoaded,
      'combatScenariosCount': _combatScenariosCache?.values.fold<int>(0, (sum, list) => sum + list.length) ?? 0,
      'combatCategoriesCount': _combatScenariosCache?.keys.length ?? 0,
      'antiPUAScenariosCount': getAllAntiPUAScenarios().length,
      'antiPUACategoriesCount': AntiPUAScenariosData.scenarios.keys.length,
      'memoryUsageKB': _estimateMemoryUsage(),
    };
  }

  /// 🔥 估算内存使用量（KB）
  static int _estimateMemoryUsage() {
    int totalSize = 0;

    // 估算实战场景内存使用
    if (_combatScenariosCache != null) {
      for (final scenarios in _combatScenariosCache!.values) {
        for (final scenario in scenarios) {
          totalSize += scenario.title.length;
          totalSize += scenario.background.length;
          totalSize += scenario.question.length;
          totalSize += scenario.explanation.length;
          totalSize += scenario.options.fold<int>(0, (sum, option) => sum + option.text.length + option.feedback.length);
          totalSize += scenario.tags.fold<int>(0, (sum, tag) => sum + tag.length);
        }
      }
    }

    // 估算反PUA场景内存使用
    for (final scenarios in AntiPUAScenariosData.scenarios.values) {
      for (final scenario in scenarios) {
        totalSize += scenario.puaTactic.length;
        totalSize += scenario.hiddenIntent.length;
        totalSize += scenario.explanation.length;
        totalSize += scenario.counterStrategies.fold<int>(0, (sum, strategy) => sum + strategy.length);
      }
    }

    // 转换为KB（粗略估算，每个字符约2字节）
    return (totalSize * 2) ~/ 1024;
  }

  /// 🔥 新增：清理缓存
  static void clearCache() {
    print('🧹 清理场景服务缓存...');
    _isCombatScenariosLoaded = false;
    _combatScenariosCache = null;
    ScenarioData.clearCache();
    print('✅ 场景服务缓存清理完成');
  }
}