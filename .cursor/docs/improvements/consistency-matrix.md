# 📊 컨텐츠 통일성 매트릭스 (Consistency Matrix)

> **최종 업데이트:** 2026-03-06  
> **목적:** 프로젝트별 통일성 기준을 명시적으로 정의하여 Agent가 참조

---

## 기능 × 화면 매트릭스

### 필수 기능 표시 기준

| 기능 | 입력 화면 | 상세 화면 | 목록 화면 | 검색 화면 | 우선순위 | 표시 형식 |
|------|----------|----------|----------|----------|----------|----------|
| **카테고리** | ✅ 필수 | ✅ 필수 | ✅ 필수 | ✅ 필수 | Critical | 칩 형태 (작은 태그) |
| **시간** | ✅ 필수 | ✅ 필수 | ✅ 필수 | ✅ 필수 | Critical | "오후 3:00" 형식 |
| **기한** | ✅ 필수 | ✅ 필수 | ✅ 필수 | ✅ 필수 | Critical | "2026년 3월 15일" 형식 |
| **우선순위** | ✅ 필수 | ✅ 필수 | ✅ 필수 | ✅ 필수 | Critical | `PriorityColors.label()` 사용 |
| **완료 상태** | - | ✅ 필수 | ✅ 권장 | ✅ 권장 | Important | 체크박스/토글 |

### 선택적 기능 표시 기준

| 기능 | 입력 화면 | 상세 화면 | 목록 화면 | 검색 화면 | 우선순위 | 표시 형식 |
|------|----------|----------|----------|----------|----------|----------|
| **설명** | ✅ 필수 | ✅ 필수 | ❌ | ✅ 권장 | Important | 텍스트 영역 |

---

## 화면별 파일 매핑

### 입력 화면 (Input)
- **파일**: `lib/widgets/todo_input_dialog.dart`
- **역할**: 할일 추가/수정 다이얼로그
- **필수 표시**: 카테고리, 시간, 기한, 우선순위

### 상세 화면 (Detail)
- **파일**: `lib/widgets/todo_detail_dialog.dart`
- **역할**: 할일 상세 정보 표시
- **필수 표시**: 카테고리, 시간, 기한, 우선순위, 완료 상태

### 목록 화면 (List)
- **파일**: `lib/widgets/calendar_widget.dart`
- **역할**: 선택된 날짜의 할일 목록 표시
- **필수 표시**: 카테고리, 시간, 기한, 우선순위 (미니 태그 형태)
- **권장 표시**: 완료 상태

### 검색 화면 (Search)
- **파일**: `lib/screens/search_result_screen.dart`
- **역할**: 검색 결과 목록 표시
- **필수 표시**: 카테고리, 시간, 기한, 우선순위 (미니 태그 형태)
- **권장 표시**: 완료 상태

---

## 표시 형식 기준

### 카테고리 (Category)
- **형식**: 칩 형태 (작은 태그)
- **위치**: 
  - 입력: 선택 다이얼로그
  - 상세: `_InfoRow` 내 칩 (expand: false)
  - 목록: `TodoMetaTagsRow` 위젯 사용
  - 검색: `TodoMetaTagsRow` 위젯 사용
- **구현**: `lib/widgets/todo_meta_tags.dart`의 `TodoMetaTagsRow` 위젯

### 시간 (Time)
- **형식**: "오후 3:00" (한국어 AM/PM)
- **위치**:
  - 입력: 시간 선택 다이얼로그
  - 상세: `_InfoRow` 내 텍스트
  - 목록: `TodoMetaTagsRow` 위젯 사용
  - 검색: `TodoMetaTagsRow` 위젯 사용
- **구현**: `TimeOfDay.format(context)` 또는 `DateFormat('a h:mm', 'ko_KR')`

### 기한 (Due Date)
- **형식**: "2026년 3월 15일" (요일 미포함)
- **위치**:
  - 입력: 날짜 선택 다이얼로그
  - 상세: `_InfoRow` 내 텍스트 (초과 시 빨간색)
  - 목록: `TodoMetaTagsRow` 위젯 사용
  - 검색: `TodoMetaTagsRow` 위젯 사용
- **구현**: `KoreanDateUtils.formatKoreanDate(date)`

### 우선순위 (Priority)
- **형식**: 
  - 단축: `PriorityColors.label(priority)` → "최상", "상", "중", "하", "최하"
  - 전체: `PriorityColors.labelFull(priority)` → "매우 높음", "높음", "보통", "낮음", "매우 낮음"
- **위치**:
  - 입력: `SegmentedButton` 내 선택
  - 상세: 헤더 배지
  - 목록: leading 아이콘 옆 칩
  - 검색: leading 컬러 바 + 필터 칩
- **구현**: `lib/constants/priority_colors.dart`의 `PriorityColors` 클래스

### 완료 상태 (Completed)
- **형식**: 체크박스/토글
- **위치**:
  - 입력: - (없음)
  - 상세: `_InfoRow` 내 토글 가능한 텍스트
  - 목록: - (권장)
  - 검색: - (권장)
- **구현**: `Icons.check_circle_rounded` / `Icons.radio_button_unchecked_rounded`

---

## 날짜 포맷 기준

### 요일 포함 날짜
- **형식**: "2026년 3월 15일 (일)"
- **사용 위치**: 상세 화면 날짜 표시
- **구현**: `KoreanDateUtils.formatKoreanDateWithWeekday(date)`

### 요일 미포함 날짜
- **형식**: "2026년 3월 15일"
- **사용 위치**: 입력 화면, 목록 화면, 검색 화면
- **구현**: `KoreanDateUtils.formatKoreanDate(date)`

---

## 공용 위젯 및 유틸리티

### 공용 위젯
- **`TodoMetaTagsRow`**: `lib/widgets/todo_meta_tags.dart`
  - 카테고리, 시간, 기한을 미니 칩 태그로 표시
  - 목록 화면과 검색 화면에서 공통 사용

### 공용 유틸리티
- **`PriorityColors`**: `lib/constants/priority_colors.dart`
  - `label(priority)`: 단축 레이블
  - `labelFull(priority)`: 전체 레이블
  - `getColor(priority)`: 색상 반환

- **`KoreanDateUtils`**: `lib/utils/date_utils.dart`
  - `formatKoreanDate(date)`: 요일 미포함
  - `formatKoreanDateWithWeekday(date)`: 요일 포함

---

## 감사 기준

### Critical 우선순위 (반드시 일치해야 함)
- 카테고리, 시간, 기한, 우선순위가 모든 화면에 표시되어야 함
- 우선순위 라벨은 `PriorityColors.label()` 또는 `PriorityColors.labelFull()` 사용
- 날짜 포맷은 `KoreanDateUtils` 사용

### Important 우선순위 (권장)
- 완료 상태가 상세 화면에 표시되어야 함
- 목록/검색 화면에도 완료 상태 표시 권장

---

## 확장 가이드

새로운 기능이 추가될 때:
1. 이 매트릭스에 기능 추가
2. 각 화면별 필수/권장 여부 결정
3. 표시 형식 정의
4. 공용 위젯/유틸리티 필요 시 생성
5. `contentConsistencyAgent`가 자동으로 감사

---

## 관련 문서

- [content-consistency-agent-plan.md](./content-consistency-agent-plan.md) - Agent 구축 계획
- [consistency-audit.md](./consistency-audit.md) - 감사 결과 보고서
