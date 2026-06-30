import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:liwanglai/main.dart';

GiftRecord _record({
  required String id,
  required String name,
  required GiftDirection direction,
  required int amount,
  bool needReturn = false,
  DateTime? date,
  String method = '现金',
  String relation = '挚友',
}) {
  return GiftRecord(
    id: id,
    name: name,
    relation: relation,
    event: '婚礼',
    direction: direction,
    tone: EventTone.red,
    amount: amount,
    date: date ?? DateTime(2025, 5, 16),
    method: method,
    book: '我家',
    needReturn: needReturn,
  );
}

void main() {
  test('ledger totals and return suggestions come from real records', () {
    final received = _record(
      id: 'received',
      name: '张晓明',
      direction: GiftDirection.received,
      amount: 800,
      needReturn: true,
    );
    final given = _record(
      id: 'given',
      name: '张晓明',
      direction: GiftDirection.given,
      amount: 600,
      date: DateTime(2024, 10, 3),
    );

    final totals = LedgerTotals.fromRecords([received, given]);
    final suggestion = ReturnGiftAdvisor.forRecord(
      record: received,
      records: [received, given],
    );

    expect(totals.received, 800);
    expect(totals.given, 600);
    expect(totals.balance, 200);
    expect(suggestion.originalAmount, 800);
    expect(suggestion.increasedAmount, 1000);
  });

  testWidgets('enters through onboarding and shows the MVP home surface', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: Scaffold(
          body: OnboardingPage(
            onEnter: () {},
          ),
        ),
      ),
    );

    expect(find.text('入簿'), findsOneWidget);
    expect(find.text('人情往来礼簿'), findsOneWidget);
    expect(find.text('礼有往来，情有分寸'), findsOneWidget);
  });

  testWidgets('home summary responds to the records it receives', (
    tester,
  ) async {
    final records = [
      _record(
        id: 'income',
        name: '甲',
        direction: GiftDirection.received,
        amount: 1200,
      ),
      _record(
        id: 'expense',
        name: '乙',
        direction: GiftDirection.given,
        amount: 300,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: Scaffold(
          body: HomePage(
            records: records,
            onNavigate: (_) {},
            onOpenQuickDesk: () {},
          ),
        ),
      ),
    );

    expect(find.text('1,200'), findsOneWidget);
    expect(find.text('300'), findsOneWidget);
    expect(find.text('+900'), findsOneWidget);
  });

  testWidgets(
    'date ledger line receives its date instead of using a mock date',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: Scaffold(body: DateLedgerLine(date: DateTime(2026, 6, 20))),
        ),
      );

      expect(find.text('2026年6月20日  星期六'), findsOneWidget);
    },
  );

  testWidgets('quick desk undo removes the saved record as well as the row', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final records = <GiftRecord>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: QuickDeskPage(
          records: records,
          onRecordAdded: records.add,
          onRecordRemoved: records.remove,
        ),
      ),
    );

    await tester.enterText(
      find.byKey(const ValueKey('quick-name-field')),
      '陈小东',
    );
    await tester.enterText(
      find.byKey(const ValueKey('quick-amount-field')),
      '600',
    );
    await tester.ensureVisible(find.text('记入并继续'));
    await tester.tap(find.text('记入并继续'));
    await tester.pump();

    expect(records, hasLength(1));
    expect(records.single.partial, isTrue);

    await tester.tap(find.text('撤销'));
    await tester.pump();

    expect(records, isEmpty);
    expect(find.text('陈小东'), findsNothing);
  });

  testWidgets('ledger exposes the pending-return filter from the prototype', (
    tester,
  ) async {
    final pending = _record(
      id: 'pending',
      name: '待回礼的人',
      direction: GiftDirection.received,
      amount: 800,
      needReturn: true,
    );
    final complete = _record(
      id: 'complete',
      name: '普通记录',
      direction: GiftDirection.given,
      amount: 300,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: Scaffold(
          body: LedgerPage(
            records: [pending, complete],
            onRecordAdded: (_) {},
            onRecordUpdated: (_) {},
          ),
        ),
      ),
    );

    await tester.ensureVisible(find.text('待回礼'));
    await tester.tap(find.text('待回礼'));
    await tester.pumpAndSettle();

    expect(find.textContaining('待回礼的人'), findsOneWidget);
    expect(find.text('普通记录'), findsNothing);
  });

  testWidgets('pending pages only expose records that still need action', (
    tester,
  ) async {
    final pendingReturn = _record(
      id: 'return',
      name: '待回礼的人',
      direction: GiftDirection.received,
      amount: 800,
      needReturn: true,
    );
    final partial = _record(
      id: 'partial',
      name: '待补全的人',
      direction: GiftDirection.received,
      amount: 600,
    ).copyWith(partial: true);
    final complete = _record(
      id: 'complete',
      name: '已完成的人',
      direction: GiftDirection.given,
      amount: 300,
    );
    final records = [pendingReturn, partial, complete];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: PendingReturnsPage(
          records: records,
          onRecordAdded: (_) {},
          onRecordUpdated: (_) {},
        ),
      ),
    );
    expect(find.textContaining('待回礼的人'), findsOneWidget);
    expect(find.text('待补全的人'), findsNothing);
    expect(find.text('已完成的人'), findsNothing);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: PendingCompletionsPage(
          records: records,
          onRecordAdded: (_) {},
          onRecordUpdated: (_) {},
        ),
      ),
    );
    expect(find.text('待补全的人'), findsOneWidget);
    expect(find.textContaining('待回礼的人'), findsNothing);
    expect(find.text('已完成的人'), findsNothing);
  });

  testWidgets('gift records require a description and persist it', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    GiftRecord? saved;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: Scaffold(body: AddRecordPage(onSave: (record) => saved = record)),
      ),
    );

    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -350),
    );
    await tester.pumpAndSettle();
    final giftOption = find
        .descendant(
          of: find.byType(ParchmentSegmentedControl<String>),
          matching: find.byType(InkWell),
        )
        .at(1);
    tester.widget<InkWell>(giftOption).onTap!.call();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('add-item-field')), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('add-name-field')), '王阿姨');
    await tester.enterText(
      find.byKey(const ValueKey('add-amount-field')),
      '500',
    );
    await tester.scrollUntilVisible(
      find.text('保存此礼').last,
      300,
      scrollable: find
          .descendant(
            of: find.byType(SingleChildScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    tester.widget<SealButton>(find.byType(SealButton)).onPressed();
    await tester.pump();
    expect(find.text('请填写礼品名称'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('add-item-field')),
      '茶具一套',
    );
    tester.widget<SealButton>(find.byType(SealButton)).onPressed();
    await tester.pump();

    expect(saved, isNotNull);
    expect(saved!.method, '礼品');
    expect(saved!.itemDescription, '茶具一套');
  });

  testWidgets(
    'return choice pre-fills the selected amount instead of a fixed value',
    (tester) async {
      final received = _record(
        id: 'received',
        name: '张晓明',
        direction: GiftDirection.received,
        amount: 800,
        needReturn: true,
      );
      final history = [
        received,
        _record(
          id: 'older',
          name: '张晓明',
          direction: GiftDirection.given,
          amount: 600,
          date: DateTime(2024, 10, 3),
        ),
      ];
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.theme,
          home: RecordDetailPage(
            record: received,
            records: history,
            onRecordAdded: (_) {},
            onRecordUpdated: (_) {},
          ),
        ),
      );

      await tester.tap(find.text('1,000元'));
      await tester.scrollUntilVisible(find.text('记录回礼'), 300);
      await tester.tap(find.text('记录回礼'));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('add-amount-field')))
            .controller!
            .text,
        '1000',
      );
    },
  );

  testWidgets('saving a return archives the original pending reminder', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final received = _record(
      id: 'received',
      name: '张晓明',
      direction: GiftDirection.received,
      amount: 800,
      needReturn: true,
    );
    GiftRecord? added;
    GiftRecord? updated;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: RecordDetailPage(
          record: received,
          records: [received],
          onRecordAdded: (record) => added = record,
          onRecordUpdated: (record) => updated = record,
        ),
      ),
    );

    await tester.scrollUntilVisible(find.text('记录回礼'), 300);
    await tester.tap(find.text('记录回礼'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('保存此礼').last,
      300,
      scrollable: find
          .descendant(
            of: find.byType(SingleChildScrollView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    tester.widget<SealButton>(find.byType(SealButton)).onPressed();
    await tester.pumpAndSettle();

    expect(added, isNotNull);
    expect(added!.direction, GiftDirection.given);
    expect(updated, isNotNull);
    expect(updated!.needReturn, isFalse);
  });

  testWidgets('editing an archived received gift keeps it out of reminders', (
    tester,
  ) async {
    final archived = _record(
      id: 'archived',
      name: '张晓明',
      direction: GiftDirection.received,
      amount: 800,
      needReturn: false,
    );
    GiftRecord? saved;
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.theme,
        home: Scaffold(
          body: AddRecordPage(
            record: archived,
            editExisting: true,
            onSave: (record) => saved = record,
          ),
        ),
      ),
    );

    tester.widget<SealButton>(find.byType(SealButton)).onPressed();
    await tester.pump();

    expect(saved, isNotNull);
    expect(saved!.needReturn, isFalse);
  });
}
