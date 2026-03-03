import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_calender/providers/calendar_provider.dart';

void main() {
  group('CalendarProvider 테스트', () {
    late CalendarProvider provider;

    setUp(() {
      provider = CalendarProvider();
    });

    test('날짜 선택 테스트', () {
      // Given: 특정 날짜
      final date = DateTime(2026, 3, 15);

      // When: 날짜 선택
      provider.selectDate(date);

      // Then: 날짜가 선택되었는지 확인
      expect(provider.selectedDate, date);
    });

    test('이전 달로 이동 테스트', () {
      // Given: 2026년 3월
      provider.goToMonth(DateTime(2026, 3, 1));

      // When: 이전 달로 이동
      provider.previousMonth();

      // Then: 2026년 2월로 이동했는지 확인
      expect(provider.currentMonth.year, 2026);
      expect(provider.currentMonth.month, 2);
    });

    test('다음 달로 이동 테스트', () {
      // Given: 2026년 3월
      provider.goToMonth(DateTime(2026, 3, 1));

      // When: 다음 달로 이동
      provider.nextMonth();

      // Then: 2026년 4월로 이동했는지 확인
      expect(provider.currentMonth.year, 2026);
      expect(provider.currentMonth.month, 4);
    });

    test('특정 월로 이동 테스트', () {
      // Given: 특정 월
      final targetMonth = DateTime(2026, 6, 1);

      // When: 특정 월로 이동
      provider.goToMonth(targetMonth);

      // Then: 해당 월로 이동했는지 확인
      expect(provider.currentMonth.year, 2026);
      expect(provider.currentMonth.month, 6);
    });

    test('오늘로 이동 테스트', () {
      // Given: 다른 날짜 선택
      provider.selectDate(DateTime(2026, 1, 1));
      provider.goToMonth(DateTime(2026, 1, 1));

      // When: 오늘로 이동
      provider.goToToday();

      // Then: 오늘 날짜와 현재 월로 이동했는지 확인
      final now = DateTime.now();
      expect(provider.selectedDate.year, now.year);
      expect(provider.selectedDate.month, now.month);
      expect(provider.selectedDate.day, now.day);
      expect(provider.currentMonth.year, now.year);
      expect(provider.currentMonth.month, now.month);
    });
  });
}
