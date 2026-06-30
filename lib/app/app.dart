import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import 'providers.dart';
import 'router.dart';

class LiWangLaiApp extends ConsumerStatefulWidget {
  const LiWangLaiApp({super.key});

  @override
  ConsumerState<LiWangLaiApp> createState() => _LiWangLaiAppState();
}

class _LiWangLaiAppState extends ConsumerState<LiWangLaiApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App 进入后台：记录时间
      ref.read(lastBackgroundedAtProvider.notifier).state = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      // App 回到前台：检查是否需要再锁
      final privacy = ref.read(privacyServiceProvider);
      final lastBackgrounded = ref.read(lastBackgroundedAtProvider);
      if (lastBackgrounded != null) {
        privacy.onResume(lastBackgrounded);
        // 如果隐私锁被触发，路由会在下一次 build 时被 redirect 拦截到 /lock
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '礼往来',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: AppRouter.router,
    );
  }
}
