import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/theme/app_palette.dart';
import '../../core/types.dart';
import '../../main.dart' as app;
import '../add_record/add_record_page.dart';
import '../ledger/ledger_page.dart';
import '../profile/profile_page.dart';
import '../search_old/search_old_page.dart';

/// Shell 页面：底部导航栏 + 五个一级模块切换。
/// 消费 [homeTabIndexProvider] 驱动 tab 切换。
class HomeShellPage extends ConsumerWidget {
  const HomeShellPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabIndex = ref.watch(homeTabIndexProvider);
    final recordsAsync = ref.watch(recordsStreamProvider);
    final records = recordsAsync.maybeWhen<List<GiftRecord>>(
      data: (list) => list,
      orElse: () => const <GiftRecord>[],
    );

    final pages = <Widget>[
      app.HomePage(
        records: records,
        onNavigate: (i) {
          ref.read(homeTabIndexProvider.notifier).state = i;
        },
        onOpenQuickDesk: () {
          context.push('/home/quick-desk');
        },
      ),
      LedgerPage(),
      AddRecordPage(),
      SearchOldPage(),
      ProfilePage(),
    ];

    final isTablet = MediaQuery.sizeOf(context).width >= 700;

    if (isTablet) {
      return _TabletShell(
        selectedIndex: tabIndex,
        onSelected: (i) {
          ref.read(homeTabIndexProvider.notifier).state = i;
        },
        pages: pages,
        onOpenQuickDesk: () => context.push('/home/quick-desk'),
      );
    }

    return _PhoneShell(
      selectedIndex: tabIndex,
      onSelected: (i) {
        ref.read(homeTabIndexProvider.notifier).state = i;
      },
      pages: pages,
      onOpenQuickDesk: () => context.push('/home/quick-desk'),
    );
  }
}

class _PhoneShell extends StatelessWidget {
  const _PhoneShell({
    required this.selectedIndex,
    required this.onSelected,
    required this.pages,
    required this.onOpenQuickDesk,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<Widget> pages;
  final VoidCallback onOpenQuickDesk;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: pages[selectedIndex],
      ),
      floatingActionButton: selectedIndex == 2
          ? null
          : CenterWriteButton(onTap: () => onSelected(2)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: selectedIndex == 2
          ? null
          : _BottomNavBar(
              selectedIndex: selectedIndex,
              onSelected: onSelected,
              onOpenQuickDesk: onOpenQuickDesk,
            ),
    );
  }
}

class _TabletShell extends StatelessWidget {
  const _TabletShell({
    required this.selectedIndex,
    required this.onSelected,
    required this.pages,
    required this.onOpenQuickDesk,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<Widget> pages;
  final VoidCallback onOpenQuickDesk;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        app.TabletRail(
          selectedIndex: selectedIndex,
          onSelected: onSelected,
          onOpenQuickDesk: onOpenQuickDesk,
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: pages[selectedIndex],
          ),
        ),
      ],
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({
    required this.selectedIndex,
    required this.onSelected,
    required this.onOpenQuickDesk,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onOpenQuickDesk;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onSelected,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppPalette.whiteTone,
      selectedItemColor: AppPalette.palaceRed,
      unselectedItemColor: AppPalette.mutedInk,
      selectedLabelStyle: const TextStyle(
        fontFamily: app.AppFonts.kaiti,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: const TextStyle(
        fontFamily: app.AppFonts.kaiti,
        fontSize: 11,
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.home),
          label: '首页',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.book),
          label: '礼簿',
        ),
        BottomNavigationBarItem(
          icon: SizedBox.shrink(),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.search),
          label: '查旧账',
        ),
        BottomNavigationBarItem(
          icon: Icon(CupertinoIcons.person),
          label: '我的',
        ),
      ],
    );
  }
}

class CenterWriteButton extends StatelessWidget {
  const CenterWriteButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB92722), Color(0xFF971B18)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppPalette.rouge.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          CupertinoIcons.pencil,
          color: Color(0xFFFFE3B0),
          size: 24,
        ),
      ),
    );
  }
}
