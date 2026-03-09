# 🧠 Agent Critic Skills

## Language Separation (언어 구분)
**Internal Processing (Agent reads)**: All instructions, logic, and internal operations are in English.
**User-Facing Content (User sees)**: All explanations, evaluations, and suggestions shown to users are in Korean.

## Overview
This skill provides core functions for the Agent Critic agent. It includes functions for intent/routing evaluation, plan review, code proposal review, and config/rules health check.

**한글 설명 (사용자용)**: 이 스킬은 Agent Critic이 사용하는 핵심 기능들을 제공합니다. Intent/라우팅 평가, 계획 리뷰, 코드 제안 리뷰, 설정/규칙 헬스체크 등의 기능을 포함합니다.

---

## Core Skills

### 1. Intent & Routing Evaluation
**Purpose**: Evaluate whether orchestrator's intent classification and agent routing are appropriate

**Input**: 
- Intent classification result
- Selected agents
- User request context

**Output**: 
- Routing appropriateness assessment
- Alternative routing suggestions (if needed)
- Reasoning for evaluation

**Process**:
1. Analyze user request to understand true intent
2. Check if selected intent matches request
3. Verify if chosen agents are appropriate for the intent
4. Identify any routing issues or improvements
5. Suggest alternatives if routing is suboptimal

**Template (for agents, in English)**:
```
Intent & Routing Evaluation:
- Request: {user_request}
- Selected Intent: {intent}
- Selected Agents: {agent_list}
- Appropriateness: {appropriate/inappropriate/uncertain}
- Issues: {list_of_issues}
- Suggestions: {alternative_routing_suggestions}
```

**한글 예시 (사용자용)**:
```
Intent & 라우팅 평가:
- 요청: "TodoProvider에 대한 테스트 코드 생성해줘"
- 선택된 Intent: test
- 선택된 Agents: testCodeGenerator
- 적절성: 적절 ✅
- 이슈: 없음
- 제안: 없음
```

---

### 2. Plan Review
**Purpose**: Review plans from planner for coverage, risk, and clarity

**Input**: 
- Plan artifact from planner
- Plan structure (plan_steps, impact_scope, acceptance_criteria, risks, scores)

**Output**: 
- Plan quality assessment
- Coverage gaps identification
- Risk analysis
- Clarity improvements
- Concrete suggestions

**Process**:
1. Analyze plan structure and completeness
2. Check if all requirements are captured
3. Verify if steps are atomic and actionable
4. Identify major risks and rollback considerations
5. Assess plan clarity and usability
6. Generate concrete improvement suggestions

**Template (for agents, in English)**:
```
Plan Review:
- Plan Quality: {quality_score}/100
- Coverage: {complete/incomplete} - {gaps}
- Clarity: {clear/unclear} - {issues}
- Risks: {risk_list}
- Suggestions: {improvement_suggestions}
```

**한글 예시 (사용자용)**:
```
계획 리뷰:
- 계획 품질: 85/100
- 커버리지: 완전 ✅ - 누락 없음
- 명확성: 명확 ✅ - 모든 단계가 실행 가능
- 리스크: API 연동 지연 가능성
- 제안: API 타임아웃 처리 추가 권장
```

---

### 3. Code Proposal Review
**Purpose**: Review code change proposals from dev agents for stability, efficiency, and code quality

**Input**: 
- Code diff or code snippet
- Change summary
- Acceptance criteria
- Risk level

**Output**: 
- Stability assessment
- Efficiency assessment
- Code quality assessment
- Concrete fix suggestions

**Process**:
1. Analyze code diff for stability issues:
   - Null safety violations
   - Missing mounted checks
   - State management issues
   - Error handling gaps
2. Check for efficiency issues:
   - Unnecessary rebuilds
   - Heavy operations in build
   - Missing caching opportunities
3. Assess code quality:
   - Readability and structure
   - Korean comments
   - Consistency with project style
4. Generate concrete, minimal fix suggestions

**Template (for agents, in English)**:
```
Code Proposal Review:
- Stability: {score}/100 - {issues}
- Efficiency: {score}/100 - {issues}
- Code Quality: {score}/100 - {issues}
- Overall: {score}/100
- Suggestions: {concrete_fix_suggestions}
```

