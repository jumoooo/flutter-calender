# ✅ Code Change Reviewer Skills

## Language Separation (언어 구분)
**Internal Processing (Agent reads)**: All instructions, logic, and internal operations are in English.
**User-Facing Content (User sees)**: All review results and suggestions shown to users are in Korean.

## Overview
This skill provides core functions for the Code Change Reviewer agent. It includes functions for diff analysis, stability checks, efficiency checks, and code quality checks.

**한글 설명 (사용자용)**: 이 스킬은 Code Change Reviewer가 사용하는 핵심 기능들을 제공합니다. Diff 분석, 안정성 체크, 효율성 체크, 코드 품질 체크 등의 기능을 포함합니다.

---

## Core Skills

### 1. Diff Analysis
**Purpose**: Analyze code diffs to understand what changed and identify review targets

**Input**: 
- Unified diff or code before/after
- Change summary
- Intent (feature_dev, bug_fix, refactor, etc.)

**Output**: 
- Changed files list
- Changed sections identification
- Change type classification
- Review priority areas

**Process**:
1. Parse diff to identify changed files
2. Identify changed sections (functions, classes, widgets)
3. Classify change type (addition, modification, deletion)
4. Identify high-priority review areas
5. Map changes to review dimensions (stability, efficiency, quality)

**Template (for agents, in English)**:
```
Diff Analysis:
- Changed Files: {file_list}
- Changed Sections: {section_list}
- Change Type: {addition/modification/deletion/mixed}
- Priority Areas: {priority_list}
```

**한글 예시 (사용자용)**:
```
Diff 분석:
- 변경된 파일: lib/providers/todo_provider.dart, lib/widgets/todo_list.dart
- 변경된 섹션: TodoProvider.addTodo(), TodoList.build()
- 변경 유형: 추가/수정 혼합
- 우선 검토 영역: async setState, null safety
```

---

### 2. Stability Check
**Purpose**: Check code changes for runtime stability issues

**Input**: 
- Code diff or code snippet
- Change context

**Output**: 
- Stability issues list
- Risk level assessment
- Fix suggestions

**Process**:
1. Check null safety:
   - Possible null dereferences
   - Missing null checks
   - Null safety violations
2. Check async + setState:
   - Missing mounted checks
   - setState after dispose
   - Async operations without proper handling
3. Check state management:
   - State changes in proper scope
   - Provider/Riverpod usage correctness
   - State update patterns
4. Check error handling:
   - Risky operations wrapped
   - Exception handling present
   - Error states handled

**Template (for agents, in English)**:
```
Stability Check:
- Null Safety: {issues}
- Async + setState: {issues}
- State Management: {issues}
- Error Handling: {issues}
- Risk Level: {low/medium/high}
- Suggestions: {fix_suggestions}
```

**한글 예시 (사용자용)**:
```
안정성 체크:
- Null Safety: 문제 없음 ✅
- Async + setState: mounted 체크 누락 1건 ⚠️
- State Management: 문제 없음 ✅
- Error Handling: API 호출 예외 처리 누락 1건 ⚠️
- 리스크 레벨: 중간
- 제안: async setState 전에 if (!mounted) return; 추가, try-catch로 API 호출 감싸기
```

---

### 3. Efficiency Check
**Purpose**: Check code changes for efficiency issues

**Input**: 
- Code diff or code snippet
- Widget tree context

**Output**: 
- Efficiency issues list
- Performance impact assessment
- Optimization suggestions

**Process**:
1. Check widget rebuilds:
   - Unnecessary rebuilds
   - Missing const constructors
   - Rebuild scope too wide
2. Check build method:
   - Heavy operations in build
   - Missing memoization
   - Repeated computations
3. Check data operations:
   - Missing caching
   - Inefficient data structures
   - Unnecessary iterations

**Template (for agents, in English)**:
```
Efficiency Check:
- Widget Rebuilds: {issues}
- Build Method: {issues}
- Data Operations: {issues}
- Performance Impact: {low/medium/high}
- Suggestions: {optimization_suggestions}
```

