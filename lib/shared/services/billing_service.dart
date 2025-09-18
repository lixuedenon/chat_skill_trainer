// lib/shared/services/billing_service.dart

import '../../core/models/user_model.dart';
import '../../core/models/conversation_model.dart';
import 'storage_service.dart';

/// 计费服务类
class BillingService {
  // 套餐定义
  static const Map<String, PackageInfo> packages = {
    'trial': PackageInfo(
      id: 'trial',
      name: '体验包',
      price: 0,
      credits: 20,
      description: '新用户免费体验',
      durationDays: 7,
    ),
    'basic': PackageInfo(
      id: 'basic',
      name: '基础包',
      price: 10,
      credits: 100,
      description: '100轮对话，适合入门用户',
      durationDays: 30,
    ),
    'standard': PackageInfo(
      id: 'standard',
      name: '标准包',
      price: 30,
      credits: 350,
      description: '350轮对话，15%优惠',
      durationDays: 30,
    ),
    'premium': PackageInfo(
      id: 'premium',
      name: 'VIP包',
      price: 50,
      credits: 600,
      description: '600轮对话，20%优惠',
      durationDays: 30,
    ),
  };

  /// 检查用户是否有足够的对话次数
  static bool hasEnoughCredits(UserModel user, int requiredCredits) {
    return user.credits >= requiredCredits;
  }

  /// 消耗对话次数
  static Future<UserModel> consumeCredits(UserModel user, int creditsToConsume) async {
    if (!hasEnoughCredits(user, creditsToConsume)) {
      throw InsufficientCreditsException('对话次数不足，当前剩余：${user.credits}');
    }

    final updatedUser = user.consumeCredits(creditsToConsume);

    // 保存到本地存储
    await StorageService.updateCurrentUser(updatedUser);

    return updatedUser;
  }

  /// 增加对话次数
  static Future<UserModel> addCredits(UserModel user, int creditsToAdd, String reason) async {
    final updatedUser = user.addCredits(creditsToAdd);

    // 记录充值记录
    await _recordTransaction(
      userId: user.id,
      type: TransactionType.credit,
      amount: creditsToAdd,
      reason: reason,
    );

    // 保存到本地存储
    await StorageService.updateCurrentUser(updatedUser);

    return updatedUser;
  }

  /// 购买套餐
  static Future<UserModel> purchasePackage(UserModel user, String packageId) async {
    final package = packages[packageId];
    if (package == null) {
      throw PackageNotFoundException('套餐不存在：$packageId');
    }

    // 模拟支付流程（实际应用中需要对接支付系统）
    final paymentResult = await _processPayment(package.price);
    if (!paymentResult) {
      throw PaymentFailedException('支付失败');
    }

    // 添加对话次数
    final updatedUser = await addCredits(
      user,
      package.credits,
      '购买${package.name}',
    );

    // 如果是VIP套餐，更新VIP状态
    if (packageId == 'premium') {
      final vipUser = updatedUser.copyWith(isVipUser: true);
      await StorageService.updateCurrentUser(vipUser);
      return vipUser;
    }

    return updatedUser;
  }

  /// 计算对话消耗
  static int calculateConversationCost(ConversationModel conversation) {
    // 基础消耗：每轮对话消耗1个credit
    int baseCost = conversation.userMessageCount;

    // 根据对话长度调整
    if (conversation.userMessageCount > 30) {
      baseCost += 5; // 长对话额外消耗
    }

    // VIP用户优惠
    if (conversation.userId.isNotEmpty) {
      // 这里可以根据用户VIP状态给予折扣
      // 实际应用中需要查询用户状态
    }

    return baseCost.clamp(1, 50); // 最少1，最多50
  }

  /// 计算字数密度对应的消耗
  static double calculateDensityCost(List<MessageModel> messages) {
    double totalCost = 0;

    for (final message in messages) {
      if (message.isUser) {
        // 根据字数密度计算消耗
        totalCost += message.densityCoefficient;
      }
    }

    return totalCost;
  }

  /// 获取推荐套餐
  static PackageInfo getRecommendedPackage(UserModel user) {
    // 根据用户的使用习惯推荐套餐
    final averageRounds = user.stats.averageRounds;
    final totalConversations = user.stats.totalConversations;

    if (totalConversations < 5) {
      return packages['basic']!; // 新用户推荐基础包
    } else if (averageRounds > 20) {
      return packages['premium']!; // 高使用量用户推荐VIP包
    } else {
      return packages['standard']!; // 一般用户推荐标准包
    }
  }

  /// 检查套餐性价比
  static double calculatePackageValue(String packageId) {
    final package = packages[packageId];
    if (package == null) return 0;

    if (package.price == 0) return double.infinity; // 免费套餐

    return package.credits / package.price; // credits per yuan
  }

  /// 获取最优惠的套餐
  static PackageInfo getMostValuePackage() {
    PackageInfo bestPackage = packages['basic']!;
    double bestValue = calculatePackageValue('basic');

    for (final packageId in packages.keys) {
      if (packageId == 'trial') continue; // 跳过试用包

      final value = calculatePackageValue(packageId);
      if (value > bestValue) {
        bestValue = value;
        bestPackage = packages[packageId]!;
      }
    }

    return bestPackage;
  }

  /// 获取用户交易历史
  static Future<List<Transaction>> getUserTransactions(String userId) async {
    // 从本地存储获取交易记录
    // 实际应用中应该从服务器获取
    return []; // 暂时返回空列表
  }

