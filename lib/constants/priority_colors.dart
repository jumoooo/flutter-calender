import 'package:flutter/material.dart';
import 'package:flutter_calender/models/todo.dart';

/// 우선순위 색상 상수
/// 
/// 앱 전반에서 사용되는 우선순위별 색상을 중앙에서 관리합니다.
/// uiStyleRefiner 문서에 정의된 표준 파스텔 색상 팔레트를 사용합니다.
class PriorityColors {
  // Private 생성자로 인스턴스화 방지
  PriorityColors._();

  /// 매우 높은 우선순위 색상 (파스텔 핑크/로즈)
  static const Color veryHigh = Color(0xFFFF6B9D);

  /// 높은 우선순위 색상 (파스텔 코랄/피치)
  static const Color high = Color(0xFFFFA07A);

  /// 보통 우선순위 색상 (파스텔 블루)
  static const Color normal = Color(0xFF9BB5FF);

  /// 낮은 우선순위 색상 (파스텔 라이트 그린)
  static const Color low = Color(0xFF90EE90);

  /// 매우 낮은 우선순위 색상 (파스텔 라이트 그레이)
  static const Color veryLow = Color(0xFFD3D3D3);

  /// 우선순위에 따른 색상 반환
  static Color getColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.veryHigh:
        return veryHigh;
      case TodoPriority.high:
        return high;
      case TodoPriority.normal:
        return normal;
      case TodoPriority.low:
        return low;
      case TodoPriority.veryLow:
        return veryLow;
    }
  }

  /// 우선순위 단축 한글 레이블 — 배지/칩 등 좁은 공간에 사용
  ///
  /// 예: 최상, 상, 중, 하, 최하
  static String label(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.veryHigh:
        return '최상';
      case TodoPriority.high:
        return '상';
      case TodoPriority.normal:
        return '중';
      case TodoPriority.low:
        return '하';
      case TodoPriority.veryLow:
        return '최하';
    }
  }

  /// 우선순위 전체 한글 레이블 — 필터 칩 등 공간이 충분한 곳에 사용
  ///
  /// 예: 매우높음, 높음, 보통, 낮음, 매우낮음
  static String labelFull(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.veryHigh:
        return '매우높음';
      case TodoPriority.high:
        return '높음';
      case TodoPriority.normal:
        return '보통';
      case TodoPriority.low:
        return '낮음';
      case TodoPriority.veryLow:
        return '매우낮음';
    }
  }
}
