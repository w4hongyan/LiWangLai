import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/types.dart';
import '../../main.dart' as app;

class SearchOldPage extends ConsumerWidget {
  const SearchOldPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(recordsStreamProvider);
    final records = recordsAsync.maybeWhen<List<app.GiftRecord>>(
      data: (list) => list,
      orElse: () => const <app.GiftRecord>[],
    );
    return app.SearchOldPage(
      records: records,
      onRecordAdded: (record) async {
        await ref.read(giftRecordRepositoryProvider).upsert(record);
      },
      onRecordUpdated: (record) async {
        await ref.read(giftRecordRepositoryProvider).upsert(record);
      },
    );
  }
}