/// 金额格式化：千分位 + 负号（礼往来使用整数「元」为单位，避免浮点误差）
class AmountUtils {
  AmountUtils._();

  static String format(int amount) {
    final sign = amount < 0 ? '-' : '';
    final raw = amount.abs().toString();
    final buffer = StringBuffer(sign);
    for (var i = 0; i < raw.length; i++) {
      if (i > 0 && (raw.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(raw[i]);
    }
    return buffer.toString();
  }

  /// 「回礼建议」按百位四舍五入（兼容原 ReturnGiftAdvisor 行为）
  static int roundToHundred(double value) {
    return (value / 100).ceil() * 100;
  }
}