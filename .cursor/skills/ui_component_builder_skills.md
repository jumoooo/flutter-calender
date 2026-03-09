# 🎨 UI Component Builder Skills

## Language Separation (언어 구분)
**Internal Processing (Agent reads)**: All instructions, logic, and internal operations are in English.
**User-Facing Content (User sees)**: All explanations, code comments, examples, and responses shown to users are in Korean.

## Overview
This skill provides core functions for the UI Component Builder agent. It includes functions for component type analysis, pattern research using Indexing & Docs and MCP tools, component design, code generation with quality checks, responsive design implementation, and error handling integration.

**한글 설명 (사용자용)**: 이 스킬은 UI Component Builder가 사용하는 핵심 기능들을 제공합니다. 컴포넌트 타입 분석, Indexing & Docs 및 MCP 도구를 활용한 패턴 연구, 컴포넌트 설계, 품질 검사가 포함된 코드 생성, 반응형 디자인 구현, 에러 처리 통합 등의 기능을 포함합니다.

---

## Skills

### 1. Analyze Component Requirements
**Purpose**: Understand user requirements for UI component creation

**Input**: 
- User request text
- Component type hints
- Styling preferences
- Functional requirements

**Output**: 
- Component type classification
- Required properties and behaviors
- Styling requirements (Material, Cupertino, Custom)
- State management needs
- Responsive design requirements

**Process**:
1. Parse request to identify component type
2. Extract required properties
3. Identify styling preferences
4. Determine state management needs
5. Assess complexity

**Template (for agents, in English)**:
```
Component Requirements:
- Type: {button/card/list/form/custom}
- Properties: {required_properties}
- Styling: {Material/Cupertino/Custom}
- State: {stateless/stateful/needs_provider}
- Complexity: {simple/moderate/complex}
```

---

### 2. Research Official Patterns (Indexing & Docs First)
**Purpose**: Find official Flutter patterns using Indexing & Docs as primary source

**Input**:
- Component type
- Required functionality
- Styling preferences

**Output**:
- Official Flutter patterns from Flutter_docs
- Material Design or Cupertino guidelines
- Best practices from architecture guide
- Latest patterns from MCP Context7 (if needed)

**Priority Order**:
1. **Indexing & Docs (Primary)**: Flutter_docs, 아키텍처 가이드
2. **MCP Context7 (Secondary)**: 최신 패턴 확인
3. **Codebase Search (Tertiary)**: 프로젝트 내 패턴

**Process**:
1. Check Flutter_docs (Indexing & Docs) for official widget patterns
2. Check Flutter 공식 아키텍처 가이드 for component structure
3. Use MCP Context7 if Indexing & Docs insufficient
4. Search codebase for existing similar patterns

**Template (for agents, in English)**:
```
Pattern Research:
- Primary (Indexing & Docs): {patterns_found}
- Secondary (MCP Context7): {latest_patterns}
- Tertiary (Codebase): {existing_patterns}
- Selected Pattern: {chosen_pattern} - Reason: {reason}
```

---

### 3. Check Project Structure (Deep Discovery)
**Purpose**: Understand project structure and existing component patterns

**Input**:
- Deep discovery report location
- Component requirements

**Output**:
- Project structure information
- Existing component patterns
- State management approach
- Styling conventions

**Process**:
1. Check for existing deep discovery report in `.cursor/docs/deep-discovery/`
2. Read project structure information
3. Identify existing component patterns
4. Understand state management approach
5. Check styling conventions

**Template (for agents, in English)**:
```
Project Structure Analysis:
- Report Used: {report_file}
- Existing Patterns: {patterns}
- State Management: {approach}
- Styling: {conventions}
- Consistency Check: {matches/needs_adjustment}
```

---

### 4. Design Component Architecture
**Purpose**: Design component structure following Flutter best practices

**Input**:
- Component requirements
- Official patterns
- Project structure

**Output**:
- Component architecture (StatelessWidget vs StatefulWidget)
- Property design (required, optional, defaults)
- State management integration plan
- Error handling strategy

**Process**:
1. Choose widget type (StatelessWidget vs StatefulWidget)
2. Design property structure
3. Plan state management integration
4. Design error handling approach
5. Plan responsive design

**Template (for agents, in English)**:
```
Component Architecture:
- Widget Type: {StatelessWidget/StatefulWidget}
- Properties: {property_list}
- State Management: {local/Provider/Riverpod/none}
- Error Handling: {strategy}
- Responsive: {yes/no}
```

---

### 5. Generate Component Code with Quality Checks
**Purpose**: Generate high-quality component code with error handling, null safety, and Korean comments

**Input**:
- Component architecture
- Official patterns
- Project conventions

**Output**:
- Complete component code
- Error handling included
- Null safety compliance
- Korean comments
- Usage example

