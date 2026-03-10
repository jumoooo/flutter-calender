import 'package:flutter/material.dart';

/// 앱 전반에서 사용되는 UI 상수
///
/// 하드코딩된 숫자 값들을 중앙에서 관리하여 일관성과 유지보수성을 향상시킵니다.
class AppConstants {
  // Private 생성자로 인스턴스화 방지
  AppConstants._();

  /// 다이얼로그 인셋 패딩 (가로)
  static const double dialogInsetPaddingHorizontal = 24.0;

  /// 다이얼로그 인셋 패딩 (세로)
  static const double dialogInsetPaddingVertical = 48.0;

  /// 다이얼로그 인셋 패딩 (작은 가로)
  static const double dialogInsetPaddingHorizontalSmall = 28.0;

  /// 다이얼로그 인셋 패딩 (작은 세로)
  static const double dialogInsetPaddingVerticalSmall = 24.0;

  /// 기본 패딩 (가로)
  static const double paddingHorizontal = 20.0;

  /// 기본 패딩 (세로)
  static const double paddingVertical = 16.0;

  /// 작은 패딩 (가로)
  static const double paddingHorizontalSmall = 12.0;

  /// 작은 패딩 (세로)
  static const double paddingVerticalSmall = 8.0;

  /// 매우 작은 패딩 (가로)
  static const double paddingHorizontalTiny = 10.0;

  /// 매우 작은 패딩 (세로)
  static const double paddingVerticalTiny = 6.0;

  /// 초소형 패딩 (가로)
  static const double paddingHorizontalMicro = 5.0;

  /// 초소형 패딩 (세로)
  static const double paddingVerticalMicro = 1.0;

  /// 헤더 패딩 (상단)
  static const double paddingHeaderTop = 18.0;

  /// 헤더 패딩 (하단)
  static const double paddingHeaderBottom = 16.0;

  /// 컨텐츠 패딩 (상단)
  static const double paddingContentTop = 20.0;

  /// 컨텐츠 패딩 (하단)
  static const double paddingContentBottom = 8.0;

  /// 간격 (작은)
  static const double spacingSmall = 6.0;

  /// 간격 (기본)
  static const double spacing = 8.0;

  /// 간격 (중간)
  static const double spacingMedium = 10.0;

  /// 간격 (큰)
  static const double spacingLarge = 14.0;

  /// 간격 (매우 큰)
  static const double spacingXLarge = 16.0;

  /// 다이얼로그 모서리 반경
  static const double borderRadiusDialog = 24.0;

  /// 버튼 모서리 반경
  static const double borderRadiusButton = 10.0;

  /// 칩/배지 모서리 반경 (완전히 둥근 형태)
  static const double borderRadiusChip = 999.0;

  /// 카드 모서리 반경
  static const double borderRadiusCard = 20.0;

  /// 아이콘 크기 (작은)
  static const double iconSizeSmall = 10.0;

  /// 아이콘 크기 (기본)
  static const double iconSize = 20.0;

  /// 아이콘 크기 (중간)
  static const double iconSizeMedium = 24.0;

  /// 버튼 최소 크기
  static const double buttonMinSize = 36.0;

  /// 날짜 셀 크기
  static const double dateCellSize = 24.0;

  /// 폰트 크기 (매우 작은)
  static const double fontSizeTiny = 10.0;

  /// 폰트 크기 (작은)
  static const double fontSizeSmall = 11.0;

  /// 폰트 크기 (기본)
  static const double fontSize = 12.0;

  /// 폰트 두께 (보통)
  static const FontWeight fontWeightNormal = FontWeight.w500;

  /// 폰트 두께 (세미볼드)
  static const FontWeight fontWeightSemiBold = FontWeight.w600;

  /// 폰트 두께 (볼드)
  static const FontWeight fontWeightBold = FontWeight.w700;

  /// 테두리 두께 (얇은)
  static const double borderWidthThin = 0.5;

  /// 테두리 두께 (기본)
  static const double borderWidth = 0.8;

  /// 테두리 두께 (중간)
  static const double borderWidthMedium = 1.5;

  /// 테두리 두께 (두꺼운)
  static const double borderWidthThick = 2.0;

  /// 테두리 두께 (매우 두꺼운)
  static const double borderWidthXThick = 2.5;

  /// 테두리 두께 (강조)
  static const double borderWidthEmphasis = 4.0;

  /// 알파 값 (매우 투명)
  static const int alphaVeryTransparent = 20;

