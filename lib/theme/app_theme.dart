import 'package:flutter/material.dart';

/// 앱 전체 테마를 중앙 관리하는 클래스
///
/// Material 3 기반으로 라이트/다크 테마를 정의합니다.
/// 두 테마 모두 동일한 seedColor를 사용하여 색상 조화를 유지합니다.
class AppTheme {
  AppTheme._(); // 인스턴스 생성 방지

  /// 테마 기본 색상 (씨드 컬러)
  static const Color _seedColor = Color(0xFF4A90D9); // 파스텔 블루

  // ─── 라이트 테마 ────────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ),
        // AppBar 스타일
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        // Card 스타일
        cardTheme: const CardThemeData(
          elevation: 1,
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        // InputDecoration 스타일
        // 라이트 모드: fillColor를 흰색으로 명시 (기본값 surfaceContainerHighest 는 회색이라 어두워 보임)
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        // FloatingActionButton 스타일
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 2,
        ),
      );

  // ─── 다크 테마 ─────────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
        // AppBar 스타일
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 1,
        ),
        // Card 스타일
        cardTheme: const CardThemeData(
          elevation: 1,
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        // InputDecoration 스타일
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
        ),
        // FloatingActionButton 스타일
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 2,
        ),
      );
}
