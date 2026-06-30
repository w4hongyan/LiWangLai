import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../app/providers.dart';
import '../../core/theme/app_palette.dart';
import '../../core/types.dart';
import '../../main.dart' as app;

/// 账本管理页：查看所有账本、创建新账本、切换当前账本
class LedgerBookManagementPage extends ConsumerWidget {
  const LedgerBookManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(ledgerBooksStreamProvider);
    final currentId = ref.watch(currentLedgerBookIdProvider);

    return Scaffold(
      backgroundColor: AppPalette.paper,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: booksAsync.when(
                data: (books) {
                  if (books.isEmpty) {
                    return const Center(
                      child: Text(
                        '暂无账本',
                        style: TextStyle(
                          color: AppPalette.mutedInk,
                          fontFamily: app.AppFonts.kaiti,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 96),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      final isCurrent = book.id == currentId;
                      return _LedgerBookRow(
                        book: book,
                        isCurrent: isCurrent,
                        onTap: () {
                          ref.read(currentLedgerBookIdProvider.notifier).state =
                              book.id;
                          ref.read(selectedBookIdProvider.notifier).state =
                              book.id;
                        },
                      );
                    },
                  );
                },
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('加载失败: $e')),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppPalette.palaceRed,
        onPressed: () => _showCreateDialog(context, ref),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 8,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                CupertinoIcons.chevron_left,
                color: AppPalette.ink,
                size: 24,
              ),
            ),
          ),
          const Positioned.fill(
            top: 20,
            child: Align(
              alignment: Alignment.topCenter,
              child: Text(
                '账本管理',
                style: TextStyle(
                  fontFamily: app.AppFonts.kaiti,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppPalette.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建账本'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '请输入账本名称',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isEmpty) return;
              final repo = ref.read(ledgerBookRepositoryProvider);
              final book = LedgerBook(
                id: const Uuid().v4(),
                name: name,
                type: LedgerBookType.family,
                themeId: 'apricot_red',
                isDefault: false,
                isArchived: false,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              await repo.upsert(book);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }
}

class _LedgerBookRow extends StatelessWidget {
  const _LedgerBookRow({
    required this.book,
    required this.isCurrent,
    required this.onTap,
  });

  final LedgerBook book;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isCurrent
              ? AppPalette.palaceRed.withValues(alpha: 0.08)
              : AppPalette.whiteTone.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCurrent
                ? AppPalette.palaceRed.withValues(alpha: 0.4)
                : AppPalette.line.withValues(alpha: 0.58),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isCurrent
                    ? AppPalette.palaceRed.withValues(alpha: 0.15)
                    : AppPalette.whiteTone,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrent
                      ? AppPalette.palaceRed.withValues(alpha: 0.4)
                      : AppPalette.line,
                ),
              ),
              child: Icon(
                CupertinoIcons.book,
                color: isCurrent ? AppPalette.palaceRed : AppPalette.mutedInk,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                book.name,
                style: TextStyle(
                  fontFamily: app.AppFonts.kaiti,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isCurrent ? AppPalette.palaceRed : AppPalette.ink,
                ),
              ),
            ),
            if (isCurrent)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppPalette.palaceRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '当前',
                  style: TextStyle(
                    color: AppPalette.palaceRed,
                    fontFamily: app.AppFonts.kaiti,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
