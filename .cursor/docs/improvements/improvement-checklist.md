# Flutter 캘린더 앱 개선 작업 체크리스트

## 📋 작업 순서 및 우선순위

### Phase 1: 기반 안정화 (높은 우선순위)
기능 확장 전 안정성과 품질 기반 구축

#### 1.1 데이터 영속성 확인 및 강화 ✅ 완료
- [x] 현재 Hive 구현 상태 확인
  - [x] `lib/providers/todo_provider.dart`에서 Hive 초기화 코드 확인
  - [x] 데이터 저장 로직 확인 (자동 저장 여부)
  - [x] 앱 시작 시 자동 로드 로직 확인
- [x] 자동 저장 구현 (변경 시 즉시 저장)
  - [x] `addTodo` 메서드에 자동 저장 추가
  - [x] `updateTodo` 메서드에 자동 저장 추가
  - [x] `deleteTodo` 메서드에 자동 저장 추가
  - [x] `toggleComplete` 메서드에 자동 저장 추가
- [x] 앱 시작 시 자동 로드
  - [x] `main.dart`에서 Hive 초기화 확인
  - [x] `TodoProvider` 초기화 시 데이터 로드 확인
  - [x] 로드 실패 시 빈 리스트로 fallback 처리
- [x] 데이터 마이그레이션 처리
  - [x] 버전 변경 시 마이그레이션 로직 추가 (`lib/utils/hive_migration.dart`)
  - [x] 이전 버전 호환성 테스트
- [x] 에러 처리 강화
  - [x] 에러 메시지 유틸리티 생성 (`lib/utils/error_messages.dart`)
  - [x] 에러 스트림 추가 및 UI 연동
  - [x] 롤백 로직 구현
- [x] 테스트 작성 및 검증
  - [x] 에러 처리 테스트 (`test/providers/todo_provider_error_test.dart`)
  - [x] 마이그레이션 테스트 (`test/utils/hive_migration_test.dart`)
  - [x] 기존 테스트 수정 및 통과 확인 (전체 42개 테스트 통과)

#### 1.2 에러 처리 강화 ✅ 완료
- [x] Provider 메서드 에러 처리
  - [x] `TodoProvider.addTodo`에 try-catch 추가
  - [x] `TodoProvider.updateTodo`에 try-catch 추가
  - [x] `TodoProvider.deleteTodo`에 try-catch 추가
  - [x] `TodoProvider.toggleComplete`에 try-catch 추가
- [x] JSON 파싱 에러 처리
  - [x] `Todo.fromJson`에 파싱 에러 처리 추가 (타입 안전성 강화)
  - [x] 잘못된 형식 데이터 처리 (nullable 타입 안전 파싱)
- [x] 사용자 친화적 에러 메시지
  - [x] 에러 타입별 메시지 정의 (`lib/utils/error_messages.dart`)
  - [x] SnackBar로 에러 표시 (CalendarScreen에서 에러 스트림 구독)
- [x] 음력 변환 fallback 강화
  - [x] `lib/utils/date_utils.dart`에서 음력 변환 실패 처리 완료
  - [x] 변환 실패 시 양력만 표시하는 fallback 구현

#### 1.3 코드 품질 개선 ✅ 완료
- [x] 상수 파일 분리
  - [x] `lib/constants/priority_colors.dart` 생성
  - [x] 우선순위 색상 상수 이동
  - [x] 매직 넘버 상수화 ✅ (2026-01-27 완료)
    - [x] `lib/constants/app_constants.dart` 생성 (UI 관련 상수: spacing, radius, sizes, font, border, alpha, duration 등)
    - [x] 9개 주요 파일에서 하드코딩된 값 상수로 교체:
      - `lib/widgets/todo_detail_dialog.dart`
      - `lib/widgets/calendar_widget.dart`
      - `lib/widgets/calendar_date_cell.dart`
      - `lib/widgets/todo_input_dialog.dart`
      - `lib/widgets/todo_meta_tags.dart`
      - `lib/screens/calendar_screen.dart`
      - `lib/widgets/custom_date_picker_dialog.dart`
      - `lib/screens/search_result_screen.dart`
      - `lib/screens/category_screen.dart`
  - [x] 앱 설정 상수 정의 ✅ (2026-01-27 완료)
    - [x] `lib/constants/app_config.dart` 생성 (앱 전반 설정: undo stack, cache, todo limit, animation duration 등)
    - [x] `lib/providers/todo_provider.dart`에서 `AppConfig.maxUndoStackSize` 사용
    - [x] `lib/utils/date_utils.dart`에서 `AppConfig.maxLunarCacheSize` 사용
