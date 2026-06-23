import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/theme/app_palette.dart';

/// /lock  隐私锁屏（A-3）
class LockPage extends ConsumerStatefulWidget {
  const LockPage({super.key});

  @override
  ConsumerState<LockPage> createState() => _LockPageState();
}

class _LockPageState extends ConsumerState<LockPage> {
  bool _authenticating = false;
  String? _errorText;

  Future<void> _unlock() async {
    if (_authenticating) return;
    setState(() {
      _authenticating = true;
      _errorText = null;
    });
    try {
      final ok = await ref
          .read(privacyServiceProvider)
          .authenticate(reason: '解锁礼往来');
      if (!mounted) return;
      if (ok) {
        context.go('/home');
      } else {
        setState(() => _errorText = '未能解锁，请重试');
      }
    } catch (e) {
      setState(() => _errorText = '解锁失败：$e');
    } finally {
      if (mounted) setState(() => _authenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.paper,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '礼往来',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppPalette.ink,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '人情往来礼簿',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppPalette.mutedInk,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 48),
                const Icon(Icons.lock_outline,
                    size: 48, color: AppPalette.palaceRed),
                const SizedBox(height: 16),
                const Text(
                  '请解锁以查看礼簿',
                  style: TextStyle(color: AppPalette.mutedInk),
                ),
                if (_errorText != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorText!,
                    style: const TextStyle(color: AppPalette.cinnabar),
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: 220,
                  child: FilledButton(
                    onPressed: _authenticating ? null : _unlock,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppPalette.palaceRed,
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(_authenticating ? '正在解锁…' : '解锁'),
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