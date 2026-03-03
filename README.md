# Flutter 캘린더 앱

Flutter를 학습하며 만든 캘린더 및 할일 관리 앱입니다. Provider를 활용한 상태 관리, 드래그 앤 드롭, 애니메이션 등 Flutter의 다양한 기능을 실습한 프로젝트입니다.

## 📱 주요 기능

- **월별 캘린더**: 한국어 형식으로 날짜 표시 (양력/음력)
- **할일 관리**: 추가, 수정, 삭제, 완료 처리 (Hive 로컬 DB 영속화)
- **드래그 앤 드롭**: 할일을 드래그하여 날짜 변경
- **우선순위**: 5단계 우선순위 설정 (매우 낮음 ~ 매우 높음)
- **반응형 디자인**: 모바일과 웹 모두 지원 (웹에서는 최대 폭 제한)
- **데이터 영속화**: 앱 재시작 후에도 할일 유지 (Hive NoSQL DB)

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

## 🧠 설계 의도 및 결정 기록

개발하면서 내린 주요 설계 결정과 그 이유 Log 입니다.

### Q1. CalendarProvider와 TodoProvider를 왜 분리했는가?

**결론: 변경 이유가 다르기 때문입니다.**

캘린더 상태(선택 날짜, 현재 월, 애니메이션 방향, 스켈레톤 여부)는 **UI 탐색 흐름**에 따라 변합니다.
할일 상태(목록, CRUD, 영속화)는 **사용자 데이터 조작**에 따라 변합니다.

이 둘을 하나로 합치면 할일을 추가할 때마다 캘린더 위젯이 리빌드되고,
월을 넘길 때마다 할일 목록 위젯이 리빌드되는 불필요한 렌더링이 발생합니다.
`Consumer`의 범위를 좁게 유지하기 위해 처음부터 분리했습니다.

```
CalendarProvider  →  월/날짜 탐색, 애니메이션 방향, 스켈레톤
TodoProvider      →  할일 CRUD, Hive 영속화, 날짜별 필터링
```

두 Provider가 서로를 참조하지 않아 독립적으로 테스트할 수 있다는 장점도 있습니다.

---

### Q2. copyWith 패턴을 사용한 이유는?

**결론: 불변 객체를 유지하면서 부분 수정을 가능하게 하기 위해서입니다.**

`Todo` 객체는 모든 필드가 `final`입니다. 완료 상태만 바꾸고 싶을 때 직접 수정할 수 없습니다.

```dart
// ❌ 불가 (final 필드)
todo.completed = true;

// ✅ copyWith 사용 — 나머지 필드는 그대로 유지
final updated = todo.copyWith(completed: true);
```

**대안과 비교:**

| 방법 | 장점 | 단점 |
|---|---|---|
| `copyWith` (현재 방식) | 직관적, 코드 생성 불필요 | 필드 추가마다 수동으로 파라미터 추가 |
| `freezed` 패키지 | `copyWith` 자동 생성, `==` 자동 구현 | 코드 생성기 설정 필요, 학습 비용 |
| 가변 객체 (mutable) | 코드 단순 | 어디서든 직접 수정 가능 → 버그 추적 어려움 |

이 프로젝트에서는 `Todo` 모델 하나이기 때문에 `copyWith`를 직접 작성하는 것이 더 용이 했습니다.
필드가 10개 이상으로 늘어나면 `freezed` 사용해볼 예정입니다.

---

## ⚡ 성능 최적화 적용 사례

코드 내에 실제로 적용된 성능 최적화 내역입니다.

| 기법 | 적용 위치 | 효과 |
|---|---|---|
| `ListView.builder` | `calendar_widget.dart`, `todo_dialog.dart` | 화면에 보이는 항목만 렌더링 |
| `ValueKey` (년-월) | `GridView.builder` 캘린더 그리드 | 월 전환 시 불필요한 전체 리빌드 방지 |
| `const` 위젯 | 전체 위젯 트리 140+ 곳 | 변경 없는 위젯은 재빌드 스킵 |
| `Consumer` 범위 최소화 | 캘린더/할일 구독 영역 분리 | 관련 없는 위젯의 리빌드 차단 |
| `NeverScrollableScrollPhysics` | 달력 `GridView` | 스크롤 이벤트 처리 비용 제거 |

> `RepaintBoundary`는 현재 미적용. 복잡한 커스텀 페인팅이 추가될 경우 도입 예정.

---

## 🧪 테스트

서비스 품질 확보를 위해 3개 계층의 테스트를 작성했습니다.

```
test/
├── widget_test.dart                     # 기본 UI 렌더링
├── models/
│   └── todo_test.dart                   # Todo 모델 직렬화/역직렬화
└── providers/
    ├── calendar_provider_test.dart      # 날짜 선택·월 이동 로직
    ├── todo_provider_test.dart          # 할일 CRUD 메모리 테스트
    └── todo_provider_hive_test.dart     # Hive 영속화 통합 테스트
```

**커버리지 영역:**
- Model: `Todo.toJson()` / `fromJson()`, `copyWith()`, 이전 버전 호환 파싱
- Provider: 날짜 선택, 월 이동, 할일 추가/수정/삭제/완료 토글
- 영속화: 앱 재시작 후 데이터 유지 여부 (Hive Box 재오픈 시뮬레이션)

```bash
flutter test              # 전체 테스트 실행
flutter test --coverage   # 커버리지 측정
```

---

## 🔭 확장 가능성

현재는 로컬 단독 앱이지만, 처음부터 확장을 고려한 구조로 설계했습니다.

**서버 연동 확장 시나리오:**

```
현재 구조                   →   서버 연동 확장 시
TodoProvider (Hive)             TodoRepository (인터페이스)
                                    ├── LocalTodoRepository (Hive, 현재)
                                    └── RemoteTodoRepository (REST API)
```

- `TodoProvider`는 데이터 접근 방식을 직접 알지 않고 Repository를 통해 동작하도록 분리 가능
- `Todo` 모델은 이미 `toJson()` / `fromJson()` 구현 → REST API 응답 파싱 준비 완료
- `CalendarProvider`는 UI 상태만 관리하므로 서버 연동 영향 없음
- 인증(Auth) Provider 추가 시 `MultiProvider` 등록만으로 확장 가능

---

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

이 프로젝트는 Flutter 학습후 실습 목적으로 제작되었습니다. 코드 리뷰나 개선 제안은 언제든 환영합니다!
