import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart' as app_router;
import 'app/app_bootstrap.dart';
import 'core/types.dart';

// 方便测试 / 旧代码 import 'package:liwanglai/main.dart' 直接拿到类型。
export 'core/types.dart';

void main() async {
  final result = await bootstrap();
  final container = buildContainer(result);
  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const app_router.LiWangLaiApp(),
    ),
  );
}

class AppPalette {
  static const paper = Color(0xFFF7EFE1);
  static const paperDeep = Color(0xFFE8D8BF);
  static const ink = Color(0xFF231A14);
  static const mutedInk = Color(0xFF7E6D58);
  static const palaceRed = Color(0xFFA82420);
  static const rouge = Color(0xFF7D1917);
  static const cinnabar = Color(0xFFB83A32);
  static const gold = Color(0xFFC79B52);
  static const paleGold = Color(0xFFE7C783);
  static const line = Color(0xFFD9C7AA);
  static const whiteTone = Color(0xFFF9F3E8);
  static const pineGrey = Color(0xFF4D4D4D);
  static const green = Color(0xFF4F7D54);
}

class AppAssets {
  static const paper = 'assets/images/paper_texture.png';
  static const onboardingBackground =
      'assets/images/onboarding_background_full.png';
  static const onboardingSeal = 'assets/images/onboarding_seal_mark.png';
  static const logo = 'assets/images/brand_logo_calligraphy.png';
  static const homeLogo = 'assets/images/brand_logo_with_seal.png';
  static const plum = 'assets/images/plum_branch_corner.png';
  static const homeMountain = 'assets/images/home_landscape_pavilion_plum.png';
  static const quickMountain = 'assets/images/intro_landscape_pavilion.png';
  static const introLandscape = 'assets/images/intro_landscape_pavilion.png';
  static const bottomMountain = 'assets/images/bottom_landscape_strip.png';
  static const monthlyLedgerCard = 'assets/images/monthly_ledger_red_card.png';
  static const yearlyLedgerCard = 'assets/images/yearly_ledger_red_card.png';
  static const yearlyLedgerPanel =
      'assets/images/yearly_ledger_panel_clean.png';
  static const iconSearchLedger = 'assets/images/ledger_search_badge.png';
  static const iconWriteBrush = 'assets/images/write_brush_badge.png';
  static const iconWriteBrushNav = 'assets/images/write_brush_badge_nav.png';
  static const iconCeremonyTable = 'assets/images/ceremony_table_badge.png';
  static const iconLedgerBook = 'assets/images/ledger_book_badge.png';
  static const iconDoubleHappiness = 'assets/images/double_happiness_badge.png';
  static const iconFamilyBlessing = 'assets/images/family_blessing_badge.png';
  static const redLedger = 'assets/images/red_ledger_texture.png';
  static const redPlaque = 'assets/images/red_plaque_clean.png';
  static const profileBanner = 'assets/images/profile_banner_texture.png';
}

class AppFonts {
  static const songti = 'LiWangLaiKai';
  static const kaiti = 'LiWangLaiKai';
}

class AppTheme {
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
          borderSide: const BorderSide(color: AppPalette.palaceRed, width: 1.4),
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
}

enum GiftDirection { received, given }

enum EventTone { red, white }

class GiftRecord {
  const GiftRecord({
    required this.id,
    required this.name,
    required this.relation,
    required this.event,
    required this.direction,
    required this.tone,
    required this.amount,
    required this.date,
    required this.method,
    required this.book,
    this.note = '',
    this.itemDescription = '',
    this.partial = false,
    this.needReturn = false,
  });

  final String id;
  final String name;
  final String relation;
  final String event;
  final GiftDirection direction;
  final EventTone tone;
  final int amount;
  final DateTime date;
  final String method;
  final String book;
  final String note;
  final String itemDescription;
  final bool partial;
  final bool needReturn;

  GiftRecord copyWith({
    String? id,
    String? name,
    String? relation,
    String? event,
    GiftDirection? direction,
    EventTone? tone,
    int? amount,
    DateTime? date,
    String? method,
    String? book,
    String? note,
    String? itemDescription,
    bool? partial,
    bool? needReturn,
  }) {
    return GiftRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      relation: relation ?? this.relation,
      event: event ?? this.event,
      direction: direction ?? this.direction,
      tone: tone ?? this.tone,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      method: method ?? this.method,
      book: book ?? this.book,
      note: note ?? this.note,
      itemDescription: itemDescription ?? this.itemDescription,
      partial: partial ?? this.partial,
      needReturn: needReturn ?? this.needReturn,
    );
  }
}

class LedgerTotals {
  const LedgerTotals({required this.received, required this.given});

  final int received;
  final int given;

  int get balance => received - given;

  factory LedgerTotals.fromRecords(Iterable<GiftRecord> records) {
    var received = 0;
    var given = 0;
    for (final record in records) {
      if (record.direction == GiftDirection.received) {
        received += record.amount;
      } else {
        given += record.amount;
      }
    }
    return LedgerTotals(received: received, given: given);
  }
}

class ReturnGiftSuggestion {
  const ReturnGiftSuggestion({
    required this.originalAmount,
    required this.increasedAmount,
  });

  final int originalAmount;
  final int increasedAmount;
}

class ReturnGiftAdvisor {
  const ReturnGiftAdvisor._();

  static ReturnGiftSuggestion forRecord({
    required GiftRecord record,
    required Iterable<GiftRecord> records,
  }) {
    // A return should start from the most recent gift, rather than a fabricated
    // history total. The 25% option mirrors the prototype's 800 -> 1,000 cue.
    final originalAmount = record.amount;
    final increasedAmount = ((originalAmount * 1.25) / 100).ceil() * 100;
    return ReturnGiftSuggestion(
      originalAmount: originalAmount,
      increasedAmount: increasedAmount,
    );
  }
}

class ReminderItem {
  const ReminderItem(this.title, this.subtitle, this.daysLeft);

  final String title;
  final String subtitle;
  final int daysLeft;
}

class StartupPage extends StatelessWidget {
  const StartupPage({super.key});

  void _enterApp(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (context) => const LiWangLaiHome()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingPage(onEnter: () => _enterApp(context));
  }
}

class LiWangLaiHome extends StatefulWidget {
  const LiWangLaiHome({super.key});

  @override
  State<LiWangLaiHome> createState() => _LiWangLaiHomeState();
}

class _LiWangLaiHomeState extends State<LiWangLaiHome> {
  int _tabIndex = 0;
  final List<GiftRecord> _records = List.of(SampleData.records);

  void _selectTab(int index) {
    setState(() {
      _tabIndex = index;
    });
  }

