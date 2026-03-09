/// 앱 전반 설정 상수
/// 
/// 앱의 동작과 제한을 정의하는 설정 값들을 중앙에서 관리합니다.
class AppConfig {
  // Private 생성자로 인스턴스화 방지
  AppConfig._();

  // ─── 데이터 관리 설정 ───────────────────────────────────────────────────────

  /// 삭제 취소 스택 최대 크기
  /// 
  /// 사용자가 삭제한 할일을 되돌릴 수 있는 최대 개수입니다.
  static const int maxUndoStackSize = 5;

  /// 음력 캐시 최대 크기
  /// 
  /// 날짜별 음력 변환 결과를 캐싱하는 최대 개수입니다.
  static const int maxLunarCacheSize = 500;

  /// 날짜 포맷 캐시 최대 크기
  /// 
  /// DateFormat 인스턴스를 캐싱하는 최대 개수입니다.
  static const int maxDateFormatCacheSize = 100;

  // ─── 할일 관리 설정 ────────────────────────────────────────────────────────

  /// 할일 개수 제한 (기본값)
  /// 
  /// 사용자가 생성할 수 있는 최대 할일 개수입니다.
  /// null이면 제한이 없습니다.
  /// 기본값: 100개 (성능 및 사용성 고려)
  static const int? defaultMaxTodoCount = 100;

  /// 할일 개수 제한 경고 임계값
  /// 
  /// 할일 개수가 이 값에 도달하면 경고를 표시합니다.
  /// null이면 경고를 표시하지 않습니다.
  /// 기본값: 80개 (제한의 80%에 도달 시 경고)
  static const int? todoCountWarningThreshold = 80;

  // ─── UI 설정 ───────────────────────────────────────────────────────────────

  /// 애니메이션 지속 시간 (밀리초)
  static const int animationDurationMs = 300;

  /// 스켈레톤 애니메이션 지속 시간 (밀리초)
  static const int skeletonAnimationDurationMs = 250;

  // ─── 검색 설정 ──────────────────────────────────────────────────────────────

  /// 검색 결과 최대 개수
  /// 
  /// 검색 결과를 제한하여 성능을 유지합니다.
  /// null이면 제한이 없습니다.
  static const int? maxSearchResults = null;

  // ─── 통계 설정 ──────────────────────────────────────────────────────────────

  /// 통계 계산 기간 (일)
  /// 
  /// 통계를 계산할 때 사용하는 기본 기간입니다.
  static const int defaultStatisticsPeriodDays = 30;

  // ─── 데이터 내보내기/가져오기 설정 ──────────────────────────────────────────

  /// 백업 파일 최대 크기 (MB)
  /// 
  /// 백업 파일의 최대 크기를 제한합니다.
  static const int maxBackupFileSizeMB = 10;

  /// 자동 백업 간격 (일)
  /// 
  /// 자동 백업을 수행하는 간격입니다.
  /// null이면 자동 백업을 수행하지 않습니다.
  static const int? autoBackupIntervalDays = null;
}