**Quality Requirements**:
- Clear variable names (descriptive, self-documenting)
- Korean comments for complex logic
- Type safety (explicit types, avoid dynamic)
- Error handling (null checks, edge cases)
- Optimization (const usage, minimal rebuilds)

**Template (for users, in Korean)**:
```dart
// {Component 설명}
class {ComponentName} extends {WidgetType} {
  // {속성 설명}
  final {Type} {propertyName};
  
  const {ComponentName}({
    required this.{propertyName},
    // ... 다른 속성들
  }) : assert({propertyName} != null, '{propertyName}은 필수입니다');
  
  @override
  Widget build(BuildContext context) {
    // {로직 설명}
    // {에러 처리}
    // {반응형 디자인}
    return {widget_tree};
  }
}
```

---

### 6. Implement Responsive Design
**Purpose**: Ensure component works on different screen sizes

**Input**:
- Component code
- Screen size requirements

**Output**:
- Responsive component code
- MediaQuery usage
- Orientation support

**Process**:
1. Identify responsive requirements
2. Add MediaQuery for screen size detection
3. Implement adaptive layouts
4. Test different screen sizes
5. Support portrait and landscape

**Template**:
```dart
// 반응형 디자인 구현
final screenWidth = MediaQuery.of(context).size.width;
final isMobile = screenWidth < 600;
final isTablet = screenWidth >= 600 && screenWidth < 1200;
final isDesktop = screenWidth >= 1200;

// 화면 크기에 따른 레이아웃 조정
if (isMobile) {
  // 모바일 레이아웃
} else if (isTablet) {
  // 태블릿 레이아웃
} else {
  // 데스크톱 레이아웃
}
```

---

### 7. Integrate Error Handling
**Purpose**: Add comprehensive error handling to components

**Input**:
- Component code
- Error scenarios

**Output**:
- Error handling code
- Null safety checks
- Edge case handling
- Fallback UI

**Error Handling Requirements**:
- Null checks for all nullable properties
- Empty state handling
- Loading state handling
- Error state UI
- Validation for inputs

**Template**:
```dart
// 에러 처리 예시
if ({property} == null) {
  return const SizedBox.shrink(); // 또는 기본 위젯
}

try {
  // 위젯 생성 로직
} catch (e) {
  // 에러 처리
  return ErrorWidget(error: e);
}
```

---

## Usage Guidelines

### When to Use Each Skill

1. **Analyze Component Requirements**: Always use at the start
2. **Research Official Patterns**: Use Indexing & Docs first, then MCP if needed
3. **Check Project Structure**: Use deep discovery report for context
4. **Design Component Architecture**: Use after requirements and patterns understood
5. **Generate Component Code**: Use after architecture designed
6. **Implement Responsive Design**: Use for components that need responsiveness
7. **Integrate Error Handling**: Always include in component generation

### Quality Standards

- Always check Indexing & Docs (Flutter_docs) first for official patterns
- Use deep discovery report to understand project structure
- Include error handling and null safety in all components
- Provide Korean comments for better readability
- Use clear, descriptive variable names
- Optimize for performance (const usage, minimal rebuilds)
- Consider responsive design
- Follow Flutter best practices
- Use English for agent communication
- Use Korean for user-facing content and code comments

---

## Integration with MCP Tools

### Indexing & Docs (Primary)
- Flutter_docs: 위젯 API, 레이아웃 패턴, Material Design
- Flutter 공식 아키텍처 가이드: 컴포넌트 구조 패턴
- Dart 언어 문서: 타입 시스템, null safety

### Context7 (Secondary)
- Use for latest Flutter UI patterns
- Check specific package documentation
- Verify new Flutter version features

### Codebase Search (Tertiary)
- Find existing component patterns
- Maintain consistency with project
- Understand project styling approach

---

## Example Workflow

### Scenario: User requests "Material Design 스타일의 커스텀 버튼 컴포넌트 만들어줘"

1. **Analyze Requirements** (Skill 1)
   - Type: Custom Button
   - Styling: Material Design
   - Properties: text, onPressed, color, etc.

2. **Research Patterns** (Skill 2)
   - Check Flutter_docs for Material button patterns
   - Check Material Design guidelines
   - Use MCP Context7 if needed

3. **Check Project Structure** (Skill 3)
   - Read deep discovery report
   - Check existing button patterns
   - Understand project conventions

4. **Design Architecture** (Skill 4)
   - Choose StatelessWidget
   - Design properties
   - Plan error handling

5. **Generate Code** (Skill 5)
   - Create component with quality checks
   - Add Korean comments
   - Include error handling

6. **Implement Responsive** (Skill 6)
   - Add MediaQuery if needed
   - Ensure works on all screen sizes

7. **Integrate Error Handling** (Skill 7)
   - Add null checks
   - Handle edge cases
   - Provide fallback UI

8. **Present Component** (in Korean for users)
   - Show complete code
   - Provide usage example
   - Explain key features
