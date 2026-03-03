import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_calender/providers/calendar_provider.dart';

void main() {
  group('CalendarProvider 테스트', () {
    late CalendarProvider provider;

    setUp(() {
      provider = CalendarProvider();
    });

    tearDown(() async {
      // CalendarProvider 생성자의 _startInitialSkeleton()이 250ms 타이머를 가지므로
      // 각 테스트 후 타이머가 완료될 때까지 대기하여 dangling timer 방지
      await Future.delayed(const Duration(milliseconds: 300));
    });

    test('날짜 선택 테스트', () async {
      // Given: 특정 날짜
      final date = DateTime(2026, 3, 15);

      // When: 날짜 선택 (async 메서드이므로 await 필요)
      await provider.selectDate(date);

      // Then: 날짜가 선택되었는지 확인
      expect(provider.selectedDate, date);
      // 날짜 선택 시 currentMonth도 해당 월로 동기화
      expect(provider.currentMonth.year, 2026);
      expect(provider.currentMonth.month, 3);
    });

    test('이전 달로 이동 테스트', () async {
      // Given: 2026년 3월
      await provider.goToMonth(DateTime(2026, 3, 1));

      // When: 이전 달로 이동
      await provider.previousMonth();

      // Then: 2026년 2월로 이동했는지 확인
      expect(provider.currentMonth.year, 2026);
      expect(provider.currentMonth.month, 2);
    });

    test('다음 달로 이동 테스트', () async {
      // Given: 2026년 3월
      await provider.goToMonth(DateTime(2026, 3, 1));

      // When: 다음 달로 이동
      await provider.nextMonth();

      // Then: 2026년 4월로 이동했는지 확인
      expect(provider.currentMonth.year, 2026);
      expect(provider.currentMonth.month, 4);
    });

    test('특정 월로 이동 테스트', () async {
      // Given: 특정 월
      final targetMonth = DateTime(2026, 6, 1);

      // When: 특정 월로 이동
      await provider.goToMonth(targetMonth);

      // Then: 해당 월로 이동했는지 확인
      expect(provider.currentMonth.year, 2026);
      expect(provider.currentMonth.month, 6);
    });

    test('오늘로 이동 테스트', () async {
      // Given: 다른 날짜 선택
      await provider.selectDate(DateTime(2026, 1, 1));
      await provider.goToMonth(DateTime(2026, 1, 1));

      // When: 오늘로 이동
      await provider.goToToday();

      // Then: 오늘 날짜와 현재 월로 이동했는지 확인
      final now = DateTime.now();
      expect(provider.selectedDate.year, now.year);
      expect(provider.selectedDate.month, now.month);
      expect(provider.selectedDate.day, now.day);
      expect(provider.currentMonth.year, now.year);
      expect(provider.currentMonth.month, now.month);
    });

    test('다음 날짜로 이동 테스트', () async {
      // Given: 2026년 3월 15일 선택
      await provider.selectDate(DateTime(2026, 3, 15));

      // When: 다음 날짜로 이동
      await provider.goToNextDay();

      // Then: 2026년 3월 16일로 이동했는지 확인
      expect(provider.selectedDate, DateTime(2026, 3, 16));
    });

    test('이전 날짜로 이동 테스트', () async {
      // Given: 2026년 3월 15일 선택
      await provider.selectDate(DateTime(2026, 3, 15));

      // When: 이전 날짜로 이동
      await provider.goToPreviousDay();

      // Then: 2026년 3월 14일로 이동했는지 확인
      expect(provider.selectedDate, DateTime(2026, 3, 14));
    });

    test('월 경계에서 이전 날짜로 이동 테스트', () async {
      // Given: 2026년 3월 1일 선택
      await provider.selectDate(DateTime(2026, 3, 1));

      // When: 이전 날짜로 이동 (월 경계 넘음)
      await provider.goToPreviousDay();

      // Then: 2026년 2월 28일로 이동하고 currentMonth도 변경
      expect(provider.selectedDate, DateTime(2026, 2, 28));
      expect(provider.currentMonth.year, 2026);
      expect(provider.currentMonth.month, 2);
    });

    test('isTransitioning 초기 상태 테스트', () {
      // Then: 생성 직후 isTransitioning은 true (스켈레톤 시작)
      // _startInitialSkeleton()이 즉시 _isTransitioning = true 설정
      expect(provider.isTransitioning, true);
    });
  });
}