  void _openQuickDesk() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => QuickDeskPage(
          records: _records,
          onRecordAdded: (record) {
            setState(() {
              _records.insert(0, record);
            });
          },
          onRecordRemoved: _removeRecord,
        ),
      ),
    );
  }

  void _addRecord(GiftRecord record) {
    setState(() {
      _records.insert(0, record);
      _tabIndex = 1;
    });
  }

  void _removeRecord(GiftRecord record) {
    setState(() {
      _records.removeWhere((item) => item.id == record.id);
    });
  }

  void _updateRecord(GiftRecord record) {
    setState(() {
      final index = _records.indexWhere((item) => item.id == record.id);
      if (index == -1) {
        _records.insert(0, record);
      } else {
        _records[index] = record;
      }
      _tabIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth >= 700;
        final pages = [
          HomePage(
            records: _records,
            onNavigate: _selectTab,
            onOpenQuickDesk: _openQuickDesk,
          ),
          LedgerPage(
            records: _records,
            onRecordAdded: _addRecord,
            onRecordUpdated: _updateRecord,
          ),
          AddRecordPage(onSave: _addRecord, onBack: () => _selectTab(0)),
          SearchOldPage(
            records: _records,
            onRecordAdded: _addRecord,
            onRecordUpdated: _updateRecord,
          ),
          ProfilePage(
            records: _records,
            onRecordAdded: _addRecord,
            onRecordUpdated: _updateRecord,
          ),
        ];

        if (isTablet) {
          return AntiqueScaffold(
            useSafeArea: _tabIndex != 2,
            child: Row(
              children: [
                TabletRail(
                  selectedIndex: _tabIndex,
                  onSelected: _selectTab,
                  onOpenQuickDesk: _openQuickDesk,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: pages[_tabIndex],
                  ),
                ),
              ],
            ),
          );
        }

        return AntiqueScaffold(
          useSafeArea: _tabIndex != 2,
          floatingActionButton: _tabIndex == 2
              ? null
              : CenterWriteButton(onTap: () => _selectTab(2)),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: _tabIndex == 2
              ? null
              : PhoneNavBar(selectedIndex: _tabIndex, onSelected: _selectTab),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: pages[_tabIndex],
          ),
        );
      },
    );
  }
}

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key, required this.onEnter});

  final VoidCallback onEnter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final logoWidth = math.min(constraints.maxWidth * 0.86, 348.0);
          final buttonWidth = math.min(constraints.maxWidth * 0.62, 244.0);
          final contentTop = math.max(
            constraints.maxHeight * 0.23,
            MediaQuery.paddingOf(context).top + 124,
          );

          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                AppAssets.onboardingBackground,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
              SafeArea(
                child: DefaultTextStyle.merge(
                  style: const TextStyle(fontFamily: AppFonts.kaiti),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: contentTop,
                        child: Column(
                          children: [
                            Image.asset(
                              AppAssets.logo,
                              width: logoWidth,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 12),
                            const OrnateSubtitle(
                              text: '人情往来礼簿',
                              fontFamily: AppFonts.kaiti,
                            ),
                            const SizedBox(height: 22),
                            const Text(
                              '礼有往来，情有分寸',
                              style: TextStyle(
                                color: AppPalette.mutedInk,
                                fontFamily: AppFonts.kaiti,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Image.asset(
                              AppAssets.onboardingSeal,
                              width: 36,
                              height: 36,
                              fit: BoxFit.contain,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 50,
                        child: Column(
                          children: [
                            SizedBox(
                              width: buttonWidth,
                              child: SealButton(
                                label: '入簿',
                                fontFamily: AppFonts.kaiti,
                                onPressed: onEnter,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.records,
    required this.onNavigate,
    required this.onOpenQuickDesk,
  });

  final List<GiftRecord> records;
  final ValueChanged<int> onNavigate;
  final VoidCallback onOpenQuickDesk;

  @override
  Widget build(BuildContext context) {
    final totals = LedgerTotals.fromRecords(records);

    return PageFrame(
      title: '礼往来',
      subtitle: '我家礼簿 · 今日往来',
      trailing: const HomeBellIcon(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final veryCompact = constraints.maxHeight < 520;
          final compact = constraints.maxHeight < 580;
          final rowHeight = veryCompact ? 24.0 : (compact ? 27.0 : 38.0);
          final landscapeReserve = veryCompact ? 8.0 : (compact ? 10.0 : 22.0);
          final landscapeInset = veryCompact ? 10.0 : 14.0;
          const visibleRecordCount = 5;
          final visibleRecords = records.take(visibleRecordCount).toList();
          final ledgerHeight = rowHeight * visibleRecords.length + 2;

          return Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              compact ? 0 : 2,
              16,
              veryCompact ? 0 : 4,
            ),
            child: Column(
              children: [
                HeroLedgerCard(
                  received: totals.received,
                  given: totals.given,
                  balance: totals.balance,
                  height: veryCompact ? 112 : (compact ? 136 : 154),
                ),
                SizedBox(height: veryCompact ? 7 : (compact ? 8 : 10)),
                ResponsiveWrap(
                  children: [
                    QuickAction(
                      imageAsset: AppAssets.iconSearchLedger,
                      label: '查往来',
                      onTap: () => onNavigate(3),
                    ),
                    QuickAction(
                      imageAsset: AppAssets.iconWriteBrush,
                      label: '记一笔',
                      onTap: () => onNavigate(2),
                    ),
                    QuickAction(
                      imageAsset: AppAssets.iconCeremonyTable,
                      label: '礼台模式',
                      onTap: onOpenQuickDesk,
                    ),
                    QuickAction(
                      imageAsset: AppAssets.iconLedgerBook,
                      label: '礼簿',
                      onTap: () => onNavigate(1),
                    ),
                  ],
                ),
                if (!veryCompact) ...[
                  SizedBox(height: compact ? 8 : 10),
                  const SectionHeader(title: '即将到来', action: '全部'),
                  const SizedBox(height: 7),
                  const UpcomingReminderGrid(items: SampleData.reminders),
                  SizedBox(height: compact ? 8 : 10),
                ] else
                  const SizedBox(height: 7),
                const SectionHeader(title: '最近往来', action: '全部'),
                const SizedBox(height: 3),
                SizedBox(
                  height: ledgerHeight + landscapeReserve,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      SizedBox(
                        height: ledgerHeight,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: RecentRecordsTable(
                            records: visibleRecords,
                            rowHeight: rowHeight,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        top: ledgerHeight - landscapeInset,
                        child: const IgnorePointer(
                          child: HomeBottomLandscape(height: 34),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LedgerPage extends StatefulWidget {
  const LedgerPage({
    super.key,
    required this.records,
    required this.onRecordAdded,
    required this.onRecordUpdated,
  });

  final List<GiftRecord> records;
  final ValueChanged<GiftRecord> onRecordAdded;
  final ValueChanged<GiftRecord> onRecordUpdated;

  @override
  State<LedgerPage> createState() => _LedgerPageState();
}

class _LedgerPageState extends State<LedgerPage> {
  String _filter = '全部';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.records.where((record) {
      final matchesQuery =
          _query.isEmpty ||
          record.name.contains(_query) ||
          record.relation.contains(_query) ||
          record.event.contains(_query);
      if (!matchesQuery) {
        return false;
      }
      return switch (_filter) {
        '收礼' => record.direction == GiftDirection.received,
        '回礼' => record.direction == GiftDirection.given,
        '喜事' => record.tone == EventTone.red,
        '白事' => record.tone == EventTone.white,
        '待补全' => record.partial,
        '待回礼' => record.needReturn,
        _ => true,
      };
    }).toList();

    final totals = LedgerTotals.fromRecords(filtered);
    final latestRecord = filtered.isEmpty
        ? null
        : filtered.reduce(
            (latest, record) =>
                record.date.isAfter(latest.date) ? record : latest,
          );

    return LedgerPageFrame(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 96),
        children: [
          _buildSearchBar(),
          const SizedBox(height: 8),
          _buildFilterChips(),
          const SizedBox(height: 10),
          _buildMonthSummary(totals, latestRecord?.date ?? DateTime.now()),
          const SizedBox(height: 10),
          if (filtered.isEmpty)
            const EmptyState(title: '没有找到记录', subtitle: '换个筛选条件，或从"记一笔"开始入簿。')
          else
            ...filtered.map(
              (record) => _LedgerRecordRow(
                record: record,
                records: widget.records,
                onRecordAdded: widget.onRecordAdded,
                onRecordUpdated: widget.onRecordUpdated,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppPalette.line.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.search,
            color: AppPalette.mutedInk.withValues(alpha: 0.6),
            size: 15,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => _query = value.trim()),
              style: const TextStyle(fontFamily: AppFonts.kaiti, fontSize: 12),
              decoration: const InputDecoration(
                hintText: '搜索姓名、关系、事件',
                hintStyle: TextStyle(
                  color: Color(0xFFB4A690),
                  fontFamily: AppFonts.kaiti,
                  fontSize: 12,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['全部', '收礼', '回礼', '喜事', '白事', '待补全', '待回礼'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in filters)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: GestureDetector(
                onTap: () => setState(() => _filter = filter),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _filter == filter
                        ? AppPalette.palaceRed
                        : AppPalette.whiteTone.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _filter == filter
                          ? AppPalette.palaceRed
                          : AppPalette.line,
                    ),
                  ),
                  child: Text(
                    filter,
                    style: TextStyle(
                      color: _filter == filter ? Colors.white : AppPalette.ink,
                      fontFamily: AppFonts.kaiti,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMonthSummary(LedgerTotals totals, DateTime month) {
    final balance = totals.balance;
    final balanceText = balance >= 0
        ? '+${formatAmount(balance)}'
        : formatAmount(balance);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppPalette.whiteTone.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppPalette.line.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Text(
            '✣',
            style: TextStyle(color: AppPalette.palaceRed, fontSize: 12),
          ),
          const SizedBox(width: 8),
          Text(
            '${month.year}年${month.month}月',
            style: const TextStyle(
              fontFamily: AppFonts.kaiti,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '收礼: ${formatAmount(totals.received)} 元',
            style: TextStyle(
              fontFamily: AppFonts.kaiti,
              fontSize: 12,
              color: AppPalette.mutedInk,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '回礼: ${formatAmount(totals.given)} 元',
            style: TextStyle(
              fontFamily: AppFonts.kaiti,
              fontSize: 12,
              color: AppPalette.mutedInk,
            ),
          ),
          const Spacer(),
          Text(
            '结余: $balanceText 元',
            style: TextStyle(
              fontFamily: AppFonts.kaiti,
              fontSize: 12,
              color: balance >= 0 ? AppPalette.palaceRed : AppPalette.green,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class LedgerPageFrame extends StatelessWidget {
  const LedgerPageFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -18,
                top: 24,
                child: Opacity(
                  opacity: 0.95,
                  child: Image.asset(
                    AppAssets.homeMountain,
                    width: 220,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(right: 16, top: 4, child: const HomeBellIcon()),
              Positioned(
                left: 18,
                top: -2,
                child: Image.asset(
                  AppAssets.logo,
                  width: 240,
                  fit: BoxFit.contain,
                ),
              ),
              const Positioned(
                left: 0,
                right: 0,
                top: 90,
                child: Center(
                  child: Text(
                    '礼簿',
                    style: TextStyle(
                      fontFamily: AppFonts.kaiti,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppPalette.ink,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _LedgerRecordRow extends StatelessWidget {
  const _LedgerRecordRow({
    required this.record,
    required this.records,
    required this.onRecordAdded,
    required this.onRecordUpdated,
  });

  final GiftRecord record;
  final List<GiftRecord> records;
  final ValueChanged<GiftRecord> onRecordAdded;
  final ValueChanged<GiftRecord> onRecordUpdated;

  @override
  Widget build(BuildContext context) {
    final isReceived = record.direction == GiftDirection.received;
    final amountColor = isReceived ? AppPalette.palaceRed : AppPalette.green;
    final sign = isReceived ? '+' : '-';
    final avatarBg = record.tone == EventTone.red
        ? const Color(0xFF5F5440)
        : AppPalette.pineGrey;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => RecordDetailPage(
              record: record,
              records: records,
              onRecordAdded: onRecordAdded,
              onRecordUpdated: onRecordUpdated,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppPalette.whiteTone.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppPalette.line.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: avatarBg,
              child: Text(
                record.name.characters.first,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: AppFonts.kaiti,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              record.name,
              style: const TextStyle(
                fontFamily: AppFonts.kaiti,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 6),
            RelationTag(text: record.relation),
            const Spacer(),
            Text(
              record.event,
              style: TextStyle(
                fontFamily: AppFonts.kaiti,
                fontSize: 12,
                color: AppPalette.mutedInk,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              formatSlashDate(record.date).substring(5),
              style: TextStyle(
                fontFamily: AppFonts.kaiti,
                fontSize: 11,
                color: AppPalette.mutedInk,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$sign${formatAmount(record.amount)}',
              style: TextStyle(
                color: amountColor,
                fontFamily: AppFonts.kaiti,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              CupertinoIcons.chevron_right,
              size: 12,
              color: AppPalette.mutedInk.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class AddRecordPage extends StatefulWidget {
  const AddRecordPage({
    super.key,
    required this.onSave,
    this.record,
    this.onBack,
    this.editExisting = false,
  });

  final ValueChanged<GiftRecord> onSave;
  final GiftRecord? record;
  final VoidCallback? onBack;
  final bool editExisting;

  @override
  State<AddRecordPage> createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _itemController = TextEditingController();
  GiftDirection _direction = GiftDirection.received;
  EventTone _tone = EventTone.red;
  String _relation = '';
  String _event = '婚礼';
  String _method = '现金';
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.record != null) {
      final r = widget.record!;
      _nameController.text = r.name;
      _amountController.text = r.amount.toString();
      _noteController.text = r.note;
      _itemController.text = r.itemDescription;
      _direction = r.direction;
      _tone = r.tone;
      _relation = r.relation;
      _event = r.event;
      _method = r.method;
      _date = r.date;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _itemController.dispose();
    super.dispose();
  }

  void _save() {
    final amount = int.tryParse(_amountController.text.trim());
    final name = _nameController.text.trim();
    final itemDescription = _itemController.text.trim();
    if (name.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请填写姓名和有效金额')));
      return;
    }
    if (_method != '现金' && itemDescription.isEmpty) {
      final label = _method == '礼品' ? '礼品名称' : '出力事项';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('请填写$label')));
      return;
    }
    final wasArchivedReceived =
        widget.editExisting &&
        widget.record?.direction == GiftDirection.received &&
        widget.record?.needReturn == false;

    widget.onSave(
      GiftRecord(
        id: widget.editExisting && widget.record != null
            ? widget.record!.id
            : DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        relation: _relation.isEmpty ? '亲友' : _relation,
        event: _event,
        direction: _direction,
        tone: _tone,
        amount: amount,
        date: _date,
        method: _method,
        book: widget.record?.book ?? '我家',
        note: _noteController.text.trim(),
        itemDescription: itemDescription,
        partial: false,
        needReturn:
            _direction == GiftDirection.received && !wasArchivedReceived,
      ),
    );
    if (!mounted) {
      return;
    }
    _nameController.clear();
    _amountController.clear();
    _noteController.clear();
    _itemController.clear();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已入簿')));
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final headerHeight = topInset + 204;
    final panelTop = topInset + 162;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        AddRecordHeader(
          onBack: _handleBack,
          topInset: topInset,
          height: headerHeight,
        ),
        Positioned.fill(
          child: SingleChildScrollView(
            clipBehavior: Clip.none,
            padding: EdgeInsets.fromLTRB(
              14,
              panelTop,
              14,
              math.max(bottomInset, 16) + 20,
            ),
            child: _AddRecordLedgerPanel(
              child: Column(
                children: [
                  const FormSectionLabel(label: '收支类型'),
                  ParchmentSegmentedControl<GiftDirection>(
                    height: 46,
                    options: const [
                      ParchmentOption(
                        value: GiftDirection.received,
                        label: '收礼',
                        icon: Icons.redeem_outlined,
                      ),
                      ParchmentOption(
                        value: GiftDirection.given,
                        label: '回礼',
                        icon: Icons.inventory_2_outlined,
                      ),
                    ],
                    selected: _direction,
                    onSelected: (value) => setState(() => _direction = value),
                  ),
                  const _LedgerDivider(),
                  const FormSectionLabel(label: '喜事白事'),
                  ParchmentSegmentedControl<EventTone>(
                    height: 46,
                    options: const [
                      ParchmentOption(
                        value: EventTone.red,
                        label: '喜事',
                        icon: Icons.favorite_border,
                      ),
                      ParchmentOption(
                        value: EventTone.white,
                        label: '白事',
                        icon: Icons.local_florist_outlined,
                      ),
                    ],
                    selected: _tone,
                    onSelected: (value) {
                      setState(() {
                        _tone = value;
                        _event = _tone == EventTone.red ? '婚礼' : '吊唁';
                      });
                    },
                  ),
                  const _LedgerDivider(),
                  _LedgerTextRow(
                    fieldKey: const ValueKey('add-name-field'),
                    label: '姓名',
                    hintText: '请输入姓名',
                    controller: _nameController,
                    suffixIcon: CupertinoIcons.person,
                    textInputAction: TextInputAction.next,
                  ),
                  _LedgerPickerRow(
                    label: '关系',
                    value: _relation,
                    placeholder: '请选择关系',
                    options: const ['亲友', '同学', '同事', '邻里', '亲戚'],
                    onSelected: (value) => setState(() => _relation = value),
                  ),
                  _LedgerPickerRow(
                    label: '事项类型',
                    value: _event,
                    placeholder: '请选择事项类型',
                    options: _tone == EventTone.red
                        ? const ['婚礼', '满月', '乔迁', '祝寿', '升学', '开业']
                        : const ['吊唁', '奠仪', '帛金', '白事其他'],
                    onSelected: (value) => setState(() => _event = value),
                  ),
                  const SizedBox(height: 8),
                  _EventChoiceGrid(
                    selected: _event,
                    options: _tone == EventTone.red
                        ? const [
                            _EventChoice('婚礼', Icons.favorite_border),
                            _EventChoice('满月', Icons.child_care_outlined),
                            _EventChoice('乔迁', Icons.home_outlined),
                            _EventChoice('祝寿', Icons.cake_outlined),
                            _EventChoice('升学', Icons.school_outlined),
                            _EventChoice('开业', Icons.business_center_outlined),
                          ]
                        : const [
                            _EventChoice('吊唁', Icons.local_florist_outlined),
                            _EventChoice('奠仪', Icons.spa_outlined),
                            _EventChoice('帛金', Icons.payments_outlined),
                            _EventChoice('白事其他', Icons.more_horiz),
                          ],
                    onSelected: (value) => setState(() => _event = value),
                  ),
                  const _LedgerDivider(),
                  _LedgerTextRow(
                    fieldKey: const ValueKey('add-amount-field'),
                    label: _method == '现金' ? '金额' : '估算金额',
                    hintText: _method == '现金' ? '请输入金额' : '请输入估算金额',
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    suffixText: '元',
                  ),
                  const _LedgerDivider(),
                  const FormSectionLabel(label: '记录方式'),
                  ParchmentSegmentedControl<String>(
                    height: 46,
                    options: const [
                      ParchmentOption(
                        value: '现金',
                        label: '现金',
                        icon: Icons.currency_yuan,
                      ),
                      ParchmentOption(
                        value: '礼品',
                        label: '礼品',
                        icon: Icons.card_giftcard,
                      ),
                      ParchmentOption(
                        value: '出力',
                        label: '出力',
                        icon: Icons.handshake_outlined,
                      ),
                    ],
                    selected: _method,
                    onSelected: (value) => setState(() => _method = value),
                  ),
                  if (_method != '现金') ...[
                    const _LedgerDivider(),
                    _LedgerTextRow(
                      fieldKey: const ValueKey('add-item-field'),
                      label: _method == '礼品' ? '礼品名称' : '出力事项',
                      hintText: _method == '礼品' ? '如：茶具一套' : '如：帮忙布置礼台',
                      controller: _itemController,
                    ),
                  ],
                  const _LedgerDivider(),
                  _LedgerInfoRow(
                    label: '日期',
                    value: formatChineseDate(_date),
                    trailing: CupertinoIcons.chevron_right,
                    onTap: _pickDate,
                  ),
                  _LedgerNoteRow(controller: _noteController),
                  const SizedBox(height: 10),
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 42),
                        child: HomeBottomLandscape(height: 68),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(38, 18, 38, 22),
                        child: SealButton(label: '保存此礼', onPressed: _save),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
      return;
    }
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: '选择往来日期',
    );
    if (picked != null && mounted) {
      setState(() => _date = picked);
    }
  }
}

class AddRecordHeader extends StatelessWidget {
  const AddRecordHeader({
    super.key,
    required this.onBack,
    required this.topInset,
    required this.height,
  });

  final VoidCallback onBack;
  final double topInset;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF8F1E1B), AppPalette.palaceRed],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppAssets.redLedger,
              fit: BoxFit.cover,
              opacity: const AlwaysStoppedAnimation(0.26),
            ),
          ),
          Positioned(
            left: 52,
            top: topInset + 26,
            child: Opacity(
              opacity: 0.18,
              child: Image.asset(AppAssets.homeMountain, width: 230),
            ),
          ),
          Positioned(
            right: -18,
            top: topInset + 30,
            child: Opacity(
              opacity: 0.18,
              child: Image.asset(AppAssets.plum, width: 120),
            ),
          ),
          Positioned(
            left: 14,
            top: topInset + 22,
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(
                CupertinoIcons.chevron_left,
                color: Colors.white,
                size: 31,
              ),
            ),
          ),
          Positioned.fill(
            top: topInset + 36,
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                '记一笔',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  shadows: const [
                    Shadow(
                      color: Color(0x66000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: 24,
            top: topInset + 34,
            child: const Column(
              children: [
                SealMark(text: '簿', size: 32, color: Colors.white),
                SizedBox(height: 3),
                Text('礼簿', style: TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddRecordLedgerPanel extends StatelessWidget {
  const _AddRecordLedgerPanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      decoration: BoxDecoration(
        color: AppPalette.whiteTone.withValues(alpha: 0.92),
        image: const DecorationImage(
          image: AssetImage(AppAssets.paper),
          fit: BoxFit.cover,
          opacity: 0.42,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPalette.line, width: 1.25),
        boxShadow: [
          BoxShadow(
            color: AppPalette.rouge.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Material(type: MaterialType.transparency, child: child),
      ),
    );
  }
}

class _LedgerDivider extends StatelessWidget {
  const _LedgerDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: AppPalette.line.withValues(alpha: 0.58),
    );
  }
}

class _LedgerTextRow extends StatelessWidget {
  const _LedgerTextRow({
    this.fieldKey,
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType,
    this.textInputAction,
    this.suffixText,
    this.suffixIcon,
  });

  final Key? fieldKey;
  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? suffixText;
  final IconData? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return _LedgerLine(
      label: label,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (suffixText != null)
            Text(
              suffixText!,
              style: const TextStyle(
                color: AppPalette.ink,
                fontFamily: AppFonts.kaiti,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          if (suffixIcon != null)
            Icon(suffixIcon, color: AppPalette.mutedInk, size: 24),
        ],
      ),
      child: TextField(
        key: fieldKey,
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        textAlign: TextAlign.right,
        style: const TextStyle(
          color: AppPalette.ink,
          fontFamily: AppFonts.kaiti,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration.collapsed(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Color(0xFFADA08B),
            fontFamily: AppFonts.kaiti,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _LedgerPickerRow extends StatelessWidget {
  const _LedgerPickerRow({
    required this.label,
    required this.value,
    required this.placeholder,
    required this.options,
    required this.onSelected,
  });

  final String label;
  final String value;
  final String placeholder;
  final List<String> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: '',
      color: AppPalette.whiteTone,
      elevation: 8,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final option in options)
          PopupMenuItem<String>(
            value: option,
            child: Text(
              option,
              style: const TextStyle(
                fontFamily: AppFonts.kaiti,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
      child: _LedgerInfoRow(
        label: label,
        value: value.isEmpty ? placeholder : value,
        muted: value.isEmpty,
        trailing: CupertinoIcons.chevron_right,
      ),
    );
  }
}

class _LedgerInfoRow extends StatelessWidget {
  const _LedgerInfoRow({
    required this.label,
    required this.value,
    this.trailing,
    this.muted = false,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? trailing;
  final bool muted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = _LedgerLine(
      label: label,
      trailing: trailing == null
          ? const SizedBox.shrink()
          : Icon(trailing, color: AppPalette.mutedInk, size: 21),
      child: Text(
        value,
        textAlign: TextAlign.right,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: muted ? const Color(0xFFADA08B) : AppPalette.mutedInk,
          fontFamily: AppFonts.kaiti,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    return onTap == null ? row : InkWell(onTap: onTap, child: row);
  }
}

class _LedgerNoteRow extends StatelessWidget {
  const _LedgerNoteRow({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _LedgerLine(
          label: '备注',
          trailing: SizedBox.shrink(),
          showDivider: false,
          child: SizedBox.shrink(),
        ),
        Container(
          height: 64,
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
          decoration: BoxDecoration(
            color: AppPalette.whiteTone.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppPalette.line.withValues(alpha: 0.7)),
          ),
          child: TextField(
            controller: controller,
            minLines: 3,
            maxLines: 3,
            style: const TextStyle(
              color: AppPalette.ink,
              fontFamily: AppFonts.kaiti,
              fontSize: 16,
            ),
            decoration: const InputDecoration.collapsed(
              hintText: '可填写备注信息（选填）',
              hintStyle: TextStyle(
                color: Color(0xFFADA08B),
                fontFamily: AppFonts.kaiti,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LedgerLine extends StatelessWidget {
  const _LedgerLine({
    required this.label,
    required this.child,
    required this.trailing,
    this.showDivider = true,
  });

  final String label;
  final Widget child;
  final Widget trailing;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: AppPalette.line.withValues(alpha: 0.58),
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          const Text('✣', style: TextStyle(color: AppPalette.palaceRed)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppPalette.ink,
              fontFamily: AppFonts.kaiti,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: child),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}

class _EventChoice {
  const _EventChoice(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _EventChoiceGrid extends StatelessWidget {
  const _EventChoiceGrid({
    required this.selected,
    required this.options,
    required this.onSelected,
  });

  final String selected;
  final List<_EventChoice> options;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 9.0;
        final width = (constraints.maxWidth - gap * 2) / 3;
        return Wrap(
          spacing: gap,
          runSpacing: 9,
          children: [
            for (final option in options)
              SizedBox(
                width: width,
                height: 42,
                child: _EventChoiceButton(
                  option: option,
                  selected: selected == option.label,
                  onTap: () => onSelected(option.label),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _EventChoiceButton extends StatelessWidget {
  const _EventChoiceButton({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _EventChoice option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: selected
                ? AppPalette.palaceRed.withValues(alpha: 0.06)
                : AppPalette.whiteTone.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppPalette.palaceRed : AppPalette.line,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                option.icon,
                color: selected
                    ? AppPalette.palaceRed
                    : const Color(0xFF8E6F45),
                size: 18,
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  option.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? AppPalette.palaceRed : AppPalette.ink,
                    fontFamily: AppFonts.kaiti,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FormSectionLabel extends StatelessWidget {
  const FormSectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Text('✣', style: TextStyle(color: AppPalette.palaceRed)),
          const SizedBox(width: 7),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class RecordDetailPage extends StatefulWidget {
  const RecordDetailPage({
    super.key,
    required this.record,
    required this.records,
    required this.onRecordAdded,
    required this.onRecordUpdated,
  });

  final GiftRecord record;
  final List<GiftRecord> records;
  final ValueChanged<GiftRecord> onRecordAdded;
  final ValueChanged<GiftRecord> onRecordUpdated;

  @override
  State<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  late GiftRecord record;
  late ReturnGiftSuggestion _suggestion;
  late int _selectedReturnAmount;

  @override
  void initState() {
    super.initState();
    record = widget.record;
    _refreshSuggestion();
  }

  List<GiftRecord> get _personRecords {
    final records =
        widget.records
            .where(
              (item) => item.name == record.name && item.book == record.book,
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    return records.isEmpty ? [record] : records;
  }

  void _refreshSuggestion() {
    _suggestion = ReturnGiftAdvisor.forRecord(
      record: record,
      records: _personRecords,
    );
    _selectedReturnAmount = _suggestion.originalAmount;
  }

  void _openEditor(
    BuildContext context,
    GiftRecord target, {
    bool updateCurrent = false,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AddRecordPage(
          record: target,
          editExisting: true,
          onSave: (updated) {
            widget.onRecordUpdated(updated);
            if (updateCurrent || updated.id == record.id) {
              setState(() {
                record = updated;
                _refreshSuggestion();
              });
            }
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarBg = record.tone == EventTone.red
        ? const Color(0xFF5F5440)
        : AppPalette.pineGrey;

    return Scaffold(
      backgroundColor: AppPalette.paper,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  _buildInfoCard(avatarBg),
                  const SizedBox(height: 20),
                  _buildRecordTimeline(context),
                  const SizedBox(height: 20),
                  _buildReturnSuggestion(),
                  const SizedBox(height: 16),
                  _buildReturnButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              CupertinoIcons.chevron_left,
              color: AppPalette.ink,
              size: 24,
            ),
          ),
          const Expanded(
            child: Text(
              '往来详情',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppFonts.kaiti,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppPalette.ink,
              ),
            ),
          ),
          IconButton(
            tooltip: '编辑',
            onPressed: () => _openEditor(context, record, updateCurrent: true),
            icon: const Icon(
              CupertinoIcons.pencil,
              color: AppPalette.palaceRed,
              size: 23,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(Color avatarBg) {
    final totals = LedgerTotals.fromRecords(_personRecords);
    final pendingAmount = record.needReturn ? _suggestion.originalAmount : 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppPalette.palaceRed, AppPalette.rouge],
        ),
        boxShadow: [
          BoxShadow(
            color: AppPalette.rouge.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: avatarBg,
                child: Text(
                  record.name.characters.first,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: AppFonts.kaiti,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          record.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: AppFonts.kaiti,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            record.relation,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: AppFonts.kaiti,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '往来有据，情意可循',
                      style: TextStyle(
                        color: Color(0xFFEFD8C0),
                        fontFamily: AppFonts.kaiti,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem('我收礼', formatAmount(totals.received)),
                ),
                Container(width: 1, height: 40, color: Colors.white24),
                Expanded(
                  child: _buildStatItem('我回礼', formatAmount(totals.given)),
                ),
                Container(width: 1, height: 40, color: Colors.white24),
                Expanded(
                  child: _buildStatItem(
                    '待回礼建议',
                    pendingAmount == 0 ? '—' : formatAmount(pendingAmount),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFEFD8C0),
            fontFamily: AppFonts.kaiti,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: AppFonts.kaiti,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Text(
          '元',
          style: TextStyle(
            color: Color(0xFFEFD8C0),
            fontFamily: AppFonts.kaiti,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordTimeline(BuildContext context) {
    final history = _personRecords;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '往来记录',
          style: TextStyle(
            fontFamily: AppFonts.kaiti,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppPalette.ink,
          ),
        ),
        const SizedBox(height: 12),
        for (var index = 0; index < history.length; index++)
          _buildTimelineItem(
            context: context,
            record: history[index],
            isLast: index == history.length - 1,
            updateCurrent: index == 0,
          ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required BuildContext context,
    required GiftRecord record,
    required bool updateCurrent,
    bool isLast = false,
  }) {
    final isReceived = record.direction == GiftDirection.received;
    final amountColor = isReceived ? AppPalette.palaceRed : AppPalette.green;
    final iconBg = isReceived
        ? const Color(0xFFB83A32)
        : const Color(0xFFC79B52);
    final iconData = isReceived
        ? CupertinoIcons.gift
        : CupertinoIcons.gift_fill;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '${record.date.year}年',
              style: const TextStyle(
                fontFamily: AppFonts.kaiti,
                fontSize: 13,
                color: AppPalette.mutedInk,
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: Colors.white, size: 16),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1,
                    color: AppPalette.line.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              onTap: () {
                _openEditor(context, record, updateCurrent: updateCurrent);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppPalette.whiteTone.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppPalette.line.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record.event,
                            style: const TextStyle(
                              fontFamily: AppFonts.kaiti,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatChineseDate(record.date),
                            style: TextStyle(
                              fontFamily: AppFonts.kaiti,
                              fontSize: 12,
                              color: AppPalette.mutedInk,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          isReceived ? '我收礼' : '我回礼',
                          style: TextStyle(
                            fontFamily: AppFonts.kaiti,
                            fontSize: 11,
                            color: AppPalette.mutedInk,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${isReceived ? '+' : '-'}${formatAmount(record.amount)}',
                          style: TextStyle(
                            fontFamily: AppFonts.kaiti,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: amountColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 14,
                      color: AppPalette.mutedInk.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnSuggestion() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppPalette.whiteTone.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.line.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '待回礼建议',
            style: TextStyle(
              fontFamily: AppFonts.kaiti,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppPalette.ink,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '参考往来习惯与关系亲密度，推荐回礼金额',
            style: TextStyle(
              fontFamily: AppFonts.kaiti,
              fontSize: 12,
              color: AppPalette.mutedInk,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildAmountOption(
                '${formatAmount(_suggestion.originalAmount)}元',
                _selectedReturnAmount == _suggestion.originalAmount,
                _suggestion.originalAmount,
              ),
              const SizedBox(width: 10),
              _buildAmountOption(
                '${formatAmount(_suggestion.increasedAmount)}元',
                _selectedReturnAmount == _suggestion.increasedAmount,
                _suggestion.increasedAmount,
              ),
              const SizedBox(width: 10),
              _buildAmountOption('自定义', false, null),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountOption(String amount, bool isSelected, int? value) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (value == null) {
            _openReturnEditor(context, _selectedReturnAmount);
          } else {
            setState(() => _selectedReturnAmount = value);
          }
        },
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: isSelected
                ? AppPalette.palaceRed
                : AppPalette.whiteTone.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? AppPalette.palaceRed
                  : AppPalette.line.withValues(alpha: 0.5),
            ),
          ),
          child: Center(
            child: Text(
              amount,
              style: TextStyle(
                fontFamily: AppFonts.kaiti,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : AppPalette.ink,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReturnButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _openReturnEditor(context, _selectedReturnAmount),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB92722), Color(0xFF971B18)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppPalette.rouge.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            '记录回礼',
            style: TextStyle(
              color: Color(0xFFFFE3B0),
              fontSize: 16,
              fontFamily: AppFonts.kaiti,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  void _openReturnEditor(BuildContext context, int amount) {
    final returnRecord = record.copyWith(
      direction: GiftDirection.given,
      event: '回礼',
      amount: amount,
      date: DateTime.now(),
      method: '现金',
      note: '',
      itemDescription: '',
      partial: false,
      needReturn: false,
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => AddRecordPage(
          record: returnRecord,
          onSave: (newRecord) {
            widget.onRecordUpdated(record.copyWith(needReturn: false));
            widget.onRecordAdded(newRecord);
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

class SearchOldPage extends StatefulWidget {
  const SearchOldPage({
    super.key,
    required this.records,
    required this.onRecordAdded,
    required this.onRecordUpdated,
  });

  final List<GiftRecord> records;
  final ValueChanged<GiftRecord> onRecordAdded;
  final ValueChanged<GiftRecord> onRecordUpdated;

  @override
  State<SearchOldPage> createState() => _SearchOldPageState();
}

class _SearchOldPageState extends State<SearchOldPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final people = _buildPeople();
    final visiblePeople = people.where((person) {
      if (_query.isEmpty) {
        return true;
      }
      return person.name.contains(_query) ||
          person.relation.contains(_query) ||
          person.records.any((record) => record.event.contains(_query));
    }).toList();

    return PageFrame(
      title: '查往来',
      subtitle: '查清来往，回得体面',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 96),
        children: [
          TextField(
            controller: TextEditingController(text: _query)
              ..selection = TextSelection.collapsed(offset: _query.length),
            onChanged: (value) => setState(() => _query = value.trim()),
            decoration: const InputDecoration(
              prefixIcon: Icon(CupertinoIcons.search),
              suffixIcon: Icon(CupertinoIcons.slider_horizontal_3),
              hintText: '搜索姓名、关系或事项',
            ),
          ),
          const SizedBox(height: 14),
          SectionHeader(title: '往来人名', action: '${visiblePeople.length}人'),
          const SizedBox(height: 8),
          if (visiblePeople.isEmpty)
            const EmptyState(title: '暂无匹配人名', subtitle: '输入姓名、关系或事项，可以快速找回往来。')
          else
            ...visiblePeople.map(
              (person) => _PersonLedgerRow(
                person: person,
                onTap: () => _openDetail(context, person.latestRecord),
              ),
            ),
        ],
      ),
    );
  }

  List<_PersonLedgerSummary> _buildPeople() {
    final grouped = <String, List<GiftRecord>>{};
    for (final record in widget.records) {
      grouped.putIfAbsent(record.name, () => []).add(record);
    }

    final people =
        grouped.entries.map((entry) {
            final records = List<GiftRecord>.of(entry.value)
              ..sort((a, b) => b.date.compareTo(a.date));
            return _PersonLedgerSummary(name: entry.key, records: records);
          }).toList()
          ..sort((a, b) => b.latestRecord.date.compareTo(a.latestRecord.date));

    return people;
  }

  void _openDetail(BuildContext context, GiftRecord record) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => RecordDetailPage(
          record: record,
          records: widget.records,
          onRecordAdded: widget.onRecordAdded,
          onRecordUpdated: widget.onRecordUpdated,
        ),
      ),
    );
  }
}

class _PersonLedgerSummary {
  const _PersonLedgerSummary({required this.name, required this.records});

  final String name;
  final List<GiftRecord> records;

  GiftRecord get latestRecord => records.first;

  String get relation => latestRecord.relation;

  int get totalReceived => records
      .where((record) => record.direction == GiftDirection.received)
      .fold(0, (sum, record) => sum + record.amount);

  int get totalGiven => records
      .where((record) => record.direction == GiftDirection.given)
      .fold(0, (sum, record) => sum + record.amount);
}

class _PersonLedgerRow extends StatelessWidget {
  const _PersonLedgerRow({required this.person, required this.onTap});

  final _PersonLedgerSummary person;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final latest = person.latestRecord;
    final balance = person.totalReceived - person.totalGiven;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: AppPalette.whiteTone.withValues(alpha: 0.64),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppPalette.line.withValues(alpha: 0.56),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor:
                      (latest.tone == EventTone.red
                              ? AppPalette.palaceRed
                              : AppPalette.pineGrey)
                          .withValues(alpha: 0.14),
                  child: Text(
                    person.name.characters.first,
                    style: TextStyle(
                      color: latest.direction == GiftDirection.received
                          ? AppPalette.palaceRed
                          : AppPalette.green,
                      fontFamily: AppFonts.kaiti,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              person.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: AppFonts.kaiti,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          RelationTag(text: person.relation),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${person.records.length}笔往来 · 最近 ${latest.event} · ${formatDate(latest.date)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppPalette.mutedInk,
                          fontFamily: AppFonts.kaiti,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      balance >= 0
                          ? '+${formatAmount(balance)}'
                          : formatAmount(balance),
                      style: TextStyle(
                        color: balance >= 0
                            ? AppPalette.palaceRed
                            : AppPalette.green,
                        fontFamily: AppFonts.kaiti,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 15,
                      color: AppPalette.mutedInk.withValues(alpha: 0.56),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class QuickDeskPage extends StatefulWidget {
  const QuickDeskPage({
    super.key,
    required this.records,
    required this.onRecordAdded,
    required this.onRecordRemoved,
  });

  final List<GiftRecord> records;
  final ValueChanged<GiftRecord> onRecordAdded;
  final ValueChanged<GiftRecord> onRecordRemoved;

  @override
  State<QuickDeskPage> createState() => _QuickDeskPageState();
}

class _QuickDeskPageState extends State<QuickDeskPage> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _nameFocus = FocusNode();
  EventTone _tone = EventTone.red;
  GiftDirection _direction = GiftDirection.received;
  String _scene = '婚礼';
  final List<GiftRecord> _sessionRecords = [];

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _quickSave() {
    final name = _nameController.text.trim();
    final amount = int.tryParse(_amountController.text.trim());
    if (name.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请先填写来宾姓名和礼金金额')));
      return;
    }

    final record = GiftRecord(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      relation: '待补全',
      event: _scene,
      direction: _direction,
      tone: _tone,
      amount: amount,
      date: DateTime.now(),
      method: '现金',
      book: '我家',
      note: _noteController.text.trim(),
      partial: true,
      needReturn: _direction == GiftDirection.received,
    );
    widget.onRecordAdded(record);
    setState(() {
      _sessionRecords.insert(0, record);
    });
    _nameController.clear();
    _amountController.clear();
    _noteController.clear();
    _nameFocus.requestFocus();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已入簿')));
  }

  void _undoLast() {
    if (_sessionRecords.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('本场还没有可撤销的记录')));
      return;
    }
    final record = _sessionRecords.first;
    setState(() {
      _sessionRecords.removeAt(0);
    });
    widget.onRecordRemoved(record);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('已撤销本场上一条记录')));
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 1000;
    final total = _sessionRecords.fold(0, (sum, record) => sum + record.amount);

    return Scaffold(
      backgroundColor: _tone == EventTone.red
          ? AppPalette.paper
          : AppPalette.whiteTone,
      body: PaperBackground(
        whiteMode: _tone == EventTone.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isWide
                ? Row(
                    children: [
                      SizedBox(
                        width: 250,
                        child: QuickDeskInfoPanel(
                          tone: _tone,
                          direction: _direction,
                          scene: _scene,
                          count: _sessionRecords.length,
                          total: total,
                          onToneChanged: _changeTone,
                          onDirectionChanged: (value) {
                            setState(() => _direction = value);
                          },
                          onSceneChanged: _changeScene,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: _inputPanel()),
                      const SizedBox(width: 16),
                      SizedBox(width: 310, child: _recentPanel()),
                    ],
                  )
                : ListView(
                    children: [
                      QuickDeskTopBar(
                        scene: _scene,
                        total: total,
                        tone: _tone,
                        onClose: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: 12),
                      QuickDeskCompactStats(
                        tone: _tone,
                        direction: _direction,
                        scene: _scene,
                        count: _sessionRecords.length,
                        total: total,
                        onToneChanged: _changeTone,
                        onDirectionChanged: (value) =>
                            setState(() => _direction = value),
                        onSceneChanged: _changeScene,
                      ),
                      const SizedBox(height: 12),
                      _inputPanel(),
                      const SizedBox(height: 12),
                      _recentPanel(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _inputPanel() {
    return AntiqueCard(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          LedgerEntryField(
            fieldKey: const ValueKey('quick-name-field'),
            focusNode: _nameFocus,
            controller: _nameController,
            textInputAction: TextInputAction.next,
            icon: CupertinoIcons.person_fill,
            label: '来宾姓名',
            hintText: '请输入姓名',
            textStyle: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          LedgerEntryField(
            fieldKey: const ValueKey('quick-amount-field'),
            controller: _amountController,
            keyboardType: TextInputType.number,
            icon: CupertinoIcons.envelope_fill,
            label: _tone == EventTone.red ? '礼金金额' : '奠仪金额',
            hintText: '请输入金额',
            suffix: '元',
            textStyle: const TextStyle(
              color: AppPalette.palaceRed,
              fontSize: 28,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          AmountQuickGrid(
            controller: _amountController,
            values: const [200, 300, 500, 600, 800, 1000, 1200, 1600],
          ),
          const SizedBox(height: 10),
          LedgerEntryField(
            controller: _noteController,
            icon: CupertinoIcons.text_bubble_fill,
            label: '备注（可选）',
            hintText: '如：同事、朋友等',
            textStyle: const TextStyle(fontSize: 17),
          ),
          const SizedBox(height: 12),
          SealButton(label: '记入并继续', onPressed: _quickSave),
        ],
      ),
    );
  }

  Widget _recentPanel() {
    final visibleRecords = _sessionRecords.isEmpty
        ? widget.records.take(4).toList()
        : _sessionRecords.take(10).toList();
    return AntiqueCard(
      padding: const EdgeInsets.fromLTRB(12, 13, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '最近记录',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton.icon(
                onPressed: _undoLast,
                icon: const Icon(CupertinoIcons.arrow_uturn_left, size: 16),
                label: const Text('撤销'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (visibleRecords.isEmpty)
            const EmptyState(title: '本场还没有记录', subtitle: '输入姓名和金额后即可连续入簿。')
          else
            DecoratedBox(
              decoration: BoxDecoration(
                color: AppPalette.whiteTone.withValues(alpha: 0.50),
                border: Border.all(
                  color: AppPalette.line.withValues(alpha: 0.7),
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < visibleRecords.length; i++)
                    QuickDeskRecentRow(
                      record: visibleRecords[i],
                      isLast: i == visibleRecords.length - 1,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _changeTone(EventTone tone) {
    setState(() {
      _tone = tone;
      _scene = tone == EventTone.red ? '婚礼' : '白事';
    });
  }

  void _changeScene(String scene) {
    setState(() {
      _scene = scene;
      _tone = scene == '白事' ? EventTone.white : EventTone.red;
    });
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.records,
    required this.onRecordAdded,
    required this.onRecordUpdated,
  });

  final List<GiftRecord> records;
  final ValueChanged<GiftRecord> onRecordAdded;
  final ValueChanged<GiftRecord> onRecordUpdated;

  void _openPendingReturns(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => PendingReturnsPage(
          records: records,
          onRecordAdded: onRecordAdded,
          onRecordUpdated: onRecordUpdated,
        ),
      ),
    );
  }

  void _openPendingCompletions(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => PendingCompletionsPage(
          records: records,
          onRecordAdded: onRecordAdded,
          onRecordUpdated: onRecordUpdated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileHeader(
          onSettings: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (context) => const SettingsPage()),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 96),
            children: [
              const _ProfileHeroCard(),
              const SizedBox(height: 14),
              _ProfileActionGrid(
                pendingCompletionCount: records
                    .where((record) => record.partial)
                    .length,
                pendingReturnCount: records
                    .where(
                      (record) =>
                          record.needReturn &&
                          record.direction == GiftDirection.received,
                    )
                    .length,
                onPendingCompletions: () => _openPendingCompletions(context),
                onPendingReturns: () => _openPendingReturns(context),
              ),
              const SizedBox(height: 14),
              _ProfileSettingsSection(
                title: '账本管理',
                items: [
                  _ProfileSettingItem(
                    icon: CupertinoIcons.book,
                    title: '当前账本',
                    value: '张晓明家庭礼簿',
                  ),
                  _ProfileSettingItem(
                    icon: CupertinoIcons.doc_text,
                    title: '待补全',
                    value:
                        '${records.where((record) => record.partial).length}条',
                    onTap: () => _openPendingCompletions(context),
                  ),
                  _ProfileSettingItem(
                    icon: CupertinoIcons.gift,
                    title: '待回礼',
                    value:
                        '${records.where((record) => record.needReturn && record.direction == GiftDirection.received).length}人',
                    onTap: () => _openPendingReturns(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const _ProfileSettingsSection(
                title: '个性化与通知',
                items: [
                  _ProfileSettingItem(
                    icon: CupertinoIcons.paintbrush,
                    title: '主题风格',
                    value: '杏花红',
                    showDot: true,
                  ),
                  _ProfileSettingItem(
                    icon: CupertinoIcons.bell,
                    title: '通知提醒',
                    value: '已开启',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const _ProfileSettingsSection(
                title: '关于与帮助',
                items: [
                  _ProfileSettingItem(
                    icon: CupertinoIcons.info_circle,
                    title: '关于礼往来',
                    value: 'MVP 1.0.0',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const _ProfileAdNotice(compact: false),
              const SizedBox(height: 14),
              const _ProfileProPanel(),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileActionGrid extends StatelessWidget {
  const _ProfileActionGrid({
    required this.pendingCompletionCount,
    required this.pendingReturnCount,
    required this.onPendingCompletions,
    required this.onPendingReturns,
  });

  final int pendingCompletionCount;
  final int pendingReturnCount;
  final VoidCallback onPendingCompletions;
  final VoidCallback onPendingReturns;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: AppPalette.whiteTone.withValues(alpha: 0.74),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.line.withValues(alpha: 0.66)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: _ProfileAction(
              icon: CupertinoIcons.book,
              label: '多账本',
              subtitle: '敬请期待',
            ),
          ),
          Expanded(
            child: _ProfileAction(
              icon: CupertinoIcons.doc_text,
              label: '待补全',
              subtitle: '$pendingCompletionCount 条',
              onTap: onPendingCompletions,
            ),
          ),
          Expanded(
            child: _ProfileAction(
              icon: CupertinoIcons.gift,
              label: '待回礼',
              subtitle: '$pendingReturnCount 人',
              onTap: onPendingReturns,
            ),
          ),
          const Expanded(
            child: _ProfileAction(
              icon: CupertinoIcons.square_arrow_up,
              label: '年度礼簿',
              subtitle: '敬请期待',
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            Icon(icon, color: AppPalette.palaceRed, size: 25),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: AppFonts.kaiti,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppPalette.mutedInk,
                fontFamily: AppFonts.kaiti,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PendingReturnsPage extends StatelessWidget {
  const PendingReturnsPage({
    super.key,
    required this.records,
    required this.onRecordAdded,
    required this.onRecordUpdated,
  });

  final List<GiftRecord> records;
  final ValueChanged<GiftRecord> onRecordAdded;
  final ValueChanged<GiftRecord> onRecordUpdated;

  @override
  Widget build(BuildContext context) {
    final pending =
        records
            .where(
              (record) =>
                  record.direction == GiftDirection.received &&
                  record.needReturn,
            )
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: AppPalette.paper,
      body: SafeArea(
        child: Column(
          children: [
            _SimplePageHeader(
              title: '待回礼提醒',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                children: [
                  _PendingReturnSummary(count: pending.length),
                  const SizedBox(height: 18),
                  const SectionHeader(title: '待回礼', action: '按最近往来'),
                  const SizedBox(height: 8),
                  if (pending.isEmpty)
                    const EmptyState(
                      title: '暂无待回礼记录',
                      subtitle: '收到的礼金会在这里提示，回礼后即可归档。',
                    )
                  else
                    for (final record in pending)
                      _PendingReturnRow(
                        record: record,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (context) => RecordDetailPage(
                              record: record,
                              records: records,
                              onRecordAdded: onRecordAdded,
                              onRecordUpdated: onRecordUpdated,
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PendingCompletionsPage extends StatelessWidget {
  const PendingCompletionsPage({
    super.key,
    required this.records,
    required this.onRecordAdded,
    required this.onRecordUpdated,
  });

  final List<GiftRecord> records;
  final ValueChanged<GiftRecord> onRecordAdded;
  final ValueChanged<GiftRecord> onRecordUpdated;

  @override
  Widget build(BuildContext context) {
    final partialRecords = records.where((record) => record.partial).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      backgroundColor: AppPalette.paper,
      body: SafeArea(
        child: Column(
          children: [
            _SimplePageHeader(
              title: '待补全',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                children: [
                  Text(
                    '礼台速记已为你保留姓名与金额，点开即可补全关系、事项与备注。',
                    style: TextStyle(
                      color: AppPalette.mutedInk.withValues(alpha: 0.9),
                      fontFamily: AppFonts.kaiti,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (partialRecords.isEmpty)
                    const EmptyState(
                      title: '暂无待补全记录',
                      subtitle: '礼台速记会自动出现在这里，方便事后整理。',
                    )
                  else
                    for (final record in partialRecords)
                      _LedgerRecordRow(
                        record: record,
                        records: records,
                        onRecordAdded: onRecordAdded,
                        onRecordUpdated: onRecordUpdated,
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimplePageHeader extends StatelessWidget {
  const _SimplePageHeader({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          IconButton(
            tooltip: '返回',
            onPressed: onBack,
            icon: const Icon(CupertinoIcons.chevron_left),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: AppFonts.kaiti,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _PendingReturnSummary extends StatelessWidget {
  const _PendingReturnSummary({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppPalette.palaceRed, AppPalette.rouge],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.gift, color: Color(0xFFFFE3B0), size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              '知礼记情，妥帖应对',
              style: TextStyle(
                color: Color(0xFFFFE3B0),
                fontFamily: AppFonts.kaiti,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Text(
            '$count 人待回礼',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: AppFonts.kaiti,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingReturnRow extends StatelessWidget {
  const _PendingReturnRow({required this.record, required this.onTap});

  final GiftRecord record;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final suggestion = ReturnGiftAdvisor.forRecord(
      record: record,
      records: const [],
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppPalette.whiteTone.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppPalette.line.withValues(alpha: 0.58)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppPalette.palaceRed,
                child: Text(
                  record.name.characters.first,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${record.name} · ${record.event}',
                      style: const TextStyle(
                        fontFamily: AppFonts.kaiti,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '上次随礼 ${formatAmount(record.amount)} 元 · 建议回礼 ${formatAmount(suggestion.increasedAmount)} 元',
                      style: const TextStyle(
                        color: AppPalette.mutedInk,
                        fontFamily: AppFonts.kaiti,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(CupertinoIcons.chevron_right, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _hideAmounts = false;
  bool _funeralPrivacy = true;
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.paper,
      body: SafeArea(
        child: Column(
          children: [
            _SimplePageHeader(
              title: '设置与隐私',
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                children: [
                  const FormSectionLabel(label: '隐私与安全'),
                  _SettingsToggleRow(
                    title: '金额隐藏',
                    subtitle: '在礼簿列表中隐藏金额',
                    value: _hideAmounts,
                    onChanged: (value) => setState(() => _hideAmounts = value),
                  ),
                  _SettingsToggleRow(
                    title: '白榜隐私保护',
                    subtitle: '白事记录仅在礼簿内显示',
                    value: _funeralPrivacy,
                    onChanged: (value) =>
                        setState(() => _funeralPrivacy = value),
                  ),
                  const SizedBox(height: 14),
                  const FormSectionLabel(label: '个性化与通知'),
                  _SettingsToggleRow(
                    title: '通知提醒',
                    subtitle: '提醒即将到来的礼事',
                    value: _notifications,
                    onChanged: (value) =>
                        setState(() => _notifications = value),
                  ),
                  const SizedBox(height: 14),
                  const _ProfileSettingsSection(
                    title: '关于与帮助',
                    items: [
                      _ProfileSettingItem(
                        icon: CupertinoIcons.info_circle,
                        title: '关于礼往来',
                        value: 'MVP 1.0.0',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsToggleRow extends StatelessWidget {
  const _SettingsToggleRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppPalette.whiteTone.withValues(alpha: 0.72),
        border: Border.all(color: AppPalette.line.withValues(alpha: 0.58)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: AppFonts.kaiti,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: AppFonts.kaiti,
                    color: AppPalette.mutedInk,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 106,
      child: Stack(
        children: [
          Positioned(
            right: 8,
            top: 10,
            child: IconButton(
              tooltip: '设置与隐私',
              onPressed: onSettings,
              icon: Icon(
                CupertinoIcons.gear_alt,
                color: AppPalette.ink.withValues(alpha: 0.78),
                size: 29,
              ),
            ),
          ),
          const Positioned.fill(
            top: 28,
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                '我的',
                style: TextStyle(
                  color: AppPalette.ink,
                  fontFamily: AppFonts.kaiti,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 142,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: const DecorationImage(
          image: AssetImage(AppAssets.profileBanner),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: AppPalette.rouge.withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: CustomPaint(
        painter: GoldCornerPainter(),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppPalette.whiteTone.withValues(alpha: 0.9),
                shape: BoxShape.circle,
                border: Border.all(color: AppPalette.paleGold, width: 1.5),
              ),
              child: const Text(
                '礼\n往\n来',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppPalette.palaceRed,
                  fontFamily: AppFonts.kaiti,
                  fontSize: 18,
                  height: 0.9,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Flexible(
                        child: Text(
                          '礼往来',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFFFFE6C0),
                            fontFamily: AppFonts.kaiti,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE3B0),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Pro',
                          style: TextStyle(
                            color: AppPalette.rouge,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '以礼传情 · 以记载心',
                    style: TextStyle(
                      color: Color(0xFFF5DDC2),
                      fontFamily: AppFonts.kaiti,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppPalette.whiteTone.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '当前账本  人情往来礼簿',
                          style: TextStyle(
                            color: AppPalette.ink,
                            fontFamily: AppFonts.kaiti,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          CupertinoIcons.chevron_right,
                          color: AppPalette.rouge,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileAdNotice extends StatelessWidget {
  const _ProfileAdNotice({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        14,
        compact ? 11 : 14,
        14,
        compact ? 11 : 14,
      ),
      decoration: BoxDecoration(
        color: compact
            ? AppPalette.whiteTone.withValues(alpha: 0.76)
            : const Color(0xFFFFF3DD).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (compact ? AppPalette.line : AppPalette.gold).withValues(
            alpha: compact ? 0.62 : 0.7,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppPalette.ink.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 34 : 42,
            height: compact ? 34 : 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppPalette.palaceRed.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppPalette.gold.withValues(alpha: 0.52),
              ),
            ),
            child: Icon(
              compact ? CupertinoIcons.sparkles : CupertinoIcons.rosette,
              color: AppPalette.palaceRed,
              size: compact ? 18 : 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  compact ? '开通 Pro，去除广告' : '未开通 Pro 时会展示广告',
                  style: const TextStyle(
                    color: AppPalette.ink,
                    fontFamily: AppFonts.kaiti,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  compact
                      ? '购买后享受无广告体验，并解锁备份、导出等能力。'
                      : '购买 Pro 可立即关闭广告，保留清爽礼簿体验。',
                  style: const TextStyle(
                    color: AppPalette.mutedInk,
                    fontFamily: AppFonts.kaiti,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppPalette.palaceRed,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppPalette.rouge.withValues(alpha: 0.18),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Text(
              '购买',
              style: TextStyle(
                color: Color(0xFFFFE3B0),
                fontFamily: AppFonts.kaiti,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSettingsSection extends StatelessWidget {
  const _ProfileSettingsSection({required this.title, required this.items});

  final String title;
  final List<_ProfileSettingItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormSectionLabel(label: title),
        Container(
          decoration: BoxDecoration(
            color: AppPalette.whiteTone.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppPalette.line.withValues(alpha: 0.58)),
            boxShadow: [
              BoxShadow(
                color: AppPalette.ink.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              for (var index = 0; index < items.length; index++)
                _ProfileSettingRow(
                  item: items[index],
                  isLast: index == items.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileSettingItem {
  const _ProfileSettingItem({
    required this.icon,
    required this.title,
    this.value,
    this.showDot = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? value;
  final bool showDot;
  final VoidCallback? onTap;
}

class _ProfileSettingRow extends StatelessWidget {
  const _ProfileSettingRow({required this.item, required this.isLast});

  final _ProfileSettingItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: AppPalette.line.withValues(alpha: 0.52),
                  ),
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppPalette.whiteTone.withValues(alpha: 0.7),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppPalette.gold.withValues(alpha: 0.54),
                ),
              ),
              child: Icon(item.icon, color: const Color(0xFF8A642F), size: 19),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppPalette.ink,
                  fontFamily: AppFonts.kaiti,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            if (item.value != null) ...[
              Text(
                item.value!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppPalette.mutedInk,
                  fontFamily: AppFonts.kaiti,
                  fontSize: 13,
                ),
              ),
              if (item.showDot) ...[
                const SizedBox(width: 7),
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppPalette.palaceRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
              const SizedBox(width: 7),
            ],
            Icon(
              CupertinoIcons.chevron_right,
              color: AppPalette.mutedInk.withValues(alpha: 0.78),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileProPanel extends StatelessWidget {
  const _ProfileProPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E7).withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppPalette.gold.withValues(alpha: 0.55)),
        image: const DecorationImage(
          image: AssetImage(AppAssets.bottomMountain),
          fit: BoxFit.fitWidth,
          alignment: Alignment.bottomCenter,
          opacity: 0.42,
        ),
      ),
      child: CustomPaint(
        painter: GoldCornerPainter(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SealMark(text: '冠', size: 42),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '礼往来 Pro',
                        style: TextStyle(
                          color: AppPalette.rouge,
                          fontFamily: AppFonts.kaiti,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        '购买后去除广告，礼簿页面更清爽',
                        style: TextStyle(
                          color: AppPalette.mutedInk,
                          fontFamily: AppFonts.kaiti,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Row(
              children: [
                Expanded(
                  child: _ProfileProBenefit(
                    icon: CupertinoIcons.cube_box,
                    text: '多账本',
                  ),
                ),
                Expanded(
                  child: _ProfileProBenefit(
                    icon: CupertinoIcons.cloud,
                    text: '云端备份',
                  ),
                ),
                Expanded(
                  child: _ProfileProBenefit(
                    icon: CupertinoIcons.chart_bar,
                    text: '智能统计',
                  ),
                ),
                Expanded(
                  child: _ProfileProBenefit(
                    icon: CupertinoIcons.headphones,
                    text: '优先客服',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 46,
              child: SealButton(label: '购买 Pro 去广告', onPressed: () {}),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileProBenefit extends StatelessWidget {
  const _ProfileProBenefit({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF8A642F), size: 22),
        const SizedBox(height: 5),
        Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppPalette.mutedInk,
            fontFamily: AppFonts.kaiti,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class AntiqueScaffold extends StatelessWidget {
  const AntiqueScaffold({
    super.key,
    required this.child,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.useSafeArea = true,
  });

  final Widget child;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PaperBackground(
        child: useSafeArea ? SafeArea(bottom: false, child: child) : child,
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final isBrandHome = title == '礼往来';
    final isProfile = title == '我的';
    return Column(
      children: [
        SizedBox(
          height: isProfile ? 106 : (isBrandHome ? 160 : 198),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              if (!isProfile)
                Positioned(
                  right: isBrandHome ? -24 : -18,
                  top: isBrandHome ? 24 : 46,
                  child: Opacity(
                    opacity: 0.95,
                    child: Image.asset(
                      AppAssets.homeMountain,
                      width: isBrandHome ? 296 : 260,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              if (isProfile)
                Positioned(
                  right: 16,
                  top: 18,
                  child:
                      trailing ??
                      const Icon(
                        CupertinoIcons.gear_alt,
                        color: AppPalette.mutedInk,
                        size: 30,
                      ),
                )
              else
                Positioned(
                  right: 16,
                  top: isBrandHome ? 4 : 14,
                  child: trailing ?? const HomeBellIcon(),
                ),
              Positioned(
                left: 18,
                right: 110,
                top: isProfile ? 30 : (isBrandHome ? -2 : 18),
                child: isBrandHome
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 216,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  AppAssets.logo,
                                  width: 208,
                                  fit: BoxFit.contain,
                                ),
                                const SizedBox(height: 3),
                                const OrnateSubtitle(
                                  text: '人情往来礼簿',
                                  fontFamily: AppFonts.kaiti,
                                  textColor: Color(0xFF3D352D),
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  '礼有往来，情有分寸',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppPalette.mutedInk,
                                    fontFamily: AppFonts.kaiti,
                                    fontSize: 14,
                                    height: 1.2,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          const DateLedgerLine(),
                        ],
                      )
                    : Column(
                        children: [
                          if (title != '我的') ...[
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppPalette.ink,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                height: 1.05,
                              ),
                            ),
                            const SizedBox(height: 8),
                            OrnateSubtitle(text: subtitle),
                          ] else ...[
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(fontSize: 24),
                            ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }
}

class OrnateSubtitle extends StatelessWidget {
  const OrnateSubtitle({
    super.key,
    required this.text,
    this.fontFamily,
    this.textColor,
  });

  final String text;
  final String? fontFamily;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 2),
        Container(width: 34, height: 1, color: AppPalette.gold),
        const SizedBox(width: 8),
        Text(
          text,
          style:
              const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ).copyWith(
                color: textColor ?? AppPalette.mutedInk,
                fontFamily: fontFamily,
              ),
        ),
        const SizedBox(width: 8),
        Container(width: 34, height: 1, color: AppPalette.gold),
      ],
    );
  }
}

class DateLedgerLine extends StatelessWidget {
  const DateLedgerLine({super.key, this.date});

  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final currentDate = date ?? DateTime.now();
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.calendar,
              color: Color(0xFF7B5B30),
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              '${formatChineseDate(currentDate)}  星期${weekdays[currentDate.weekday - 1]}',
              style: const TextStyle(
                color: AppPalette.ink,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 22),
            const Text(
              '今日往来',
              style: TextStyle(color: AppPalette.mutedInk, fontSize: 12),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: AppPalette.palaceRed.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '宜',
                style: TextStyle(
                  color: AppPalette.palaceRed,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 5),
            const Text(
              '纳采 会亲友',
              style: TextStyle(color: AppPalette.mutedInk, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

class HomeBellIcon extends StatelessWidget {
  const HomeBellIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 34,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            right: 3,
            bottom: 1,
            child: Icon(
              CupertinoIcons.bell,
              color: Color(0xFF7B5B30),
              size: 28,
            ),
          ),
          Positioned(
            right: 0,
            top: 1,
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppPalette.palaceRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PaperBackground extends StatelessWidget {
  const PaperBackground({
    super.key,
    required this.child,
    this.whiteMode = false,
  });

  final Widget child;
  final bool whiteMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: whiteMode ? AppPalette.whiteTone : AppPalette.paper,
        image: const DecorationImage(
          image: AssetImage(AppAssets.paper),
          fit: BoxFit.cover,
          opacity: 0.55,
        ),
      ),
      child: CustomPaint(
        painter: PaperPainter(whiteMode: whiteMode),
        child: child,
      ),
    );
  }
}

class PaperPainter extends CustomPainter {
  const PaperPainter({required this.whiteMode});

  final bool whiteMode;

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = (whiteMode ? Colors.black : AppPalette.gold).withValues(
        alpha: whiteMode ? 0.018 : 0.025,
      )
      ..strokeWidth = 1;

    for (double y = 18; y < size.height; y += 34) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 3), basePaint);
    }

    final wash = Paint()
      ..shader =
          RadialGradient(
            colors: [
              (whiteMode ? AppPalette.pineGrey : AppPalette.palaceRed)
                  .withValues(alpha: 0.10),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * 0.82, size.height * 0.12),
              radius: size.width * 0.5,
            ),
          );
    canvas.drawRect(Offset.zero & size, wash);
  }

  @override
  bool shouldRepaint(covariant PaperPainter oldDelegate) {
    return oldDelegate.whiteMode != whiteMode;
  }
}

class InkLandscape extends StatelessWidget {
  const InkLandscape({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: InkLandscapePainter()),
    );
  }
}

class InkLandscapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final mountain = Paint()
      ..color = AppPalette.ink.withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.15,
        size.height * 0.28,
        size.width * 0.34,
        size.height * 0.72,
      )
      ..quadraticBezierTo(
        size.width * 0.48,
        size.height * 0.16,
        size.width * 0.68,
        size.height * 0.76,
      )
      ..quadraticBezierTo(
        size.width * 0.84,
        size.height * 0.34,
        size.width,
        size.height * 0.74,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, mountain);

    final line = Paint()
      ..color = AppPalette.ink.withValues(alpha: 0.18)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.65, size.height * 0.62),
      Offset(size.width * 0.9, size.height * 0.62),
      line,
    );
    canvas.drawLine(
      Offset(size.width * 0.72, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.38),
      line,
    );
    canvas.drawLine(
      Offset(size.width * 0.8, size.height * 0.38),
      Offset(size.width * 0.88, size.height * 0.5),
      line,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PlumBranch extends StatelessWidget {
  const PlumBranch({super.key, this.size = 92});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: PlumPainter()),
    );
  }
}

class PlumPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final branch = Paint()
      ..color = AppPalette.ink.withValues(alpha: 0.22)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.95, size.height * 0.18),
      Offset(size.width * 0.1, size.height * 0.72),
      branch,
    );
    canvas.drawLine(
      Offset(size.width * 0.55, size.height * 0.38),
      Offset(size.width * 0.38, size.height * 0.15),
      branch,
    );
    final blossom = Paint()
      ..color = AppPalette.cinnabar.withValues(alpha: 0.72);
    final points = [
      Offset(size.width * 0.82, size.height * 0.25),
      Offset(size.width * 0.68, size.height * 0.34),
      Offset(size.width * 0.54, size.height * 0.42),
      Offset(size.width * 0.43, size.height * 0.22),
      Offset(size.width * 0.32, size.height * 0.56),
      Offset(size.width * 0.18, size.height * 0.68),
    ];
    for (final point in points) {
      canvas.drawCircle(point, 3.5, blossom);
      canvas.drawCircle(
        point.translate(4, -2),
        2.2,
        blossom..color = AppPalette.gold.withValues(alpha: 0.65),
      );
      blossom.color = AppPalette.cinnabar.withValues(alpha: 0.72);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SealMark extends StatelessWidget {
  const SealMark({
    super.key,
    required this.text,
    this.size = 34,
    this.color = AppPalette.palaceRed,
    this.fontFamily,
  });

  final String text;
  final double size;
  final Color color;
  final String? fontFamily;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: color == Colors.white ? 0.18 : 0.96),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: color == Colors.white ? Colors.white : AppPalette.gold,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color == Colors.white ? Colors.white : Colors.white,
          fontSize: size * 0.46,
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class SealButton extends StatelessWidget {
  const SealButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fontFamily,
  });

  final String label;
  final VoidCallback onPressed;
  final String? fontFamily;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onPressed,
          child: Container(
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFB92722), Color(0xFF971B18)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppPalette.rouge.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CustomPaint(
              painter: ChineseKnotButtonPainter(),
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFFFFE3B0),
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ).copyWith(fontFamily: fontFamily),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChineseKnotButtonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final radius = const Radius.circular(10);
    final outer = RRect.fromRectAndRadius(
      Offset.zero & size,
      radius,
    ).deflate(1.4);
    final inner = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(7),
    ).deflate(6);
    final border = Paint()
      ..color = AppPalette.paleGold.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35;
    final innerBorder = Paint()
      ..color = AppPalette.paleGold.withValues(alpha: 0.78)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85;
    canvas.drawRRect(outer, border);
    canvas.drawRRect(inner, innerBorder);

    final texture = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (double y = 12; y < size.height - 6; y += 8) {
      canvas.drawLine(Offset(20, y), Offset(size.width - 20, y + 1), texture);
    }

    final knot = Paint()
      ..color = AppPalette.paleGold.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.05
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    void drawCorner(Canvas canvas, bool right, bool bottom) {
      final dx = right ? size.width : 0.0;
      final dy = bottom ? size.height : 0.0;
      canvas.save();
      canvas.translate(dx, dy);
      canvas.scale(right ? -1.0 : 1.0, bottom ? -1.0 : 1.0);

      final path = Path()
        ..moveTo(9, 22)
        ..lineTo(9, 15)
        ..lineTo(15, 15)
        ..lineTo(15, 9)
        ..lineTo(22, 9)
        ..moveTo(12, 22)
        ..lineTo(12, 18)
        ..lineTo(18, 18)
        ..lineTo(18, 12)
        ..lineTo(22, 12)
        ..moveTo(9, 18)
        ..lineTo(6, 18)
        ..lineTo(6, 25)
        ..moveTo(18, 9)
        ..lineTo(18, 6)
        ..lineTo(25, 6);
      canvas.drawPath(path, knot);

      final accent = Paint()
        ..color = AppPalette.gold.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.75;
      canvas.drawArc(
        const Rect.fromLTWH(16, 25, 21, 14),
        math.pi,
        math.pi,
        false,
        accent,
      );
      canvas.restore();
    }

    drawCorner(canvas, false, false);
    drawCorner(canvas, true, false);
    drawCorner(canvas, false, true);
    drawCorner(canvas, true, true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AntiqueCard extends StatelessWidget {
  const AntiqueCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.gradient,
  });

  final Widget child;
  final EdgeInsets padding;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        color: gradient == null
            ? AppPalette.whiteTone.withValues(alpha: 0.78)
            : null,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppPalette.line),
        boxShadow: [
          BoxShadow(
            color: AppPalette.ink.withValues(alpha: 0.055),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}

class LedgerEntryField extends StatelessWidget {
  const LedgerEntryField({
    super.key,
    this.fieldKey,
    required this.controller,
    required this.icon,
    required this.label,
    required this.hintText,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.suffix,
    this.textStyle,
  });

  final Key? fieldKey;
  final TextEditingController controller;
  final IconData icon;
  final String label;
  final String hintText;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? suffix;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppPalette.whiteTone.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppPalette.line),
        boxShadow: [
          BoxShadow(
            color: AppPalette.ink.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppPalette.rouge, size: 23),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: AppPalette.ink,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              key: fieldKey,
              focusNode: focusNode,
              controller: controller,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              textAlign: TextAlign.right,
              style: textStyle,
              decoration: InputDecoration.collapsed(
                hintText: hintText,
                hintStyle: const TextStyle(
                  color: Color(0xFFB4A690),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (suffix != null) ...[
            const SizedBox(width: 10),
            Text(
              suffix!,
              style: const TextStyle(
                color: AppPalette.ink,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class AmountQuickGrid extends StatelessWidget {
  const AmountQuickGrid({
    super.key,
    required this.controller,
    required this.values,
  });

  final TextEditingController controller;
  final List<int> values;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 10.0;
        final itemWidth = (constraints.maxWidth - gap * 3) / 4;
        final itemHeight = math.max(38.0, itemWidth * 0.48);
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final value in values)
              SizedBox(
                width: itemWidth,
                height: itemHeight,
                child: _AmountQuickButton(
                  value: value,
                  onTap: () => controller.text = value.toString(),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _AmountQuickButton extends StatelessWidget {
  const _AmountQuickButton({required this.value, required this.onTap});

  final int value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$value',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: AppPalette.whiteTone.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppPalette.line),
            ),
            child: Center(
              child: Text(
                '$value',
                style: const TextStyle(
                  color: AppPalette.palaceRed,
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ParchmentOption<T> {
  const ParchmentOption({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

class ParchmentSegmentedControl<T> extends StatelessWidget {
  const ParchmentSegmentedControl({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.height = 58,
  });

  final List<ParchmentOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppPalette.whiteTone.withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.line),
      ),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++)
            Expanded(
              child: _ParchmentSegment<T>(
                option: options[i],
                selected: selected == options[i].value,
                onTap: () => onSelected(options[i].value),
              ),
            ),
        ],
      ),
    );
  }
}

class _ParchmentSegment<T> extends StatelessWidget {
  const _ParchmentSegment({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final ParchmentOption<T> option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(9),
            gradient: selected
                ? const LinearGradient(
                    colors: [AppPalette.cinnabar, AppPalette.palaceRed],
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (option.icon != null) ...[
                Icon(
                  option.icon,
                  size: 20,
                  color: selected
                      ? const Color(0xFFFFE3B0)
                      : AppPalette.mutedInk,
                ),
                const SizedBox(width: 7),
              ],
              Text(
                option.label,
                style: TextStyle(
                  color: selected ? const Color(0xFFFFE3B0) : AppPalette.ink,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HeroLedgerCard extends StatelessWidget {
  const HeroLedgerCard({
    super.key,
    required this.received,
    required this.given,
    required this.balance,
    this.height = 134,
  });

  final int received;
  final int given;
  final int balance;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage(AppAssets.yearlyLedgerPanel),
          fit: BoxFit.fill,
        ),
        boxShadow: [
          BoxShadow(
            color: AppPalette.rouge.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: height * 0.20,
              child: const Text(
                '往来概览',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFFF5D184),
                  fontSize: 18,
                  fontFamily: AppFonts.kaiti,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3,
                  height: 1,
                ),
              ),
            ),
            Positioned(
              left: 20,
              right: 20,
              top: height * 0.40,
              child: const Row(
                children: [
                  Expanded(child: _LedgerMetricLabel(text: '收礼')),
                  Expanded(child: _LedgerMetricLabel(text: '回礼')),
                  Expanded(child: _LedgerMetricLabel(text: '往来结余')),
                ],
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: height * 0.03,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: MetricBlock(value: received)),
                  Expanded(child: MetricBlock(value: given)),
                  Expanded(child: MetricBlock(value: balance, signed: true)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LedgerMetricLabel extends StatelessWidget {
  const _LedgerMetricLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Color(0xFFF4DEC2),
        fontSize: 14,
        fontFamily: AppFonts.kaiti,
        fontWeight: FontWeight.w700,
        height: 1,
      ),
    );
  }
}

class MetricBlock extends StatelessWidget {
  const MetricBlock({super.key, required this.value, this.signed = false});

  final int value;
  final bool signed;

  @override
  Widget build(BuildContext context) {
    final text = signed && value > 0
        ? '+${formatAmount(value)}'
        : formatAmount(value);
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            maxLines: 1,
            style: const TextStyle(
              color: Color(0xFFF7D68D),
              fontSize: 28,
              fontFamily: AppFonts.songti,
              fontWeight: FontWeight.w500,
              height: 0.95,
            ),
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          '元',
          style: TextStyle(
            color: Color(0xFFF4DEC2),
            fontSize: 12,
            fontFamily: AppFonts.kaiti,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class GoldCornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppPalette.paleGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final inset = 8.0;
    final len = 22.0;
    for (final origin in [
      Offset(inset, inset),
      Offset(size.width - inset, inset),
      Offset(inset, size.height - inset),
      Offset(size.width - inset, size.height - inset),
    ]) {
      final sx = origin.dx < size.width / 2 ? 1.0 : -1.0;
      final sy = origin.dy < size.height / 2 ? 1.0 : -1.0;
      canvas.drawLine(origin, origin.translate(sx * len, 0), paint);
      canvas.drawLine(origin, origin.translate(0, sy * len), paint);
      canvas.drawLine(
        origin.translate(sx * 6, sy * 6),
        origin.translate(sx * len, sy * 6),
        paint,
      );
      canvas.drawLine(
        origin.translate(sx * 6, sy * 6),
        origin.translate(sx * 6, sy * len),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QuickAction extends StatelessWidget {
  const QuickAction({
    super.key,
    this.imageAsset,
    this.icon,
    required this.label,
    required this.onTap,
  }) : assert(imageAsset != null || icon != null);

  final String? imageAsset;
  final IconData? icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          decoration: const BoxDecoration(
            color: Colors.transparent,
            border: Border(right: BorderSide(color: AppPalette.line)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (imageAsset != null)
                Image.asset(
                  imageAsset!,
                  width: 56,
                  height: 56,
                  fit: BoxFit.contain,
                )
              else
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8ED),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppPalette.gold.withValues(alpha: 0.55),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(icon, color: AppPalette.palaceRed, size: 24),
                ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppPalette.ink,
                  fontFamily: AppFonts.kaiti,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResponsiveWrap extends StatelessWidget {
  const ResponsiveWrap({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 320 ? 4 : 2;
        final gap = constraints.maxWidth >= 320 ? 0.0 : 8.0;
        final width = (constraints.maxWidth - gap * (columns - 1)) / columns;
        final rowChildren = [
          for (final child in children) Expanded(child: child),
        ];
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: AppPalette.whiteTone.withValues(alpha: 0.78),
              border: Border.all(color: AppPalette.line),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppPalette.ink.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: columns == 4
                ? Row(children: rowChildren)
                : Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final child in children)
                        SizedBox(width: width, child: child),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, required this.action});

  final String title;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          '✣',
          style: TextStyle(color: AppPalette.palaceRed, fontSize: 12),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 14,
            fontFamily: AppFonts.kaiti,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        Text(
          action,
          style: const TextStyle(color: AppPalette.mutedInk, fontSize: 13),
        ),
        const SizedBox(width: 2),
        const Icon(
          CupertinoIcons.chevron_right,
          size: 12,
          color: AppPalette.mutedInk,
        ),
      ],
    );
  }
}

class UpcomingReminderGrid extends StatelessWidget {
  const UpcomingReminderGrid({super.key, required this.items});

  final List<ReminderItem> items;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < math.min(items.length, 2); index++) ...[
          Expanded(
            child: ReminderTile(
              item: items[index],
              imageAsset: index == 0
                  ? AppAssets.iconDoubleHappiness
                  : AppAssets.iconFamilyBlessing,
            ),
          ),
          if (index == 0) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class ReminderTile extends StatelessWidget {
  const ReminderTile({super.key, required this.item, required this.imageAsset});

  final ReminderItem item;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    final parts = item.subtitle.split(' · ');
    final dateText = parts.isNotEmpty ? parts.first : item.subtitle;
    final weekText = parts.length > 1 ? parts[1] : '';
    return Container(
      height: 66,
      decoration: BoxDecoration(
        color: AppPalette.whiteTone.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppPalette.line.withValues(alpha: 0.82)),
        image: DecorationImage(
          image: const AssetImage(AppAssets.paper),
          fit: BoxFit.cover,
          opacity: 0.18,
        ),
        boxShadow: [
          BoxShadow(
            color: AppPalette.ink.withValues(alpha: 0.045),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Image.asset(
                imageAsset,
                width: 44,
                height: 44,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.daysLeft}天后 $dateText${weekText.isEmpty ? '' : ' $weekText'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppPalette.mutedInk,
                      fontSize: 10,
                      fontFamily: AppFonts.kaiti,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecentRecordsTable extends StatelessWidget {
  const RecentRecordsTable({
    super.key,
    required this.records,
    this.rowHeight = 44,
  });

  final List<GiftRecord> records;
  final double rowHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppPalette.whiteTone.withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppPalette.line.withValues(alpha: 0.86)),
        image: const DecorationImage(
          image: AssetImage(AppAssets.paper),
          fit: BoxFit.cover,
          opacity: 0.22,
        ),
      ),
      child: Column(
        children: [
          for (var index = 0; index < records.length; index++)
            RecentRecordRow(
              record: records[index],
              isLast: index == records.length - 1,
              height: rowHeight,
            ),
        ],
      ),
    );
  }
}

class HomeBottomLandscape extends StatelessWidget {
  const HomeBottomLandscape({super.key, this.height = 16});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Align(
        alignment: Alignment.topCenter,
        child: Opacity(
          opacity: 0.55,
          child: Image.asset(
            AppAssets.bottomMountain,
            fit: BoxFit.fitWidth,
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}

class RecentRecordRow extends StatelessWidget {
  const RecentRecordRow({
    super.key,
    required this.record,
    required this.isLast,
    required this.height,
  });

  final GiftRecord record;
  final bool isLast;
  final double height;

  @override
  Widget build(BuildContext context) {
    final amountColor = record.direction == GiftDirection.received
        ? AppPalette.palaceRed
        : AppPalette.green;
    final sign = record.direction == GiftDirection.received ? '+' : '-';
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppPalette.line.withValues(alpha: 0.70),
                ),
              ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: record.tone == EventTone.red
                ? const Color(0xFF5F5440)
                : AppPalette.pineGrey,
            child: Text(
              record.name.characters.first,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: AppFonts.kaiti,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 64),
                child: Text(
                  record.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: AppFonts.kaiti,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              RelationTag(text: record.relation),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              record.event,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppPalette.mutedInk,
                fontFamily: AppFonts.kaiti,
                fontSize: 13,
              ),
            ),
          ),
          SizedBox(
            width: 74,
            child: Text(
              formatSlashDate(record.date),
              textAlign: TextAlign.right,
              style: const TextStyle(color: AppPalette.mutedInk, fontSize: 12),
            ),
          ),
          SizedBox(
            width: 66,
            child: Text(
              '$sign${formatAmount(record.amount)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: amountColor,
                fontSize: 16,
                fontFamily: AppFonts.songti,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecordTile extends StatelessWidget {
  const RecordTile({super.key, required this.record});

  final GiftRecord record;

  @override
  Widget build(BuildContext context) {
    final directionColor = record.direction == GiftDirection.received
        ? AppPalette.palaceRed
        : const Color(0xFF3C7C58);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AntiqueCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
                  (record.tone == EventTone.red
                          ? AppPalette.palaceRed
                          : AppPalette.pineGrey)
                      .withValues(alpha: 0.12),
              child: Text(
                record.name.characters.first,
                style: TextStyle(
                  color: directionColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          record.name,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 6),
                      RelationTag(text: record.relation),
                      if (record.partial) ...[
                        const SizedBox(width: 5),
                        const RelationTag(text: '待补全', muted: true),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${record.event} · ${record.method} · ${formatDate(record.date)}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppPalette.mutedInk,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${record.direction == GiftDirection.received ? '+' : '-'}${formatAmount(record.amount)}',
              style: TextStyle(
                color: directionColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickDeskRecentRow extends StatelessWidget {
  const QuickDeskRecentRow({
    super.key,
    required this.record,
    required this.isLast,
  });

  final GiftRecord record;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final amountColor = record.direction == GiftDirection.received
        ? AppPalette.palaceRed
        : AppPalette.green;
    final status = record.partial ? '待补全' : '已记录';
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppPalette.line.withValues(alpha: 0.70),
                ),
              ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF5E543F),
            child: Text(
              record.name.characters.first,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 5,
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    record.name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                RelationTag(text: record.relation, muted: record.partial),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${record.direction == GiftDirection.received ? '+' : '-'}${formatAmount(record.amount)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: amountColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(
            width: 44,
            child: Text(
              formatTime(record.date),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppPalette.mutedInk, fontSize: 12),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(
              color: record.partial
                  ? const Color(0xFFFFE9C7)
                  : const Color(0xFFEAF0D6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: record.partial ? AppPalette.rouge : AppPalette.green,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RelationTag extends StatelessWidget {
  const RelationTag({super.key, required this.text, this.muted = false});

  final String text;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: muted
            ? AppPalette.line.withValues(alpha: 0.32)
            : AppPalette.gold.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: muted ? AppPalette.mutedInk : AppPalette.palaceRed,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class MonthSummaryCard extends StatelessWidget {
  const MonthSummaryCard({
    super.key,
    required this.totalReceived,
    required this.totalGiven,
    required this.count,
  });

  final int totalReceived;
  final int totalGiven;
  final int count;

  @override
  Widget build(BuildContext context) {
    return AntiqueCard(
      child: Row(
        children: [
          const SealMark(text: '月'),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('2026年6月', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(
                  '收礼 ${formatAmount(totalReceived)} 元｜回礼 ${formatAmount(totalGiven)} 元',
                  style: const TextStyle(color: AppPalette.mutedInk),
                ),
              ],
            ),
          ),
          Text('$count 笔', style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class OptionGroup extends StatelessWidget {
  const OptionGroup({
    super.key,
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = options.length <= 3 ? options.length : 3;
              final gap = 8.0;
              final width =
                  (constraints.maxWidth - gap * (columns - 1)) / columns;
              return Wrap(
                spacing: gap,
                runSpacing: 8,
                children: [
                  for (final option in options)
                    SizedBox(
                      width: width,
                      height: 48,
                      child: FormOptionButton(
                        label: option,
                        selected: selected == option,
                        onTap: () => onSelected(option),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class FormOptionButton extends StatelessWidget {
  const FormOptionButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: selected
                ? AppPalette.palaceRed.withValues(alpha: 0.08)
                : AppPalette.whiteTone.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppPalette.palaceRed : AppPalette.line,
            ),
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? AppPalette.palaceRed : AppPalette.ink,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PersonSummaryCard extends StatelessWidget {
  const PersonSummaryCard({
    super.key,
    required this.record,
    required this.count,
  });

  final GiftRecord record;
  final int count;

  @override
  Widget build(BuildContext context) {
    return AntiqueCard(
      gradient: const LinearGradient(
        colors: [AppPalette.palaceRed, AppPalette.rouge],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white.withValues(alpha: 0.16),
            child: Text(
              record.name.characters.first,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${record.relation} · 最近 ${record.event}',
                  style: const TextStyle(color: Color(0xFFEFD8C0)),
                ),
              ],
            ),
          ),
          Text(
            '$count 笔',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class ReturnGiftCard extends StatelessWidget {
  const ReturnGiftCard({
    super.key,
    required this.oldAmount,
    required this.suggestedAmount,
  });

  final int oldAmount;
  final int suggestedAmount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 176,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            image: const DecorationImage(
              image: AssetImage(AppAssets.redLedger),
              fit: BoxFit.cover,
              opacity: 0.98,
            ),
            boxShadow: [
              BoxShadow(
                color: AppPalette.rouge.withValues(alpha: 0.22),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: CustomPaint(
            painter: GoldCornerPainter(),
            child: Row(
              children: [
                Expanded(
                  child: CoupleBlock(
                    title: '彼时彼刻',
                    subtitle: '他随我',
                    amount: oldAmount,
                    redMode: true,
                  ),
                ),
                Container(width: 1, height: 96, color: Colors.white24),
                const SizedBox(
                  width: 86,
                  child: Center(
                    child: Text(
                      '情礼\n更意重',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppPalette.paleGold,
                        fontSize: 17,
                        height: 1.6,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Container(width: 1, height: 96, color: Colors.white24),
                Expanded(
                  child: CoupleBlock(
                    title: '此时此刻',
                    subtitle: '我回他',
                    amount: suggestedAmount,
                    redMode: true,
                  ),
                ),
              ],
            ),
          ),
        ),
        AntiqueCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: ReturnOption(
                  icon: CupertinoIcons.refresh,
                  title: '原礼返回',
                ),
              ),
              Expanded(
                child: ReturnOption(
                  icon: CupertinoIcons.chart_bar_alt_fill,
                  title: '小幅加礼',
                ),
              ),
              Expanded(
                child: ReturnOption(
                  icon: CupertinoIcons.person_2,
                  title: '按关系调整',
                ),
              ),
              Expanded(
                child: ReturnOption(icon: CupertinoIcons.pencil, title: '自定义'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ReturnOption extends StatelessWidget {
  const ReturnOption({super.key, required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppPalette.palaceRed, size: 26),
        const SizedBox(height: 7),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class CoupleBlock extends StatelessWidget {
  const CoupleBlock({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    this.redMode = false,
  });

  final String title;
  final String subtitle;
  final int amount;
  final bool redMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: redMode ? AppPalette.paleGold : AppPalette.mutedInk,
            fontSize: redMode ? 13 : 14,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(
            color: redMode ? Colors.white : AppPalette.ink,
            fontSize: redMode ? 24 : 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          formatAmount(amount),
          style: TextStyle(
            color: redMode ? const Color(0xFFF5D184) : AppPalette.palaceRed,
            fontSize: redMode ? 44 : 24,
            fontWeight: FontWeight.w500,
            height: 1,
          ),
        ),
        Text(
          '元',
          style: TextStyle(
            color: redMode ? AppPalette.paleGold : AppPalette.mutedInk,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class TimelineTile extends StatelessWidget {
  const TimelineTile({super.key, required this.record});

  final GiftRecord record;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: record.direction == GiftDirection.received
                    ? AppPalette.palaceRed
                    : const Color(0xFF3C7C58),
                shape: BoxShape.circle,
              ),
            ),
            Container(width: 1, height: 66, color: AppPalette.line),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(child: RecordTile(record: record)),
      ],
    );
  }
}

class QuickDeskTopBar extends StatelessWidget {
  const QuickDeskTopBar({
    super.key,
    required this.scene,
    required this.total,
    required this.tone,
    required this.onClose,
  });

  final String scene;
  final int total;
  final EventTone tone;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 30,
            child: Image.asset(AppAssets.quickMountain, width: 188),
          ),
          Positioned(
            left: -2,
            top: 6,
            child: IconButton(
              onPressed: onClose,
              icon: const Icon(
                CupertinoIcons.chevron_left,
                color: AppPalette.ink,
                size: 26,
              ),
            ),
          ),
          Positioned(
            left: 18,
            top: 20,
            child: Image.asset(AppAssets.logo, width: 158),
          ),
          const Positioned(
            left: 34,
            top: 76,
            child: OrnateSubtitle(text: '礼台模式'),
          ),
          Positioned(
            left: 42,
            top: 106,
            child: Text(
              '$scene · 今日合计 ${formatAmount(total)}',
              style: const TextStyle(
                color: AppPalette.mutedInk,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 14,
            child: SealMark(text: tone == EventTone.red ? '红' : '白'),
          ),
        ],
      ),
    );
  }
}

class QuickDeskInfoPanel extends StatelessWidget {
  const QuickDeskInfoPanel({
    super.key,
    required this.tone,
    required this.direction,
    required this.scene,
    required this.count,
    required this.total,
    required this.onToneChanged,
    required this.onDirectionChanged,
    required this.onSceneChanged,
  });

  final EventTone tone;
  final GiftDirection direction;
  final String scene;
  final int count;
  final int total;
  final ValueChanged<EventTone> onToneChanged;
  final ValueChanged<GiftDirection> onDirectionChanged;
  final ValueChanged<String> onSceneChanged;

  @override
  Widget build(BuildContext context) {
    return AntiqueCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('礼台信息', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          InfoLine(label: '当前账本', value: '我家'),
          InfoLine(label: '今日记录', value: '$count 笔'),
          InfoLine(label: '今日合计', value: '${formatAmount(total)} 元'),
          InfoLine(label: '待补全', value: '$count 笔'),
          const SizedBox(height: 10),
          SegmentedButton<EventTone>(
            segments: const [
              ButtonSegment(value: EventTone.red, label: Text('红榜')),
              ButtonSegment(value: EventTone.white, label: Text('白榜')),
            ],
            selected: {tone},
            onSelectionChanged: (value) => onToneChanged(value.first),
          ),
          const SizedBox(height: 10),
          SegmentedButton<GiftDirection>(
            segments: const [
              ButtonSegment(value: GiftDirection.received, label: Text('收礼')),
              ButtonSegment(value: GiftDirection.given, label: Text('回礼')),
            ],
            selected: {direction},
            onSelectionChanged: (value) => onDirectionChanged(value.first),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final value in const ['婚礼', '满月', '乔迁', '白事', '其他'])
                ChoiceChip(
                  label: Text(value),
                  selected: scene == value,
                  onSelected: (_) => onSceneChanged(value),
                ),
            ],
          ),
          if (tone == EventTone.white) ...[
            const SizedBox(height: 10),
            const Text(
              '所有白榜记录仅自己可见',
              style: TextStyle(color: AppPalette.pineGrey, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class QuickDeskCompactStats extends StatelessWidget {
  const QuickDeskCompactStats({
    super.key,
    required this.tone,
    required this.direction,
    required this.scene,
    required this.count,
    required this.total,
    required this.onToneChanged,
    required this.onDirectionChanged,
    required this.onSceneChanged,
  });

  final EventTone tone;
  final GiftDirection direction;
  final String scene;
  final int count;
  final int total;
  final ValueChanged<EventTone> onToneChanged;
  final ValueChanged<GiftDirection> onDirectionChanged;
  final ValueChanged<String> onSceneChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: const BoxDecoration(
            color: AppPalette.palaceRed,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Text(
            '$scene · ${direction == GiftDirection.received ? '收礼' : '回礼'}',
            style: const TextStyle(
              color: Color(0xFFFFE3B0),
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        AntiqueCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Expanded(
                child: InfoStat(
                  icon: CupertinoIcons.doc_text,
                  label: '今日记录',
                  value: '$count 条',
                ),
              ),
              Container(width: 1, height: 34, color: AppPalette.line),
              Expanded(
                child: InfoStat(
                  icon: CupertinoIcons.money_yen_circle,
                  label: '今日总额',
                  value: '¥${formatAmount(total)}',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class SceneToggleChip extends StatelessWidget {
  const SceneToggleChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final Widget label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 66),
          height: 36,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected
                ? AppPalette.palaceRed.withValues(alpha: 0.10)
                : AppPalette.whiteTone.withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: selected ? AppPalette.palaceRed : AppPalette.line,
            ),
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: selected ? AppPalette.palaceRed : AppPalette.mutedInk,
              fontWeight: FontWeight.w800,
            ),
            child: label,
          ),
        ),
      ),
    );
  }
}

class InfoStat extends StatelessWidget {
  const InfoStat({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppPalette.gold, size: 22),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppPalette.mutedInk)),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: AppPalette.palaceRed,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class InfoLine extends StatelessWidget {
  const InfoLine({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(color: AppPalette.mutedInk)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class TabletRail extends StatelessWidget {
  const TabletRail({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.onOpenQuickDesk,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onOpenQuickDesk;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.42),
        border: const Border(right: BorderSide(color: AppPalette.line)),
      ),
      child: Column(
        children: [
          const SealMark(text: '礼', size: 44),
          const SizedBox(height: 18),
          RailButton(
            icon: CupertinoIcons.house,
            label: '首页',
            selected: selectedIndex == 0,
            onTap: () => onSelected(0),
          ),
          RailButton(
            icon: CupertinoIcons.book,
            label: '礼簿',
            selected: selectedIndex == 1,
            onTap: () => onSelected(1),
          ),
          RailButton(
            icon: CupertinoIcons.pencil_outline,
            label: '记一笔',
            selected: selectedIndex == 2,
            onTap: () => onSelected(2),
          ),
          RailButton(
            icon: CupertinoIcons.search,
            label: '查往来',
            selected: selectedIndex == 3,
            onTap: () => onSelected(3),
          ),
          RailButton(
            icon: CupertinoIcons.person,
            label: '我的',
            selected: selectedIndex == 4,
            onTap: () => onSelected(4),
          ),
          const Spacer(),
          RailButton(
            icon: CupertinoIcons.rectangle_stack_badge_person_crop,
            label: '礼台',
            selected: false,
            onTap: onOpenQuickDesk,
          ),
        ],
      ),
    );
  }
}

class RailButton extends StatelessWidget {
  const RailButton({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppPalette.palaceRed.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? AppPalette.palaceRed : AppPalette.mutedInk,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppPalette.palaceRed : AppPalette.mutedInk,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PhoneNavBar extends StatelessWidget {
  const PhoneNavBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppPalette.paper.withValues(alpha: 0.96),
      elevation: 8,
      notchMargin: 4,
      padding: EdgeInsets.zero,
      shape: const CircularNotchedRectangle(),
      child: Container(
        height: 52,
        decoration: const BoxDecoration(color: AppPalette.paper),
        child: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NavButton(
                icon: CupertinoIcons.house,
                label: '首页',
                selected: selectedIndex == 0,
                onTap: () => onSelected(0),
              ),
              NavButton(
                icon: CupertinoIcons.book,
                label: '礼簿',
                selected: selectedIndex == 1,
                onTap: () => onSelected(1),
              ),
              const SizedBox(width: 62),
              NavButton(
                icon: CupertinoIcons.search,
                label: '查往来',
                selected: selectedIndex == 3,
                onTap: () => onSelected(3),
              ),
              NavButton(
                icon: CupertinoIcons.person,
                label: '我的',
                selected: selectedIndex == 4,
                onTap: () => onSelected(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CenterWriteButton extends StatelessWidget {
  const CenterWriteButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '记一笔',
      child: GestureDetector(
        onTap: onTap,
        child: Transform.translate(
          offset: const Offset(0, 40),
          child: SizedBox(
            width: 62,
            height: 64,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppPalette.paleGold, width: 1.2),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      AppAssets.iconWriteBrushNav,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  '记一笔',
                  style: TextStyle(
                    color: AppPalette.palaceRed,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NavButton extends StatelessWidget {
  const NavButton({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppPalette.palaceRed : AppPalette.mutedInk;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 1),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.doc_text_search,
            color: AppPalette.mutedInk.withValues(alpha: 0.6),
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppPalette.mutedInk),
          ),
        ],
      ),
    );
  }
}

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.items});

  final String title;
  final List<SettingsItem> items;

  @override
  Widget build(BuildContext context) {
    return AntiqueCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final item in items)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(item.title),
              subtitle: Text(item.subtitle),
              trailing: const Icon(CupertinoIcons.chevron_right, size: 18),
            ),
        ],
      ),
    );
  }
}

class SettingsItem {
  const SettingsItem(this.title, this.subtitle);

  final String title;
  final String subtitle;
}

class SampleData {
  static final records = [
    GiftRecord(
      id: 'r1',
      name: '张晓明',
      relation: '挚友',
      event: '订婚之喜',
      direction: GiftDirection.received,
      tone: EventTone.red,
      amount: 1200,
      date: DateTime(2025, 5, 11),
      method: '现金',
      book: '我家',
    ),
    GiftRecord(
      id: 'r2',
      name: '李建国',
      relation: '同事',
      event: '乔迁之喜',
      direction: GiftDirection.given,
      tone: EventTone.red,
      amount: 800,
      date: DateTime(2025, 5, 10),
      method: '现金',
      book: '我家',
    ),
    GiftRecord(
      id: 'r3',
      name: '王丽丽',
      relation: '表姐',
      event: '宝宝满月',
      direction: GiftDirection.received,
      tone: EventTone.red,
      amount: 600,
      date: DateTime(2025, 5, 8),
      method: '现金',
      book: '我家',
    ),
    GiftRecord(
      id: 'r4',
      name: '陈志强',
      relation: '发小',
      event: '婚礼',
      direction: GiftDirection.given,
      tone: EventTone.red,
      amount: 1000,
      date: DateTime(2025, 5, 5),
      method: '现金',
      book: '我家',
    ),
    GiftRecord(
      id: 'r5',
      name: '刘芳',
      relation: '同学',
      event: '生日',
      direction: GiftDirection.received,
      tone: EventTone.red,
      amount: 300,
      date: DateTime(2025, 5, 3),
      method: '现金',
      book: '我家',
    ),
  ];

  static const reminders = [
    ReminderItem('张晓明婚礼', '5月21日 · 星期三', 5),
    ReminderItem('小宝满月', '5月30日 · 星期五', 14),
  ];
}

String formatAmount(int amount) {
  final sign = amount < 0 ? '-' : '';
  final raw = amount.abs().toString();
  final buffer = StringBuffer(sign);
  for (int i = 0; i < raw.length; i++) {
    if (i > 0 && (raw.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(raw[i]);
  }
  return buffer.toString();
}

String formatDate(DateTime date) {
  return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
}

String formatSlashDate(DateTime date) {
  return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
}

String formatChineseDate(DateTime date) {
  return '${date.year}年${date.month}月${date.day}日';
}

String formatTime(DateTime date) {
  return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

double softSin(double value) => math.sin(value).clamp(-1, 1).toDouble();