- [x] 우선순위 색상 중앙 관리
  - [x] `lib/constants/priority_colors.dart` 생성
  - [x] 모든 위젯에서 중앙 상수 사용하도록 변경
    - [x] `lib/widgets/calendar_widget.dart` 수정
    - [x] `lib/widgets/calendar_date_cell.dart` 수정
    - [x] `lib/widgets/todo_item.dart` 수정
    - [x] `lib/screens/todo_input_screen.dart` 수정
  - [x] 중복 정의 제거
  - [x] 코드 중복 제거 ✅ (2026-01-27 완료)
  - [x] 공통 위젯 추출 (`lib/widgets/common/`) ✅ (2026-01-27 완료)
    - [x] `lib/widgets/common/snackbar_helper.dart` 생성 (SnackBar 표시 유틸리티)
    - [x] 에러/성공/정보 메시지 헬퍼 함수 구현
    - [x] 액션 버튼 지원 (되돌리기, 확인 등)
  - [x] 공통 유틸리티 함수 추출 ✅ (2026-01-27 완료)
    - [x] SnackBar 표시 로직 중앙화
    - [x] 6곳에서 중복 코드 제거 및 교체:
      - `lib/widgets/calendar_widget.dart` (2곳)
      - `lib/screens/calendar_screen.dart` (1곳)
      - `lib/widgets/todo_input_dialog.dart` (1곳)
      - `lib/screens/category_screen.dart` (2곳)
  - [x] 반복되는 로직 함수화 ✅ (2026-01-27 완료)

#### 1.4 성능 최적화 ✅ 완료
- [x] 날짜별 인덱싱 구현
  - [x] `TodoProvider`에 `Map<String, List<Todo>>` 인덱스 추가 (`_dateIndex`)
  - [x] `getTodosByDate` 메서드 최적화 (O(n) → O(1))
  - [x] Todo 추가/수정/삭제/이동 시 인덱스 자동 동기화
  - [x] 실패 시 인덱스도 롤백되도록 구현
- [x] 음력/포맷팅 캐싱
  - [x] `date_utils.dart`에 `_lunarCache` 추가 (최대 500개)
  - [x] `DateFormat` 인스턴스 캐싱 (`_formatCache`)
- [x] 테스트 작성
  - [x] 날짜 인덱스 O(1) 조회 검증 (5개 테스트, `todo_provider_test.dart`)
- [x] ListView.builder 가상화 확인
  - [x] `calendar_widget.dart`에서 `ListView.builder` 사용 확인 (이미 구현됨)
  - [x] `todo_dialog.dart`에서 `ListView.builder` 사용 확인 (이미 구현됨)
- [x] 메모이제이션 적용
  - [x] 날짜 포맷팅 결과 캐싱 (`_formatCache`)
  - [x] 음력 변환 결과 캐싱 (`_lunarCache`)

---

### Phase 2: 핵심 기능 확장 (중간 우선순위)
사용자 경험 향상을 위한 핵심 기능 추가

#### 2.1 다크 모드 지원 ✅ 완료
- [x] ThemeData 설정
  - [x] `lib/theme/app_theme.dart` 생성 (Material3 라이트/다크 테마 중앙 정의)
  - [x] `main.dart`에 `darkTheme`, `themeMode` 연동
  - [x] `calendar_widget.dart` 하드코딩 색상 → `colorScheme` 교체
  - [x] `calendar_screen.dart` today 버튼 색상 → `colorScheme` 교체
- [x] 시스템 설정 자동 감지
  - [x] `ThemeMode.system` 기본값 (기기 다크 모드 연동)
- [x] 수동 전환 옵션
  - [x] `lib/providers/theme_provider.dart` 생성 (ThemeMode 상태 관리)
  - [x] `lib/screens/settings_screen.dart` 생성 (시스템/라이트/다크 선택 UI)
  - [x] SharedPreferences로 선택 저장 (앱 재시작 후에도 유지)
  - [x] CalendarScreen AppBar에 설정 아이콘 추가
