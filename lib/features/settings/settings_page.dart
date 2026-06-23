import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/theme/app_palette.dart';
import '../../domain/services/export_service.dart';
import '../../domain/services/reminder_scheduler.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _privacyLock = true;
  bool _notifications = true;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final privacy = ref.read(privacyServiceProvider);
    final enabled = await privacy.isEnabled();
    if (!mounted) return;
    setState(() => _privacyLock = enabled);
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
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: AppPalette.paper,
        elevation: 0,
        foregroundColor: AppPalette.ink,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('隐私锁'),
            subtitle: const Text('每次启动 / 离开 30s 后需解锁'),
            value: _privacyLock,
            onChanged: (v) async {
              await ref.read(privacyServiceProvider).setEnabled(v);
              if (!mounted) return;
              setState(() => _privacyLock = v);
            },
          ),
          SwitchListTile(
            title: const Text('通知提醒'),
            subtitle: const Text('回礼前 N 天、亲友生日 / 白事周年'),
            value: _notifications,
            onChanged: (v) async {
              setState(() => _notifications = v);
              if (v) {
                await _requestNotificationPermission();
              }
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('导出 JSON 备份'),
            subtitle: const Text('全量备份，用于跨设备恢复'),
            enabled: !_exporting,
            onTap: () => _export(ExportFormat.json),
          ),
          ListTile(
            title: const Text('导出 CSV 礼簿'),
            subtitle: const Text('Excel 直接打开'),
            enabled: !_exporting,
            onTap: () => _export(ExportFormat.csv),
          ),
          ListTile(
            title: const Text('导出 PDF 年度礼簿'),
            subtitle: const Text('按月份分组的可读版本'),
            enabled: !_exporting,
            onTap: () => _export(ExportFormat.pdf),
          ),
        ],
      ),
    );
  }
}