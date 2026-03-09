# ⚡ Feature Implementation Skills

## Language Separation (언어 구분)
**Internal Processing (Agent reads)**: All instructions, logic, and internal operations are in English.
**User-Facing Content (User sees)**: All explanations, code comments, examples, and responses shown to users are in Korean.

## Overview
This skill provides core functions for the Feature Implementation agent. It includes functions for feature requirement analysis, architecture design using Indexing & Docs and MCP tools, feature structure planning, component generation, state management integration, navigation integration, and error handling implementation.

**한글 설명 (사용자용)**: 이 스킬은 Feature Implementation이 사용하는 핵심 기능들을 제공합니다. 기능 요구사항 분석, Indexing & Docs 및 MCP 도구를 활용한 아키텍처 설계, 기능 구조 계획, 컴포넌트 생성, 상태 관리 통합, 네비게이션 통합, 에러 처리 구현 등의 기능을 포함합니다.

---

## Skills

### 1. Analyze Feature Requirements
**Purpose**: Understand user requirements for feature implementation

**Input**: 
- User request text
- Feature description
- Functional requirements
- UI requirements

**Output**: 
- Feature scope and requirements
- UI components needed
- Business logic requirements
- State management needs
- Navigation requirements
- API integration needs (if any)

**Process**:
1. Parse request to understand feature scope
2. Identify UI components needed
3. Determine business logic requirements
4. Identify state management needs
5. Check navigation requirements
6. Assess complexity

**Template (for agents, in English)**:
```
Feature Requirements:
- Scope: {feature_description}
- UI Components: {components_needed}
- Business Logic: {logic_requirements}
- State Management: {needs}
- Navigation: {requirements}
- API Integration: {needs}
- Complexity: {simple/moderate/complex}
```

---

### 2. Research Architecture Patterns (Indexing & Docs First)
**Purpose**: Find official Flutter architecture patterns using Indexing & Docs as primary source

**Input**:
- Feature requirements
- Project context

**Output**:
- Official Flutter architecture patterns from Flutter 공식 아키텍처 가이드
- State management patterns
- Navigation patterns
- Best practices

**Priority Order**:
1. **Indexing & Docs (Primary)**: Flutter 공식 아키텍처 가이드, Flutter_docs
2. **MCP Context7 (Secondary)**: 최신 아키텍처 패턴 확인
3. **Codebase Search (Tertiary)**: 프로젝트 내 패턴

**Process**:
1. Check Flutter 공식 아키텍처 가이드 (Indexing & Docs) for architecture patterns
2. Check Flutter_docs for navigation and state management patterns
3. Use MCP Context7 if Indexing & Docs insufficient
4. Search codebase for existing feature patterns

**Template (for agents, in English)**:
```
Architecture Research:
- Primary (Indexing & Docs): {patterns_found}
- Secondary (MCP Context7): {latest_patterns}
- Tertiary (Codebase): {existing_patterns}
- Selected Architecture: {chosen_pattern} - Reason: {reason}
```

---

### 3. Check Project Structure (Deep Discovery)
**Purpose**: Understand project architecture and existing feature patterns

**Input**:
- Deep discovery report location
- Feature requirements

**Output**:
- Project structure information
- Existing feature patterns
- State management approach
- Navigation structure
- Architecture conventions

**Process**:
1. Check for existing deep discovery report in `.cursor/docs/deep-discovery/`
2. Read project structure information
3. Identify existing feature patterns
4. Understand state management approach
5. Check navigation structure
6. Understand architecture conventions

**Template (for agents, in English)**:
```
Project Structure Analysis:
- Report Used: {report_file}
- Existing Features: {patterns}
- State Management: {approach}
- Navigation: {structure}
- Architecture: {conventions}
- Consistency Check: {matches/needs_adjustment}
```

---

### 4. Design Feature Architecture
**Purpose**: Design feature structure following Flutter best practices

**Input**:
- Feature requirements
- Official architecture patterns
- Project structure

**Output**:
- Feature directory structure
- File organization plan
- State management design
- Navigation integration plan
- Business logic structure

**Process**:
1. Plan directory structure (lib/features/{feature_name}/)
2. Design file organization (screen, provider, model, service)
3. Plan state management approach
4. Design navigation integration
5. Plan business logic structure

**Template (for agents, in English)**:
```
Feature Architecture:
- Directory: lib/features/{feature_name}/
- Files: {file_list}
- State Management: {Provider/Riverpod/local}
- Navigation: {route_integration}
- Business Logic: {service_structure}
```

---

### 5. Generate Feature Components
**Purpose**: Generate all feature components (screen, provider, model, service)

**Input**:
- Feature architecture
- Official patterns
- Project conventions

**Output**:
- Complete feature code
- Screen/widget files
- State management files
- Business logic files
- Model files (if needed)

**Quality Requirements**:
- Clear structure and organization
- Korean comments for complex logic
- Type safety and null safety
- Error handling at all layers
- Proper separation of concerns

**Template (for users, in Korean)**:
```dart
// {Feature 설명}
// lib/features/{feature_name}/{feature_name}_screen.dart
class {FeatureName}Screen extends StatelessWidget {
  // {화면 구현}
}

// lib/features/{feature_name}/{feature_name}_provider.dart
class {FeatureName}Provider extends ChangeNotifier {
  // {상태 관리 로직}
}

// lib/features/{feature_name}/{feature_name}_model.dart
class {FeatureName}Model {
  // {데이터 모델}
}
```

