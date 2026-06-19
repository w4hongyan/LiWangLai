import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:liwanglai/main.dart';

void main() {
  testWidgets('enters the app and shows the MVP home surface', (tester) async {
    await tester.pumpWidget(const LiWangLaiApp());

    expect(find.text('人情往来礼簿'), findsOneWidget);
    expect(find.text('6,800'), findsOneWidget);
    expect(find.text('查往来'), findsWidgets);
    expect(find.text('礼台模式'), findsWidgets);
  });

  testWidgets('quick desk saves a partial gift record', (tester) async {
    await tester.pumpWidget(const LiWangLaiApp());

    await tester.tap(find.text('礼台模式').first);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('quick-name-field')),
      '陈小东',
    );
    await tester.enterText(
      find.byKey(const ValueKey('quick-amount-field')),
      '600',
    );
    await tester.ensureVisible(find.text('记入并继续'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('记入并继续'));
    await tester.pump();

    expect(find.text('已入簿'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('陈小东'), findsOneWidget);
    expect(find.textContaining('+600'), findsOneWidget);
    expect(find.text('待补全'), findsWidgets);
  });
}
