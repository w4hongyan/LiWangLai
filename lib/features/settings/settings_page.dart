import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_palette.dart';
import '../../domain/services/export_service.dart';
import '../../domain/services/reminder_scheduler.dart';
import '../../main.dart' as app;

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _privacyLock = true;
  bool _hideAmounts = false;
  bool _funeralPrivacy = false;
  bool _notifications = true;
  bool _exporting = false;
  bool _importing = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final privacy = ref.read(privacyServiceProvider);
    final enabled = await privacy.isEnabled();
    if (!mounted) return;
    setState(() {
      _privacyLock = enabled;
      _hideAmounts = prefs.getBool('settings.hideAmounts') ?? false;
      _funeralPrivacy = prefs.getBool('settings.funeralPrivacy') ?? false;
      _notifications = prefs.getBool('settings.notifications') ?? true;
    });
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setBool(key, value);
  }

  Future<void> _export(ExportFormat format) async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final records = await ref.read(giftRecordRepositoryProvider).listAll();
      final service = ref.read(exportServiceProvider);
      final result = switch (format) {
        ExportFormat.json => await service.exportToJson(records),
        ExportFormat.csv => await service.exportToCsv(records),
        ExportFormat.pdf => await service.exportToPdf(records),
      };
      if (!mounted) return;
      await service.share(result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('导出失败：$e')));
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _importJson() async {
    if (_importing) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('导入 JSON 备份'),
        content: const Text(
          '导入将合并到当前礼簿中，不会覆盖已有记录。是否继续？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('继续导入'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() => _importing = true);
    try {
      final service = ref.read(exportServiceProvider);
      final records = await service.pickAndImportJson();
      if (!mounted) return;

      if (records.isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('未选择文件或文件中无记录')));
        return;
      }

      final repo = ref.read(giftRecordRepositoryProvider);
      var imported = 0;
      for (final record in records) {
        await repo.upsert(record);
        imported++;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('成功导入 $imported 条记录')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('导入失败：$e')),
      );
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  Future<void> _requestNotificationPermission() async {
    final scheduler = ref.read(reminderSchedulerProvider);
    final result = await scheduler.requestPermission();
    if (!mounted) return;
    final label = switch (result) {
      NotificationPermissionResult.granted => '通知权限已开启',
      NotificationPermissionResult.denied => '通知权限被拒，可在系统设置开启',
      NotificationPermissionResult.permanentlyDenied =>
        '通知权限已永久拒绝，请到系统设置中开启',
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(label)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.paper,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                children: [
                  _buildSection(
                    title: '账本管理',
                    children: [
                      _SettingsRow(
                        icon: CupertinoIcons.book,
                        title: '当前账本',
                        value: '张晓明家庭礼簿',
                      ),
                      _SettingsRow(
                        icon: CupertinoIcons.cloud_download,
                        title: '本地备份与恢复',
                        onTap: _importJson,
                      ),
                      _SettingsRow(
                        icon: CupertinoIcons.square_arrow_up,
                        title: '导出礼簿',
                        onTap: _exporting ? null : () => _export(ExportFormat.json),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildSection(
                    title: '隐私与安全',
                    children: [
                      _SettingsToggleRow(
                        icon: CupertinoIcons.lock,
                        title: '隐私锁',
                        subtitle: _privacyLock ? '已开启' : '未开启',
                        value: _privacyLock,
                        onChanged: (v) async {
                          await ref.read(privacyServiceProvider).setEnabled(v);
                          if (!mounted) return;
                          setState(() => _privacyLock = v);
                        },
                      ),
                      _SettingsToggleRow(
                        icon: CupertinoIcons.eye_slash,
                        title: '金额隐藏',
                        subtitle: '在礼簿列表中隐藏金额',
                        value: _hideAmounts,
                        onChanged: (v) {
                          setState(() => _hideAmounts = v);
                          _saveBool('settings.hideAmounts', v);
                        },
                      ),
                      _SettingsToggleRow(
                        icon: CupertinoIcons.shield,
                        title: '白榜隐私保护',
                        subtitle: '白事记录仅在礼簿内显示',
                        value: _funeralPrivacy,
                        onChanged: (v) {
                          setState(() => _funeralPrivacy = v);
                          _saveBool('settings.funeralPrivacy', v);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildSection(
                    title: '个性化与通知',
                    children: [
                      _SettingsRow(
                        icon: CupertinoIcons.paintbrush,
                        title: '主题风格',
                        value: '杏花红',
                        showDot: true,
                      ),
                      _SettingsToggleRow(
                        icon: CupertinoIcons.bell,
                        title: '通知提醒',
                        subtitle: _notifications ? '已开启' : '已关闭',
                        value: _notifications,
                        onChanged: (v) async {
                          setState(() => _notifications = v);
                          _saveBool('settings.notifications', v);
                          if (v) {
                            await _requestNotificationPermission();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildSection(
                    title: '关于与帮助',
                    children: [
                      _SettingsRow(
                        icon: CupertinoIcons.info_circle,
                        title: '关于礼往来',
                        value: 'MVP 1.0.0',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildProPanel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -18,
            top: 10,
            child: Opacity(
              opacity: 0.18,
              child: Image.asset(
                'assets/images/home_landscape_pavilion_plum.png',
                width: 220,
                fit: BoxFit.contain,
              ),
            ),
          ),
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
                '设置与隐私',
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

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('✣', style: TextStyle(color: AppPalette.palaceRed)),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                fontFamily: app.AppFonts.kaiti,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppPalette.ink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppPalette.whiteTone.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppPalette.line.withValues(alpha: 0.58)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildProPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E7).withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppPalette.gold.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(CupertinoIcons.star, color: AppPalette.palaceRed, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '礼往来 Pro',
                      style: TextStyle(
                        color: AppPalette.rouge,
                        fontFamily: app.AppFonts.kaiti,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '解锁更多高级功能，礼往来更懂你',
                      style: TextStyle(
                        color: AppPalette.mutedInk,
                        fontFamily: app.AppFonts.kaiti,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: _ProBenefit(icon: CupertinoIcons.book, text: '多账本管理'),
              ),
              Expanded(
                child: _ProBenefit(
                    icon: CupertinoIcons.cloud, text: '云端备份'),
              ),
              Expanded(
                child: _ProBenefit(
                    icon: CupertinoIcons.chart_bar, text: '智能统计'),
              ),
              Expanded(
                child: _ProBenefit(
                    icon: CupertinoIcons.paintbrush, text: '专属主题'),
              ),
              Expanded(
                child: _ProBenefit(
                    icon: CupertinoIcons.headphones, text: '优先客服'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 44,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Pro 功能开发中'),
                    content: const Text(
                      'Pro 多账本、云端备份、智能统计等功能正在开发中，敬请期待。',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('知道了'),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.palaceRed,
                foregroundColor: const Color(0xFFFFE3B0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
              child: const Text(
                '查看会员权益 >',
                style: TextStyle(
                  fontFamily: app.AppFonts.kaiti,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProBenefit extends StatelessWidget {
  const _ProBenefit({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF8A642F), size: 20),
        const SizedBox(height: 4),
        Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppPalette.mutedInk,
            fontFamily: app.AppFonts.kaiti,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 54,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppPalette.line.withValues(alpha: 0.4),
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppPalette.whiteTone.withValues(alpha: 0.7),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppPalette.gold.withValues(alpha: 0.5),
                ),
              ),
              child: Icon(icon, color: const Color(0xFF8A642F), size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppPalette.ink,
                  fontFamily: app.AppFonts.kaiti,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (value != null) ...[
              Text(
                value!,
                style: const TextStyle(
                  color: AppPalette.mutedInk,
                  fontFamily: app.AppFonts.kaiti,
                  fontSize: 13,
                ),
              ),
              if (showDot) ...[
                const SizedBox(width: 6),
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppPalette.palaceRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
              const SizedBox(width: 6),
            ],
            Icon(
              CupertinoIcons.chevron_right,
              color: AppPalette.mutedInk.withValues(alpha: 0.7),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsToggleRow extends StatelessWidget {
  const _SettingsToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppPalette.line.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppPalette.whiteTone.withValues(alpha: 0.7),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppPalette.gold.withValues(alpha: 0.5),
              ),
            ),
            child: Icon(icon, color: const Color(0xFF8A642F), size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppPalette.ink,
                    fontFamily: app.AppFonts.kaiti,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppPalette.mutedInk,
                    fontFamily: app.AppFonts.kaiti,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppPalette.palaceRed,
          ),
        ],
      ),
    );
  }
}