- [x] 테스트 작성
  - [x] `test/providers/theme_provider_test.dart` (9개 테스트)

#### 2.2 검색 기능 ✅ 완료
- [x] 검색 UI 구현
  - [x] 검색 화면 생성 (`lib/screens/search_result_screen.dart`)
  - [x] `calendar_screen.dart` AppBar에 검색(🔍) 아이콘 추가
- [x] 검색 로직 구현
  - [x] `TodoProvider`에 `searchTodos` 메서드 추가
  - [x] 제목 검색 구현 (대소문자 무시)
  - [x] 설명 검색 구현 (대소문자 무시)
  - [x] 검색어 하이라이팅 (RichText)
- [x] 날짜 범위 검색
  - [x] 시작일/종료일 필터 추가
  - [x] 날짜 범위 선택 UI (DatePicker 연동)
- [x] 우선순위 필터링
  - [x] 우선순위별 FilterChip
  - [x] 다중 우선순위 선택 지원
- [x] 검색 결과 날짜별 그룹핑 (날짜 내림차순)

#### 2.3 할일 카테고리/태그 ✅ 완료
- [x] 카테고리 모델 추가
  - [x] `lib/models/category.dart` 생성 (Category, DefaultCategories, CategoryColors, CategoryIcons)
  - [x] `lib/models/category_adapter.dart` 생성 (Hive TypeAdapter, typeId=1)
  - [x] 카테고리 색상/아이콘 속성 (colorValue, iconCode)
- [x] Todo 모델 확장
  - [x] `Todo` 모델에 `categoryId` 필드 추가
  - [x] `TodoAdapter` 하위 호환 확장 (v2: availableBytes로 신규 필드 판별)
- [x] 카테고리 관리
  - [x] `CategoryProvider` 생성 (`lib/providers/category_provider.dart`)
  - [x] 카테고리 CRUD 기능 (add/update/delete)
  - [x] 기본 카테고리 생성 (업무/개인/쇼핑/건강/학습)
  - [x] `lib/screens/category_screen.dart` 생성 (관리 화면)
- [x] 카테고리 UI
  - [x] 할일 입력 화면에 카테고리 선택 DropdownButton 추가
  - [x] 할일 아이템에 카테고리 색상 세로선 표시
  - [x] CalendarScreen AppBar에 카테고리 관리 아이콘 추가
  - [x] main.dart에 CategoryProvider 및 CategoryAdapter 등록

#### 2.4 알림 기능
- [ ] 패키지 추가
  - [ ] `pubspec.yaml`에 `flutter_local_notifications` 추가
  - [ ] Android/iOS 권한 설정
- [ ] 알림 서비스 구현
  - [ ] `lib/services/notification_service.dart` 생성
  - [ ] 알림 스케줄링 로직
  - [ ] 알림 취소 로직
- [ ] Todo 모델 확장
  - [ ] `Todo` 모델에 `reminderDateTime` 필드 추가
  - [ ] 알림 활성화 여부 필드 추가
- [ ] 알림 UI
  - [ ] 할일 입력 화면에 알림 설정 추가
  - [ ] 알림 설정 화면 (`lib/screens/notification_settings_screen.dart`)
  - [ ] 알림 목록 표시

---

### Phase 3: 사용자 경험 개선 (중간 우선순위)
일상 사용성 향상

#### 3.1 사용자 경험 개선 ✅ 완료 (일괄 삭제 제외)
- [x] 되돌리기 기능
  - [x] `TodoProvider`에 undo 스택 추가 (`_undoStack`, 최대 5개)
  - [x] 삭제 시 SnackBar에 '되돌리기' 버튼 (TodoItem 롱프레스 삭제 시)
  - [x] `undoLastDelete()` 메서드 구현
- [x] 할일 복사 기능
  - [x] `TodoProvider`에 `duplicateTodo` 메서드 추가
  - [x] 할일 아이템 롱프레스 시 복사/삭제 바텀시트 메뉴
