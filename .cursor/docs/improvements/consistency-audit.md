# 📋 UI 일관성 감사 보고서 (Consistency Audit)

> **분석 기준일:** 2026-03-06  
> **분석 대상:** `lib/` 전체 — 모델, 위젯, 화면, 상태관리

---

## 🔍 발견된 불일치 항목

### 🔴 Issue 1 — Todo 모델 필드가 UI 어디에도 노출되지 않음

`Todo` 모델에 `categoryId`, `dueDate`, `todoTime` 필드가 정의되어 있지만
어떤 화면에서도 입력하거나 표시되지 않았습니다.

| 필드 | 입력 다이얼로그 | 상세보기 | 캘린더 일정 목록 | 검색 결과 |
|---|:---:|:---:|:---:|:---:|
| `priority` | ✅ | ✅ | ✅ | ✅ |
| `title` | ✅ | ✅ | ✅ | ✅ |
| `description` | ✅ | ✅ | ❌ | ✅ |
| `date` | ✅ | ✅ | ✅(중복) | ✅ |
| `completed` | ✅ | ✅ | ❌ | ✅ |
| **`categoryId`** | ❌ | ❌ | ❌ | ❌ |
| **`dueDate`** | ❌ | ❌ | ❌ | ❌ |
| **`todoTime`** | ❌ | ❌ | ❌ | ❌ |

---

### 🔴 Issue 2 — 우선순위 한글 레이블이 화면마다 다름

같은 `TodoPriority` enum 값이 위치에 따라 다른 텍스트로 표시됨.
`PriorityColors` 상수 파일에 중앙화되지 않아 4개 파일에 각각 분산.

| enum | 입력/상세/목록 | 검색 필터 | 상태 |
|---|---|---|---|
| `veryHigh` | `최상` | `매우높음` | ❌ 불일치 |
| `high` | `상` | `높음` | ❌ 불일치 |
| `normal` | `중` | `보통` | ❌ 불일치 |
| `low` | `하` | `낮음` | ❌ 불일치 |
| `veryLow` | `최하` | `매우낮음` | ❌ 불일치 |

---

### 🔴 Issue 3 — 날짜 포맷 및 포맷 방법 불일치

| 위치 | 형식 | 방법 |
|---|---|---|
| `TodoDetailDialog` | `yyyy년 M월 d일 (E)` + `'ko_KR'` | `intl.DateFormat` 직접 사용 ❌ |
| `SearchResultScreen` 날짜 헤더 | `yyyy년 M월 d일 (E)` + `'ko'` | `intl.DateFormat` 직접 사용 ❌ |
| `TodoInputDialog` 날짜 표시 | `yyyy년 M월 d일` | `KoreanDateUtils` 사용 ✅ |
| 캘린더 일정 목록 subtitle | `yyyy년 M월 d일` | `KoreanDateUtils` 사용 ✅ |

- `'ko'` vs `'ko_KR'` locale 혼재
- 요일 포함 여부 불일치
- `intl.DateFormat` 직접 사용 vs `KoreanDateUtils` 래퍼 혼재

---

### 🟡 Issue 4 — 캘린더 일정 목록 subtitle이 중복/무의미

캘린더 하단 일정 목록은 **선택된 날짜 기준**으로 이미 필터링됩니다.  
subtitle에 같은 날짜를 또 표시하는 것은 정보 가치가 없습니다.  
category, time, dueDate 등 실질적인 메타 정보가 표시되어야 합니다.

---

### 🟡 Issue 5 — 우선순위 시각화 스타일 불일치

| 위치 | 스타일 |
|---|---|
| `TodoDetailDialog` 헤더 | 둥근 알약형 배지 (`pill badge`) |
| 캘린더 일정 목록 leading | 둥근 알약형 배지 (`pill badge`) |
| 검색 결과 아이템 leading | `4px 세로 컬러 바` ← 다름 |
| 검색 필터 칩 | `FilterChip` ← 다름 |

