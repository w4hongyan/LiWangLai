/// 响应式断点（设计文档 §9.3）
class AppBreakpoints {
  AppBreakpoints._();

  /// < 700：iPhone 单栏布局
  static const double phoneMax = 699;

  /// 700 - 999：iPad 竖屏 / 双栏布局
  static const double tabletMin = 700;

  /// >= 1000：iPad 横屏 / 三栏布局
  static const double desktopLikeMin = 1000;

  static bool isPhone(double width) => width <= phoneMax;
  static bool isTablet(double width) => width >= tabletMin;
  static bool isDesktopLike(double width) => width >= desktopLikeMin;
}