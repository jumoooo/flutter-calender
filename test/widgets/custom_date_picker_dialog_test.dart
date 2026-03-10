// 커스텀 날짜 선택 다이얼로그 관련 유닛 테스트
// 날짜 파싱 로직, 월 날짜 생성, 범위 검증, 포맷팅을 순수 유닛 테스트로 검증

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_calender/utils/date_utils.dart' as korean_date;
import 'package:intl/date_symbol_data_local.dart';

void main() {
  group('날짜 입력 파싱 로직 테스트', () {
    // _CustomDatePickerDialog 내부의 날짜 파싱 로직을 직접 추출하여 테스트
    // (private 클래스 접근 불가 → 동일 로직을 유닛 테스트로 검증)

    /// YYYY.MM.DD 형식 파싱 함수 (다이얼로그 내부 로직과 동일)
    DateTime? parseDate(String input) {
      final parts = input.split('.');
      if (parts.length != 3) return null;
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final day = int.tryParse(parts[2]);
      if (year == null || month == null || day == null) return null;
      if (month < 1 || month > 12) return null;
      if (day < 1 || day > 31) return null;
      try {
        return DateTime(year, month, day);
      } catch (_) {
        return null;
      }
    }

    test('유효한 날짜 형식 파싱 성공 테스트', () {
      // YYYY.MM.DD 형식의 올바른 날짜가 파싱되어야 함
      final result = parseDate('2026.03.15');
      expect(result, isNotNull);
      expect(result!.year, 2026);
      expect(result.month, 3);
      expect(result.day, 15);
    });

    test('잘못된 구분자 형식 파싱 실패 테스트', () {
      // 하이픈 구분자는 파싱 실패해야 함
      expect(parseDate('2026-03-15'), isNull);
      // 슬래시 구분자도 파싱 실패해야 함
      expect(parseDate('2026/03/15'), isNull);
    });

    test('문자가 포함된 입력 파싱 실패 테스트', () {
      expect(parseDate('2026.3월.15'), isNull);
      expect(parseDate('abc.def.ghi'), isNull);
      expect(parseDate(''), isNull);
    });

    test('범위를 벗어난 월/일 파싱 실패 테스트', () {
      // 월이 0 또는 13이면 실패
      expect(parseDate('2026.00.15'), isNull);
      expect(parseDate('2026.13.15'), isNull);
      // 일이 0이면 실패
      expect(parseDate('2026.03.00'), isNull);
    });

    test('경계값 날짜 파싱 테스트', () {
      // 1월 1일
      final jan1 = parseDate('2026.01.01');
      expect(jan1, isNotNull);
      expect(jan1!.month, 1);
      expect(jan1.day, 1);

      // 12월 31일
      final dec31 = parseDate('2026.12.31');
      expect(dec31, isNotNull);
      expect(dec31!.month, 12);
      expect(dec31.day, 31);
    });
  });

  group('월 날짜 생성 로직 테스트 (KoreanDateUtils)', () {
    test('3월 날짜 목록 생성 테스트 (31일)', () {
      final days = korean_date.KoreanDateUtils.getDaysInMonth(
        DateTime(2026, 3),
      );
      expect(days.length, 31);
      expect(days.first.day, 1);
      expect(days.last.day, 31);
    });

    test('2월 날짜 목록 생성 테스트 (윤년 아닌 경우 28일)', () {
      final days = korean_date.KoreanDateUtils.getDaysInMonth(
        DateTime(2025, 2),
      );
      expect(days.length, 28);
    });

    test('2월 날짜 목록 생성 테스트 (윤년: 29일)', () {
      // 2024년은 윤년
      final days = korean_date.KoreanDateUtils.getDaysInMonth(
        DateTime(2024, 2),
      );
      expect(days.length, 29);
    });

    test('4월 날짜 목록 생성 테스트 (30일)', () {
      final days = korean_date.KoreanDateUtils.getDaysInMonth(
        DateTime(2026, 4),
      );
      expect(days.length, 30);
    });

    test('날짜 비교 (isSameDay) 테스트', () {
      final date1 = DateTime(2026, 3, 15, 10, 30); // 시간 포함
      final date2 = DateTime(2026, 3, 15, 22, 0); // 다른 시간

      // 같은 날이므로 true
      expect(korean_date.KoreanDateUtils.isSameDay(date1, date2), isTrue);

      // 다른 날이므로 false
      final date3 = DateTime(2026, 3, 16);
      expect(korean_date.KoreanDateUtils.isSameDay(date1, date3), isFalse);
    });
  });

  group('날짜 범위 유효성 검사 테스트', () {
    final firstDate = DateTime(2020, 1, 1);
    final lastDate = DateTime(2030, 12, 31);

    bool isInRange(DateTime date) {
      return !date.isBefore(firstDate) && !date.isAfter(lastDate);
    }

    test('범위 내 날짜 유효 테스트', () {
      expect(isInRange(DateTime(2026, 3, 15)), isTrue);
      expect(isInRange(DateTime(2020, 1, 1)), isTrue); // 경계값
      expect(isInRange(DateTime(2030, 12, 31)), isTrue); // 경계값
    });

    test('범위 밖 날짜 무효 테스트', () {
      expect(isInRange(DateTime(2019, 12, 31)), isFalse); // firstDate 이전
      expect(isInRange(DateTime(2031, 1, 1)), isFalse); // lastDate 이후
    });
  });

  group('날짜 포맷팅 테스트 (KoreanDateUtils)', () {
    setUpAll(() async {
      // 한국어 로케일 초기화
      await initializeDateFormatting('ko_KR', null);
    });

    test('한국어 날짜 포맷팅 테스트', () {
      final date = DateTime(2026, 3, 15);
      final formatted = korean_date.KoreanDateUtils.formatKoreanDate(date);
      expect(formatted, '2026년 3월 15일');
    });

    test('한국어 월 포맷팅 테스트', () {
      final date = DateTime(2026, 3, 15);
      final formatted = korean_date.KoreanDateUtils.formatKoreanMonth(date);
      expect(formatted, '2026년 3월');
    });

    test('요일 한국어 변환 테스트', () {
      // 2026년 3월 15일은 일요일
      final sunday = DateTime(2026, 3, 15);
      expect(korean_date.KoreanDateUtils.getKoreanWeekday(sunday), '일');

      // 2026년 3월 16일은 월요일
      final monday = DateTime(2026, 3, 16);
      expect(korean_date.KoreanDateUtils.getKoreanWeekday(monday), '월');
    });

    test('음력 변환 테스트 (오프라인 klc 라이브러리)', () {
      final date = DateTime(2026, 3, 15);
      final lunar = korean_date.KoreanDateUtils.getLunarDescription(date);
      // '음력' 접두사가 포함되어야 함
      expect(lunar, startsWith('음력'));
    });
  });
}