> 검색 필터 칩은 FilterChip이 문맥상 적합하므로 유지.  
> 검색 결과 아이템 leading 스타일은 다른 컴포넌트와 통일 필요 없음 — 리스트형이라 바 형태도 허용.

---

## ✅ 수정 사항 목록

### 1. `lib/constants/priority_colors.dart`
- `label(priority)` 정적 메서드 추가 — 단축 레이블 (`최상/상/중/하/최하`)
- `labelFull(priority)` 정적 메서드 추가 — 전체 레이블 (`매우높음/높음/보통/낮음/매우낮음`)

### 2. `lib/utils/date_utils.dart`
- `formatKoreanDateWithWeekday(date)` 정적 메서드 추가 — 예: `"2026년 3월 15일 (일)"`

### 3. `lib/widgets/todo_input_dialog.dart`
- `todoTime` 시간 선택 UI 추가 (시스템 `showTimePicker` 사용)
- `dueDate` 기한 선택 UI 추가 (커스텀 날짜 피커 사용)
- `categoryId` 카테고리 선택 UI 추가 (없음 + 칩 형태)
- `_save()` / `initState()` 에 새 필드 반영

### 4. `lib/widgets/todo_detail_dialog.dart`
- 날짜 포맷 `intl.DateFormat` → `KoreanDateUtils.formatKoreanDateWithWeekday()` 통일
- `todoTime` 시간 표시 행 추가
- `dueDate` 기한 표시 행 추가 (초과 시 빨간색)
- `categoryId` 카테고리 칩 표시 행 추가
- `_priorityLabel()` → `PriorityColors.label()` 중앙 메서드 사용

### 5. `lib/widgets/calendar_widget.dart`
- 일정 목록 `ListTile` subtitle: 중복 날짜 → category + time + dueDate 메타 태그 교체
- `_priorityLabelShort()` → `PriorityColors.label()` 사용

### 6. `lib/screens/search_result_screen.dart`
- `_SearchResultItem` 에 category + time + dueDate 메타 태그 행 추가
- `_priorityLabels` 맵 → `PriorityColors.labelFull()` 사용으로 통일

---

## 📐 통일 기준 (표준)

| 항목 | 표준 |
|---|---|
| 우선순위 단축 레이블 | `PriorityColors.label(priority)` |
| 우선순위 전체 레이블 | `PriorityColors.labelFull(priority)` |
| 날짜 포맷 (요일 포함) | `KoreanDateUtils.formatKoreanDateWithWeekday(date)` |
| 날짜 포맷 (요일 미포함) | `KoreanDateUtils.formatKoreanDate(date)` |
| 메타 태그 위젯 | `_MetaTag(label, icon, color)` — 각 파일 내 private 위젯 |
| 카테고리 조회 | `CategoryProvider.getById(categoryId)` |

---

## 🧩 통일성 Agent 시스템 연계

- 이 문서는 이제 다음 산출물과 함께 사용됩니다:
  - `content-consistency-agent-plan.md` — 컨텐츠 통일성 Agent 설계 및 실행 계획
  - `consistency-matrix.md` — 기능 × 화면 매트릭스 (카테고리/시간/기한/우선순위/완료 상태 기준)
  - `contentConsistencyAgent.md` — 컨텐츠 통일성 감사 전담 Agent
  - `content_consistency_skills.md` — 매트릭스 파싱/감사/제안/리포트 스킬

### 감사 플로우 요약

1. `feature_dev` 작업 완료 후, Orchestrator가 컨텐츠 통일성 감사 제안
2. 사용자가 동의하면 `contentConsistencyAgent` 실행
3. Agent는 `consistency-matrix.md`를 기준으로 입력/상세/목록/검색 화면을 점검
4. 누락/불일치 항목을 찾으면, 이 문서(`consistency-audit.md`)에 결과를 추가로 기록
5. 사용자가 원하면 제안된 수정 사항을 실제 코드에 적용

> 즉, 이 파일은 **실제 코드 상태**를 기록하는 감사 리포트이고,  
> `contentConsistencyAgent` + `consistency-matrix.md`는 **무엇을 어떻게 검사할지**를 정의하는 기준/로직입니다.