  /// 生成账单摘要
  static Future<BillingSummary> generateBillingSummary(String userId, DateTime startDate, DateTime endDate) async {
    final transactions = await getUserTransactions(userId);
    final userConversations = await StorageService.getUserConversations(userId);

    // 筛选时间段内的数据
    final periodTransactions = transactions.where((t) =>
      t.timestamp.isAfter(startDate) && t.timestamp.isBefore(endDate)
    ).toList();

    final periodConversations = userConversations.where((c) =>
      c.createdAt.isAfter(startDate) && c.createdAt.isBefore(endDate)
    ).toList();

    int totalSpent = periodTransactions
        .where((t) => t.type == TransactionType.debit)
        .map((t) => t.amount)
        .fold(0, (sum, amount) => sum + amount);

    int totalEarned = periodTransactions
        .where((t) => t.type == TransactionType.credit)
        .map((t) => t.amount)
        .fold(0, (sum, amount) => sum + amount);

    return BillingSummary(
      startDate: startDate,
      endDate: endDate,
      totalConversations: periodConversations.length,
      totalCreditsSpent: totalSpent,
      totalCreditsEarned: totalEarned,
      averageCreditsPerConversation: periodConversations.isEmpty
          ? 0.0
          : totalSpent / periodConversations.length,
      transactions: periodTransactions,
    );
  }

  /// 检查是否需要充值提醒
  static bool shouldShowTopUpReminder(UserModel user) {
    if (user.credits <= 10) return true; // 少于10次时提醒

    // 根据用户使用习惯判断
    final averageRounds = user.stats.averageRounds;
    if (averageRounds > 0 && user.credits < averageRounds * 2) {
      return true; // 剩余次数不足两次平均对话
    }

    return false;
  }

  /// 获取充值建议
  static String getTopUpSuggestion(UserModel user) {
    final recommended = getRecommendedPackage(user);
    final currentCredits = user.credits;

    if (currentCredits <= 5) {
      return '对话次数即将用完，推荐购买${recommended.name}（${recommended.credits}轮对话）';
    } else if (currentCredits <= 20) {
      return '建议提前充值，推荐${recommended.name}，性价比最高';
    } else {
      return '当前余额充足，可以继续使用';
    }
  }

  // ========== 私有方法 ==========

  /// 模拟支付处理
  static Future<bool> _processPayment(int amount) async {
    // 模拟支付延迟
    await Future.delayed(Duration(seconds: 2));

    // 模拟支付成功率（实际应用中对接真实支付系统）
    return true; // 总是成功，用于测试
  }

  /// 记录交易
  static Future<void> _recordTransaction({
    required String userId,
    required TransactionType type,
    required int amount,
    required String reason,
  }) async {
    final transaction = Transaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      type: type,
      amount: amount,
      reason: reason,
      timestamp: DateTime.now(),
    );

    // 保存到本地存储（实际应用中应该发送到服务器）
    // await StorageService.saveTransaction(transaction);
  }
}

/// 套餐信息类
class PackageInfo {
  final String id;            // 套餐ID
  final String name;          // 套餐名称
  final int price;            // 价格（分）
  final int credits;          // 对话次数
  final String description;   // 描述
  final int durationDays;     // 有效期（天）

  const PackageInfo({
    required this.id,
    required this.name,
    required this.price,
    required this.credits,
    required this.description,
    required this.durationDays,
  });

  /// 获取价格（元）
  double get priceInYuan => price / 100.0;

  /// 获取性价比（credits per yuan）
  double get valueRatio => price > 0 ? credits / priceInYuan : double.infinity;

  /// 获取优惠百分比（相对于基础包）
  int get discountPercentage {
    const baseValue = 10.0; // 基础包的性价比
    if (price == 0) return 100; // 免费套餐
    if (valueRatio <= baseValue) return 0;
    return ((valueRatio - baseValue) / baseValue * 100).round();
  }
}

/// 交易类型枚举
enum TransactionType {
  credit, // 充值
  debit,  // 消费
}

/// 交易记录类
class Transaction {
  final String id;                    // 交易ID
  final String userId;                // 用户ID
  final TransactionType type;         // 交易类型
  final int amount;                   // 金额（credits）
  final String reason;                // 交易原因
  final DateTime timestamp;           // 交易时间

  const Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.reason,
    required this.timestamp,
  });
}

/// 账单摘要类
class BillingSummary {
  final DateTime startDate;              // 开始日期
  final DateTime endDate;                // 结束日期
  final int totalConversations;          // 总对话数
  final int totalCreditsSpent;           // 总消费credits
  final int totalCreditsEarned;          // 总获得credits
  final double averageCreditsPerConversation; // 平均每次对话消费
  final List<Transaction> transactions;   // 交易记录

  const BillingSummary({
    required this.startDate,
    required this.endDate,
    required this.totalConversations,
    required this.totalCreditsSpent,
    required this.totalCreditsEarned,
    required this.averageCreditsPerConversation,
    required this.transactions,
  });

  /// 净消费（消费 - 充值）
  int get netSpending => totalCreditsSpent - totalCreditsEarned;
}

/// 自定义异常类
class InsufficientCreditsException implements Exception {
  final String message;
  InsufficientCreditsException(this.message);
  @override
  String toString() => 'InsufficientCreditsException: $message';
}

class PackageNotFoundException implements Exception {
  final String message;
  PackageNotFoundException(this.message);
  @override
  String toString() => 'PackageNotFoundException: $message';
}

class PaymentFailedException implements Exception {
  final String message;
  PaymentFailedException(this.message);
  @override
  String toString() => 'PaymentFailedException: $message';
}