- [x] 일괄 선택/삭제 ✅ 완료 (2026-01-27)
  - [x] 선택 모드 UI 추가
  - [x] 다중 선택 체크박스
  - [x] 일괄 삭제 버튼
  - [x] 일괄 삭제 메서드 구현 (`TodoProvider.deleteTodos`)
  - [x] 테스트 작성 (4개 테스트)
  - 📋 **구현 계획**: `.cursor/docs/plans/PHASE_3.1_BATCH_SELECTION_DELETE_PLAN.md` 참조
  - 📋 **작업 로그**: `.cursor/docs/improvements/phase-3.1-batch-selection-delete/2026-01-27-work-log.md` 참조

#### 3.2 날짜/시간 기능 확장 ✅ 완료 (반복 일정 제외)
- [x] 시간 선택 기능
  - [x] `Todo` 모델에 `todoTime` 필드 추가 (TimeOfDay)
  - [x] `TodoAdapter` 하위 호환 확장으로 저장/로드 지원
  - [x] 할일 입력 화면에 시간 선택기 추가 (TimePicker)
  - [x] 할일 아이템에 시간 표시 (메타 칩)
- [ ] 반복 일정 (복잡도 높아 추후 진행)
- [x] 기한 기능
  - [x] `Todo` 모델에 `dueDate` 필드 추가
  - [x] 할일 입력 화면에 기한 DatePicker 추가
  - [x] 기한 초과 시 빨간색 표시 (할일 아이템 + 입력 화면)

#### 3.3 UI/UX 개선 ✅ 완료 (개수 제한 경고 제외)
- [x] 정렬 옵션
  - [x] `TodoSortType` enum 정의 (byCreation/byPriority/byDueDate/byTitle)
  - [x] `TodoProvider`에 정렬 로직 추가 (`setSortType`, `sortType` getter)
  - [x] 일정 영역 헤더에 정렬 바텀시트 UI 추가 (`_SortFilterButtons`)
- [x] 필터링 기능
  - [x] 완료된 할일 숨기기/보기 토글 (`toggleHideCompleted`, `hideCompleted`)
  - [x] 일정 영역 헤더에 완료 숨기기 토글 아이콘 추가
- [x] 할일 개수 제한 경고 ✅ (2026-01-27 완료)
  - [x] `AppConfig`에 기본 제한값 설정 (`defaultMaxTodoCount = 100`, `todoCountWarningThreshold = 80`)
  - [x] `TodoProvider`에 할일 개수 제한 설정 추가 (`maxTodoCount`, `setMaxTodoCount`, `todoCount` getter)
  - [x] 경고 스트림 추가 (`warningStream`, `_warningController`)
  - [x] 할일 추가 시 개수 체크 로직 추가 (`addTodo` 메서드에서 제한 체크 및 경고 스트림 알림)
  - [x] 에러 타입 추가 (`AppErrorType.todoLimitExceeded`, `ErrorMessages.todoLimitExceeded`)
  - [x] 제한 초과 시 경고 다이얼로그 표시 (`todo_input_dialog.dart`에 `_showWarningDialog` 구현)
  - [x] 제한 초과 시 에러 메시지 표시 (`_save` 메서드에서 에러 처리)
  - [x] 테스트 추가 (4개 테스트: 제한값 확인, 제한 초과, 경고 스트림, 제한 없음)

---

### Phase 4: 고급 기능 및 품질 보증 (낮은 우선순위)
장기적 가치와 품질 향상

#### 4.1 테스트 커버리지 확대
- [ ] Provider 단위 테스트
  - [ ] `CalendarProvider` 테스트 보완
  - [ ] `TodoProvider` 에러 케이스 테스트 추가
  - [ ] 새 기능 테스트 추가 (검색, 필터링 등)
- [ ] 위젯 테스트 확대
  - [ ] `calendar_widget.dart` 상호작용 테스트
  - [ ] `todo_item.dart` 드래그 앤 드롭 테스트
  - [ ] 다크 모드 UI 테스트
- [ ] 통합 테스트
  - [ ] 전체 플로우 테스트 (할일 추가 → 수정 → 삭제)
  - [ ] 데이터 영속화 통합 테스트
  - [ ] 알림 통합 테스트

#### 4.2 접근성 개선
- [ ] 시맨틱 레이블 추가
  - [ ] 모든 버튼에 `Semantics` 위젯 추가
  - [ ] 할일 아이템에 의미 있는 레이블
  - [ ] 캘린더 날짜 셀에 레이블 추가
