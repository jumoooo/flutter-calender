/// 에러 메시지 유틸리티
///
/// 앱 전반에서 사용되는 사용자 친화적인 에러 메시지를 정의합니다.
class ErrorMessages {
  // Private 생성자로 인스턴스화 방지
  ErrorMessages._();

  // ========== 데이터 영속성 관련 에러 ==========

  /// Hive 초기화 실패
  static const String hiveInitFailed = '데이터 저장소를 초기화할 수 없습니다.\n앱을 재시작해주세요.';

  /// 데이터 로드 실패
  static const String dataLoadFailed =
      '데이터를 불러올 수 없습니다.\n일부 데이터가 손실되었을 수 있습니다.';

  /// 데이터 저장 실패
  static const String dataSaveFailed = '데이터를 저장할 수 없습니다.\n저장 공간을 확인해주세요.';

  /// 데이터 삭제 실패
  static const String dataDeleteFailed = '데이터를 삭제할 수 없습니다.\n다시 시도해주세요.';

  /// 데이터 마이그레이션 실패
  static const String migrationFailed = '데이터 형식을 업데이트할 수 없습니다.\n앱을 재시작해주세요.';

  // ========== 할일 관련 에러 ==========

  /// 할일 추가 실패
  static const String todoAddFailed = '할일을 추가할 수 없습니다.\n다시 시도해주세요.';

  /// 할일 수정 실패
  static const String todoUpdateFailed = '할일을 수정할 수 없습니다.\n다시 시도해주세요.';

  /// 할일 삭제 실패
  static const String todoDeleteFailed = '할일을 삭제할 수 없습니다.\n다시 시도해주세요.';

  /// 할일 완료 상태 변경 실패
  static const String todoToggleFailed = '할일 상태를 변경할 수 없습니다.\n다시 시도해주세요.';

  /// 할일 날짜 변경 실패
  static const String todoMoveFailed = '할일 날짜를 변경할 수 없습니다.\n다시 시도해주세요.';

  /// 할일 개수 제한 초과
  static const String todoLimitExceeded =
      '할일 개수 제한에 도달했습니다.\n일부 할일을 삭제한 후 다시 시도해주세요.';

  // ========== 데이터 파싱 관련 에러 ==========

  /// JSON 파싱 실패
  static const String jsonParseFailed = '데이터 형식이 올바르지 않습니다.\n손상된 데이터는 건너뛰었습니다.';

  /// 날짜 파싱 실패
  static const String dateParseFailed = '날짜 형식이 올바르지 않습니다.';

  // ========== 일반 에러 ==========

  /// 알 수 없는 에러
  static const String unknownError = '알 수 없는 오류가 발생했습니다.\n앱을 재시작해주세요.';

  /// 네트워크 에러 (향후 확장용)
  static const String networkError = '네트워크 연결을 확인해주세요.';

  /// 권한 에러 (향후 확장용)
  static const String permissionError = '필요한 권한이 없습니다.\n설정에서 권한을 확인해주세요.';

  // ========== 에러 메시지 가져오기 메서드 ==========

  /// 에러 타입에 따라 적절한 메시지 반환
  ///
  /// [errorType] 에러 타입 문자열
  /// [defaultMessage] 기본 메시지 (선택사항)
  static String getMessage(String errorType, {String? defaultMessage}) {
    switch (errorType) {
      case 'hive_init_failed':
        return hiveInitFailed;
      case 'data_load_failed':
        return dataLoadFailed;
      case 'data_save_failed':
        return dataSaveFailed;
      case 'data_delete_failed':
        return dataDeleteFailed;
      case 'migration_failed':
        return migrationFailed;
      case 'todo_add_failed':
        return todoAddFailed;
      case 'todo_update_failed':
        return todoUpdateFailed;
      case 'todo_delete_failed':
        return todoDeleteFailed;
      case 'todo_toggle_failed':
        return todoToggleFailed;
      case 'todo_move_failed':
        return todoMoveFailed;
      case 'todo_limit_exceeded':
        return todoLimitExceeded;
      case 'json_parse_failed':
        return jsonParseFailed;
      case 'date_parse_failed':
        return dateParseFailed;
      case 'network_error':
        return networkError;
      case 'permission_error':
        return permissionError;
      default:
        return defaultMessage ?? unknownError;
    }
  }

