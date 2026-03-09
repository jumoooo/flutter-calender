# 🧪 Test Code Generator Skills

## Language Separation (언어 구분)
**Internal Processing (Agent reads)**: All instructions, logic, and internal operations are in English.
**User-Facing Content (User sees)**: All explanations, code comments, examples, and responses shown to users are in Korean.

## Overview
This skill provides core functions for the Test Code Generator agent. It includes functions for request validity assessment, code analysis and test pattern discovery, test generation, and coverage measurement and reporting.

**한글 설명 (사용자용)**: 이 스킬은 Test Code Generator가 사용하는 핵심 기능들을 제공합니다. 요청 유효성 평가, 코드 분석 및 테스트 패턴 발견, 테스트 생성, 커버리지 측정 및 보고 등의 기능을 포함합니다.

---

## Core Skills

### 1. Request Validity Assessment
**Purpose**: Evaluate if the request is within testCodeGenerator's expertise

**Input**: 
- User request text
- Request context

**Output**: 
- Validity assessment (valid / invalid / uncertain)
- Rejection reason (if invalid)
- Alternative agent suggestion (if invalid)

**Process**:
1. Parse request to understand what is being asked
2. Check if request is within expertise (test code generation only)
3. Identify if request involves:
   - Production code modification → INVALID (suggest featureImplementation)
   - Test framework changes → INVALID (suggest agentBuilder)
   - Test code generation → VALID
4. If uncertain, mark as UNCERTAIN and ask clarifying questions

**Template (for agents, in English)**:
```
Request Assessment:
- Request: {user_request}
- Validity: {valid/invalid/uncertain}
- Reason: {assessment_reason}
- Alternative: {suggested_agent_if_invalid}
```

**한글 예시 (사용자용)**:
```
요청 평가:
- 요청: "TodoProvider에 대한 테스트 코드 생성해줘"
- 유효성: 유효
- 이유: 테스트 코드 생성은 testCodeGenerator의 전문 영역입니다.
```

---

### 2. Code Analysis and Test Pattern Discovery
**Purpose**: Analyze implementation code and discover existing test patterns in the project

**Input**: 
- Target implementation file paths
- Project test directory structure

**Output**: 
- Public methods to test
- Edge cases and error conditions
- Existing test patterns (structure, assertions, mocks)
- Test dependencies needed

**Process**:
1. Read target implementation files
2. Identify all public methods
3. Identify edge cases and error conditions
4. Search for existing tests in project
5. Analyze existing test patterns:
   - Test structure (setUp, tearDown, group)
   - Assertion patterns
   - Mock patterns
   - Hive initialization patterns
6. Document patterns for reuse

**Template (for agents, in English)**:
```
Code Analysis:
- Target: {file_path}
- Public Methods: {list}
- Edge Cases: {list}
- Existing Patterns: {pattern_summary}
- Dependencies: {list}
```

**한글 예시 (사용자용)**:
```
코드 분석:
- 대상: lib/providers/todo_provider.dart
- Public 메서드: addTodo, removeTodo, updateTodo, getAllTodos
- Edge Cases: 빈 리스트, null 값, 중복 ID
- 기존 패턴: setUpAll에서 Hive.init(tempDir.path) 사용, tearDownAll에서 정리
- 의존성: Hive, TodoAdapter
```

---

### 3. Test Generation
**Purpose**: Generate test code following project patterns and best practices

**Input**: 
- Code analysis results
- Test patterns from discovery
- Test type (unit, widget, integration)
- Coverage targets

**Output**: 
- Generated test file content
- Test cases for each public method
- Edge case tests
- Korean comments included

**Process**:
1. Plan test structure based on existing patterns
2. Generate test file with proper imports
3. Generate setUp/tearDown based on patterns
4. Generate test cases for each public method
5. Generate edge case tests
6. Add Korean comments explaining test logic
7. Follow all rules from `.cursor/rules/flutter-test.mdc`

**Template (for agents, in English)**:
```
Test Generation:
- File: {test_file_path}
- Test Cases: {count}
- Coverage: {estimated_percentage}%
- Patterns Used: {pattern_list}
```

