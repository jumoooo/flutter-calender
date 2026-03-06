// ThemeProvider 유닛 테스트
//
// SharedPreferences를 실제로 사용하지 않고,
// SharedPreferences.setMockInitialValues()를 활용하여 테스트합니다.
// (flutter_test가 기본으로 SharedPreferences 모킹을 지원합니다)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_calender/providers/theme_provider.dart';

void main() {
  // ✅ 각 테스트 전에 SharedPreferences 초기값 초기화
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ThemeProvider 초기화 테스트', () {
    test('저장된 값 없을 때 기본값은 ThemeMode.system', () async {
      final provider = ThemeProvider();
      await provider.initialize();

      expect(provider.themeMode, ThemeMode.system);
    });

    test('저장된 값이 light이면 ThemeMode.light 로드', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'light'});

      final provider = ThemeProvider();
      await provider.initialize();

      expect(provider.themeMode, ThemeMode.light);
    });

    test('저장된 값이 dark이면 ThemeMode.dark 로드', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});

      final provider = ThemeProvider();
      await provider.initialize();

      expect(provider.themeMode, ThemeMode.dark);
    });

    test('저장된 값이 system이면 ThemeMode.system 로드', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'system'});

      final provider = ThemeProvider();
      await provider.initialize();

      expect(provider.themeMode, ThemeMode.system);
    });

    test('알 수 없는 값이면 ThemeMode.system 으로 fallback', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'unknown_value'});

      final provider = ThemeProvider();
      await provider.initialize();

      expect(provider.themeMode, ThemeMode.system);
    });
  });

  group('ThemeProvider 변경 테스트', () {
    test('setThemeMode(dark) 호출 시 themeMode가 dark로 변경', () async {
      final provider = ThemeProvider();
      await provider.initialize();

      await provider.setThemeMode(ThemeMode.dark);

      expect(provider.themeMode, ThemeMode.dark);
    });

    test('setThemeMode 후 SharedPreferences에 저장됨', () async {
      final provider = ThemeProvider();
      await provider.initialize();
      await provider.setThemeMode(ThemeMode.light);

      // 새 인스턴스로 로드하여 저장 여부 확인
      final provider2 = ThemeProvider();
      await provider2.initialize();

      expect(provider2.themeMode, ThemeMode.light);
    });

    test('동일한 모드를 다시 설정해도 오류 없이 처리', () async {
      final provider = ThemeProvider();
      await provider.initialize();
      await provider.setThemeMode(ThemeMode.system);

      // 같은 값 재설정 — notifyListeners 불필요하므로 단순히 오류 없이 완료되어야 함
      await provider.setThemeMode(ThemeMode.system);

      expect(provider.themeMode, ThemeMode.system);
    });

    test('light → dark → system 순서로 변경', () async {
      final provider = ThemeProvider();
      await provider.initialize();

      await provider.setThemeMode(ThemeMode.light);
      expect(provider.themeMode, ThemeMode.light);

      await provider.setThemeMode(ThemeMode.dark);
      expect(provider.themeMode, ThemeMode.dark);

      await provider.setThemeMode(ThemeMode.system);
      expect(provider.themeMode, ThemeMode.system);
    });

    test('notifyListeners가 호출되어 리스너가 변경을 감지', () async {
      final provider = ThemeProvider();
      await provider.initialize();

      int notifyCount = 0;
      provider.addListener(() => notifyCount++);

      await provider.setThemeMode(ThemeMode.dark);
      expect(notifyCount, 1);

      await provider.setThemeMode(ThemeMode.light);
      expect(notifyCount, 2);

      // 동일한 값 재설정 시 notifyListeners 호출 안 됨
      await provider.setThemeMode(ThemeMode.light);
      expect(notifyCount, 2);
    });
  });
}