**한글 예시 (사용자용)**:
```
코드 제안 리뷰:
- 안정성: 90/100 - mounted 체크 누락 1건
- 효율성: 85/100 - 불필요한 rebuild 가능성
- 코드 품질: 95/100 - 한글 주석 잘 포함됨
- 종합: 90/100
- 제안: async setState 전에 mounted 체크 추가 권장
```

---

### 4. Config / Rules Health Check
**Purpose**: Review agent/rules configuration for conflicts, duplicates, and outdated assumptions

**Input**: 
- Rules files (`.cursor/rules/*.mdc`)
- Agent files (`.cursor/agents/*.md`)
- Skills files (`.cursor/skills/*.md`)

**Output**: 
- Conflict detection report
- Duplicate rule identification
- Outdated assumption identification
- Cleanup suggestions

**Process**:
1. Read all rules, agents, and skills files
2. Identify conflicting instructions
3. Find duplicate rules or overlapping functionality
4. Detect outdated or overly specific assumptions
5. Check for missing Korean/English sections or mismatched meanings
6. Generate concrete cleanup suggestions

**Template (for agents, in English)**:
```
Config / Rules Health Check:
- Conflicts: {conflict_list}
- Duplicates: {duplicate_list}
- Outdated: {outdated_list}
- Missing Sections: {missing_list}
- Suggestions: {cleanup_suggestions}
```

**한글 예시 (사용자용)**:
```
설정/규칙 헬스체크:
- 충돌: orchestrator.mdc와 planner.mdc에서 feature_dev 라우팅 규칙 불일치
- 중복: flutter-test.mdc와 code-style.mdc에서 테스트 규칙 중복
- 구식: agentBuilder.mdc의 일부 템플릿이 2026-02-24 표준과 불일치
- 누락 섹션: 없음
- 제안: orchestrator와 planner의 feature_dev 라우팅 규칙 통합 권장
```

---

## Skills Usage Examples

### Example 1: Intent & Routing Evaluation

**Scenario**: Orchestrator routes "테스트 코드 생성" to testCodeGenerator

**Process**:
1. **Intent & Routing Evaluation**: ✅ Appropriate (test intent → testCodeGenerator)
2. **Result**: No issues, routing is correct

**Output**:
```
✅ Intent & 라우팅 평가 완료

요청: "테스트 코드 생성"
선택된 Intent: test
선택된 Agents: testCodeGenerator
평가: 적절 ✅

이슈 없음. 라우팅이 요청에 적합합니다.
```

### Example 2: Plan Review

**Scenario**: Planner creates a feature implementation plan

**Process**:
1. **Plan Review**: Analyze plan structure
2. **Coverage Check**: Verify all requirements captured
3. **Risk Analysis**: Identify potential risks
4. **Suggestions**: Generate improvement suggestions

**Output**:
```
📋 계획 리뷰 완료

계획 품질: 85/100
- 커버리지: 완전 ✅
- 명확성: 명확 ✅
- 리스크: API 연동 지연 가능성

제안:
- API 타임아웃 처리 추가 권장
- 에러 상태 UI 포함 권장
```

### Example 3: Code Proposal Review

**Scenario**: featureImplementation proposes code changes

**Process**:
1. **Code Proposal Review**: Analyze diff
2. **Stability Check**: Find null safety, mounted check issues
3. **Efficiency Check**: Identify rebuild issues
4. **Suggestions**: Generate concrete fixes

**Output**:
```
✅ 코드 제안 리뷰 완료

안정성: 90/100
- 이슈: async setState 전 mounted 체크 누락

효율성: 85/100
- 이슈: 불필요한 rebuild 가능성

제안:
- setState 전에 if (!mounted) return; 추가
- Consumer 위젯으로 rebuild 범위 축소
```

---

## Verification Skills

### Review Quality Verification
- Review covers all dimensions (stability, efficiency, quality)
- Suggestions are concrete and actionable
- Korean explanations are clear

### Lightweight Operation Verification
- Review is focused and not overly verbose
- Only critical issues are flagged
- Suggestions are minimal and targeted

---

## Important Notes

1. **Always be constructive**: Point out issues with clear, actionable suggestions
2. **Stay lightweight**: Avoid re-solving the whole problem; review and refine
3. **Prioritize safety**: Focus on stability and error prevention
4. **Respect architecture**: Follow existing rules and architecture patterns
5. **Use Korean for users**: All user-facing content must be in Korean
