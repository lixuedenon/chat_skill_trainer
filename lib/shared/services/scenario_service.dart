// lib/shared/services/scenario_service.dart

import '../../core/constants/scenario_data.dart';
import '../../features/anti_pua/anti_pua_scenarios.dart'; // 添加缺失的导入

/// 场景管理服务 - 统一管理各种训练场景
class ScenarioService {
  /// 获取实战训练场景
  static List<CombatScenario> getCombatScenarios(String category) {
    return ScenarioData.getCombatScenariosByCategory(category);
  }

  /// 获取反PUA训练场景 - 修复方法
  static List<AntiPUAScenario> getAntiPUAScenarios(String category) {
    return AntiPUAScenariosData.getScenariosByCategory(category); // 使用正确的数据源
  }

  /// 获取随机实战场景
  static CombatScenario getRandomCombatScenario() {
    return ScenarioData.getRandomCombatScenario();
  }

  /// 获取所有可用的实战训练分类
  static List<String> getAvailableCombatCategories() {
    return ScenarioData.combatScenarios.keys.toList();
  }

  /// 获取所有可用的反PUA训练分类
  static List<String> getAvailableAntiPUACategories() {
    return AntiPUAScenariosData.scenarios.keys.toList(); // 修复数据源
  }

  /// 根据用户水平推荐场景
  static List<CombatScenario> getRecommendedScenarios(int userLevel) {
    if (userLevel <= 2) {
      return getCombatScenarios('anti_routine').take(3).toList();
    } else if (userLevel <= 5) {
      return getCombatScenarios('crisis_handling').take(3).toList();
    } else {
      return getCombatScenarios('high_difficulty').take(3).toList();
    }
  }

  /// 验证场景数据完整性
  static bool validateScenarioData() {
    try {
      // 检查实战场景数据完整性
      for (final scenarios in ScenarioData.combatScenarios.values) {
        for (final scenario in scenarios) {
          if (scenario.id.isEmpty ||
              scenario.title.isEmpty ||
              scenario.options.isEmpty) {
            return false;
          }
        }
      }

      // 检查反PUA场景数据完整性
      for (final scenarios in AntiPUAScenariosData.scenarios.values) {
        for (final scenario in scenarios) {
          if (scenario.id.isEmpty ||
              scenario.puaTactic.isEmpty ||
              scenario.counterStrategies.isEmpty) {
            return false;
          }
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// 🔥 新增：获取随机反PUA场景
  static AntiPUAScenario? getRandomAntiPUAScenario([String? category]) {
    return AntiPUAScenariosData.getRandomScenario(category);
  }

  /// 🔥 新增：根据ID获取反PUA场景
  static AntiPUAScenario? getAntiPUAScenarioById(String id) {
    return AntiPUAScenariosData.getScenarioById(id);
  }

  /// 🔥 新增：获取所有反PUA场景
  static List<AntiPUAScenario> getAllAntiPUAScenarios() {
    return AntiPUAScenariosData.getAllScenarios();
  }

  /// 🔥 新增：根据用户水平推荐反PUA场景
  static List<AntiPUAScenario> getRecommendedAntiPUAScenarios(int userLevel) {
    if (userLevel <= 2) {
      return getAntiPUAScenarios('recognition').take(2).toList();
    } else if (userLevel <= 5) {
      return getAntiPUAScenarios('counter_strategies').take(2).toList();
    } else {
      return getAntiPUAScenarios('self_protection').take(2).toList();
    }
  }
}