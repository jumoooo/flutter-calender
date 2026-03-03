import 'package:intl/intl.dart';
import 'package:klc/klc.dart' as klc;

/// 한국 날짜 유틸리티 클래스
class KoreanDateUtils {
  /// 한국 로케일 설정
  static const String koreanLocale = 'ko_KR';

  /// 한국 시간대
  static const String koreanTimeZone = 'Asia/Seoul';

  /// 날짜를 한국어 형식으로 포맷팅 (예: "2026년 3월 15일")
  static String formatKoreanDate(DateTime date) {
    return DateFormat('yyyy년 M월 d일', koreanLocale).format(date);
  }

  /// 날짜를 한국어 형식으로 포맷팅 (예: "2026년 3월")
  static String formatKoreanMonth(DateTime date) {
    return DateFormat('yyyy년 M월', koreanLocale).format(date);
  }

  /// 요일을 한국어로 반환 (예: "월", "화", "수", "목", "금", "토", "일")
  static String getKoreanWeekday(DateTime date) {
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return weekdays[date.weekday % 7];
  }

  /// 해당 월의 첫 번째 날짜 반환
  static DateTime getFirstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// 해당 월의 마지막 날짜 반환
  static DateTime getLastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// 해당 월의 모든 날짜 리스트 반환
  static List<DateTime> getDaysInMonth(DateTime date) {
    final firstDay = getFirstDayOfMonth(date);
    final lastDay = getLastDayOfMonth(date);
    final days = <DateTime>[];

    for (var day = firstDay.day; day <= lastDay.day; day++) {
      days.add(DateTime(date.year, date.month, day));
    }

    return days;
  }

  /// 두 날짜가 같은 날인지 확인
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// 날짜가 오늘인지 확인
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }

  /// 한국 음력 표기 (klc 패키지 / KARI 기준, 오프라인 동기 계산)
  ///
  /// - 네트워크 없이 바로 계산되므로, 양력 텍스트와 동일한 속도로 표시됩니다.
  /// - klc: https://pub.dev/documentation/klc/latest/ 에서 제공하는
  ///   `setSolarDate`, `getLunarIsoFormat` 함수를 사용합니다.
  /// - 예: 양력 2026-03-03 -> "음력 1.15"
  static String getLunarDescription(DateTime date) {
    try {
      // 1) 양력 날짜를 klc 에 설정 (연/월/일)
      klc.setSolarDate(date.year, date.month, date.day);

      final iso = klc.getLunarIsoFormat();
      final datePart = iso.split(' ').first;
      final parts = datePart.split('-');
      if (parts.length != 3) {
        return '음력 ${date.month}.${date.day}';
      }

      final lunarMonth = int.tryParse(parts[1]) ?? date.month;
      final lunarDay = int.tryParse(parts[2]) ?? date.day;
      return '음력 $lunarMonth.$lunarDay';
    } catch (_) {
      return '음력 ${date.month}.${date.day}';
    }
  }
}
