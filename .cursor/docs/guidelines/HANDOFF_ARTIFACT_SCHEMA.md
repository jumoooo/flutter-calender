# Handoff Artifact 스키마 (Handoff Artifact Schema)

## 개요

이 문서는 Agent 간 작업 전달을 위한 표준화된 Handoff Artifact 스키마를 정의합니다.

---

## 범용 Handoff Artifact 스키마

### 기본 스키마

```json
{
  "intent": "feature_dev | bug_fix | refactor | test | docs | code_explain | codebase_discovery",
  "summary": "short English summary of the change",
  "plan_steps": [
    {
      "id": "S1",
      "title": "clear, atomic step",
      "critical": true,
      "dependencies": ["S0"],
      "estimated_time": "2-3 hours"
    }
  ],
  "impact_scope": {
    "files": ["relative/path/to/file.dart"],
    "state_management": ["ProviderName.stateVariable"],
    "navigation": ["route_name"],
    "ui_components": ["ComponentName"]
  },
  "risks": [
    "risk description 1",
    "risk description 2"
  ],
  "acceptance_criteria": [
    "clear acceptance criterion 1",
    "clear acceptance criterion 2"
  ],
  "scores": {
    "quality": 85,
    "efficiency": 80,
    "stability": 90,
    "overall": 85
  },
  "evaluation_notes": "short explanation of why the scores were assigned",
  "agent_plan": [
    {
      "agent": "planner",
      "role": "planning / handoff creation"
    },
    {
      "agent": "featureImplementation",
      "role": "code implementation"
    }
  ],
  "created_at": "ISO8601 timestamp",
  "created_by": "agent_name"
}
```

---

## 필수 필드 (Required Fields)

### 모든 Handoff Artifact에 필수

```markdown
- `intent`: 작업 의도 (feature_dev, bug_fix, refactor, test, docs, code_explain, codebase_discovery)
- `summary`: 작업 요약 (영어, 간결하게)
- `plan_steps`: 실행 가능한 단계 목록 (최소 1개)
- `impact_scope.files`: 수정될 파일 목록 (최소 1개)
- `acceptance_criteria`: 수용 기준 목록 (최소 1개)
- `scores.overall`: 종합 점수 (0-100)
```

---

## Handoff 패턴

### Pattern 1: planner → featureImplementation

**사용 시나리오**: 기능 개발 계획을 구현 Agent에게 전달

**스키마**:
```json
{
  "intent": "feature_dev",
  "summary": "Add todo filtering by category",
  "plan_steps": [
    {
      "id": "S1",
      "title": "Add category filter to TodoProvider",
      "critical": true
    },
    {
      "id": "S2",
      "title": "Update TodoList widget to use filter",
      "critical": true,
      "dependencies": ["S1"]
    }
  ],
  "impact_scope": {
    "files": [
      "lib/providers/todo_provider.dart",
      "lib/widgets/todo_list.dart"
    ],
    "state_management": ["TodoProvider.filteredTodos"]
  },
  "risks": [
    "Filter logic may affect performance with large todo lists"
  ],
  "acceptance_criteria": [
    "Category filter works correctly",
    "Filtered todos update in real-time",
    "No performance degradation with 100+ todos"
  ],
  "scores": {
    "quality": 85,
    "efficiency": 80,
    "stability": 90,
    "overall": 85
  },
  "evaluation_notes": "Well-structured plan with clear steps and risk awareness",
  "agent_plan": [
    {
      "agent": "planner",
      "role": "plan creation"
    },
    {
      "agent": "featureImplementation",
      "role": "code implementation"
    },
    {
      "agent": "testCodeGenerator",
      "role": "test generation (subagent)"
    }
  ]
}
```

---

### Pattern 2: featureImplementation → codeChangeReviewer

**사용 시나리오**: 코드 변경 제안을 리뷰 Agent에게 전달

**스키마**:
```json
{
  "intent": "feature_dev",
  "summary": "Add category filter to TodoProvider",
  "plan_context": {
    "from_planner": true,
    "acceptance_criteria": [
      "Category filter works correctly",
      "Filtered todos update in real-time"
    ]
  },
  "diff": "unified diff or code before/after",
  "risk_level": "medium",
  "changed_files": [
    "lib/providers/todo_provider.dart",
    "lib/widgets/todo_list.dart"
  ]
}
```

---

### Pattern 3: planner → testCodeGenerator

**사용 시나리오**: 테스트 생성 계획을 testCodeGenerator에게 전달

**스키마**:
```json
{
  "intent": "test",
  "summary": "Generate tests for TodoProvider",
  "plan_steps": [
    {
      "id": "S1",
      "title": "Generate unit tests for all public methods",
      "critical": true
    },
    {
      "id": "S2",
      "title": "Generate widget tests for TodoList",
      "critical": false
    }
  ],
  "impact_scope": {
    "files": [
      "test/providers/todo_provider_test.dart",
      "test/widgets/todo_list_test.dart"
    ]
  },
  "acceptance_criteria": [
    "All public methods have tests",
    "Coverage ≥ 85% for TodoProvider",
    "All tests pass"
  ],
  "scores": {
    "quality": 90,
    "efficiency": 85,
    "stability": 95,
    "overall": 90
  }
}
```