  /// 알파 값 (투명)
  static const int alphaTransparent = 24;

  /// 알파 값 (반투명)
  static const int alphaSemiTransparent = 26;

  /// 알파 값 (중간)
  static const int alphaMedium = 36;

  /// 알파 값 (불투명)
  static const int alphaOpaque = 160;

  /// 알파 값 (매우 불투명)
  static const int alphaVeryOpaque = 180;

  /// 다이얼로그 최소 높이 비율
  static const double dialogMinHeightRatio = 0.55;

  /// 다이얼로그 최대 높이 비율
  static const double dialogMaxHeightRatio = 0.80;

  /// 화면 분할 비율 (일정 영역)
  static const double scheduleAreaRatio = 0.5;

  /// 구분선 두께
  static const double dividerHeight = 1.5;

  /// 글자 간격 (기본)
  static const double letterSpacing = 0.5;

  /// 애니메이션 지속 시간 (기본)
  static const Duration animationDuration = Duration(milliseconds: 300);

  /// 다이얼로그 인셋 패딩
  static EdgeInsets get dialogInsetPadding => const EdgeInsets.symmetric(
    horizontal: dialogInsetPaddingHorizontal,
    vertical: dialogInsetPaddingVertical,
  );

  /// 다이얼로그 인셋 패딩 (작은)
  static EdgeInsets get dialogInsetPaddingSmall => const EdgeInsets.symmetric(
    horizontal: dialogInsetPaddingHorizontalSmall,
    vertical: dialogInsetPaddingVerticalSmall,
  );

  /// 기본 패딩
  static EdgeInsets get defaultPadding => const EdgeInsets.fromLTRB(
    paddingHorizontal,
    paddingContentTop,
    paddingHorizontal,
    paddingContentBottom,
  );

  /// 헤더 패딩
  static EdgeInsets get headerPadding => const EdgeInsets.fromLTRB(
    paddingHorizontal,
    paddingHeaderTop,
    paddingHorizontalSmall,
    paddingHeaderBottom,
  );

  /// 컨텐츠 패딩
  static EdgeInsets get contentPadding => const EdgeInsets.fromLTRB(
    paddingHorizontal,
    paddingContentTop,
    paddingHorizontal,
    paddingContentBottom,
  );

  /// 작은 패딩
  static EdgeInsets get smallPadding => const EdgeInsets.symmetric(
    horizontal: paddingHorizontalSmall,
    vertical: paddingVerticalSmall,
  );

  /// 매우 작은 패딩
  static EdgeInsets get tinyPadding => const EdgeInsets.symmetric(
    horizontal: paddingHorizontalTiny,
    vertical: paddingVerticalTiny,
  );

  /// 초소형 패딩
  static EdgeInsets get microPadding => const EdgeInsets.symmetric(
    horizontal: paddingHorizontalMicro,
    vertical: paddingVerticalMicro,
  );

  /// 버튼 패딩
  static EdgeInsets get buttonPadding => const EdgeInsets.symmetric(
    horizontal: paddingHorizontal,
    vertical: paddingVerticalSmall,
  );

  /// 다이얼로그 모서리 반경
  static BorderRadius get dialogBorderRadius =>
      BorderRadius.circular(borderRadiusDialog);

  /// 버튼 모서리 반경
  static BorderRadius get buttonBorderRadius =>
      BorderRadius.circular(borderRadiusButton);

  /// 칩/배지 모서리 반경
  static BorderRadius get chipBorderRadius =>
      BorderRadius.circular(borderRadiusChip);

  /// 카드 모서리 반경
  static BorderRadius get cardBorderRadius =>
      BorderRadius.circular(borderRadiusCard);

  /// 버튼 최소 크기
  static Size get buttonMinSizeBox => const Size(buttonMinSize, buttonMinSize);

  /// 아이콘 크기
  static double get iconSizeDefault => iconSize;

  /// 테두리 (기본)
  static BorderSide borderSide(Color color) =>
      BorderSide(color: color, width: borderWidth);

  /// 테두리 (중간)
  static BorderSide borderSideMedium(Color color) =>
      BorderSide(color: color, width: borderWidthMedium);

  /// 테두리 (두꺼운)
  static BorderSide borderSideThick(Color color) =>
      BorderSide(color: color, width: borderWidthThick);

  /// 테두리 (강조)
  static BorderSide borderSideEmphasis(Color color) =>
      BorderSide(color: color, width: borderWidthEmphasis);
}