  /// Exception 객체로부터 사용자 친화적 메시지 생성
  ///
  /// [exception] 발생한 예외 객체
  static String fromException(Exception exception) {
    final message = exception.toString().toLowerCase();

    // Hive 관련 에러
    if (message.contains('hive') || message.contains('box')) {
      if (message.contains('init') || message.contains('open')) {
        return hiveInitFailed;
      }
      if (message.contains('save') || message.contains('put')) {
        return dataSaveFailed;
      }
      if (message.contains('delete') || message.contains('remove')) {
        return dataDeleteFailed;
      }
      return dataLoadFailed;
    }

    // JSON 관련 에러
    if (message.contains('json') || message.contains('parse')) {
      return jsonParseFailed;
    }

    // 날짜 관련 에러
    if (message.contains('date') || message.contains('datetime')) {
      return dateParseFailed;
    }

    // 기본 메시지
    return unknownError;
  }
}

/// 에러 타입 enum
///
/// 에러를 분류하기 위한 타입 정의
enum AppErrorType {
  /// Hive 초기화 실패
  hiveInitFailed,

  /// 데이터 로드 실패
  dataLoadFailed,

  /// 데이터 저장 실패
  dataSaveFailed,

  /// 데이터 삭제 실패
  dataDeleteFailed,

  /// 데이터 마이그레이션 실패
  migrationFailed,

  /// 할일 추가 실패
  todoAddFailed,

  /// 할일 수정 실패
  todoUpdateFailed,

  /// 할일 삭제 실패
  todoDeleteFailed,

  /// 할일 완료 상태 변경 실패
  todoToggleFailed,

  /// 할일 날짜 변경 실패
  todoMoveFailed,

  /// 할일 개수 제한 초과
  todoLimitExceeded,

  /// JSON 파싱 실패
  jsonParseFailed,

  /// 날짜 파싱 실패
  dateParseFailed,

  /// 알 수 없는 에러
  unknownError,
}

/// 앱 에러 모델
///
/// 에러 정보를 담는 클래스
class AppError {
  /// 에러 타입
  final AppErrorType type;

  /// 에러 메시지
  final String message;

  /// 원본 예외 (선택사항)
  final Exception? originalException;

  /// 에러 발생 시간
  final DateTime timestamp;

  AppError({
    required this.type,
    required this.message,
    this.originalException,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// 에러 타입으로부터 AppError 생성
  factory AppError.fromType(AppErrorType type, {Exception? exception}) {
    String message;

    // 에러 타입에 따라 직접 메시지 매핑
    switch (type) {
      case AppErrorType.hiveInitFailed:
        message = ErrorMessages.hiveInitFailed;
        break;
      case AppErrorType.dataLoadFailed:
        message = ErrorMessages.dataLoadFailed;
        break;
      case AppErrorType.dataSaveFailed:
        message = ErrorMessages.dataSaveFailed;
        break;
      case AppErrorType.dataDeleteFailed:
        message = ErrorMessages.dataDeleteFailed;
        break;
      case AppErrorType.migrationFailed:
        message = ErrorMessages.migrationFailed;
        break;
      case AppErrorType.todoAddFailed:
        message = ErrorMessages.todoAddFailed;
        break;
      case AppErrorType.todoUpdateFailed:
        message = ErrorMessages.todoUpdateFailed;
        break;
      case AppErrorType.todoDeleteFailed:
        message = ErrorMessages.todoDeleteFailed;
        break;
      case AppErrorType.todoToggleFailed:
        message = ErrorMessages.todoToggleFailed;
        break;
      case AppErrorType.todoMoveFailed:
        message = ErrorMessages.todoMoveFailed;
        break;
      case AppErrorType.todoLimitExceeded:
        message = ErrorMessages.todoLimitExceeded;
        break;
      case AppErrorType.jsonParseFailed:
        message = ErrorMessages.jsonParseFailed;
        break;
      case AppErrorType.dateParseFailed:
        message = ErrorMessages.dateParseFailed;
        break;
      case AppErrorType.unknownError:
        message = ErrorMessages.unknownError;
        break;
    }

    return AppError(type: type, message: message, originalException: exception);
  }

  /// Exception으로부터 AppError 생성
  factory AppError.fromException(Exception exception) {
    final message = ErrorMessages.fromException(exception);

    return AppError(
      type: AppErrorType.unknownError,
      message: message,
      originalException: exception,
    );
  }

  @override
  String toString() => message;
}
