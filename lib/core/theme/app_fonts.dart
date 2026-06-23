/// 字体策略：默认使用系统字体；品牌标题/页面标题可使用自有授权字体（§10.4）
class AppFonts {
  AppFonts._();

  /// 楷意宋意合一的品牌字体（自有 assets/fonts/LiWangLaiKai.ttf）
  static const String kaiti = 'LiWangLaiKai';
  static const String songti = 'LiWangLaiKai';

  /// 退回到平台默认
  static const String fallback = 'sans-serif';
}