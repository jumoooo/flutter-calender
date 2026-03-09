import 'package:flutter_calender/constants/app_config.dart';
import 'package:intl/intl.dart';
import 'package:klc/klc.dart' as klc;

/// 한국 날짜 유틸리티 클래스
class KoreanDateUtils {
  /// 한국 로케일 설정
  static const String koreanLocale = 'ko_KR';

  /// 음력 변환 결과 캐시 ('yyyy-M-d' → '음력 M.d')
  /// 동일 날짜의 반복 계산을 방지합니다 (최대 500개 항목 유지)
  static final Map<String, String> _lunarCache = {};

  /// DateFormat 인스턴스 캐시 (동일 포맷 문자열 반복 생성 방지)
  static final Map<String, DateFormat> _formatCache = {};

  /// DateFormat을 캐시에서 가져오거나 생성
  static DateFormat _getFormat(String pattern) {
    return _formatCache.putIfAbsent(pattern, () => DateFormat(pattern, koreanLocale));
  }

  /// 한국 시간대
  static const String koreanTimeZone = 'Asia/Seoul';

  /// 날짜를 한국어 형식으로 포맷팅 (예: "2026년 3월 15일")
  static String formatKoreanDate(DateTime date) {
    return _getFormat('yyyy년 M월 d일').format(date);
  }

  /// 날짜를 요일 포함 한국어 형식으로 포맷팅 (예: "2026년 3월 15일 (일)")
  ///
  /// TodoDetailDialog, SearchResultScreen 등 날짜+요일이 함께 필요한 곳에 사용.
  /// intl.DateFormat 직접 사용 대신 이 메서드를 통해 locale을 'ko_KR'로 통일합니다.
  static String formatKoreanDateWithWeekday(DateTime date) {
    return _getFormat('yyyy년 M월 d일 (E)').format(date);
  }

  /// 날짜를 한국어 형식으로 포맷팅 (예: "2026년 3월")
  static String formatKoreanMonth(DateTime date) {
    return _getFormat('yyyy년 M월').format(date);
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
  /// - 네트워크 없이 바로 계산됩니다.
  /// - 결과를 캐시하여 동일 날짜의 반복 계산을 방지합니다.
  /// - 예: 양력 2026-03-03 -> "음력 1.15"
  static String getLunarDescription(DateTime date) {
    final cacheKey = '${date.year}-${date.month}-${date.day}';

    // ✅ 캐시에 있으면 즉시 반환
    final cached = _lunarCache[cacheKey];
    if (cached != null) return cached;

    // ✅ 캐시 크기 제한 (최대 개수 초과 시 가장 오래된 항목 제거)
    if (_lunarCache.length >= AppConfig.maxLunarCacheSize) {
      _lunarCache.remove(_lunarCache.keys.first);
    }

    try {
      klc.setSolarDate(date.year, date.month, date.day);
      final iso = klc.getLunarIsoFormat();
      final datePart = iso.split(' ').first;
      final parts = datePart.split('-');

      final result = parts.length == 3
          ? '음력 ${int.tryParse(parts[1]) ?? date.month}.${int.tryParse(parts[2]) ?? date.day}'
          : '음력 ${date.month}.${date.day}';

      _lunarCache[cacheKey] = result;
      return result;
    } catch (_) {
      final fallback = '음력 ${date.month}.${date.day}';
      _lunarCache[cacheKey] = fallback;
      return fallback;
    }
  }
}
