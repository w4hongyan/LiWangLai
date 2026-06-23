import 'package:flutter/material.dart';

import 'app_fonts.dart';
import 'app_palette.dart';

/// 设计文档 §10 主题：UI 全自定义，不使用默认 Material 风格。
class AppTheme {
  AppTheme._();

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppPalette.paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppPalette.palaceRed,
        primary: AppPalette.palaceRed,
        secondary: AppPalette.gold,
        surface: AppPalette.paper,
      ),
      fontFamily: AppFonts.kaiti,
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: AppPalette.ink,
          fontSize: 36,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        headlineMedium: TextStyle(
          color: AppPalette.ink,
          fontSize: 28,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        titleLarge: TextStyle(
          color: AppPalette.ink,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
        titleMedium: TextStyle(
          color: AppPalette.ink,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
        bodyLarge: TextStyle(
          color: AppPalette.ink,
          fontSize: 16,
          height: 1.45,
          letterSpacing: 0,
        ),
        bodyMedium: TextStyle(
          color: AppPalette.ink,
          fontSize: 14,
          height: 1.35,
          letterSpacing: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.whiteTone.withValues(alpha: 0.74),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppPalette.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppPalette.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: AppPalette.palaceRed, width: 1.4),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white.withValues(alpha: 0.55),
        selectedColor: AppPalette.palaceRed.withValues(alpha: 0.12),
        labelStyle: const TextStyle(color: AppPalette.ink),
        side: const BorderSide(color: AppPalette.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  /// 白榜主题（设计文档 §10.3）
  static ThemeData get whiteTheme {
    return theme.copyWith(
      scaffoldBackgroundColor: AppPalette.funeralPaper,
      colorScheme: theme.colorScheme.copyWith(
        primary: AppPalette.funeralInk,
        secondary: AppPalette.pineGrey,
        surface: AppPalette.funeralPaper,
      ),
    );
  }
}