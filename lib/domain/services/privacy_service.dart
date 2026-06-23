import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/errors/app_exception.dart';
import '../../core/errors/logger.dart';

/// A-3 隐私锁
///
/// - 默认开启 Face ID / 密码锁
/// - 后台→前台超过 gracePeriod 触发再锁
/// - 失败次数计数：3 次失败后强制走系统密码
class PrivacyService extends ChangeNotifier {
  PrivacyService({
    LocalAuthentication? auth,
    SharedPreferences? prefs,
    this.gracePeriod = const Duration(seconds: 30),
  })  : _auth = auth ?? LocalAuthentication(),
        _prefsFuture = prefs == null
            ? SharedPreferences.getInstance()
            : Future.value(prefs);

  final LocalAuthentication _auth;
  final Future<SharedPreferences> _prefsFuture;
  final Duration gracePeriod;

  bool _locked = false;
  int _failCount = 0;

  bool get locked => _locked;
  int get failCount => _failCount;

  /// 应用启动后是否启用隐私锁（持久化）
  Future<bool> isEnabled() async {
    final prefs = await _prefsFuture;
    return prefs.getBool(_kEnabled) ?? true;
  }

  Future<void> setEnabled(bool value) async {
    final prefs = await _prefsFuture;
    await prefs.setBool(_kEnabled, value);
    if (!value) {
      _locked = false;
      notifyListeners();
    } else {
      _locked = true;
      notifyListeners();
    }
  }

  /// App 启动时调用：默认锁住
  void lock() {
    if (_locked) return;
    _locked = true;
    notifyListeners();
  }

  /// App 从后台回到前台时调用：判断是否需要再锁
  void onResume(DateTime lastBackgroundedAt) {
    if (DateTime.now().difference(lastBackgroundedAt) >= gracePeriod) {
      _locked = true;
      notifyListeners();
    }
  }

  /// 用户尝试解锁
  Future<bool> authenticate({String? reason}) async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) {
        // 设备不支持生物识别（模拟器）也算解锁成功，避免死锁
        AppLogger.instance.w('设备不支持生物识别，跳过认证');
        _locked = false;
        _failCount = 0;
        notifyListeners();
        return true;
      }
      final ok = await _auth.authenticate(
        localizedReason: reason ?? '解锁礼往来',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      if (ok) {
        _locked = false;
        _failCount = 0;
        notifyListeners();
        return true;
      }
      _failCount++;
      notifyListeners();
      return false;
    } catch (e, st) {
      AppLogger.instance.e('认证失败', error: e, stack: st);
      throw AuthException('认证失败', cause: e, stackTrace: st);
    }
  }

  static const String _kEnabled = 'privacy.lock.enabled';
}