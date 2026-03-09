# 🧩 Env Orchestrator Architect Skills

## Language Separation (언어 구분)
**Internal Processing (Agent reads)**: All instructions, logic, and internal operations are in English.
**User-Facing Content (User sees)**: All explanations, designs, and suggestions shown to users are in Korean.

## Overview
This skill provides core functions for the Env Orchestrator Architect agent. It includes functions for environment analysis, routing design, handoff contract design, and conflict detection.

**한글 설명 (사용자용)**: 이 스킬은 Env Orchestrator Architect가 사용하는 핵심 기능들을 제공합니다. 환경 분석, 라우팅 설계, 핸드오프 계약 설계, 충돌 감지 등의 기능을 포함합니다.

---

## Core Skills

### 1. Environment Analysis
**Purpose**: Analyze current agent/rule/config setup and identify issues

**Input**: 
- Agent files (`.cursor/agents/*.md`)
- Rules files (`.cursor/rules/*.mdc`)
- Config files (`.cursor/config/*.json`)

**Output**: 
- Current setup summary
- Missing roles identification
- Conflicting rules detection
- Duplicate logic identification
- Outdated logic identification

**Process**:
1. Scan `.cursor/agents`, `.cursor/rules`, `.cursor/config`
2. Identify existing agents and their roles
3. Check for missing roles
4. Detect conflicting rules
5. Find duplicate or outdated logic
6. Generate analysis report

**Template (for agents, in English)**:
```
Environment Analysis:
- Agents: {agent_list}
- Rules: {rule_list}
- Missing Roles: {missing_list}
- Conflicts: {conflict_list}
- Duplicates: {duplicate_list}
- Outdated: {outdated_list}
```

**한글 예시 (사용자용)**:
```
환경 분석:
- 에이전트: orchestrator, planner, featureImplementation, testCodeGenerator
- 규칙: orchestrator.mdc, planner.mdc, agent-handoff.mdc
- 누락된 역할: 없음 ✅
- 충돌: orchestrator.mdc와 planner.mdc에서 feature_dev 라우팅 규칙 불일치 ⚠️
- 중복: 없음 ✅
- 구식: 없음 ✅
```

---

### 2. Routing Design
**Purpose**: Design intent-based routing rules for orchestrator

**Input**: 
- User intents (planning, feature_dev, bug_fix, etc.)
- Available agents
- Current routing rules

**Output**: 
- Routing rule design
- Intent-to-agent mapping
- Routing logic specification

**Process**:
1. Identify all user intents
2. Map intents to appropriate agents
3. Design routing logic
4. Specify primary and supporting agents
5. Document routing rules

**Template (for agents, in English)**:
```
Routing Design:
- Intent: {intent}
- Primary Agent: {agent}
- Supporting Agents: {agent_list}
- Routing Logic: {logic_description}
```

**한글 예시 (사용자용)**:
```
라우팅 설계:
- Intent: feature_dev
- Primary Agent: planner
- Supporting Agents: featureImplementation, testCodeGenerator
- 라우팅 로직: planner가 계획 생성 → featureImplementation이 구현 → testCodeGenerator가 테스트 생성
```

---

### 3. Handoff Contract Design
**Purpose**: Design standardized handoff contracts between agents

**Input**: 
- Agent pairs (planner → featureImplementation, etc.)
- Handoff requirements
- Current handoff patterns

**Output**: 
- Handoff contract schema
- Required fields specification
- Quality gate definition
- Contract documentation

**Process**:
1. Identify agent pairs that need handoffs
2. Define handoff requirements
3. Design contract schema (JSON-like)
4. Specify required fields
5. Define quality gates
6. Document contract in both English and Korean

**Template (for agents, in English)**:
```
Handoff Contract Design:
- From Agent: {agent}
- To Agent: {agent}
- Contract Schema: {schema}
- Required Fields: {field_list}
- Quality Gates: {gate_list}
```

**한글 예시 (사용자용)**:
```
핸드오프 계약 설계:
- From Agent: planner
- To Agent: featureImplementation
- 계약 스키마: JSON with plan_steps, impact_scope, acceptance_criteria
- 필수 필드: intent, plan_steps, impact_scope.files, acceptance_criteria, scores.overall
- 품질 게이트: scores.overall >= 70
```

---

### 4. Conflict Detection
**Purpose**: Detect conflicts in rules, agents, or configurations

**Input**: 
- Rules files
- Agent files
- Config files

**Output**: 
- Conflict list
- Conflict type classification
- Resolution suggestions

**Process**:
1. Read all rules, agents, and configs
2. Compare instructions for conflicts
3. Classify conflict types (routing, behavior, naming)
4. Identify conflicting sections
5. Generate resolution suggestions

**Template (for agents, in English)**:
```
Conflict Detection:
- Conflicts: {conflict_list}
- Conflict Types: {type_list}
- Affected Files: {file_list}
- Suggestions: {resolution_suggestions}
```

**한글 예시 (사용자용)**:
```
충돌 감지:
- 충돌: orchestrator.mdc와 planner.mdc에서 feature_dev 라우팅 규칙 불일치
- 충돌 유형: 라우팅 규칙 불일치
- 영향받는 파일: .cursor/rules/orchestrator.mdc, .cursor/rules/planner.mdc
- 제안: 두 규칙을 통합하여 일관된 라우팅 규칙으로 수정
```

---

## Skills Usage Examples

### Example 1: Environment Analysis

**Scenario**: Analyze current `.cursor` setup for issues

**Process**:
1. **Environment Analysis**: Scan all files
2. **Conflict Detection**: Find conflicts
3. **Report**: Generate analysis report

**Output**:
```
✅ 환경 분석 완료

현재 설정:
- 에이전트: 17개 (Active)
- 규칙: 9개
- 설정: 1개

이슈:
- 충돌: orchestrator.mdc와 planner.mdc에서 feature_dev 라우팅 규칙 불일치 ⚠️

제안:
- 라우팅 규칙 통합 권장
```

### Example 2: Routing Design

**Scenario**: Design routing for new intent

**Process**:
1. **Routing Design**: Map intent to agents
2. **Handoff Contract Design**: Design contracts
3. **Documentation**: Document routing rules

**Output**:
```
✅ 라우팅 설계 완료

Intent: test
- Primary Agent: testCodeGenerator
- Supporting Agents: 없음
- 라우팅 로직: testCodeGenerator가 직접 테스트 생성

핸드오프 계약:
- From: 없음 (직접 호출)
- To: testCodeGenerator
- 계약: 요청 텍스트만 전달
```

---

## Verification Skills

### Design Completeness Verification
- All intents mapped to agents
- All handoff contracts defined
- All conflicts resolved

### Reusability Verification
- Designs work across sessions
- Designs work across projects
- Minimal project-specific assumptions

---

## Important Notes

1. **Think at system level**: Design for the whole system, not individual requests
2. **Prefer minimal rules**: Keep rules small and composable
3. **Ensure reusability**: Design for cross-session and cross-project reuse
4. **Coordinate with agentBuilder**: Delegate concrete changes to agentBuilder
5. **Use Korean for users**: All user-facing content must be in Korean