---

### Pattern 4: orchestrator → multiple agents

**사용 시나리오**: 복잡한 작업을 여러 Agent에게 분배

**스키마**:
```json
{
  "intent": "feature_dev",
  "summary": "Add todo filtering and search functionality",
  "distribution_plan": {
    "primary_agent": "planner",
    "supporting_agents": [
      {
        "agent": "featureImplementation",
        "role": "filter implementation"
      },
      {
        "agent": "uiComponentBuilder",
        "role": "search UI component"
      },
      {
        "agent": "testCodeGenerator",
        "role": "test generation"
      }
    ]
  },
  "coordination_points": [
    "After planner creates plan",
    "After featureImplementation completes filter",
    "After all agents complete"
  ]
}
```

---

## Handoff 검증 메커니즘

### 1. 스키마 검증

```markdown
**검증 단계**:
1. 필수 필드 존재 확인
2. 필드 타입 검증
3. 필드 값 유효성 검증

**검증 실패 시**:
- 에러 로깅 (ERROR 레벨)
- 사용자에게 artifact 수정 요청
- agentBuilder에게 artifact 수정 위임
```

### 2. 품질 게이트

```markdown
**품질 기준**:
- `scores.overall` ≥ 70: 통과
- `scores.overall` < 70: 보강 요청 또는 사용자 확인

**보강 요청**:
- planner에게 계획 보강 요청
- 또는 사용자에게 낮은 신뢰도 알림 및 진행 여부 확인
```

### 3. 의존성 검증

```markdown
**검증 항목**:
- `plan_steps`의 dependencies가 유효한지 확인
- 순환 의존성 없음 확인
- 모든 의존성이 해결 가능한지 확인
```

---

## Handoff Artifact 생성 가이드

### planner가 생성할 때

```markdown
1. **필수 필드 채우기**:
   - intent, summary, plan_steps, impact_scope.files, acceptance_criteria, scores.overall

2. **품질 점수 계산**:
   - Quality: 요구사항 커버리지, 완전성, 명확성 (0-100)
   - Efficiency: 단계 최적화, 시간 정확성, 리소스 활용 (0-100)
   - Stability: 의존성 리스크, 롤백 가능성, 에러 처리 (0-100)
   - Overall: (Quality × 0.4) + (Efficiency × 0.35) + (Stability × 0.25)

3. **agent_plan 작성**:
   - 이번 작업에 참여할 예상 Agent 목록
   - 각 Agent의 역할 명시

4. **검증**:
   - 필수 필드 모두 채워졌는지 확인
   - scores.overall ≥ 70인지 확인
   - plan_steps가 실행 가능한지 확인
```

---

## Handoff Artifact 사용 가이드

### featureImplementation이 받을 때

```markdown
1. **Artifact 읽기**:
   - plan_steps를 구현 체크리스트로 사용
   - impact_scope.files 안에서만 변경 수행
   - acceptance_criteria를 테스트 목록으로 사용

2. **계획 준수**:
   - plan_steps 순서대로 구현
   - impact_scope를 벗어나지 않기
   - acceptance_criteria 모두 만족 확인

3. **리스크 고려**:
   - risks 목록 확인
   - scores.overall이 낮으면 추가 주의
   - 에러 처리 및 엣지 케이스 강화
```

---

## Handoff Artifact 예시

### 예시 1: 간단한 기능 개발

```json
{
  "intent": "feature_dev",
  "summary": "Add dark mode toggle",
  "plan_steps": [
    {
      "id": "S1",
      "title": "Add ThemeProvider",
      "critical": true
    },
    {
      "id": "S2",
      "title": "Add toggle button to settings",
      "critical": true,
      "dependencies": ["S1"]
    }
  ],
  "impact_scope": {
    "files": [
      "lib/providers/theme_provider.dart",
      "lib/screens/settings_screen.dart"
    ],
    "state_management": ["ThemeProvider.isDarkMode"]
  },
  "risks": [
    "Theme change may cause UI flicker"
  ],
  "acceptance_criteria": [
    "Dark mode toggle works",
    "Theme persists across app restarts",
    "No UI flicker on theme change"
  ],
  "scores": {
    "quality": 90,
    "efficiency": 85,
    "stability": 95,
    "overall": 90
  },
  "evaluation_notes": "Simple feature with clear steps and low risk",
  "agent_plan": [
    {
      "agent": "planner",
      "role": "plan creation"
    },
    {
      "agent": "featureImplementation",
      "role": "implementation"
    }
  ]
}
```

---

## 참조 문서

- `.cursor/agents/planner.md` - Phase 5.5: Handoff Artifact Creation
- `.cursor/rules/agent-handoff.mdc` - Agent Handoff 규칙
- `.cursor/docs/guidelines/ERROR_HANDLING_GUIDELINES.md` - 에러 처리 가이드라인

---

**문서 버전**: 1.0  
**최종 업데이트**: 2026-03-07  
**작성자**: Agent System Upgrade Team