- [ ] 스크린 리더 지원 강화
  - [ ] 할일 상태 음성 안내
  - [ ] 날짜 선택 음성 안내
  - [ ] 우선순위 음성 안내
- [ ] 키보드 네비게이션 개선
  - [ ] 포커스 순서 최적화
  - [ ] 키보드 단축키 지원 (선택사항)

#### 4.3 통계 및 분석
- [ ] 통계 모델 생성
  - [ ] `lib/models/statistics.dart` 생성
  - [ ] 통계 데이터 구조 정의
- [ ] 통계 Provider
  - [ ] `lib/providers/statistics_provider.dart` 생성
  - [ ] 완료율 계산 로직
  - [ ] 우선순위별 분포 계산
  - [ ] 월별/주별 할일 통계 계산
- [ ] 통계 UI
  - [ ] 통계 화면 생성 (`lib/screens/statistics_screen.dart`)
  - [ ] 차트 라이브러리 추가 (`fl_chart` 또는 `charts_flutter`)
  - [ ] 완료율 원형 차트
  - [ ] 우선순위 분포 막대 그래프
  - [ ] 월별 추이 라인 차트

#### 4.4 데이터 내보내기/가져오기
- [ ] JSON 내보내기
  - [ ] `TodoProvider`에 `exportToJson` 메서드 추가
  - [ ] 파일 저장 기능 (`path_provider` 활용)
  - [ ] 내보내기 UI (설정 화면에 버튼 추가)
- [ ] JSON 가져오기
  - [ ] `TodoProvider`에 `importFromJson` 메서드 추가
  - [ ] 파일 선택 기능 (`file_picker` 활용)
  - [ ] 데이터 검증 및 병합 로직
  - [ ] 가져오기 확인 다이얼로그
- [ ] CSV 내보내기
  - [ ] CSV 변환 로직
  - [ ] CSV 내보내기 메서드
- [ ] 백업/복원 기능
  - [ ] 자동 백업 스케줄 (선택사항)
  - [ ] 클라우드 백업 연동 (선택사항)

---

## 📊 작업 의존성 관계

```
Phase 1 (기반 안정화)
├── 1.1 데이터 영속성 ──┐
├── 1.2 에러 처리 ──────┤──→ 모든 후속 작업의 기반
├── 1.3 코드 품질 ──────┤
└── 1.4 성능 최적화 ────┘

Phase 2 (핵심 기능)
├── 2.1 다크 모드 (독립적)
├── 2.2 검색 기능 (1.4 성능 최적화 후 권장)
├── 2.3 카테고리/태그 (1.1 데이터 영속성 필요)
└── 2.4 알림 기능 (독립적)

Phase 3 (UX 개선)
├── 3.1 UX 개선 (1.2 에러 처리 후 권장)
├── 3.2 날짜/시간 확장 (2.4 알림 기능과 연계 가능)
└── 3.3 UI/UX 개선 (독립적)

Phase 4 (고급 기능)
├── 4.1 테스트 (모든 기능 구현 후)
├── 4.2 접근성 (독립적, 낮은 우선순위)
├── 4.3 통계 (2.3 카테고리 후 권장)
└── 4.4 데이터 내보내기 (1.1 데이터 영속성 필요)
```

## 🎯 권장 작업 순서 (빠른 시작)

1. Phase 1 완료 (기반 안정화) - 필수
2. Phase 2.1 다크 모드 (빠른 성과)
3. Phase 2.2 검색 기능 (사용자 요구 높음)
4. Phase 3.1 UX 개선 (되돌리기 등)
5. Phase 2.3 카테고리/태그 (기능 확장)
6. Phase 2.4 알림 기능
7. Phase 3.2, 3.3 (날짜/시간, UI/UX)
8. Phase 4 (고급 기능)

## 📝 체크리스트 사용 방법

각 작업 항목은:
- [ ] 체크박스로 진행 상황 추적
- 세부 작업으로 분해
- 의존성 명시
- AI 에이전트에게 단계별로 전달 가능

예시: "Phase 1.1 데이터 영속성 확인 및 강화 작업을 시작해줘"

---

**생성일**: 2025-01-27
**마지막 업데이트**: 2025-01-27
