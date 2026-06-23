import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/errors/logger.dart';
import '../../core/utils/date_utils.dart';
import '../entities/reminder.dart';

/// A-4 本地通知调度
///
/// 适配 iOS / Android：
/// - iOS：需要请求权限（flutter_local_notifications 内部请求）
/// - Android 13+：需要 POST_NOTIFICATIONS 权限
///
/// 红/白榜分别有 channel（Android 区分 importance / sound）
class ReminderScheduler {
  ReminderScheduler({
    FlutterLocalNotificationsPlugin? plugin,
    SharedPreferences? prefs,
  })  : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
        _prefsFuture =
            prefs == null ? SharedPreferences.getInstance() : Future.value(prefs);

  final FlutterLocalNotificationsPlugin _plugin;
  final Future<SharedPreferences> _prefsFuture;
  bool _initialized = false;

  static const String _kPermissionAsked = 'notification.permission.asked';

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    try {
      tzdata.initializeTimeZones();
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      const androidInit =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      await _plugin.initialize(
        const InitializationSettings(
          iOS: iosInit,
          android: androidInit,
        ),
      );
      if (Platform.isAndroid) {
        await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(_redChannel);
        await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(_whiteChannel);
      }
    } catch (e, st) {
      AppLogger.instance.e('通知插件初始化失败', error: e, stack: st);
      throw NotificationException(
        '通知插件初始化失败',
        cause: e,
        stackTrace: st,
      );
    }
  }

  /// 请求权限；记录是否已询问过（避免反复弹窗）
  Future<NotificationPermissionResult> requestPermission() async {
    try {
      final prefs = await _prefsFuture;
      if (Platform.isIOS) {
        final granted = await _plugin
                .resolvePlatformSpecificImplementation<
                    IOSFlutterLocalNotificationsPlugin>()
                ?.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
        await prefs.setBool(_kPermissionAsked, true);
        return granted
            ? NotificationPermissionResult.granted
            : NotificationPermissionResult.denied;
      }
      if (Platform.isAndroid) {
        final status = await Permission.notification.request();
        await prefs.setBool(_kPermissionAsked, true);
        return switch (status) {
          PermissionStatus.granted ||
          PermissionStatus.limited =>
            NotificationPermissionResult.granted,
          PermissionStatus.permanentlyDenied =>
            NotificationPermissionResult.permanentlyDenied,
          _ => NotificationPermissionResult.denied,
        };
      }
      return NotificationPermissionResult.granted;
    } catch (e, st) {
      AppLogger.instance.e('请求通知权限失败', error: e, stack: st);
      throw NotificationException(
        '请求通知权限失败',
        cause: e,
        stackTrace: st,
      );
    }
  }

  Future<bool> hasAsked() async {
    final prefs = await _prefsFuture;
    return prefs.getBool(_kPermissionAsked) ?? false;
  }

  /// 调度一条本地通知。remindAt 必须晚于当前时刻。
  Future<void> schedule(Reminder reminder) async {
    if (reminder.status != ReminderStatus.pending) return;
    if (reminder.remindAt.isBefore(DateTime.now())) {
      AppLogger.instance.w('跳过过期提醒 id=${reminder.id}');
      return;
    }
    try {
      final details = _details(reminder);
      await _plugin.zonedSchedule(
        _idFromReminder(reminder),
        reminder.title,
        '${AppDateUtils.chinese(reminder.date)} · ${reminder.note ?? ''}',
        _nextInstanceOf(reminder.remindAt),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: reminder.id,
      );
    } catch (e, st) {
      AppLogger.instance.e('调度通知失败', error: e, stack: st);
      throw NotificationException('调度通知失败', cause: e, stackTrace: st);
    }
  }

  Future<void> cancel(String reminderId) async {
    try {
      await _plugin.cancel(_idFromReminderId(reminderId));
    } catch (e, st) {
      AppLogger.instance.e('取消通知失败', error: e, stack: st);
    }
  }

  NotificationDetails _details(Reminder reminder) {
    final isRed = reminder.note?.contains('白事') != true;
    if (Platform.isAndroid) {
      return NotificationDetails(
        android: AndroidNotificationDetails(
          isRed
              ? AppConstants.notificationChannelRedId
              : AppConstants.notificationChannelWhiteId,
          isRed ? '红榜提醒' : '白榜提醒',
          channelDescription: isRed ? '喜事、满月、回礼等' : '白事、奠仪等',
          importance: Importance.high,
          priority: Priority.high,
        ),
      );
    }
    return const NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  int _idFromReminder(Reminder r) => _idFromReminderId(r.id);
  int _idFromReminderId(String id) => id.hashCode & 0x7fffffff;

  tz.TZDateTime _nextInstanceOf(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  static const AndroidNotificationChannel _redChannel =
      AndroidNotificationChannel(
    AppConstants.notificationChannelRedId,
    '红榜提醒',
    description: '婚礼、满月、乔迁、回礼等',
    importance: Importance.high,
  );
  static const AndroidNotificationChannel _whiteChannel =
      AndroidNotificationChannel(
    AppConstants.notificationChannelWhiteId,
    '白榜提醒',
    description: '白事、奠仪等',
    importance: Importance.high,
  );

  @visibleForTesting
  static AndroidNotificationChannel get redChannelForTest => _redChannel;
  @visibleForTesting
  static AndroidNotificationChannel get whiteChannelForTest => _whiteChannel;
}

/// 权限询问结果（A-9：可据此走兜底 UI）
enum NotificationPermissionResult {
  granted,
  denied,
  permanentlyDenied,
}