import 'package:flutter/material.dart';

/// SnackBar 표시 유틸리티
///
/// 앱 전반에서 사용되는 SnackBar 표시 로직을 중앙에서 관리합니다.
/// 에러, 성공, 정보 메시지 등을 일관된 스타일로 표시할 수 있습니다.
class SnackbarHelper {
  // Private 생성자로 인스턴스화 방지
  SnackbarHelper._();

  /// 에러 메시지 기본 지속 시간 (초)
  static const int _defaultErrorDurationSeconds = 3;

  /// 성공 메시지 기본 지속 시간 (초)
  static const int _defaultSuccessDurationSeconds = 4;

  /// 정보 메시지 기본 지속 시간 (초)
  static const int _defaultInfoDurationSeconds = 3;

  /// 에러 메시지를 표시합니다.
  ///
  /// [context] BuildContext
  /// [message] 표시할 에러 메시지
  /// [duration] 지속 시간 (초), 기본값: 3초
  /// [actionLabel] 액션 버튼 라벨 (선택사항)
  /// [onActionPressed] 액션 버튼 클릭 시 실행할 콜백 (선택사항)
  static void showError(
    BuildContext context,
    String message, {
    int durationSeconds = _defaultErrorDurationSeconds,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        duration: Duration(seconds: durationSeconds),
        action: actionLabel != null && onActionPressed != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: Colors.white,
                onPressed: onActionPressed,
              )
            : null,
      ),
    );
  }

  /// 에러 메시지를 표시합니다 (간단한 확인 버튼 포함).
  ///
  /// [context] BuildContext
  /// [message] 표시할 에러 메시지
  /// [duration] 지속 시간 (초), 기본값: 3초
  static void showErrorWithConfirm(
    BuildContext context,
    String message, {
    int durationSeconds = _defaultErrorDurationSeconds,
  }) {
    showError(
      context,
      message,
      durationSeconds: durationSeconds,
      actionLabel: '확인',
      onActionPressed: () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      },
    );
  }

  /// 성공 메시지를 표시합니다.
  ///
  /// [context] BuildContext
  /// [message] 표시할 성공 메시지
  /// [duration] 지속 시간 (초), 기본값: 4초
  /// [actionLabel] 액션 버튼 라벨 (선택사항)
  /// [onActionPressed] 액션 버튼 클릭 시 실행할 콜백 (선택사항)
  static void showSuccess(
    BuildContext context,
    String message, {
    int durationSeconds = _defaultSuccessDurationSeconds,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: durationSeconds),
        action: actionLabel != null && onActionPressed != null
            ? SnackBarAction(label: actionLabel, onPressed: onActionPressed)
            : null,
      ),
    );
  }

  /// 정보 메시지를 표시합니다.
  ///
  /// [context] BuildContext
  /// [message] 표시할 정보 메시지
  /// [duration] 지속 시간 (초), 기본값: 3초
  /// [actionLabel] 액션 버튼 라벨 (선택사항)
  /// [onActionPressed] 액션 버튼 클릭 시 실행할 콜백 (선택사항)
  static void showInfo(
    BuildContext context,
    String message, {
    int durationSeconds = _defaultInfoDurationSeconds,
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: durationSeconds),
        action: actionLabel != null && onActionPressed != null
            ? SnackBarAction(label: actionLabel, onPressed: onActionPressed)
            : null,
      ),
    );
  }

  /// 커스텀 SnackBar를 표시합니다.
  ///
  /// [context] BuildContext
  /// [snackBar] 표시할 SnackBar 위젯
  static void showCustom(BuildContext context, SnackBar snackBar) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
