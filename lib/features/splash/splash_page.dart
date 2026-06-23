import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../main.dart' as app;

/// /  启动页 / 入簿（设计文档 §7.1）
///
/// 入簿按钮走 go_router：跳转到 /home 让路由守卫拦截到 /lock（隐私锁），
/// 而非绕过 router 直接 push 到 main.dart 的旧 UI。
class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return app.OnboardingPage(
      onEnter: () => context.go('/home'),
    );
  }
}