---

### 6. Integrate State Management
**Purpose**: Integrate appropriate state management (Provider, Riverpod, etc.)

**Input**:
- Feature architecture
- Project's state management approach
- State requirements

**Output**:
- State management implementation
- State update methods
- State access patterns

**Process**:
1. Choose state management approach based on project
2. Generate Provider/Riverpod classes
3. Implement state logic
4. Add state update methods
5. Integrate with UI

**Template**:
```dart
// 상태 관리 통합 예시
class {FeatureName}Provider extends ChangeNotifier {
  // 상태 변수
  {StateType} _state = {initialValue};
  
  // 상태 접근
  {StateType} get state => _state;
  
  // 상태 업데이트
  void updateState({StateType} newState) {
    _state = newState;
    notifyListeners();
  }
}
```

---

### 7. Integrate Navigation
**Purpose**: Integrate feature with existing navigation structure

**Input**:
- Feature architecture
- Existing navigation structure
- Route requirements

**Output**:
- Route definitions
- Navigation implementation
- Integration with existing routes

**Process**:
1. Check existing navigation structure
2. Define feature routes
3. Implement navigation calls
4. Integrate with existing navigation
5. Test navigation flow

**Template**:
```dart
// 네비게이션 통합 예시
// routes.dart에 추가
static const String {featureName}Route = '/{feature_name}';

// 네비게이션 호출
Navigator.pushNamed(
  context,
  Routes.{featureName}Route,
  arguments: {arguments},
);
```

---

### 8. Implement Error Handling
**Purpose**: Add comprehensive error handling to feature

**Input**:
- Feature code
- Error scenarios

**Output**:
- Error handling code at all layers
- Validation logic
- Edge case handling
- Error UI states

**Error Handling Requirements**:
- Input validation
- API error handling (if applicable)
- State error handling
- UI error states
- User-friendly error messages in Korean

**Template**:
```dart
// 에러 처리 예시
try {
  // 기능 로직
} catch (e) {
  // 에러 처리
  _handleError(e);
}

void _handleError(dynamic error) {
  // 에러 상태 업데이트
  _errorState = error.toString();
  notifyListeners();
}
```

---

## Usage Guidelines

### When to Use Each Skill

1. **Analyze Feature Requirements**: Always use at the start
2. **Research Architecture Patterns**: Use Indexing & Docs first, then MCP if needed
3. **Check Project Structure**: Use deep discovery report for context
4. **Design Feature Architecture**: Use after requirements and patterns understood
5. **Generate Feature Components**: Use after architecture designed
6. **Integrate State Management**: Use after components generated
7. **Integrate Navigation**: Use after state management integrated
8. **Implement Error Handling**: Always include in feature generation

### Quality Standards

- Always check Indexing & Docs (Flutter 공식 아키텍처 가이드) first for architecture patterns
- Use deep discovery report to understand project structure
- Include comprehensive error handling at all layers
- Provide Korean comments for better readability
- Use clear, organized structure
- Follow Flutter best practices
- Ensure proper separation of concerns
- Integrate seamlessly with existing project
- Use English for agent communication
- Use Korean for user-facing content and code comments

---

## Integration with MCP Tools

### Indexing & Docs (Primary)
- Flutter 공식 아키텍처 가이드: 기능 구조, 레이어 분리, 상태 관리 패턴
- Flutter_docs: 네비게이션, 상태 관리 API, 위젯 사용법
- Dart 언어 문서: 타입 시스템, 비동기 처리

### Context7 (Secondary)
- Use for latest Flutter architecture patterns
- Check specific state management package documentation
- Verify new Flutter version features

### Codebase Search (Tertiary)
- Find existing feature patterns
- Maintain consistency with project
- Understand project architecture approach

---

## Example Workflow

### Scenario: User requests "로그인 기능 구현해줘"

1. **Analyze Requirements** (Skill 1)
   - Scope: Login feature
   - UI: Login form (email, password, button)
   - Logic: Authentication, validation
   - State: Loading, success, error
   - Navigation: Redirect on success

2. **Research Patterns** (Skill 2)
   - Check Flutter 공식 아키텍처 가이드 for feature structure
   - Check Flutter_docs for navigation patterns
   - Use MCP Context7 if needed

3. **Check Project Structure** (Skill 3)
   - Read deep discovery report
   - Check existing feature patterns
   - Understand state management approach

4. **Design Architecture** (Skill 4)
   - Plan directory: lib/features/login/
   - Files: login_screen.dart, login_provider.dart, login_model.dart
   - State: Provider
   - Navigation: Route integration

5. **Generate Components** (Skill 5)
   - Create screen with form
   - Create provider with state
   - Create model for data

6. **Integrate State Management** (Skill 6)
   - Implement Provider
   - Add state update methods
   - Connect with UI

7. **Integrate Navigation** (Skill 7)
   - Add route definition
   - Implement navigation calls
   - Integrate with existing routes

8. **Implement Error Handling** (Skill 8)
   - Add validation
   - Handle API errors
   - Create error UI states

9. **Present Feature** (in Korean for users)
   - Show feature structure
   - Provide integration guidance
   - Explain key features
