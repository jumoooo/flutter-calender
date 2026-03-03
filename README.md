# Flutter 캘린더 앱

Flutter를 학습하며 만든 캘린더 및 할일 관리 앱입니다. Provider를 활용한 상태 관리, 드래그 앤 드롭, 애니메이션 등 Flutter의 다양한 기능을 실습한 프로젝트입니다.

## 📱 주요 기능

- **월별 캘린더**: 한국어 형식으로 날짜 표시 (양력/음력)
- **할일 관리**: 추가, 수정, 삭제, 완료 처리
- **드래그 앤 드롭**: 할일을 드래그하여 날짜 변경
- **우선순위**: 5단계 우선순위 설정 (매우 낮음 ~ 매우 높음)
- **반응형 디자인**: 모바일과 웹 모두 지원 (웹에서는 최대 폭 제한)

## 🛠️ 사용 기술

### 핵심 기술
- **Flutter** (Dart 3.11.0)
- **Provider** (상태 관리)
- **Material Design 3**

### 주요 패키지
- `provider: ^6.1.2` - 상태 관리
- `intl: ^0.20.2` - 날짜 포맷팅 및 한국어 로컬라이제이션
- `klc: ^0.1.0` - 한국 음력 변환
- `flutter_localizations` - Material 위젯의 한국어 지원

## 📁 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점, Provider 설정
├── models/
│   └── todo.dart            # Todo 모델 (불변 객체 패턴)
├── providers/
│   ├── calendar_provider.dart  # 캘린더 상태 관리
│   └── todo_provider.dart     # 할일 상태 관리
├── screens/
│   ├── calendar_screen.dart    # 메인 캘린더 화면
│   └── todo_input_screen.dart  # 할일 입력/수정 화면
├── utils/
│   └── date_utils.dart        # 날짜 유틸리티 (한국어 포맷, 음력 변환)
└── widgets/
    ├── calendar_widget.dart    # 캘린더 위젯 (월 표시, 드래그 처리)
    ├── calendar_date_cell.dart # 날짜 셀 위젯
    ├── todo_item.dart          # 할일 아이템 (드래그 가능)
    └── todo_dialog.dart        # 할일 목록 다이얼로그
```

## 💡 개발하며 배운 것들

### 1. 상태 관리 (Provider)
- `ChangeNotifier`를 상속한 Provider 클래스 구현
- `MultiProvider`로 여러 Provider 등록
- `Consumer`와 `Provider.of`를 적절히 사용하여 불필요한 리빌드 방지

### 2. 드래그 앤 드롭
- `Draggable`과 `DragTarget` 위젯 활용
- 드래그 중 피드백 위젯 커스터마이징
- 드롭 시 날짜 변경 로직 구현

### 3. 애니메이션
- `AnimationController`와 `CurvedAnimation`을 사용한 부드러운 월 전환
- `AnimatedContainer`로 드래그 오프셋 시각화
- `AnimatedSwitcher`로 스켈레톤 로딩 처리

### 4. 한국어 로컬라이제이션
- `flutter_localizations`로 Material 위젯 한국어 지원
- `intl` 패키지로 날짜 포맷팅
- `klc` 패키지로 음력 변환 (오프라인 계산)

### 5. 반응형 디자인
- `MediaQuery`로 화면 크기 감지
- 웹에서는 최대 폭 520px로 제한하여 카드 형태로 표시
- 모바일에서는 전체 화면 활용

### 6. 불변 객체 패턴
- `copyWith` 메서드로 상태 변경
- JSON 직렬화/역직렬화 구현
- 이전 버전 호환성 고려 (enum 이름 변경 대응)

## 🎨 UI/UX 고민

- **우선순위 표시**: 색상 동그라미로 직관적인 시각화
- **파스텔 색상**: 모든 화면에서 일관된 색상 팔레트 사용
- **드래그 피드백**: 드래그 중 시각적 피드백 제공
- **애니메이션**: 월 전환 시 부드러운 슬라이드 효과
- **접근성**: 색상 대비 고려 (흰 배경에서도 구분 가능)

## 🚀 실행 방법

```bash
# 의존성 설치
flutter pub get

# 실행
flutter run
```

## 📚 참고 자료

- [Flutter 공식 문서](https://flutter.dev/docs)
- [Provider 패키지](https://pub.dev/packages/provider)
- [Material Design 3](https://m3.material.io/)

---

이 프로젝트는 Flutter 학습을 목적으로 제작되었습니다. 코드 리뷰나 개선 제안은 언제든 환영합니다!
