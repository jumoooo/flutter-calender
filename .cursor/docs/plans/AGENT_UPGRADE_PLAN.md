# Agent 설계 보완 및 업그레이드 계획

**작성일**: 2026-03-07  
**목적**: 최신 문서 기반 Agent 시스템 개선  
**참조 문서**: 최신 Agent 설계 베스트 프랙티스 (2026-03-07 기준)

---

## 📋 목차

1. [개요](#개요)
2. [실제 구현 현황](#실제-구현-현황)
3. [Agent-Rules-Skills 매핑](#agent-rules-skills-매핑)
4. [보완 사항 요약](#보완-사항-요약)
5. [1. 명령어 중심 구조 추가](#1-명령어-중심-구조-추가)
4. [2. 3단계 경계 설정 명시](#2-3단계-경계-설정-명시)
5. [3. 검증 명령어 통합](#3-검증-명령어-통합)
6. [4. 완료 기준 명시](#4-완료-기준-명시)
7. [5. 우선순위 명시](#5-우선순위-명시)
8. [6. AGENTS.md 파일 추가 (위치: .cursor/AGENTS.md)](#6-agentsmd-파일-추가-위치-cursoragentsmd)
9. [7. Subagent 전략 명확화](#7-subagent-전략-명확화)
10. [8. 검증 메커니즘 강화](#8-검증-메커니즘-강화)
11. [9. 문서 참조 시스템](#9-문서-참조-시스템)
12. [10. Karpathy 원칙 실행 명령어화](#10-karpathy-원칙-실행-명령어화)
13. [11. Skills 파일 일관성 확보](#11-skills-파일-일관성-확보)
14. [12. 에러 처리 및 복구 전략 표준화](#12-에러-처리-및-복구-전략-표준화)
15. [13. Handoff Artifact 표준화](#13-handoff-artifact-표준화)
16. [14. 로깅 및 모니터링 체계화](#14-로깅-및-모니터링-체계화)
17. [15. 캐싱 전략 확장](#15-캐싱-전략-확장)
18. [16. Agent 상태 관리 체계화](#16-agent-상태-관리-체계화)
19. [17. 의존성 관리](#17-의존성-관리)
20. [18. Rules 파일 일관성 검증](#18-rules-파일-일관성-검증)
21. [19. 성능 최적화 전략](#19-성능-최적화-전략)
22. [20. 문서화 일관성](#20-문서화-일관성)
23. [구현 계획](#구현-계획)
24. [전체 검토 및 킥(Kick) 제안](#전체-검토-및-킥kick-제안)
25. [참조 문서](#참조-문서)
26. [문서 버전 히스토리](#문서-버전-히스토리)

---

## 개요

최신 문서들을 기반으로 현재 Agent 설계에 필요한 보완 사항을 정리했습니다.  
이 문서는 모든 보완 사항을 상세히 설명하고, 구현 계획을 제시합니다.

**핵심 원칙**: `.cursor` 폴더만 복사하면 모든 Agent 설정이 포함되도록 설계

---

## 실제 구현 현황

**최종 업데이트**: 2026-03-07 (현재 시점)  
**기준 시점**: 2026-03-07 현재 실제 구현 상태

### Agent 구현 현황

| 상태 | 개수 | Agent 목록 |
|------|------|------------|
| ✅ Active | 15개 | agentBuilder, agentCritic, apiIntegration, codeChangeReviewer, commitAgent, contentConsistencyAgent, cursorSetup, deepDiscoveryAgent, envOrchestratorArchitect, featureImplementation, orchestrator, planner, testCodeGenerator, uiComponentBuilder, uiStyleRefiner |
| ⚠️ PLANNED | 2개 | studyAgent, documentUploader |

**총 Agent 수**: 17개 (Active 15개 + PLANNED 2개)

### Skills 파일 현황

| 상태 | 개수 | Skills 파일 목록 |
|------|------|------------------|
| ✅ 보유 | 14개 | agent_builder_skills.md, agent_critic_skills.md, api_integration_skills.md, code_change_reviewer_skills.md, commit_agent_skills.md, content_consistency_skills.md, cursor_setup_skills.md, deep_discovery_agent_skills.md, env_orchestrator_architect_skills.md, feature_implementation_skills.md, orchestrator_skills.md, planner_skills.md, test_code_generator_skills.md, ui_component_builder_skills.md, ui_style_refiner_skills.md |

**Skills 보유율**: 100% (15/15 Active Agent) ✅

### Rules 파일 현황

| 상태 | 개수 | Rules 파일 목록 |
|------|------|-----------------|
| ✅ 존재 | 9개 | agent-builder.mdc, agent-handoff.mdc, bilingual-docs.mdc, code-style.mdc, deep-discovery-agent.mdc, env-orchestrator-architect.mdc, flutter-test.mdc, orchestrator.mdc, planner.mdc |

**Rules 파일 상태**: 모든 Rules 파일 정상 ✅

### 구현 진행 상황

| Phase | 상태 | 완료 여부 | 비고 |
|-------|------|----------|------|
| Phase 1: AGENTS.md 생성 | ✅ 완료 | ✅ | `.cursor/AGENTS.md` 생성 완료 (2026-03-07) |
| Phase 2: testCodeGenerator 생성 | ✅ 완료 | ✅ | testCodeGenerator Agent 생성 완료 (2026-03-07) |
| Phase 3: 기존 Agent 개선 | ✅ 완료 | ✅ | featureImplementation, planner, orchestrator, contentConsistencyAgent 개선 완료 (2026-03-07) |
| Phase 4: 문서 참조 시스템 통합 | ✅ 완료 | ✅ | 모든 주요 Agent에 Documentation References 섹션 추가 완료 (2026-03-07) |
| Phase 5: 검증 메커니즘 테스트 | ✅ 완료 | ✅ | Verification Pipeline 확인 완료 (2026-03-07) |
| Phase 6: 추가 개선 사항 구현 | ✅ 완료 | ✅ | Skills 파일 4개, 가이드라인 문서 3개, 캐싱 전략 확장 완료 (2026-03-07) |
| Phase 7: 시스템 차원 개선 | ✅ 완료 | ✅ | 의존성 관리, Rules 파일 일관성, 성능 최적화, 문서화 일관성 완료 (2026-03-07) |

**전체 진행률**: 100% ✅ (모든 Phase 완료)

### 주요 완료 사항

1. **AGENTS.md 생성 완료** ✅ (2026-03-07):
   - 프로젝트별 Agent 동작 규칙 통합
   - Commands, Testing, Structure, Style, Git Workflow, Boundaries, Success Criteria, Priority Order, Documentation References 섹션 포함

2. **testCodeGenerator 생성 완료** ✅ (2026-03-07):
   - `.cursor/agents/testCodeGenerator.md` 생성
   - `.cursor/skills/test_code_generator_skills.md` 생성
   - Orchestrator에 등록 및 Task Distribution Rule 추가
   - Core Principles 6가지, Commands, Boundaries, Success Criteria, Verification Pipeline 포함

3. **기존 Agent 개선 완료** ✅ (2026-03-07):
   - featureImplementation: Commands, Boundaries, Success Criteria 추가, Core Principles에 Karpathy 원칙 통합
   - planner: Success Criteria 추가
   - orchestrator: Success Criteria 추가
   - contentConsistencyAgent: Core Principles 보완, Success Criteria 추가

4. **문서 참조 시스템 통합 완료** ✅ (2026-03-07):
   - 모든 주요 Agent에 Documentation References 섹션 추가
   - `.cursor/AGENTS.md` 자동 참조 설정

5. **Skills 파일 생성 완료** ✅ (2026-03-07):
   - agent_critic_skills.md
   - code_change_reviewer_skills.md
   - deep_discovery_agent_skills.md
   - env_orchestrator_architect_skills.md

6. **가이드라인 문서 생성 완료** ✅ (2026-03-07):
   - ERROR_HANDLING_GUIDELINES.md
   - HANDOFF_ARTIFACT_SCHEMA.md
   - LOGGING_GUIDELINES.md

7. **캐싱 전략 확장 완료** ✅ (2026-03-07):
   - planner, featureImplementation, orchestrator, deepDiscoveryAgent에 Caching Strategy 섹션 추가

8. **의존성 관리 완료** ✅ (2026-03-07):
   - featureImplementation, planner, orchestrator에 Dependencies 섹션 추가

---

## Agent-Rules-Skills 매핑

이 섹션은 각 Agent가 어떤 Rules와 Skills를 사용하는지, 그리고 현재 상태를 명확히 보여줍니다.

### Agent별 상세 매핑

| Agent | Skills 파일 | Rules 파일 | MCP 도구 | 상태 | 비고 |
|-------|------------|-----------|---------|------|------|
| **agentBuilder** | ✅ agent_builder_skills.md | ✅ agent-builder.mdc | Codebase Search, Context7 | Active | ✅ 9-Step Upgrade Pipeline, Hard Reject System, Know Your Limits 구현 완료 (2026-03-07) |
| **agentCritic** | ✅ agent_critic_skills.md | - | Codebase Search | Active | Phase 6에서 생성 완료 (2026-03-07) |
| **apiIntegration** | ✅ api_integration_skills.md | - | Context7, Codebase Search | Active | |
| **codeChangeReviewer** | ✅ code_change_reviewer_skills.md | - | Codebase Search | Active | Phase 6에서 생성 완료 (2026-03-07) |
| **commitAgent** | ✅ commit_agent_skills.md | - | None (git 직접 사용) | Active | |
| **contentConsistencyAgent** | ✅ content_consistency_skills.md | - | Codebase Search, grep | Active | |
| **cursorSetup** | ✅ cursor_setup_skills.md | - | Codebase Search | Active | |
| **deepDiscoveryAgent** | ✅ deep_discovery_agent_skills.md | ✅ deep-discovery-agent.mdc | Codebase Search, grep, list_dir | Active | Phase 6에서 생성 완료 (2026-03-07) |
| **envOrchestratorArchitect** | ✅ env_orchestrator_architect_skills.md | ✅ env-orchestrator-architect.mdc | Codebase Search | Active | Phase 6에서 생성 완료 (2026-03-07) |
| **featureImplementation** | ✅ feature_implementation_skills.md | ✅ code-style.mdc, flutter-test.mdc | Context7, Codebase Search | Active | |
| **orchestrator** | ✅ orchestrator_skills.md | ✅ orchestrator.mdc | Codebase Search | Active | |
| **planner** | ✅ planner_skills.md | ✅ planner.mdc | Sequential Thinking, Context7, Codebase Search, Browser Tools | Active | |
| **uiComponentBuilder** | ✅ ui_component_builder_skills.md | - | Context7, Codebase Search | Active | |
| **uiStyleRefiner** | ✅ ui_style_refiner_skills.md | - | Context7, Codebase Search | Active | |
| **testCodeGenerator** | ✅ test_code_generator_skills.md | ✅ flutter-test.mdc | Context7, Codebase Search | ✅ Active | Phase 2에서 생성 완료 (2026-03-07) |
| **studyAgent** | ⏳ 예정 | - | Context7, Notion, Codebase Search | ⚠️ PLANNED | Orchestrator Registry에만 존재 |
| **documentUploader** | ⏳ 예정 | - | Notion MCP, Playwright MCP, Codebase Search | ⚠️ PLANNED | Orchestrator Registry에만 존재 |

### Rules 파일별 적용 Agent

| Rules 파일 | 적용 대상 Agent | alwaysApply |
|-----------|----------------|-------------|
| **agent-builder.mdc** | agentBuilder | true |
| **agent-handoff.mdc** | 모든 Agent (협업 시) | true |
| **bilingual-docs.mdc** | 모든 Agent | true |
| **code-style.mdc** | featureImplementation, uiComponentBuilder 등 | true |
| **deep-discovery-agent.mdc** | deepDiscoveryAgent | true |
| **env-orchestrator-architect.mdc** | envOrchestratorArchitect | true |
| **flutter-test.mdc** | testCodeGenerator, featureImplementation | true |
| **orchestrator.mdc** | orchestrator | true |
| **planner.mdc** | planner | true |

### Skills 파일 생성 우선순위

| 우선순위 | Agent | 이유 | 상태 |
|---------|-------|------|------|
| P1 | agentCritic | Meta-level critic, 복잡한 로직 | ✅ 완료 (2026-03-07) |
| P1 | codeChangeReviewer | 코드 리뷰 로직, 재사용 가능한 패턴 | ✅ 완료 (2026-03-07) |
| P2 | deepDiscoveryAgent | 프로젝트 분석 로직, 패턴 재사용 가능 | ✅ 완료 (2026-03-07) |
| P2 | envOrchestratorArchitect | 환경 설계 로직, 복잡한 분석 | ✅ 완료 (2026-03-07) |

### 개선 완료 사항 요약

1. **Skills 파일 생성 완료 (4개)**: Phase 6에서 생성 완료 ✅
2. **testCodeGenerator 생성 완료**: Phase 2에서 생성 완료 ✅
3. **AGENTS.md 생성 완료**: Phase 1에서 생성 완료 ✅
4. **기존 Agent 개선 완료**: Phase 3에서 완료 ✅
5. **문서 참조 시스템 통합 완료**: Phase 4에서 완료 ✅
6. **가이드라인 문서 생성 완료**: Phase 6에서 완료 ✅
7. **캐싱 전략 확장 완료**: Phase 6에서 완료 ✅
8. **의존성 관리 완료**: Phase 7에서 완료 ✅
3. **PLANNED Agent 문서화**: studyAgent, documentUploader 상세 문서화 필요
4. **AGENTS.md 미생성**: Phase 1에서 생성 예정

---

## 보완 사항 요약

| 번호 | 보완 사항 | 적용 대상 | 영향도 | 난이도 | 우선순위 점수 | 등급 | 예상 시간 |
|------|----------|----------|--------|--------|---------------|------|----------|
| 1 | 명령어 중심 구조 추가 | 모든 Agent | 높음(3) | 낮음(1) | 1.8 | P1 | 1-2시간 |
| 2 | 3단계 경계 설정 명시 | 모든 Agent | 높음(3) | 낮음(1) | 1.8 | P1 | 1-2시간 |
| 3 | 검증 명령어 통합 | testCodeGenerator, featureImplementation | 높음(3) | 중간(2) | 1.5 | P1 | 2-3시간 |
| 4 | 완료 기준 명시 | 모든 Agent | 중간(2) | 낮음(1) | 1.1 | P2 | 1-2시간 |
| 5 | 우선순위 명시 | 모든 Agent | 중간(2) | 낮음(1) | 1.1 | P2 | 1-2시간 |
| 6 | AGENTS.md 파일 추가 | 프로젝트 전체 | 높음(3) | 낮음(1) | 1.8 | P1 | 2-3시간 |
| 7 | Subagent 전략 명확화 | testCodeGenerator | 중간(2) | 낮음(1) | 1.1 | P2 | 1-2시간 |
| 8 | 검증 메커니즘 강화 | testCodeGenerator | 높음(3) | 중간(2) | 1.5 | P1 | 2-3시간 |
| 9 | 문서 참조 시스템 | 모든 Agent | 중간(2) | 낮음(1) | 1.1 | P2 | 1-2시간 |
| 10 | Karpathy 원칙 실행 명령어화 | 모든 Agent | 높음(3) | 중간(2) | 1.5 | P1 | 2-3시간 |
| 11 | Skills 파일 일관성 확보 | 모든 Agent | 높음(3) | 중간(2) | 1.5 | P1 | 2-3시간 |
| 12 | 에러 처리 및 복구 전략 표준화 | 모든 Agent | 높음(3) | 중간(2) | 1.5 | P1 | 2-3시간 |
| 13 | Handoff Artifact 표준화 | Agent 간 협업 | 높음(3) | 중간(2) | 1.5 | P1 | 2-3시간 |
| 14 | 로깅 및 모니터링 체계화 | 모든 Agent | 중간(2) | 중간(2) | 0.8 | P3 | 3-4시간 |
| 15 | 캐싱 전략 확장 | 모든 Agent | 중간(2) | 중간(2) | 0.8 | P3 | 2-3시간 |
| 16 | Agent 상태 관리 체계화 | System Management | 중간(2) | 중간(2) | 0.8 | P3 | 3-4시간 |
| 17 | 의존성 관리 | Agent 간 협업 | 낮음(1) | 중간(2) | 0.1 | P3 | 2-3시간 |
| 18 | Rules 파일 일관성 검증 | Rules 시스템 | 낮음(1) | 중간(2) | 0.1 | P3 | 2-3시간 |
| 19 | 성능 최적화 전략 | System 전체 | 낮음(1) | 높음(3) | -0.2 | P3 | 4-5시간 |
| 20 | 문서화 일관성 | 모든 Agent | 낮음(1) | 중간(2) | 0.1 | P3 | 2-3시간 |

**우선순위 계산 공식**: 우선순위 점수 = 영향도 점수 × 0.7 - 난이도 점수 × 0.3  
**등급 체계**: P0 (≥2.0) → P1 (1.5-1.9) → P2 (1.0-1.4) → P3 (<1.0)

---

## 1. 명령어 중심 구조 추가

### 현재 상태
- 설명 중심 구조
- 명령어가 섞여 있거나 명확하지 않음

### 보완 내용
**명령어 섹션을 최상단에 배치**하여 실행 가능한 명령어를 우선 제시

### testCodeGenerator에 추가할 섹션

```markdown
## Commands (최우선 배치)

### Test Execution
- `flutter test` - Run all tests
- `flutter test --coverage` - Run tests with coverage analysis
- `flutter test test/{directory}/` - Run tests in specific directory
- `flutter test --name {test_name}` - Run specific test

### Code Analysis
- `dart analyze` - Run static analysis
- `dart analyze --fatal-infos` - Fail on info-level issues
- `flutter analyze` - Flutter-specific analysis

### Coverage Verification
- `flutter test --coverage && genhtml coverage/lcov.info -o coverage/html` - Generate coverage report
- Target: 85-90% coverage for critical logic
```

### featureImplementation에 추가할 섹션

```markdown
## Commands

### Code Generation
- `flutter create` - Create new Flutter components
- `dart format .` - Format code
- `dart fix --apply` - Apply automated fixes

### Verification
- `flutter analyze` - Analyze code
- `flutter test` - Run tests
- `dart analyze --fatal-infos` - Strict analysis
```

### 적용 방법
1. 각 Agent 파일의 `Core Principles` 섹션 바로 다음에 `Commands` 섹션 추가
2. 설명보다 명령어를 우선 배치
3. 실행 가능한 형태로 작성

**참조**: [AGENTS.md 패턴 분석](https://blakecrosley.com/ko/blog/agents-md-patterns), [GitHub Copilot 베스트 프랙티스](https://ounols.kr/posts/github-copilot-agents-md-best-practices/)

---

## 2. 3단계 경계 설정 명시

### 현재 상태
- 원칙만 있음
- 경계가 모호함

### 보완 내용
**✅ Always / ⚠️ Ask first / 🚫 Never** 구조로 명확히 구분

### testCodeGenerator에 추가할 섹션

```markdown
## Boundaries (경계 설정)

### ✅ Always Do
- Generate unit tests for all public methods
- Include edge cases in test coverage
- Follow existing test patterns from project
- Use `Hive.init(tempDir.path)` for Hive tests
- Use fixed-duration `pump()` instead of `pumpAndSettle()` for animated widgets
- Add `await` to all async method calls
- Include Korean comments in test code

### ⚠️ Ask First
- Creating complex integration tests spanning multiple modules
- Adding new test dependencies (packages)
- Modifying existing passing tests
- Creating test utilities/helpers (unless requested)
- Changing test directory structure

### 🚫 Never Do
- Modify production code (lib/ directory)
- Use `Hive.initFlutter()` in tests
- Use `pumpAndSettle()` with AnimationController
- Skip `await` on async methods
- Modify unrelated test files
- Add unrequested abstractions or utilities
```

### featureImplementation에 추가할 섹션

```markdown
## Boundaries

### ✅ Always Do
- Follow Flutter best practices
- Include error handling
- Add Korean comments
- Maintain existing architecture
- Run `dart analyze` before completion

### ⚠️ Ask First
- Major architecture changes
- Adding new dependencies
- Changing state management patterns
- Modifying core infrastructure

### 🚫 Never Do
- Break existing functionality
- Remove code without explicit request
- Change unrelated files
- Add unrequested features
```

### 적용 방법
1. 각 Agent 파일에 `Boundaries` 섹션 추가
2. 3단계로 명확히 구분
3. 구체적인 예시 포함

**참조**: [베스트 AI 코딩 에이전트 가이드](https://nextplatform.net/agents-md-for-ai-coding-agent/), [GitHub Copilot 베스트 프랙티스](https://ounols.kr/posts/github-copilot-agents-md-best-practices/)

---

## 3. 검증 명령어 통합

### 현재 상태
- 원칙만 있음
- 검증 방법이 모호함

### 보완 내용
**각 원칙에 검증 명령어를 명시**하여 실행 가능하게 만듦

### testCodeGenerator Workflow에 추가

```markdown
### Phase 5: Test Execution and Verification

1. **Run Tests**
   ```bash
   flutter test
   ```
   - Fix any compilation errors
   - Fix any test failures

2. **Measure Coverage**
   ```bash
   flutter test --coverage
   genhtml coverage/lcov.info -o coverage/html
   ```
   - Analyze coverage report
   - Compare with targets (85-90% for critical logic)

3. **Verify Code Quality**
   ```bash
   dart analyze --fatal-infos
   ```
   - Ensure no analyzer warnings
   - Fix any style issues

4. **Report Goal Achievement**
   - Coverage achieved vs. targets
   - Test types created
   - Test cases covered
   - Any remaining gaps
```

### 적용 방법
1. Workflow의 각 Phase에 검증 명령어 추가
2. 명령어 실행 결과를 기준으로 다음 단계 결정
3. 실패 시 명확한 오류 메시지 제공

**참조**: [AGENTS.md 패턴 분석](https://blakecrosley.com/ko/blog/agents-md-patterns), [OpenCode Agents](https://opencode.ai/docs/ko/agents/)

---

## 4. 완료 기준 명시

### 현재 상태
- 모호한 표현 ("적절히 테스트", "완료")
- 완료 여부 판단이 어려움

### 보완 내용
**명확한 완료 기준 정의** 및 우선순위 부여

### testCodeGenerator에 추가할 섹션

```markdown
## Success Criteria (완료 기준)

### Priority 1: Test Execution
- ✅ All tests pass: `flutter test` exits with code 0
- ✅ No compilation errors
- ✅ No test failures

### Priority 2: Coverage Target
- ✅ Coverage ≥ 85% for critical logic (providers, services, models)
- ✅ Coverage ≥ 70% for UI components
- ✅ All public methods have at least one test

### Priority 3: Code Quality
- ✅ `dart analyze` passes with no errors
- ✅ All tests follow project patterns
- ✅ Korean comments included for clarity

### Verification Command
```bash
flutter test --coverage && \
dart analyze --fatal-infos && \
genhtml coverage/lcov.info -o coverage/html
```

**Complete when**: All Priority 1, 2, 3 criteria are met.
```

### 적용 방법
1. 각 Agent에 `Success Criteria` 섹션 추가
2. 우선순위별로 구분
3. 검증 명령어 포함
4. 완료 조건 명시

**참조**: [AGENTS.md 패턴 분석](https://blakecrosley.com/ko/blog/agents-md-patterns), [GitHub Copilot 베스트 프랙티스](https://ounols.kr/posts/github-copilot-agents-md-best-practices/)

---

## 5. 우선순위 명시

### 현재 상태
- 충돌하는 지시 가능성
- 우선순위 불명확

### 보완 내용
**명확한 우선순위 부여**로 충돌 방지

### testCodeGenerator Core Principles에 추가

```markdown
## Priority Order (우선순위)

When principles conflict, follow this order:

1. **Test Correctness** (Highest)
   - Tests must pass
   - Tests must be accurate
   - Overrides: Simplicity, Pattern Reuse

2. **Code Simplicity**
   - No unrequested abstractions
   - Overrides: Pattern Reuse (if pattern is overly complex)

3. **Pattern Reuse**
   - Follow existing test patterns
   - Overrides: Goal-Driven (if pattern exists)

4. **Goal Achievement**
   - Meet coverage targets
   - Overrides: Surgical Changes (if needed for coverage)

5. **Surgical Changes** (Lowest)
   - Only modify requested files
   - Overrides: None (always respect)
```

### 적용 방법
1. 각 Agent에 `Priority Order` 섹션 추가
2. 원칙 간 충돌 시 우선순위 명시
3. 예외 상황 처리 방법 포함

**참조**: [AGENTS.md 패턴 분석](https://blakecrosley.com/ko/blog/agents-md-patterns)

---

## 6. AGENTS.md 파일 추가 (위치: .cursor/AGENTS.md)

### 현재 상태
- AGENTS.md 파일 없음
- 프로젝트별 Agent 동작 규칙이 분산됨

### 보완 내용
**`.cursor/AGENTS.md` 파일 생성**하여 프로젝트별 Agent 동작 규칙 통합

### 파일 위치
- **경로**: `.cursor/AGENTS.md`
- **목적**: AI 코딩 에이전트가 프로젝트에서 어떻게 동작해야 하는지 정의
- **참조**: 모든 Agent가 이 파일을 자동으로 참조

### 구조

```markdown
# AGENTS.md

이 파일은 AI 코딩 에이전트가 프로젝트에서 어떻게 동작해야 하는지 정의합니다.
`.cursor` 폴더와 함께 이식 가능하도록 설계되었습니다.

## Commands (명령어)

### Test Code Generation
- `flutter test` - Run all tests
- `flutter test --coverage` - Measure coverage
- `flutter test test/{directory}/` - Run tests in specific directory
- `flutter test --name {test_name}` - Run specific test
- `dart analyze` - Run static analysis
- `dart analyze --fatal-infos` - Fail on info-level issues
- `genhtml coverage/lcov.info -o coverage/html` - Generate coverage report

### Code Quality
- `flutter analyze` - Flutter-specific analysis
- `dart format .` - Format code
- `dart fix --apply` - Apply automated fixes

## Testing (테스트)

### Framework
- Flutter Test Framework (`package:test`)
- Mockito for mocking (if needed)
- Integration test support

### Structure
- `test/` - All test files
- `test/models/` - Model tests
- `test/providers/` - Provider tests
- `test/widgets/` - Widget tests
- `test/integration/` - Integration tests

### Patterns
- Use `test()` for unit tests
- Use `testWidgets()` for widget tests
- Use `group()` to organize related tests
- Use `setUp()` / `tearDown()` for test isolation
- Use `setUpAll()` / `tearDownAll()` for shared resources (Hive)

### Style
- Test file naming: `{component}_test.dart`
- Test naming: Descriptive Korean or English
- Group naming: `{Component} Tests`
- Include Korean comments for clarity

## Structure (구조)

### Test Directory
```
test/
├── models/
│   └── {model}_test.dart
├── providers/
│   └── {provider}_test.dart
├── widgets/
│   └── {widget}_test.dart
└── integration/
    └── {feature}_test.dart
```

### Code Organization
- One test file per implementation file
- Mirror `lib/` structure in `test/`
- Keep tests close to implementation when possible

## Style (스타일)

### Test Code Style
- Use descriptive test names
- Include setup/teardown for isolation
- Use `expect()` with clear assertions
- Include Korean comments for complex logic
- Follow existing test patterns in project

### Code Comments
- Korean comments for user-facing explanations
- English comments for technical details
- Document test assumptions and edge cases

## Git Workflow (Git 워크플로우)

### Test Commits
- Commit tests with implementation code
- Use conventional commits: `test: add tests for {component}`
- Include coverage reports in PR descriptions

### Branch Strategy
- Create test branches: `test/{feature-name}`
- Merge tests with feature branches
- Keep test coverage above 85% for critical logic

## Boundaries (경계)

### ✅ Always Do
- Generate unit tests for all public methods
- Include edge cases in test coverage
- Follow existing test patterns from project
- Use `Hive.init(tempDir.path)` for Hive tests
- Use fixed-duration `pump()` instead of `pumpAndSettle()` for animated widgets
- Add `await` to all async method calls
- Include Korean comments in test code
- Run `dart analyze` before committing

### ⚠️ Ask First
- Creating complex integration tests spanning multiple modules
- Adding new test dependencies (packages)
- Modifying existing passing tests
- Creating test utilities/helpers (unless requested)
- Changing test directory structure
- Adding new test frameworks

### 🚫 Never Do
- Modify production code (lib/ directory) from test generation
- Use `Hive.initFlutter()` in tests
- Use `pumpAndSettle()` with AnimationController
- Skip `await` on async methods
- Modify unrelated test files
- Add unrequested abstractions or utilities
- Change project structure without approval
- Remove existing tests without explicit request

## Success Criteria (완료 기준)

### Priority 1: Test Execution
- ✅ All tests pass: `flutter test` exits with code 0
- ✅ No compilation errors
- ✅ No test failures

### Priority 2: Coverage Target
- ✅ Coverage ≥ 85% for critical logic (providers, services, models)
- ✅ Coverage ≥ 70% for UI components
- ✅ All public methods have at least one test

### Priority 3: Code Quality
- ✅ `dart analyze` passes with no errors
- ✅ All tests follow project patterns
- ✅ Korean comments included for clarity

### Verification Command
```bash
flutter test --coverage && \
dart analyze --fatal-infos && \
genhtml coverage/lcov.info -o coverage/html
```

**Complete when**: All Priority 1, 2, 3 criteria are met.

## Priority Order (우선순위)

When principles conflict, follow this order:

1. **Test Correctness** (Highest)
   - Tests must pass
   - Tests must be accurate
   - Overrides: Simplicity, Pattern Reuse

2. **Code Simplicity**
   - No unrequested abstractions
   - Overrides: Pattern Reuse (if pattern is overly complex)

3. **Pattern Reuse**
   - Follow existing test patterns
   - Overrides: Goal-Driven (if pattern exists)

4. **Goal Achievement**
   - Meet coverage targets
   - Overrides: Surgical Changes (if needed for coverage)

5. **Surgical Changes** (Lowest)
   - Only modify requested files
   - Overrides: None (always respect)

## Documentation References (문서 참조)

### Auto-Reference Documents
- `.cursor/rules/flutter-test.mdc` - Flutter testing guidelines
- `.cursor/AGENTS.md` - This file (project-specific agent rules)
- `.cursor/docs/deep-discovery/*.json` - Project structure context

### External Documentation
- Flutter Testing Guide (Indexing & Docs)
- Flutter Test Framework (Indexing & Docs)
- Dart Language Tour (Indexing & Docs)
```

### 적용 방법
1. `.cursor/AGENTS.md` 파일 생성
2. 위 구조대로 작성
3. 프로젝트 특성에 맞게 커스터마이징
4. 모든 Agent가 이 파일을 참조하도록 설정

**참조**: [AGENTS.md 패턴 분석](https://blakecrosley.com/ko/blog/agents-md-patterns), [GitHub Copilot 베스트 프랙티스](https://ounols.kr/posts/github-copilot-agents-md-best-practices/)

---

## 7. Subagent 전략 명확화

### 현재 상태
- testCodeGenerator 역할만 정의
- Primary vs Subagent 구분 없음

### 보완 내용
**Primary vs Subagent 구분 명시** 및 사용 패턴 정의

### testCodeGenerator Orchestrator Integration에 추가

```markdown
## Agent Type

- **Primary Agent**: Can be invoked directly by users (`@testCodeGenerator`)
- **Subagent**: Can be invoked by orchestrator after feature implementation
- **Both**: Supports both usage patterns

### Subagent Collaboration
When invoked as subagent:
- Receives handoff artifact from `featureImplementation`
- Generates tests for implemented features
- Reports back to orchestrator

### Primary Agent Usage
When invoked as primary agent:
- User directly requests test generation
- Analyzes implementation code
- Generates comprehensive test suite
```

### 적용 방법
1. 각 Agent에 `Agent Type` 섹션 추가
2. Primary/Subagent 구분 명시
3. 사용 패턴 정의

**참조**: [OpenCode Agents](https://opencode.ai/docs/ko/agents/), [Ralph Playbook 방법론](https://blog.choonzang.com/it/software/4353/)

---

## 8. 검증 메커니즘 강화

### 현재 상태
- 검증 단계가 모호함
- 정확한 검증 명령어 부재

### 보완 내용
**정확한 검증 명령어와 완료 기준** 명시

### testCodeGenerator에 추가할 섹션

```markdown
## Verification Pipeline

### Step 1: Test Execution
```bash
flutter test
```
**Expected**: Exit code 0, all tests pass

### Step 2: Coverage Analysis
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```
**Expected**: Coverage ≥ 85% for critical logic

### Step 3: Code Quality
```bash
dart analyze --fatal-infos
```
**Expected**: No errors, no warnings

### Step 4: Pattern Compliance
- Manual review: Tests follow existing patterns
- Manual review: Korean comments included
```

### 적용 방법
1. 각 Agent에 `Verification Pipeline` 섹션 추가
2. 단계별 검증 명령어 명시
3. 예상 결과 정의
4. 실패 시 처리 방법 포함

**참조**: [Ralph Playbook 방법론](https://blog.choonzang.com/it/software/4353/), [GitHub Copilot 베스트 프랙티스](https://ounols.kr/posts/github-copilot-agents-md-best-practices/)

---

## 9. 문서 참조 시스템

### 현재 상태
- Agent 파일만 참조
- 외부 문서 참조 구조 없음

### 보완 내용
**외부 문서 자동 참조 구조** 추가

### testCodeGenerator에 추가할 섹션

```markdown
## Documentation References

### Auto-Reference Documents
- `.cursor/rules/flutter-test.mdc` - Flutter testing guidelines
- `.cursor/AGENTS.md` - Project-specific agent rules
- `.cursor/docs/deep-discovery/*.json` - Project structure context

### External Documentation
- Flutter Testing Guide (Indexing & Docs)
- Flutter Test Framework (Indexing & Docs)
```

### 적용 방법
1. 각 Agent에 `Documentation References` 섹션 추가
2. 자동 참조 문서 목록
3. 외부 문서 참조 방법

**참조**: [Ralph Playbook 방법론](https://blog.choonzang.com/it/software/4353/)

---

## 10. Karpathy 원칙 실행 명령어화

### 현재 상태
- 개념적 원칙만 있음
- 실행 방법 불명확

### 보완 내용
**각 원칙에 검증 명령어 연결**

### testCodeGenerator Core Principles에 추가

```markdown
### 1. Think Before Testing
**Verification**: Before generating tests, list:
- Assumptions about code structure
- Uncertainties about requirements
- Test cases to cover (minimum 5)

**Command**: None (internal process)

### 2. Simplicity First
**Verification**: 
```bash
dart analyze --fatal-infos
```
**Check**: No unrequested utilities/abstractions

### 3. Surgical Changes
**Verification**: 
```bash
git diff --name-only
```
**Check**: Only test files modified

### 4. Goal-Driven Execution
**Verification**:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```
**Check**: Coverage targets met (85-90%)
```

### 적용 방법
1. 각 Core Principle에 `Verification` 섹션 추가
2. 검증 명령어 명시
3. 확인 사항 정의

**참조**: [Karpathy 가이드라인](https://playbooks.com/skills/forrestchang/andrej-karpathy-skills/karpathy-guidelines)

---

## 11. Skills 파일 일관성 확보

### 현재 상태
- 일부 Agent만 Skills 파일 보유 (14개 Agent 중 10개)
- 누락: `agentCritic`, `codeChangeReviewer`, `deepDiscoveryAgent`, `envOrchestratorArchitect`
- Skills 파일 구조가 일관되지 않을 수 있음

### 보완 내용
**모든 Agent에 Skills 파일 생성 또는 명시적 제외 사유 문서화**

### 적용 방법

#### 1. Skills 파일 생성 기준
- **필수 생성**: 복잡한 로직이나 재사용 가능한 패턴이 있는 Agent
- **선택 생성**: 단순한 Agent는 Agent 파일 내에 포함 가능
- **제외 사유 문서화**: Skills 파일이 없는 경우 Agent 파일에 명시

#### 2. Skills 파일 템플릿 표준화
```markdown
# {Agent Name} Skills

## Language Separation
**Internal Processing**: English
**User-Facing**: Korean

## Overview
[English overview of skills]

**한글 설명 (사용자용)**: [Korean overview]

## Core Skills

### 1. {Skill Name}
**Purpose**: [English purpose]

**Input**: 
- [Input parameters]

**Output**: 
- [Output description]

**Verification**:
- [How to verify this skill works]

**Template**:
[Korean template for users]

**Example**:
[Korean example]
```

#### 3. Skills 파일 일관성 검증
- 모든 Skills 파일이 동일한 구조를 따르는지 확인
- 필수 섹션 포함 여부 검증
- 언어 구분 준수 확인

### 적용 대상
1. `agentCritic` → `agent_critic_skills.md` 생성
2. `codeChangeReviewer` → `code_change_reviewer_skills.md` 생성
3. `deepDiscoveryAgent` → `deep_discovery_agent_skills.md` 생성
4. `envOrchestratorArchitect` → `env_orchestrator_architect_skills.md` 생성
5. 기존 Skills 파일 구조 일관성 검증

**참조**: `.cursor/templates/agent_template.md`, 기존 Skills 파일들

---

## 12. 에러 처리 및 복구 전략 표준화

### 현재 상태
- MCP Context7 가이드라인만 존재 (`.cursor/docs/guidelines/MCP_CONTEXT7_GUIDELINES.md`)
- 다른 MCP 도구(Notion, Browser Tools, Sequential Thinking) 에러 처리 부족
- 일반적인 Agent 실패 시 복구 전략 부족

### 보완 내용
**공통 에러 처리 전략 문서화 및 모든 Agent에 적용**

### 공통 에러 처리 가이드라인 생성

`.cursor/docs/guidelines/ERROR_HANDLING_GUIDELINES.md` 파일 생성:

```markdown
# 에러 처리 및 복구 전략 가이드라인

## MCP 도구별 에러 처리

### Context7
- 타임아웃: 10초, 최대 재시도 1회
- 폴백: Indexing & Docs → Codebase Search
- 에러 로깅: 내부용 (사용자에게 노출하지 않음)

### Notion MCP
- API 실패: Browser automation으로 폴백
- 권한 오류: 사용자에게 명확한 오류 메시지
- 타임아웃: 15초, 재시도 1회

### Browser Tools (Playwright)
- 페이지 로드 실패: 재시도 1회, 실패 시 사용자 알림
- 요소 찾기 실패: 스크린샷 저장 후 사용자에게 보고
- 타임아웃: 30초

### Sequential Thinking
- 타임아웃: 60초 (복잡한 사고 프로세스)
- 실패 시: 단순화된 접근 방식으로 폴백

### Codebase Search
- 검색 결과 없음: 사용자에게 명확한 피드백
- 타임아웃: 5초, 즉시 폴백 없음 (로컬 작업)

## Agent 실패 시 복구 전략

### 1. 부분 실패 처리
- 일부 작업만 완료된 경우: 완료된 부분 보고, 실패한 부분 재시도
- 사용자에게 진행 상황 명확히 보고

### 2. 완전 실패 처리
- 명확한 오류 메시지 제공 (한국어)
- 복구 옵션 제시 (범위 축소, 다른 접근 방식 등)
- 사용자 확인 후 재시도

### 3. 자동 복구
- 일시적 오류 (네트워크, 타임아웃): 자동 재시도
- 영구적 오류 (권한, 잘못된 입력): 사용자 확인 필요

## 에러 로깅 표준

### 로깅 레벨
- **ERROR**: 복구 불가능한 오류
- **WARNING**: 복구 가능한 오류
- **INFO**: 일반 정보 (성능 메트릭 등)

### 로깅 형식
```
[AGENT_NAME] [LEVEL] [TIMESTAMP] [MESSAGE]
[CONTEXT] (optional)
```

### 로깅 위치
- 내부 로깅: `.cursor/logs/` (선택적, 사용자에게 노출하지 않음)
- 사용자 보고: 한국어로 명확한 메시지
```

### 적용 방법
1. `.cursor/docs/guidelines/ERROR_HANDLING_GUIDELINES.md` 파일 생성
2. 모든 Agent의 Workflow에 에러 처리 단계 추가
3. MCP 도구 사용 시 폴백 전략 명시

**참조**: `.cursor/docs/guidelines/MCP_CONTEXT7_GUIDELINES.md`

---

## 13. Handoff Artifact 표준화

### 현재 상태
- `planner` → `featureImplementation` handoff만 정의
- 다른 Agent 간 handoff 표준 부족
- Handoff 검증 메커니즘 부족

### 보완 내용
**범용 Handoff Artifact 스키마 정의 및 모든 Agent 간 협업에 적용**

### 범용 Handoff Artifact 스키마

```json
{
  "version": "1.0",
  "intent": "feature_dev | bug_fix | refactor | test | docs | code_explain",
  "from_agent": "agent_name",
  "to_agent": "agent_name",
  "summary": "short English summary",
  "context": {
    "project_root": "path/to/project",
    "deep_discovery_report": "path/to/report.json",
    "related_files": ["file1.dart", "file2.dart"]
  },
  "task": {
    "description": "clear task description",
    "steps": [
      {"id": "S1", "title": "step title", "critical": true}
    ],
    "acceptance_criteria": ["criterion 1", "criterion 2"],
    "constraints": ["constraint 1", "constraint 2"]
  },
  "impact_scope": {
    "files": ["relative/path/to/file.dart"],
    "directories": ["lib/providers/"],
    "state_management": ["ProviderName.state"],
    "navigation": ["route_name"]
  },
  "risks": [
    {"level": "low|medium|high", "description": "risk description", "mitigation": "mitigation strategy"}
  ],
  "quality_metrics": {
    "scores": {
      "quality": 0,
      "efficiency": 0,
      "stability": 0,
      "overall": 0
    },
    "evaluation_notes": "short explanation"
  },
  "agent_plan": [
    {
      "agent": "agent_name",
      "role": "role description",
      "sequence": 1
    }
  ],
  "metadata": {
    "created_at": "ISO 8601 timestamp",
    "expires_at": "ISO 8601 timestamp (optional)",
    "priority": "low|medium|high|critical"
  }
}
```

### Handoff 패턴 정의

#### Pattern 1: Planner → Dev Agent
- **From**: `planner`
- **To**: `featureImplementation`, `apiIntegration`, `uiComponentBuilder` 등
- **Artifact**: 위 스키마 사용

#### Pattern 2: Dev Agent → Test Agent
- **From**: `featureImplementation`
- **To**: `testCodeGenerator`
- **Artifact**: 구현 파일 목록, 테스트 범위, 커버리지 목표

#### Pattern 3: Dev Agent → Reviewer
- **From**: `featureImplementation`
- **To**: `codeChangeReviewer`, `agentCritic`
- **Artifact**: Diff, 변경 파일 목록, 리스크 레벨

#### Pattern 4: Orchestrator → Multiple Agents
- **From**: `orchestrator`
- **To**: 여러 Agent
- **Artifact**: 각 Agent별로 분할된 Handoff Artifact

### Handoff 검증 메커니즘

```markdown
## Handoff Validation

### Required Fields Check
- [ ] `intent` exists and is valid
- [ ] `from_agent` and `to_agent` exist
- [ ] `task.steps` is non-empty
- [ ] `impact_scope.files` is non-empty (if applicable)
- [ ] `acceptance_criteria` is non-empty

### Quality Gate
- [ ] `quality_metrics.scores.overall` ≥ 70 (or configurable threshold)
- [ ] All critical steps identified
- [ ] Risks documented with mitigation

### Rejection Conditions
- Missing required fields → Request refinement from source agent
- Low quality score → Request improvement or user confirmation
- Ambiguous task description → Request clarification
```

### 적용 방법
1. `.cursor/docs/guidelines/HANDOFF_ARTIFACT_SCHEMA.md` 파일 생성
2. 모든 Agent 간 협업에 Handoff Artifact 사용
3. Handoff 검증 메커니즘 통합

**참조**: `.cursor/rules/agent-handoff.mdc`, `planner.md` Phase 5.5

---

## 14. 로깅 및 모니터링 체계화

### 현재 상태
- MCP Context7 가이드라인에 내부 로깅만 언급
- Agent별 로깅 전략 부재
- 성능 모니터링 체계 없음

### 보완 내용
**로깅 표준 정의 및 성능 모니터링 체계 구축**

### 로깅 가이드라인 생성

`.cursor/docs/guidelines/LOGGING_GUIDELINES.md` 파일 생성:

```markdown
# 로깅 및 모니터링 가이드라인

## 로깅 레벨

### ERROR
- 복구 불가능한 오류
- 사용자 개입 필요
- 예: MCP 도구 완전 실패, 파일 시스템 오류

### WARNING
- 복구 가능한 오류
- 폴백 전략 사용
- 예: Context7 타임아웃, 일시적 네트워크 오류

### INFO
- 일반 정보
- 성능 메트릭, 작업 진행 상황
- 예: Agent 호출, 작업 완료

### DEBUG
- 디버깅 정보 (개발 중에만)
- 상세한 실행 흐름
- 예: 각 단계별 상세 로그

## 로깅 포인트

### 필수 로깅 포인트
1. **Agent 시작**: Agent 이름, 요청 내용
2. **MCP 도구 호출**: 도구 이름, 성공/실패
3. **중요 결정**: Intent 분류, Agent 선택
4. **에러 발생**: 에러 타입, 복구 시도
5. **작업 완료**: 완료 시간, 결과 요약

### 선택적 로깅 포인트
- 각 Workflow Phase 시작/완료
- 캐시 히트/미스
- 성능 메트릭 (응답 시간, 처리량)

## 로깅 형식

### 표준 형식
```
[AGENT_NAME] [LEVEL] [TIMESTAMP] [MESSAGE]
[CONTEXT] (optional)
[STACK_TRACE] (ERROR 레벨만)
```

### 예시
```
[orchestrator] [INFO] [2026-03-07T10:30:00Z] Intent classified: feature_dev
[orchestrator] [INFO] [2026-03-07T10:30:01Z] Selected agents: planner, featureImplementation
[planner] [WARNING] [2026-03-07T10:30:15Z] Context7 timeout, using fallback
[featureImplementation] [ERROR] [2026-03-07T10:35:00Z] File write failed: permission denied
```

## 성능 모니터링

### 메트릭 수집
- **Agent 응답 시간**: 요청부터 완료까지
- **MCP 도구 응답 시간**: 호출부터 응답까지
- **작업 처리량**: 시간당 처리 작업 수
- **에러율**: 전체 요청 대비 에러 비율

### 모니터링 대시보드 (선택적)
- Agent별 성능 비교
- MCP 도구 사용 통계
- 에러 패턴 분석

## 로깅 저장 위치

### 내부 로깅
- **경로**: `.cursor/logs/` (선택적, gitignore에 추가)
- **파일명**: `agent_{name}_{date}.log`
- **보관 기간**: 7일 (설정 가능)

### 사용자 보고
- **형식**: 한국어로 명확한 메시지
- **위치**: 채팅 응답
- **레벨**: ERROR, WARNING만 사용자에게 노출
```

### 적용 방법
1. `.cursor/docs/guidelines/LOGGING_GUIDELINES.md` 파일 생성
2. 모든 Agent의 Workflow에 로깅 포인트 추가
3. 성능 메트릭 수집 시작 (선택적)

---

## 15. 캐싱 전략 확장

### 현재 상태
- Context7 Library ID 캐싱만 언급
- 다른 캐싱 전략 부족

### 보완 내용
**캐싱 전략 확장 및 모든 Agent에 적용**

### 캐싱 전략 정의

```markdown
## Caching Strategy

### 1. Deep Discovery 리포트 캐싱
- **키**: `{project_root}_{branch}_{mode}_{depth}`
- **TTL**: 7일
- **검증**: 파일 존재 및 타임스탬프 확인
- **무효화**: 프로젝트 구조 변경 감지 시

### 2. Codebase Search 결과 캐싱
- **키**: `{query_hash}_{file_pattern}`
- **TTL**: 1시간 (코드 변경 가능성 고려)
- **검증**: 파일 수정 시간 확인
- **무효화**: 관련 파일 변경 시

### 3. Context7 쿼리 결과 캐싱
- **키**: `{library_id}_{query_hash}`
- **TTL**: 24시간 (문서 변경 빈도 낮음)
- **검증**: Library 버전 확인
- **무효화**: Library 업데이트 시

### 4. Agent Registry 캐싱
- **키**: `agent_registry`
- **TTL**: 무제한 (Agent 추가 시 무효화)
- **검증**: `.cursor/agents/` 디렉토리 변경 확인
- **무효화**: Agent 파일 추가/삭제/수정 시

### 캐시 저장 위치
- **메모리 캐시**: 세션 내 유지
- **파일 캐시**: `.cursor/cache/` (선택적)
- **Gitignore**: `.cursor/cache/` 추가
```

### 적용 방법
1. 각 Agent에 캐싱 전략 명시
2. 캐시 무효화 조건 정의
3. 캐시 히트율 모니터링 (선택적)

---

## 16. Agent 상태 관리 체계화

### 현재 상태
- Agent Registry에 상태 표시 (Active, Planned)
- 상태 전환 프로세스 부재

### 보완 내용
**Agent 상태 정의 및 상태 전환 프로세스 문서화**

### Agent 상태 정의

```markdown
## Agent States

### Active
- Agent 파일 존재
- Skills 파일 존재 (해당되는 경우)
- Orchestrator에 등록됨
- 정상 동작 중

### Planned
- Agent 계획만 있음
- Agent 파일 미생성
- 향후 구현 예정

### Deprecated
- 더 이상 사용하지 않음
- 대체 Agent 존재
- 마이그레이션 가이드 제공

### Maintenance
- 일시적 사용 중단
- 버그 수정 중
- 곧 Active로 복귀 예정

### Experimental
- 실험적 기능
- 안정성 보장 없음
- 피드백 수집 중
```

### 상태 전환 프로세스

```markdown
## State Transition Process

### Planned → Active
1. Agent 파일 생성
2. Skills 파일 생성 (해당되는 경우)
3. Orchestrator에 등록
4. 테스트 완료
5. 상태 업데이트

### Active → Deprecated
1. 대체 Agent 확인
2. 마이그레이션 가이드 작성
3. Orchestrator에서 제거
4. 상태 업데이트
5. 사용자 알림

### Active → Maintenance
1. 문제 식별
2. 상태 업데이트
3. Orchestrator에서 일시 제외
4. 수정 완료 후 Active로 복귀
```

### 적용 방법
1. Agent Registry에 상태 관리 섹션 추가
2. 상태 전환 프로세스 문서화
3. 상태별 동작 규칙 정의

---

## 17. 의존성 관리

### 현재 상태
- Agent 간 협업은 언급되지만 의존성 명시 부족
- 순환 의존성 검증 부족

### 보완 내용
**Agent 의존성 그래프 생성 및 순환 의존성 검증**

### 의존성 정의

```markdown
## Agent Dependencies

### Direct Dependencies
- **featureImplementation** depends on:
  - `planner` (for implementation plans)
  - `uiComponentBuilder` (for UI components)
  - `apiIntegration` (for API integration)

### Indirect Dependencies
- **testCodeGenerator** depends on:
  - `featureImplementation` (for implementation code)
  - `planner` (indirect, via featureImplementation)

### Dependency Graph
```
orchestrator
  ├── planner
  │     └── deepDiscoveryAgent
  ├── featureImplementation
  │     ├── planner
  │     ├── uiComponentBuilder
  │     └── apiIntegration
  └── testCodeGenerator
        └── featureImplementation
```

### 순환 의존성 검증
- **검증 도구**: `envOrchestratorArchitect` 또는 `agentBuilder`
- **검증 시점**: Agent 생성/수정 시
- **에러 처리**: 순환 의존성 발견 시 즉시 중단, 사용자에게 보고
```

### 적용 방법
1. 각 Agent에 `Dependencies` 섹션 추가
2. 의존성 그래프 자동 생성 도구 개발 (선택적)
3. 순환 의존성 검증 메커니즘 통합

---

## 18. Rules 파일 일관성 검증

### 현재 상태
- Rules 파일 9개 존재
- 구조 및 적용 방식 일관성 검증 부족

### 보완 내용
**Rules 파일 템플릿 표준화 및 충돌 검증 자동화**

### Rules 파일 템플릿 표준화

```markdown
---
alwaysApply: true | false
description: "Rule description in English"
globs: "*.dart,*.md"  # optional
---

## Internal Instructions (English)

- Purpose: [Short English description]
- Scope: [What files/directories this applies to]
- Behavior: [How the rule behaves]

## 사용자용 설명 (한글)

[Korean explanation for users]
```

### Rules 충돌 검증

```markdown
## Rules Conflict Detection

### 검증 항목
1. **중복 규칙**: 같은 목적의 규칙이 여러 파일에 있는지
2. **충돌 규칙**: 서로 모순되는 규칙이 있는지
3. **우선순위**: `alwaysApply: true` 규칙 간 충돌 시 우선순위
4. **Globs 충돌**: 같은 파일에 적용되는 규칙 간 충돌

### 검증 도구
- `agentCritic` (config health check 모드)
- `envOrchestratorArchitect`

### 검증 시점
- Rules 파일 생성/수정 시
- 정기적 검증 (주 1회, 선택적)
```

### 적용 방법
1. Rules 파일 템플릿 표준화
2. 충돌 검증 자동화 도구 개발 (선택적)
3. Rules 적용 우선순위 명시

---

## 19. 성능 최적화 전략

### 현재 상태
- 개별 Agent 최적화는 있으나 시스템 차원 전략 부족

### 보완 내용
**시스템 차원 성능 최적화 전략 수립**

### 최적화 전략

```markdown
## Performance Optimization Strategy

### 1. Agent 호출 최적화
- **병렬 실행**: 독립적인 Agent는 병렬 호출
- **순차 실행**: 의존성이 있는 Agent는 순차 호출
- **조기 종료**: 실패 시 불필요한 Agent 호출 중단

### 2. 컨텍스트 재사용
- **Deep Discovery 리포트**: 7일간 재사용
- **Codebase Search 결과**: 1시간간 재사용
- **Agent Registry**: Agent 변경 시까지 재사용

### 3. 불필요한 작업 방지
- **조건부 실행**: 필요할 때만 Agent 호출
- **캐시 활용**: 동일한 요청은 캐시 사용
- **점진적 로딩**: 필요한 정보만 로드

### 4. MCP 도구 최적화
- **Indexing & Docs 우선**: 가장 빠른 소스
- **Context7 조건부**: 필요할 때만 호출
- **타임아웃 설정**: 무한 대기 방지
```

### 적용 방법
1. Orchestrator에 성능 최적화 로직 추가
2. Agent 호출 패턴 분석 및 최적화
3. 성능 메트릭 수집 및 분석

---

## 20. 문서화 일관성

### 현재 상태
- Agent별 문서화 수준 상이
- 공통 섹션 누락 가능

### 보완 내용
**Agent 문서화 체크리스트 및 필수 섹션 검증**

### 문서화 체크리스트

```markdown
## Agent Documentation Checklist

### 필수 섹션
- [ ] Frontmatter (name, model, description, category)
- [ ] Language Separation
- [ ] Role (영어 + 한글)
- [ ] Goals (영어 + 한글)
- [ ] Persona
- [ ] Core Principles
- [ ] Commands (해당되는 경우)
- [ ] Boundaries (해당되는 경우)
- [ ] Workflow
- [ ] Success Criteria
- [ ] Skills to Use
- [ ] Orchestrator Integration

### 선택 섹션
- [ ] MCP Tools Usage Strategy
- [ ] Indexing & Docs Usage Strategy
- [ ] Deep Discovery Integration
- [ ] Response Template
- [ ] Auto-Invocation Triggers

### 검증 도구
- `agentBuilder` (생성 시 자동 검증)
- `agentCritic` (정기적 검증, 선택적)
```

### 적용 방법
1. Agent 문서화 체크리스트 생성
2. `agentBuilder`에 체크리스트 통합
3. 기존 Agent 파일 검증 및 보완

---

## 구현 계획

### Phase 1: AGENTS.md 생성 (우선순위: 높음)

**작업 내용**:
1. `.cursor/AGENTS.md` 파일 생성
2. Commands, Testing, Structure, Style, Git Workflow, Boundaries, Success Criteria, Priority Order 섹션 작성
3. 프로젝트 특성에 맞게 커스터마이징

**예상 시간**: 2-3시간

**검증**:
- [ ] `.cursor/AGENTS.md` 파일 존재
- [ ] 모든 필수 섹션 포함
- [ ] 명령어가 실행 가능한 형태로 작성됨
- [ ] 경계 설정이 명확함

### Phase 2: testCodeGenerator Agent 생성 (우선순위: 높음)

**작업 내용**:
1. `agentBuilder`를 사용하여 `testCodeGenerator` Agent 생성
2. Core Principles (6가지) 통합
3. Commands 섹션 추가
4. Boundaries 섹션 추가
5. Success Criteria 섹션 추가
6. Verification Pipeline 추가
7. Workflow에 검증 단계 통합
8. Skills 파일 생성 (`test_code_generator_skills.md`)
9. Orchestrator에 등록

**예상 시간**: 4-5시간

**검증**:
- [ ] `.cursor/agents/testCodeGenerator.md` 파일 생성
- [ ] 모든 Core Principles 포함
- [ ] Commands 섹션 포함
- [ ] Boundaries 섹션 포함
- [ ] Success Criteria 포함
- [ ] Verification Pipeline 포함
- [ ] Skills 파일 생성
- [ ] Orchestrator에 등록됨

### Phase 3: 기존 Agent 개선 (우선순위: 중간)

**작업 내용**:
1. `featureImplementation`에 Commands + Boundaries + Success Criteria 추가
2. `planner`에 5가지 원칙 + Success Criteria 추가
3. `orchestrator`에 5가지 원칙 + Success Criteria 추가
4. `contentConsistencyAgent`에 5가지 원칙 + Success Criteria 추가

**예상 시간**: 3-4시간

**검증**:
- [ ] 각 Agent에 Core Principles 추가됨
- [ ] Commands 섹션 추가됨 (해당되는 경우)
- [ ] Boundaries 섹션 추가됨 (해당되는 경우)
- [ ] Success Criteria 추가됨
- [ ] 기존 기능 유지됨

### Phase 4: 문서 참조 시스템 통합 (우선순위: 중간)

**작업 내용**:
1. 모든 Agent에 `.cursor/AGENTS.md` 자동 참조 로직 추가
2. `.cursor/rules/flutter-test.mdc` 참조 확인
3. Deep Discovery 리포트 참조 확인

**예상 시간**: 1-2시간

**검증**:
- [ ] Agent들이 `.cursor/AGENTS.md`를 참조함
- [ ] 규칙 파일 참조가 작동함
- [ ] Deep Discovery 리포트 참조가 작동함

### Phase 5: 검증 메커니즘 테스트 (우선순위: 높음)

**작업 내용**:
1. testCodeGenerator의 Verification Pipeline 테스트
2. 각 Agent의 Commands 실행 테스트
3. Success Criteria 검증 테스트

**예상 시간**: 2-3시간

**검증**:
- [ ] 모든 검증 명령어가 정상 실행됨
- [ ] Success Criteria가 올바르게 평가됨
- [ ] 오류 처리 동작 확인

### Phase 6: 추가 개선 사항 구현 (우선순위: 중간)

**작업 내용**:
1. Skills 파일 일관성 확보 (누락된 Skills 파일 생성)
2. 에러 처리 가이드라인 문서 생성 및 적용
3. Handoff Artifact 표준화 (범용 스키마 정의)
4. 로깅 가이드라인 문서 생성
5. 캐싱 전략 확장 및 적용

**예상 시간**: 4-5시간

**검증**:
- [ ] 모든 Agent에 Skills 파일 존재 또는 제외 사유 문서화
- [ ] ERROR_HANDLING_GUIDELINES.md 생성
- [ ] HANDOFF_ARTIFACT_SCHEMA.md 생성
- [ ] LOGGING_GUIDELINES.md 생성
- [ ] 캐싱 전략이 모든 Agent에 적용됨

### Phase 7: 시스템 차원 개선 (우선순위: 낮음)

**작업 내용**:
1. Agent 상태 관리 체계화
2. 의존성 관리 및 순환 의존성 검증
3. Rules 파일 일관성 검증
4. 성능 최적화 전략 적용
5. 문서화 일관성 검증 및 보완

**예상 시간**: 3-4시간

**검증**:
- [ ] Agent 상태 관리 프로세스 문서화
- [ ] 의존성 그래프 생성
- [ ] Rules 파일 충돌 검증 완료
- [ ] 성능 최적화 전략 적용
- [ ] 모든 Agent 문서화 체크리스트 통과

---

## 전체 검토 및 킥(Kick) 제안

### 문서 구조 검토

#### ✅ 잘 구성된 부분

1. **체계적인 구조**
   - 20가지 보완 사항을 명확히 분류
   - 우선순위별 정리 (높음/중간/낮음)
   - 각 보완 사항마다 현재 상태 → 보완 내용 → 적용 방법 순서

2. **실행 가능한 가이드**
   - 구체적인 코드 예시 포함
   - 명령어 중심 구조
   - 검증 방법 명시

3. **포터블성 고려**
   - `.cursor` 폴더 중심 설계
   - 프로젝트 독립적 구조
   - 이식 가능성 강조

#### 🔧 개선 제안 (Kick)

##### 1. 빠른 시작 가이드 추가

**제안**: 문서 시작 부분에 "빠른 시작" 섹션 추가

```markdown
## 🚀 빠른 시작 (Quick Start)

### 최우선 작업 (1시간 내)
1. `.cursor/AGENTS.md` 파일 생성 (30분)
2. `testCodeGenerator` Agent 생성 (30분)

### 핵심 개선 사항 (하루 내)
1. 모든 Agent에 Commands 섹션 추가
2. 모든 Agent에 Boundaries 섹션 추가
3. 에러 처리 가이드라인 문서 생성

### 전체 구현 (일주일 내)
- Phase 1-7 순차 진행
- 각 Phase별 검증 완료 후 다음 단계 진행
```

**이유**: 사용자가 즉시 시작할 수 있는 명확한 로드맵 제공

##### 2. 우선순위 매트릭스 시각화

**제안**: 보완 사항 요약 테이블에 영향도/난이도 추가 및 우선순위 자동 계산

### 평가 기준 정의

#### 영향도 (Impact) 평가 기준
- **높음 (High)**: 
  - 모든 Agent에 적용되거나 핵심 기능에 영향
  - 시스템 전반의 품질/효율성에 큰 개선
  - 예: AGENTS.md 파일 추가, 명령어 중심 구조
- **중간 (Medium)**: 
  - 일부 Agent나 특정 기능에 영향
  - 중간 수준의 개선 효과
  - 예: 로깅 체계화, 캐싱 전략
- **낮음 (Low)**: 
  - 특정 영역에만 영향
  - 미미한 개선 효과
  - 예: 문서화 일관성, Rules 파일 검증

#### 난이도 (Effort) 평가 기준
- **낮음 (Low)**: 
  - 1-2시간 이내 완료 가능
  - 단순한 문서 작성 또는 설정 변경
  - 예: AGENTS.md 파일 생성, 빠른 시작 가이드 추가
- **중간 (Medium)**: 
  - 3-5시간 소요
  - 여러 파일 수정 또는 중간 복잡도 작업
  - 예: Skills 파일 일관성 확보, 에러 처리 가이드라인 작성
- **높음 (High)**: 
  - 6시간 이상 소요
  - 복잡한 로직 구현 또는 대규모 리팩토링
  - 예: 검증 자동화 스크립트 작성, 성능 최적화 전략 적용

### 우선순위 계산 공식

**우선순위 점수 = 영향도 점수 × 0.7 - 난이도 점수 × 0.3**

점수 변환:
- 높음 = 3점
- 중간 = 2점
- 낮음 = 1점

**우선순위 등급 결정:**
- **P0 (Critical)**: 점수 ≥ 2.0 → 즉시 실행
- **P1 (High)**: 점수 1.5-1.9 → 1주일 내 실행
- **P2 (Medium)**: 점수 1.0-1.4 → 1개월 내 실행
- **P3 (Low)**: 점수 < 1.0 → 3개월 내 실행

### 개선된 보완 사항 요약 테이블

| 번호 | 보완 사항 | 영향도 | 난이도 | 우선순위 점수 | 등급 | 예상 시간 |
|------|----------|--------|--------|---------------|------|----------|
| 1 | 명령어 중심 구조 추가 | 높음(3) | 낮음(1) | 1.8 | P1 | 1-2시간 |
| 2 | 3단계 경계 설정 명시 | 높음(3) | 낮음(1) | 1.8 | P1 | 1-2시간 |
| 3 | 검증 명령어 통합 | 높음(3) | 중간(2) | 1.5 | P1 | 2-3시간 |
| 4 | 완료 기준 명시 | 중간(2) | 낮음(1) | 1.1 | P2 | 1-2시간 |
| 5 | 우선순위 명시 | 중간(2) | 낮음(1) | 1.1 | P2 | 1-2시간 |
| 6 | AGENTS.md 파일 추가 | 높음(3) | 낮음(1) | 1.8 | P1 | 2-3시간 |
| 7 | Subagent 전략 명확화 | 중간(2) | 낮음(1) | 1.1 | P2 | 1-2시간 |
| 8 | 검증 메커니즘 강화 | 높음(3) | 중간(2) | 1.5 | P1 | 2-3시간 |
| 9 | 문서 참조 시스템 | 중간(2) | 낮음(1) | 1.1 | P2 | 1-2시간 |
| 10 | Karpathy 원칙 실행 명령어화 | 높음(3) | 중간(2) | 1.5 | P1 | 2-3시간 |
| 11 | Skills 파일 일관성 확보 | 높음(3) | 중간(2) | 1.5 | P1 | 2-3시간 |
| 12 | 에러 처리 및 복구 전략 표준화 | 높음(3) | 중간(2) | 1.5 | P1 | 2-3시간 |
| 13 | Handoff Artifact 표준화 | 높음(3) | 중간(2) | 1.5 | P1 | 2-3시간 |
| 14 | 로깅 및 모니터링 체계화 | 중간(2) | 중간(2) | 0.8 | P3 | 3-4시간 |
| 15 | 캐싱 전략 확장 | 중간(2) | 중간(2) | 0.8 | P3 | 2-3시간 |
| 16 | Agent 상태 관리 체계화 | 중간(2) | 중간(2) | 0.8 | P3 | 3-4시간 |
| 17 | 의존성 관리 | 낮음(1) | 중간(2) | 0.1 | P3 | 2-3시간 |
| 18 | Rules 파일 일관성 검증 | 낮음(1) | 중간(2) | 0.1 | P3 | 2-3시간 |
| 19 | 성능 최적화 전략 | 낮음(1) | 높음(3) | -0.2 | P3 | 4-5시간 |
| 20 | 문서화 일관성 | 낮음(1) | 중간(2) | 0.1 | P3 | 2-3시간 |

### 시각화 방법

#### 1. 우선순위 매트릭스 차트 (2D)
```
영향도
  ↑
높음│ P1  P1  P1  P1  P1  P1
   │
중간│ P2  P2  P2  P2  P3  P3
   │
낮음│ P3  P3  P3  P3  P3  P3
   └────────────────────────→ 난이도
     낮음 중간 높음
```

#### 2. 우선순위 등급별 그룹화
- **P0 (Critical)**: 없음 (모든 항목이 P1 이상)
- **P1 (High)**: 1, 2, 3, 6, 8, 10, 11, 12, 13 (9개)
- **P2 (Medium)**: 4, 5, 7, 9 (4개)
- **P3 (Low)**: 14, 15, 16, 17, 18, 19, 20 (7개)

#### 3. 실행 로드맵
- **Week 1**: P1 항목 중 영향도 높음 + 난이도 낮음 우선 (1, 2, 6)
- **Week 2**: P1 항목 나머지 (3, 8, 10, 11, 12, 13)
- **Month 1**: P2 항목 (4, 5, 7, 9)
- **Month 2-3**: P3 항목 (14-20)

### 동점 처리 규칙

우선순위 점수가 동일한 경우:
1. **영향도가 높은 것 우선**: 영향도 점수 비교
2. **난이도가 낮은 것 우선**: 영향도도 동일하면 난이도 비교
3. **의존성이 적은 것 우선**: 위 조건도 동일하면 의존성 비교
4. **예상 시간이 짧은 것 우선**: 모든 조건이 동일하면 예상 시간 비교

### 동적 우선순위 조정

프로젝트 상황에 따라 우선순위 조정 가능:
- **시간이 부족한 경우**: 난이도 가중치 증가 (0.3 → 0.5)
- **품질이 중요한 경우**: 영향도 가중치 증가 (0.7 → 0.8)
- **의존성이 중요한 경우**: 의존성 점수 추가 고려

### 우선순위 재평가

- **Phase 완료 후**: 완료된 Phase의 보완 사항 제외하고 재평가
- **새로운 요구사항 발생 시**: 새로운 보완 사항 추가 후 전체 재평가
- **정기 재평가**: 월 1회 전체 우선순위 재평가

### 적용 방법

1. **보완 사항 요약 테이블 확장**
   - 영향도, 난이도 컬럼 추가
   - 우선순위 점수 자동 계산
   - 우선순위 등급 표시

2. **우선순위 매트릭스 차트 추가**
   - 2D 매트릭스로 시각화
   - 등급별 색상 구분

3. **실행 로드맵 생성**
   - 등급별 그룹화
   - 시간별 실행 계획

**이유**: 
- 객관적 우선순위 결정: 영향도와 난이도를 정량적으로 평가
- 효율적 리소스 배분: 높은 ROI 항목 우선 실행
- 명확한 실행 계획: 등급별 실행 로드맵 제공
- 의사결정 지원: 데이터 기반 우선순위 결정

##### 3. 구현 순서 최적화

**제안**: 의존성을 고려한 구현 순서 제안

```markdown
## 최적 구현 순서 (의존성 고려)

### Week 1: 기반 구축
- Day 1: AGENTS.md 생성 (모든 Agent의 참조 기준)
- Day 2: 에러 처리 가이드라인 (다른 작업의 기반)
- Day 3-4: testCodeGenerator 생성 (새 Agent 템플릿)
- Day 5: Skills 파일 일관성 (기존 Agent 보완)

### Week 2: 핵심 개선
- Day 1-2: 기존 Agent 개선 (Commands, Boundaries 추가)
- Day 3: Handoff Artifact 표준화
- Day 4: 로깅 가이드라인
- Day 5: 검증 및 테스트

### Week 3: 시스템 최적화
- Day 1-2: 캐싱 전략, 성능 최적화
- Day 3: 의존성 관리, 상태 관리
- Day 4-5: Rules 검증, 문서화 일관성
```

**이유**: 의존성을 고려한 효율적인 구현 순서

##### 4. 검증 자동화 도구 제안

**제안**: 각 보완 사항 적용 후 자동 검증 스크립트

```markdown
## 검증 자동화

### 검증 스크립트 (선택적)
```bash
# .cursor/scripts/verify_agents.sh
# - 모든 Agent 파일 존재 확인
# - 필수 섹션 포함 여부 확인
# - Skills 파일 일관성 확인
# - Rules 파일 충돌 검증
```

**이유**: 수동 검증 오류 방지, 일관성 보장

##### 5. 롤백 전략 추가

**제안**: 구현 실패 시 롤백 방법 명시

```markdown
## 롤백 전략

### 백업
- 구현 전: `.cursor` 폴더 전체 백업
- Git 커밋: 각 Phase 완료 시 커밋

### 롤백 방법
1. Git을 사용하는 경우: `git checkout .cursor/`
2. 백업을 사용하는 경우: 백업 폴더에서 복원
3. 부분 롤백: 특정 Agent 파일만 복원
```

**이유**: 안전한 실험과 복구 가능성

##### 6. 성공 지표 정의

**제안**: 각 Phase별 성공 지표 명시

```markdown
## 성공 지표

### Phase 1 성공 지표
- AGENTS.md 파일이 모든 Agent에서 참조됨
- 명령어 실행 성공률 100%
- 경계 설정이 명확히 구분됨

### Phase 2 성공 지표
- testCodeGenerator가 정상 동작
- 테스트 생성 성공률 ≥ 90%
- 커버리지 목표 달성

### 전체 성공 지표
- 모든 Agent가 일관된 구조
- 에러 처리 전략 적용률 100%
- Handoff Artifact 사용률 100%
```

**이유**: 객관적인 성공 측정 기준

##### 7. 점진적 마이그레이션 전략

**제안**: 기존 Agent를 한 번에 바꾸지 않고 점진적으로 개선

```markdown
## 점진적 마이그레이션 전략

### 단계별 접근
1. **새 Agent부터**: testCodeGenerator에 모든 개선 사항 적용
2. **자주 사용하는 Agent**: featureImplementation, planner 우선 개선
3. **나머지 Agent**: 점진적으로 개선

### A/B 테스트 (선택적)
- 기존 버전과 새 버전을 병행 운영
- 사용자 피드백 수집 후 결정
```

**이유**: 리스크 최소화, 안정적인 전환

##### 8. 커뮤니티 베스트 프랙티스 통합

**제안**: 추가 참조 문서 및 커뮤니티 사례

```markdown
## 추가 참조 자료

### 커뮤니티 사례
- [Cursor Community Agent Examples](링크)
- [Flutter Agent Patterns](링크)
- [Multi-Agent System Design](링크)

### 관련 도구
- Agent 성능 모니터링 도구
- Handoff Artifact 검증 도구
- 의존성 그래프 시각화 도구
```

**이유**: 지속적인 개선을 위한 참고 자료

##### 9. 문서 버전 관리

**제안**: 문서 버전 히스토리 추가

```markdown
## 문서 버전 히스토리

### v1.1 (2026-03-07)
- 추가 개선 사항 10개 추가 (11-20)
- Phase 6-7 추가
- 킥(Kick) 제안 섹션 추가

### v1.0 (2026-03-07)
- 초기 문서 작성
- 보완 사항 10개 정의 (1-10)
- Phase 1-5 구현 계획
```

**이유**: 변경 이력 추적 및 버전 관리

##### 10. 실행 가능한 체크리스트 강화

**제안**: 각 Phase별 상세 체크리스트를 별도 파일로 분리

```markdown
## 상세 체크리스트

각 Phase별 상세 체크리스트는 다음 파일 참조:
- `.cursor/docs/checklists/phase1_checklist.md`
- `.cursor/docs/checklists/phase2_checklist.md`
- ...
```

**이유**: 실행 시 바로 사용 가능한 체크리스트

---

## 킥(Kick) 제안 요약

### 즉시 적용 가능한 킥

1. **빠른 시작 가이드**: 문서 상단에 추가하여 즉시 시작 가능
2. **우선순위 매트릭스**: 영향도/난이도 추가로 작업 선택 용이
3. **검증 자동화**: 스크립트로 검증 시간 단축

### 중기 킥

4. **구현 순서 최적화**: 의존성 고려한 효율적 순서
5. **성공 지표 정의**: 객관적 측정 기준
6. **점진적 마이그레이션**: 리스크 최소화

### 장기 킥

7. **롤백 전략**: 안전한 실험 환경
8. **커뮤니티 통합**: 지속적 개선
9. **문서 버전 관리**: 변경 이력 추적
10. **상세 체크리스트**: 실행 가능한 가이드

---

## 참조 문서

### 내부 문서
- `.cursor/rules/flutter-test.mdc` - Flutter 테스트 규칙
- `.cursor/docs/PORTABILITY_GUIDE.md` - 포터블성 가이드

### 외부 문서
1. [베스트 AI 코딩 에이전트 가이드](https://nextplatform.net/agents-md-for-ai-coding-agent/) - AGENTS.md 작성법
2. [OpenCode Agents 문서](https://opencode.ai/docs/ko/agents/) - Primary/Subagent 구분
3. [Ralph Playbook 방법론](https://blog.choonzang.com/it/software/4353/) - 자율적 AI 루프와 역압
4. [Karpathy 가이드라인](https://playbooks.com/skills/forrestchang/andrej-karpathy-skills/karpathy-guidelines) - Think Before 원칙
5. [AGENTS.md 패턴 분석](https://blakecrosley.com/ko/blog/agents-md-patterns) - 2,500개 저장소 기반 패턴
6. [GitHub Copilot agents.md 베스트 프랙티스](https://ounols.kr/posts/github-copilot-agents-md-best-practices/) - 6가지 핵심 영역

---

## 체크리스트

### 구현 전
- [ ] 이 문서 검토 완료
- [ ] 구현 계획 승인
- [ ] 백업 완료

### 구현 중
- [ ] Phase 1: AGENTS.md 생성 완료
- [ ] Phase 2: testCodeGenerator 생성 완료
- [ ] Phase 3: 기존 Agent 개선 완료
- [ ] Phase 4: 문서 참조 시스템 통합 완료
- [ ] Phase 5: 검증 메커니즘 테스트 완료
- [ ] Phase 6: 추가 개선 사항 구현 완료
- [ ] Phase 7: 시스템 차원 개선 완료

### 구현 후
- [ ] 모든 보완 사항 적용 확인
- [ ] 검증 명령어 정상 실행 확인
- [ ] 문서 참조 시스템 동작 확인
- [ ] 포터블성 확인 (`.cursor` 폴더만 복사해도 동작)

---

---

## 문서 버전 히스토리

### v1.3 (2026-03-07)
- **전체 시스템 업그레이드 완료** 반영
  - Phase 1-7 모든 작업 완료
  - testCodeGenerator 생성 완료
  - Skills 파일 4개 생성 완료
  - 가이드라인 문서 3개 생성 완료
  - 캐싱 전략 확장 완료
  - 의존성 관리 완료
- **실제 구현 현황** 업데이트
  - 모든 Phase 완료 상태로 업데이트
  - 전체 진행률 100%로 업데이트
  - Skills 보유율 100%로 업데이트
  - testCodeGenerator 생성 완료 반영

### v1.2 (2026-03-07)
- **agentBuilder 업그레이드 완료** 반영
  - 9-Step Upgrade Pipeline 구현 완료
  - Hard Reject System 추가 (5가지 HARD REJECT 조건)
  - Know Your Limits 원칙 추가 (Core Principle 0)
  - Functionality Overlap Analysis 추가 (중복도 60% 이상 시 자동 거절)
  - 각 Step에 한글 설명 확장 (영문 Process 내용 모두 포함)
- **실제 구현 현황** 업데이트
  - Phase 3 진행 상황 업데이트 (agentBuilder 완료)
  - 전체 진행률 업데이트 (약 5%)
  - 주요 발견 사항에 agentBuilder 업그레이드 추가

### v1.1 (2026-03-07)
- **실제 구현 현황** 섹션 추가
  - Agent 구현 현황 (Active 14개, PLANNED 2개, 미생성 1개)
  - Skills 파일 현황 (보유 10개, 누락 4개)
  - Rules 파일 현황 (9개)
  - 구현 진행 상황 (Phase별 상태)
  - 주요 발견 사항
- **Agent-Rules-Skills 매핑** 섹션 추가
  - Agent별 상세 매핑 테이블
  - Rules 파일별 적용 Agent
  - Skills 파일 생성 우선순위
  - 개선 필요 사항 요약
- 문서 구조 개선
  - 목차에 새 섹션 추가
  - 실제 구현 상태와 문서 일치성 강화

### v1.0 (2026-03-07)
- 초기 문서 작성
- 보완 사항 20개 정의 (1-20)
- Phase 1-7 구현 계획
- 킥(Kick) 제안 10개
- 우선순위 매트릭스 구체화

---

**문서 버전**: 1.3  
**최종 업데이트**: 2026-03-07  
**작성자**: Agent System Upgrade Team
