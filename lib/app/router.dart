import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/add_record/add_record_page.dart';
import '../features/home/home_page.dart';
import '../features/ledger/ledger_page.dart';
import '../features/lock/lock_page.dart';
import '../features/profile/profile_page.dart';
import '../features/quick_desk/quick_desk_page.dart';
import '../features/search_old/search_old_page.dart';
import '../features/settings/settings_page.dart';
import '../features/splash/splash_page.dart';
import 'providers.dart';

/// A-6 真路由。go_router + 嵌套 shell。
/// 隐私锁未解锁时，全部路由跳转被拦截到 /lock。
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: '/lock',
    redirect: (context, state) {
      // Splash 永远放行
      if (state.matchedLocation == '/') {
        debugPrint('[router] matched=/ -> allow splash');
        return null;
      }
      // 其它路由：检查隐私锁
      final container = ProviderScope.containerOf(context);
      final privacy = container.read(privacyServiceProvider);
      debugPrint(
        '[router] matched=${state.matchedLocation} locked=${privacy.locked}',
      );
      if (privacy.locked && state.matchedLocation != '/lock') {
        debugPrint('[router] -> /lock');
        return '/lock';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/lock',
        builder: (context, state) => const LockPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
        routes: [
          GoRoute(
            path: 'ledger',
            builder: (context, state) => const LedgerPage(),
          ),
          GoRoute(
            path: 'add',
            builder: (context, state) => const AddRecordPage(),
          ),
          GoRoute(
            path: 'search',
            builder: (context, state) => const SearchOldPage(),
          ),
          GoRoute(
            path: 'profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: 'quick-desk',
            builder: (context, state) => const QuickDeskPage(),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => _ErrorRoute(error: state.error),
  );
}

class _ErrorRoute extends StatelessWidget {
  const _ErrorRoute({this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('页面走丢了', style: TextStyle(fontSize: 22)),
              const SizedBox(height: 12),
              if (error != null)
                Text('$error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go('/home'),
                child: const Text('回首页'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}