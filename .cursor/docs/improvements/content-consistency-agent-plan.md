# 📋 Content Consistency Agent 구축 계획

> **계획 수립일:** 2026-03-06  
> **목표:** 컨텐츠/기능 레벨 통일성을 자동으로 감사하고 수정 제안하는 Agent 시스템 구축

---

## 🎯 목표

기능/컨텐츠 레벨의 통일성(카테고리, 시간, 기한 등이 모든 입력·표시·검색 화면에서 일관되게 표시되는지)을 **능동적으로 감사하고 자동 수정 제안**하는 Agent 시스템 구축.

---

## 📐 설계 원칙 (2026년 기준 Best Practice)

### 1. Single Responsibility Principle (SRP)
- 각 Agent는 하나의 책임만 담당
- `uiStyleRefiner`: 스타일 통일성 (색상/간격/정렬)
- `contentConsistencyAgent`: 컨텐츠 통일성 (기능/데이터 표시 일관성)

### 2. Opt-in 자동화 패턴
- 완전 자동 실행은 위험 → "자동 감지 → 제안 → 사용자 확인 → 실행" 방식
- `feature_dev` 완료 후 Orchestrator가 제안
- 사용자 확인 후 실행

### 3. 산출물 기반 감사 (Artifact-driven)
- 코드 직접 스캔은 느리고 비효율적
- Agent 간 산출물(JSON/Markdown) 교환으로 효율성 향상
- Agent 간 결합도 감소

### 4. 명시적 기준 정의
- Agent 내부 하드코딩 지양
- 별도 매트릭스 파일로 기준 관리
- 프로젝트 확장 시 기준 확장 용이

---

## 📁 생성/수정 파일 목록

### 신규 생성 파일

| 파일 | 목적 | 우선순위 |
|---|---|---|
| `.cursor/agents/contentConsistencyAgent.md` | Agent 본체 — 감사 로직 + 매트릭스 체크 | Critical |
| `.cursor/skills/content_consistency_skills.md` | 감사 체크리스트/전략 | Critical |
| `.cursor/docs/improvements/consistency-matrix.md` | 기능 × 화면 매트릭스 (기준 정의) | Critical |
| `.cursor/docs/improvements/content-consistency-agent-plan.md` | 이 계획 문서 | Critical |

### 수정 파일

| 파일 | 수정 내용 | 우선순위 |
|---|---|---|
| `.cursor/agents/orchestrator.md` | Agent Registry + Rule 추가 | Important |
| `.cursor/docs/improvements/consistency-audit.md` | 새 Agent 시스템 반영 | Important |

---

## 🔄 실행 흐름 (최종 설계)

```
[사용자] feature_dev 요청
  ↓
[Orchestrator] planner → featureImplementation 실행
  ↓
[featureImplementation] 작업 완료 + 산출물 생성
  {
    "modified_files": ["lib/widgets/new_feature.dart"],
    "new_features": ["카테고리 필터 기능"],
    "impact_scope": {...}
  }
  ↓
[Orchestrator] "통일성 감사를 제안합니다. 진행할까요?" (Opt-in 제안)
  ↓
[사용자] "진행" 또는 "나중에"
  ↓
[contentConsistencyAgent] (사용자 확인 시)
  1. consistency-matrix.md 읽기
  2. featureImplementation 산출물 읽기
  3. 매트릭스 기반 감사 수행
  4. 문제 발견 시 수정 제안 생성
  ↓
[contentConsistencyAgent] "다음 문제를 발견했습니다:
  - 새 기능이 검색 화면에 반영되지 않음
  수정할까요?"
  ↓
[사용자] "수정해줘"
  ↓
[contentConsistencyAgent] 수정 적용
  ↓
[contentConsistencyAgent] consistency-audit.md 업데이트
```

---

## 📊 기능 × 화면 매트릭스 (기준)

