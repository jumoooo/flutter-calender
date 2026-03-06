import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 앱 테마 모드를 관리하는 Provider
///
/// - 시스템 자동(system) / 라이트(light) / 다크(dark) 세 가지 모드 지원
/// - SharedPreferences를 사용하여 앱 재시작 후에도 선택 유지
class ThemeProvider with ChangeNotifier {
  static const String _prefsKey = 'theme_mode';

  /// 현재 선택된 ThemeMode (기본값: 시스템 자동)
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  /// SharedPreferences에서 저장된 테마 설정 로드
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_prefsKey);
      _themeMode = _fromString(savedMode);
      notifyListeners();
    } catch (e) {
      // 로드 실패 시 기본값(system) 유지
      debugPrint('테마 설정 로드 실패: $e');
    }
  }

  /// 테마 모드 변경 및 저장
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;

    _themeMode = mode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, _toString(mode));
    } catch (e) {
      debugPrint('테마 설정 저장 실패: $e');
    }
  }

  /// ThemeMode → 저장용 문자열 변환
  String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// 저장된 문자열 → ThemeMode 변환
  ThemeMode _fromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
