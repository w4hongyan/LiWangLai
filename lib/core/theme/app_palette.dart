import 'package:flutter/material.dart';

/// 设计文档 §10.3 主色板
/// 红榜用：宫墙红、胭脂红、暖金、宣纸白、墨黑、朱砂红
/// 白榜用：墨黑、松烟灰、素纸白、淡灰线、冷青灰、寒梅灰
class AppPalette {
  AppPalette._();

  // 通用
  static const Color paper = Color(0xFFF7EFE1);
  static const Color paperDeep = Color(0xFFE8D8BF);
  static const Color ink = Color(0xFF231A14);
  static const Color mutedInk = Color(0xFF7E6D58);
  static const Color line = Color(0xFFD9C7AA);
  static const Color whiteTone = Color(0xFFF9F3E8);

  // 红榜
  static const Color palaceRed = Color(0xFFA82420);
  static const Color rouge = Color(0xFF7D1917);
  static const Color cinnabar = Color(0xFFB83A32);
  static const Color gold = Color(0xFFC79B52);
  static const Color paleGold = Color(0xFFE7C783);

  // 白榜
  static const Color pineGrey = Color(0xFF4D4D4D);
  static const Color coldGreenGrey = Color(0xFF9FA3A0);
  static const Color plumGrey = Color(0xFF6F7470);
  static const Color funeralInk = Color(0xFF222222);
  static const Color funeralPaper = Color(0xFFF6F3EC);
  static const Color funeralLine = Color(0xFFD8D3C8);

  // 兼容旧色
  static const Color green = Color(0xFF4F7D54);
}