| 기능 | 입력 화면 | 상세 화면 | 목록 화면 | 검색 화면 | 우선순위 |
|------|----------|----------|----------|----------|----------|
| 카테고리 | ✅ 필수 | ✅ 필수 | ✅ 필수 | ✅ 필수 | Critical |
| 시간 | ✅ 필수 | ✅ 필수 | ✅ 필수 | ✅ 필수 | Critical |
| 기한 | ✅ 필수 | ✅ 필수 | ✅ 필수 | ✅ 필수 | Critical |
| 우선순위 | ✅ 필수 | ✅ 필수 | ✅ 필수 | ✅ 필수 | Critical |
| 완료 상태 | - | ✅ 필수 | ✅ 권장 | ✅ 권장 | Important |

### 화면별 파일 매핑

- **입력 화면**: `lib/widgets/todo_input_dialog.dart`
- **상세 화면**: `lib/widgets/todo_detail_dialog.dart`
- **목록 화면**: `lib/widgets/calendar_widget.dart`
- **검색 화면**: `lib/screens/search_result_screen.dart`

### 표시 형식 기준

- **카테고리**: 칩 형태 (작은 태그)
- **시간**: "오후 3:00" 형식
- **기한**: "2026년 3월 15일" 형식
- **우선순위**: `PriorityColors.label()` 사용
- **날짜 포맷**: `KoreanDateUtils.formatKoreanDateWithWeekday()` 사용

---

## ✅ 구현 체크리스트

### Phase 1: 계획 수립 및 문서화
- [x] 상세 구현 계획 수립
- [x] `.cursor/docs/improvements/content-consistency-agent-plan.md` 생성
- [ ] 체크리스트 생성 및 관리 파일 생성

### Phase 2: 기준 정의 파일 생성
- [ ] `consistency-matrix.md` 생성 (기능 × 화면 매트릭스)

### Phase 3: Agent 파일 생성
- [ ] `contentConsistencyAgent.md` 생성
- [ ] `content_consistency_skills.md` 생성

### Phase 4: Orchestrator 통합
- [ ] `orchestrator.md` 수정 (Agent Registry + Rule 추가)

### Phase 5: 검증 및 산출물 업데이트
- [ ] 생성된 파일 검증
- [ ] `consistency-audit.md` 업데이트 (새 Agent 시스템 반영)

---

## 📝 산출물 관리 전략

### 컨텍스트 저장 및 전달 방식

1. **계획 문서**: `.cursor/docs/improvements/content-consistency-agent-plan.md`
   - 전체 계획 및 설계 원칙 저장
   - 체크리스트 포함

2. **매트릭스 파일**: `.cursor/docs/improvements/consistency-matrix.md`
   - 기능 × 화면 기준 정의
   - Agent가 참조하는 기준

3. **감사 보고서**: `.cursor/docs/improvements/consistency-audit.md`
   - 감사 결과 저장
   - Agent가 업데이트

4. **Agent 간 산출물 교환**:
   - `featureImplementation` → 산출물 생성 (JSON/Markdown)
   - `contentConsistencyAgent` → 산출물 읽기 → 감사 수행
   - 감사 결과 → 산출물 생성 → 사용자 확인 → 수정 적용

---

## 🎯 기대 효과

| 항목 | 효과 |
|---|---|
| **효율성** | 산출물 기반 감사로 빠른 실행 |
| **퀄리티** | 매트릭스 기반 명확한 기준으로 정확한 감사 |
| **안정성** | Opt-in 방식으로 예상치 못한 변경 방지 |
| **유지보수성** | 기준 파일 분리로 확장 용이 |
| **사용자 경험** | 자동 제안으로 편의성 향상 |

---

## 📅 진행 상황

- **2026-03-06**: 계획 수립 완료
- **진행 중**: Phase 1 완료, Phase 2 시작

---

## 🔗 관련 문서

- [consistency-audit.md](./consistency-audit.md) - 기존 감사 보고서
- [orchestrator.md](../../agents/orchestrator.md) - Orchestrator Agent
- [agentBuilder.md](../../agents/agentBuilder.md) - Agent Builder