**한글 예시 (사용자용)**:
```
테스트 생성:
- 파일: test/providers/todo_provider_test.dart
- 테스트 케이스: 8개
- 예상 커버리지: 90%
- 사용된 패턴: setUpAll Hive 초기화, tearDownAll 정리, async/await 사용
```

---

### 4. Coverage Measurement and Reporting
**Purpose**: Measure test coverage and report progress toward targets

**Input**: 
- Test execution results
- Coverage data

**Output**: 
- Coverage report (overall, by component type)
- Progress toward targets
- Gap analysis
- Recommendations

**Process**:
1. Run `flutter test --coverage`
2. Generate coverage report: `genhtml coverage/lcov.info -o coverage/html`
3. Analyze coverage by component type:
   - Critical logic (providers, services, models): Target 85-90%
   - UI components: Target 70%
4. Identify gaps
5. Report progress and recommendations

**Template (for agents, in English)**:
```
Coverage Report:
- Overall: {percentage}%
- Critical Logic: {percentage}% (Target: 85-90%)
- UI Components: {percentage}% (Target: 70%)
- Gaps: {list}
- Recommendations: {list}
```

**한글 예시 (사용자용)**:
```
커버리지 보고:
- 전체: 87%
- 핵심 로직: 92% (목표: 85-90%) ✅
- UI 컴포넌트: 65% (목표: 70%) ⚠️
- 갭: CalendarWidget 테스트 부족
- 권장사항: CalendarWidget 위젯 테스트 추가
```

---

## Skills Usage Examples

### Example 1: Unit Test Generation

**Scenario**: User requests unit tests for TodoProvider

**Process**:
1. **Request Validity Assessment**: ✅ Valid (test code generation)
2. **Code Analysis**: Analyze TodoProvider, find existing test patterns
3. **Test Generation**: Generate test file following project patterns
4. **Coverage Measurement**: Run coverage analysis and report

**Output**:
```
✅ 테스트 생성 완료

생성된 테스트:
- test/providers/todo_provider_test.dart: TodoProvider 단위 테스트

커버리지 결과:
- 전체 커버리지: 92%
- 핵심 로직 커버리지: 92% (목표: 85-90%) ✅

테스트 실행 결과:
- ✅ 모든 테스트 통과 (8개 테스트)
- ✅ 컴파일 오류 없음
- ✅ 코드 품질 검사 통과
```

### Example 2: Widget Test Generation

**Scenario**: User requests widget tests for CalendarWidget

**Process**:
1. **Request Validity Assessment**: ✅ Valid
2. **Code Analysis**: Analyze CalendarWidget, note AnimationController usage
3. **Test Generation**: Generate widget test using fixed-duration pump() (not pumpAndSettle())
4. **Coverage Measurement**: Measure and report UI component coverage

**Output**:
```
✅ 위젯 테스트 생성 완료

생성된 테스트:
- test/widgets/calendar_widget_test.dart: CalendarWidget 위젯 테스트

주의사항:
- AnimationController 사용으로 인해 pumpAndSettle() 대신 고정 시간 pump() 사용
- Hive 초기화는 setUpAll에서 tempDir.path 사용

커버리지 결과:
- UI 컴포넌트 커버리지: 72% (목표: 70%) ✅
```

---

## Verification Skills

### Test Execution Verification
- Run `flutter test` and verify exit code 0
- Check for compilation errors
- Check for test failures
- Report results

### Code Quality Verification
- Run `dart analyze --fatal-infos`
- Check for errors and warnings
- Fix any issues found
- Report results

### Pattern Compliance Verification
- Review generated tests against existing patterns
- Verify Korean comments included
- Verify rules from `.cursor/rules/flutter-test.mdc` followed
- Report compliance status

---

## Important Notes

1. **Always follow `.cursor/rules/flutter-test.mdc`** rules strictly
2. **Never modify production code** - only test files
3. **Always use existing test patterns** from project
4. **Always include Korean comments** in test code
5. **Always verify tests pass** before reporting completion
6. **Always measure and report coverage** toward targets
