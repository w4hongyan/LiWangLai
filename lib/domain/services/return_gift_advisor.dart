import '../../core/utils/amount_utils.dart';
import '../entities/gift_record.dart';

/// 回礼建议结果
class ReturnGiftSuggestion {
  const ReturnGiftSuggestion({
    required this.originalAmount,
    required this.increasedAmount,
    required this.relationAdjustedAmount,
  });

  /// 「原礼返回」金额
  final int originalAmount;

  /// 「小幅加礼」金额：原礼 1.25× 后四舍五入到百位（设计文档 §14.1）
  final int increasedAmount;

  /// 按关系分级的建议金额（A 阶段保守实现：B 阶段会扩展亲疏策略）
  final int relationAdjustedAmount;
}

/// 设计文档 §14.1：回礼建议
///
/// A 阶段策略：
/// - originalAmount：完全原额返回
/// - increasedAmount：原额 × 1.25 后四舍五入到百位（喜事白事共用）
/// - relationAdjustedAmount：根据 relation 关键字粗略分级
///   - 「至亲/父母/岳父母」→ increasedAmount × 1.3
///   - 「挚友/发小」→ increasedAmount
///   - 「同事/同学/邻里/亲友」→ increasedAmount × 0.9
///   - 其它 → originalAmount
class ReturnGiftAdvisor {
  const ReturnGiftAdvisor._();

  static const _tierClose = {'至亲', '父母', '岳父母', '亲兄弟', '姐妹'};
  static const _tierMid = {'挚友', '发小', '闺蜜', '兄弟'};
  static const _tierDistant = {'同事', '同学', '邻里', '亲友', '客户'};

  static ReturnGiftSuggestion forRecord({
    required GiftRecord record,
    required Iterable<GiftRecord> records,
  }) {
    final originalAmount = record.amount;
    final increasedAmount = AmountUtils.roundToHundred(
      originalAmount * 1.25,
    );
    final relationAdjustedAmount = _adjustByRelation(
      record.relation,
      increasedAmount,
      originalAmount,
    );
    return ReturnGiftSuggestion(
      originalAmount: originalAmount,
      increasedAmount: increasedAmount,
      relationAdjustedAmount: relationAdjustedAmount,
    );
  }

  static int _adjustByRelation(
    String relation,
    int increased,
    int original,
  ) {
    final rel = relation.trim();
    if (rel.isEmpty) return original;
    if (_tierClose.any(rel.contains)) {
      return AmountUtils.roundToHundred(increased * 1.3);
    }
    if (_tierMid.any(rel.contains)) {
      return increased;
    }
    if (_tierDistant.any(rel.contains)) {
      return AmountUtils.roundToHundred(increased * 0.9);
    }
    return original;
  }
}