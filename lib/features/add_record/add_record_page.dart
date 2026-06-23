import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../main.dart' as app;

class AddRecordPage extends ConsumerWidget {
  const AddRecordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return app.AddRecordPage(
      onSave: (record) async {
        await ref.read(giftRecordRepositoryProvider).upsert(record);
      },
      onBack: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}