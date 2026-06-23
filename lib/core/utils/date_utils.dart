import 'package:intl/intl.dart';

/// 日期格式化：金额外的所有日期展示集中在此，避免散落 format 方法
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _dot = DateFormat('yyyy.MM.dd');
  static final DateFormat _slash = DateFormat('yyyy/MM/dd');
  static final DateFormat _chinese = DateFormat('yyyy年M月d日');
  static final DateFormat _chineseWithWeekday =
      DateFormat('yyyy年M月d日  EEEE', 'zh_CN');
  static final DateFormat _short = DateFormat('M月d日');

  static String dot(DateTime d) => _dot.format(d);
  static String slash(DateTime d) => _slash.format(d);
  static String chinese(DateTime d) => _chinese.format(d);
  static String chineseWithWeekday(DateTime d) =>
      _chineseWithWeekday.format(d);
  static String short(DateTime d) => _short.format(d);

  /// 是否本月内
  static bool isSameMonth(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month;

  /// 是否同年
  static bool isSameYear(DateTime a, DateTime b) => a.year == b.year;
}