**한글 예시 (사용자용)**:
```
효율성 체크:
- 위젯 Rebuild: Consumer 범위가 너무 넓음 ⚠️
- Build Method: 문제 없음 ✅
- 데이터 연산: 문제 없음 ✅
- 성능 영향: 낮음
- 제안: Consumer를 더 작은 위젯으로 축소하여 rebuild 범위 최소화
```

---

### 4. Code Quality Check
**Purpose**: Check code changes for code quality issues

**Input**: 
- Code diff or code snippet
- Project style context

**Output**: 
- Code quality issues list
- Readability assessment
- Consistency assessment
- Improvement suggestions

**Process**:
1. Check readability:
   - Clear structure
   - Meaningful naming
   - Proper indentation
   - Code organization
2. Check comments:
   - Korean comments for complex logic
   - Documentation completeness
   - Comment clarity
3. Check consistency:
   - Project style compliance
   - Naming conventions
   - Code patterns

**Template (for agents, in English)**:
```
Code Quality Check:
- Readability: {score}/100 - {issues}
- Comments: {score}/100 - {issues}
- Consistency: {score}/100 - {issues}
- Overall: {score}/100
- Suggestions: {improvement_suggestions}
```

**한글 예시 (사용자용)**:
```
코드 품질 체크:
- 가독성: 95/100 - 구조 명확 ✅
- 주석: 90/100 - 한글 주석 잘 포함됨 ✅
- 일관성: 95/100 - 프로젝트 스타일 준수 ✅
- 종합: 93/100
- 제안: 특별한 개선 사항 없음
```

---

## Skills Usage Examples

### Example 1: Stability Check

**Scenario**: featureImplementation adds async setState without mounted check

**Process**:
1. **Diff Analysis**: Identify async setState usage
2. **Stability Check**: Find missing mounted check
3. **Suggestions**: Generate fix suggestion

**Output**:
```
⚠️ 안정성 이슈 발견

문제: async setState 전 mounted 체크 누락
위치: lib/providers/todo_provider.dart:45
리스크: 위젯 dispose 후 setState 호출 가능성

제안:
```dart
// 수정 전
await apiCall();
setState(() {
  _todos = result;
});

// 수정 후
await apiCall();
if (!mounted) return;
setState(() {
  _todos = result;
});
```
```

### Example 2: Efficiency Check

**Scenario**: featureImplementation uses Consumer with too wide scope

**Process**:
1. **Diff Analysis**: Identify Consumer usage
2. **Efficiency Check**: Find wide rebuild scope
3. **Suggestions**: Generate optimization suggestion

**Output**:
```
⚠️ 효율성 개선 제안

문제: Consumer 범위가 너무 넓어 불필요한 rebuild 발생
위치: lib/widgets/todo_list.dart:30
영향: 낮음 (작은 위젯 트리)

제안:
Consumer를 더 작은 위젯으로 축소하여 rebuild 범위 최소화
```

### Example 3: Code Quality Check

**Scenario**: featureImplementation adds code with good structure

**Process**:
1. **Diff Analysis**: Analyze code structure
2. **Code Quality Check**: Assess readability, comments, consistency
3. **Result**: High quality, minor suggestions

**Output**:
```
✅ 코드 품질 검토 완료

가독성: 95/100 ✅
주석: 90/100 ✅
일관성: 95/100 ✅
종합: 93/100

특별한 개선 사항 없음. 코드 품질이 우수합니다.
```

---

## Verification Skills

### Review Completeness Verification
- All dimensions checked (stability, efficiency, quality)
- All critical issues identified
- Suggestions are concrete and actionable

### Review Accuracy Verification
- Issues are real and not false positives
- Suggestions are correct and safe
- Risk assessments are accurate

---

## Important Notes

1. **Focus on diff**: Review primarily the changed code, not the whole file
2. **Be concrete**: Provide specific file locations and code snippets
3. **Stay minimal**: Suggest only necessary fixes, avoid over-refactoring
4. **Prioritize safety**: Focus on stability issues first
5. **Use Korean for users**: All review results must be in Korean
