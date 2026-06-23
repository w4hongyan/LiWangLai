import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../domain/entities/gift_record.dart';
import '../../main.dart' as app;

/// /home 首页（A-1 接通 recordsStreamProvider，验收：A-9 错误兜底）
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(recordsStreamProvider);

    final records = recordsAsync.when<List<GiftRecord>>(
      data: (list) => list,
      loading: () => const <GiftRecord>[],
      error: (_, _) => const <GiftRecord>[],
    );

    return app.HomePage(
      records: records,
      onNavigate: (i) {
        ref.read(homeTabIndexProvider.notifier).state = i;
      },
      onOpenQuickDesk: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const QuickDeskRoutePage(),
          ),
        );
      },
    );
  }
}

/// 给原 HomePage 提供 upcoming reminders（保持旧 API 不破）
class QuickDeskRoutePage extends ConsumerWidget {
  const QuickDeskRoutePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(recordsStreamProvider);
    final records = recordsAsync.maybeWhen<List<GiftRecord>>(
      data: (list) => list,
      orElse: () => const <GiftRecord>[],
    );
    return app.QuickDeskPage(
      records: records,
      onRecordAdded: (record) async {
        await ref.read(giftRecordRepositoryProvider).upsert(record);
      },
      onRecordRemoved: (record) async {
        await ref.read(giftRecordRepositoryProvider).softDelete(record.id);
      },
    );
  }
}