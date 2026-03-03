import 'package:flutter/foundation.dart';
import 'package:flutter_calender/utils/date_utils.dart' as korean_date;

/// 캘린더 상태 관리 Provider
///
/// - 선택된 날짜/월 상태 관리
/// - 날짜/월 이동 시에는 항상 해당 월로 동기화
/// - 앱 최초 진입 시에만 짧게 스켈레톤을 보여주고,
///   이후에는 스켈레톤이 다시 뜨지 않도록 제어
class CalendarProvider with ChangeNotifier {
  /// 앱 최초 진입 시 스켈레톤을 한 번만 보여주기 위한 플래그
  bool _initialSkeletonStarted = false;

  /// 현재 선택된 날짜
  DateTime _selectedDate = DateTime.now();

  /// 현재 표시 중인 월
  DateTime _currentMonth = DateTime.now();

  /// 화면 전환 중인지 여부 (스켈레톤 표시용)
  bool _isTransitioning = false;

  /// 월 전환 시 애니메이션 방향
  ///
  /// -1: 이전 달(오른쪽에서 왼쪽으로 이동)
  ///  1: 다음 달(왼쪽에서 오른쪽으로 이동)
  ///  0: 방향 없음/초기 상태
  int _monthSlideDirection = 0;

  /// 현재 선택된 날짜 getter
  DateTime get selectedDate => _selectedDate;

  /// 현재 표시 중인 월 getter
  DateTime get currentMonth => _currentMonth;

  /// 전환 중 여부 getter
  bool get isTransitioning => _isTransitioning;

  /// 월 전환 애니메이션 방향 getter
  int get monthSlideDirection => _monthSlideDirection;

  /// 선택된 날짜를 한국어 형식으로 반환 (예: "2026년 3월 15일")
  String get selectedDateFormatted =>
      korean_date.KoreanDateUtils.formatKoreanDate(_selectedDate);

  /// 현재 표시 중인 월을 한국어 형식으로 반환 (예: "2026년 3월")
  String get currentMonthFormatted =>
      korean_date.KoreanDateUtils.formatKoreanMonth(_currentMonth);

  /// 생성자에서 최초 진입 시 한 번만 스켈레톤을 잠깐 보여줌
  CalendarProvider() {
    _startInitialSkeleton();
  }

  /// 앱이 처음 열렸을 때만 짧게 스켈레톤을 보여주는 헬퍼
  ///
  /// - isTransitioning = true 로 설정 후 약간의 지연 뒤 false 로 되돌림
  /// - 한 번 실행되면 다시는 실행되지 않도록 플래그로 제어
  Future<void> _startInitialSkeleton() async {
    if (_initialSkeletonStarted) return;
    _initialSkeletonStarted = true;

    _isTransitioning = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 250));

    _isTransitioning = false;
    notifyListeners();
  }

  /// 내부 헬퍼: 상태 변경용 공통 로직
  ///
  /// - 이후 전환에서는 별도의 로딩 스켈레톤을 사용하지 않고
  ///   단순히 상태만 변경하도록 유지
  Future<void> _runWithTransition(void Function() action) async {
    action();
    notifyListeners();
  }

  /// 날짜 선택
  ///
  /// - 선택된 날짜를 변경
  /// - 동시에 currentMonth 를 해당 날짜의 월로 동기화
  Future<void> selectDate(DateTime date) async {
    await _runWithTransition(() {
      // 단순 날짜 선택은 월 슬라이드 방향 없음으로 처리
      _monthSlideDirection = 0;
      _selectedDate = date;
      _currentMonth = DateTime(date.year, date.month, 1);
    });
  }

  /// 이전 달로 이동
  Future<void> previousMonth() async {
    await _runWithTransition(() {
      // 이전 달로 이동 → 오른쪽에서 왼쪽으로 넘어가는 느낌 (-1)
      _monthSlideDirection = -1;
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month - 1,
        1,
      );

      final now = DateTime.now();
      final isCurrentMonthHasToday =
          _currentMonth.year == now.year && _currentMonth.month == now.month;

      // 이전/다음 달로 이동 시:
      // - 해당 달이 오늘을 포함하고 있으면 오늘 날짜로 선택
      // - 그렇지 않으면 1일을 기본 선택으로 설정
      _selectedDate = isCurrentMonthHasToday
          ? now
          : DateTime(_currentMonth.year, _currentMonth.month, 1);
    });
  }

  /// 다음 달로 이동
  Future<void> nextMonth() async {
    await _runWithTransition(() {
      // 다음 달로 이동 → 왼쪽에서 오른쪽으로 넘어가는 느낌 (1)
      _monthSlideDirection = 1;
      _currentMonth = DateTime(
        _currentMonth.year,
        _currentMonth.month + 1,
        1,
      );

      final now = DateTime.now();
      final isCurrentMonthHasToday =
          _currentMonth.year == now.year && _currentMonth.month == now.month;

      // 다음 달로 이동 시도 동일한 규칙 적용
      _selectedDate = isCurrentMonthHasToday
          ? now
          : DateTime(_currentMonth.year, _currentMonth.month, 1);
    });
  }

  /// 특정 월로 이동
  Future<void> goToMonth(DateTime month) async {
    await _runWithTransition(() {
      // 외부에서 직접 월 이동을 호출할 경우 방향은 알 수 없으므로 0 으로 둠
      _monthSlideDirection = 0;
      _currentMonth = DateTime(month.year, month.month, 1);

      final now = DateTime.now();
      final isCurrentMonthHasToday =
          _currentMonth.year == now.year && _currentMonth.month == now.month;

      _selectedDate = isCurrentMonthHasToday
          ? now
          : DateTime(_currentMonth.year, _currentMonth.month, 1);
    });
  }

  /// 오늘로 이동
  Future<void> goToToday() async {
    await _runWithTransition(() {
      final now = DateTime.now();
      // 오늘로 점프할 때는 슬라이드 방향을 사용하지 않음
      _monthSlideDirection = 0;
      _selectedDate = now;
      _currentMonth = DateTime(now.year, now.month, 1);
    });
  }

  /// 다음 날짜로 이동 (스와이프/제스처용)
  ///
  /// - 선택된 날짜를 +1일
  /// - 월이 넘어가면 currentMonth 도 함께 해당 월로 이동
  Future<void> goToNextDay() async {
    await _runWithTransition(() {
      final next = _selectedDate.add(const Duration(days: 1));
      _selectedDate = next;
      // 일 단위 다음 이동 시, 월이 바뀌면 오른쪽으로 넘기는 애니메이션 느낌 (1)
      _monthSlideDirection = 1;
      _currentMonth = DateTime(next.year, next.month, 1);
    });
  }

  /// 이전 날짜로 이동 (스와이프/제스처용)
  ///
  /// - 선택된 날짜를 -1일
  /// - 월이 넘어가면 currentMonth 도 함께 해당 월로 이동
  Future<void> goToPreviousDay() async {
    await _runWithTransition(() {
      final prev = _selectedDate.subtract(const Duration(days: 1));
      _selectedDate = prev;
      // 일 단위 이전 이동 시, 월이 바뀌면 왼쪽으로 넘기는 애니메이션 느낌 (-1)
      _monthSlideDirection = -1;
      _currentMonth = DateTime(prev.year, prev.month, 1);
    });
  }
}
