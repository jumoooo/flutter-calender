# 🛠️ Agent Builder Skills

## Language Separation (언어 구분)
**Internal Processing (Agent reads)**: All instructions, logic, and internal operations are in English.
**User-Facing Content (User sees)**: All explanations, questions, prompts, and responses shown to users are in Korean.

## Overview
This skill provides core functions for the Agent Builder agent. It includes functions for structured information collection, conflict detection, template generation, and agent creation.

**한글 설명 (사용자용)**: 이 스킬은 Agent Builder가 사용하는 핵심 기능들을 제공합니다. 구조화된 정보 수집, 충돌 탐지, 템플릿 생성, Agent 생성 등의 기능을 포함합니다.

---

## Skills

### 1. Collect Required Information with Multiple-Choice
**Purpose**: Guide users through structured information collection using multiple-choice questions

**Input**: 
- User's initial request (may be vague)
- Context about what agent they want to create

**Output**: 
- Structured information collection prompts in Korean
- Multiple-choice questions for key decisions
- Summary of collected information

**Template**:
```
[Agent: Agent Builder]

📋 Agent 생성 정보 수집

{Agent purpose}를 위한 Agent를 생성하기 위해 다음 정보가 필요합니다:

1. Agent 이름을 정해주세요:
   - 예시: {example1}, {example2}, {example3}
   - 입력: [사용자 입력 대기]

2. Agent의 주요 목적을 선택해주세요:
   A) {option A}
   B) {option B}
   C) {option C}
   D) {option D}
   E) 모두 포함
   F) 기타 (직접 입력)

[... more questions ...]

위 정보를 입력해주시면 계속 진행하겠습니다.
```

**Example**:
```
[Agent: Agent Builder]

📋 Agent 생성 정보 수집

코드 리뷰 Agent를 생성하기 위해 다음 정보가 필요합니다:

1. Agent 이름을 정해주세요:
   - 예시: codeReviewer, reviewAgent, codeInspector
   - 입력: [사용자 입력 대기]

2. Agent의 주요 목적을 선택해주세요:
   A) 코드 품질 검사 및 개선 제안
   B) 보안 취약점 탐지
   C) 성능 최적화 제안
   D) 스타일 가이드 준수 확인
   E) 모두 포함
   F) 기타 (직접 입력)
```

---

### 2. Analyze Existing Agents and Skills
**Purpose**: Check existing agents, skills, and rules for reuse opportunities and conflicts

**Input**:
- Target agent name
- Agent purpose and functionality

**Output**:
- List of existing agents with similar functionality
- List of reusable skills
- List of existing rules
- Conflict detection results
- Reuse recommendations

**Process**:
1. List all files in `.cursor/agents/` directory
2. List all files in `.cursor/skills/` directory
3. List all files in `.cursor/rules/` directory
4. Read relevant files to understand functionality
5. Compare with new agent requirements
6. Identify conflicts or overlaps
7. Recommend reuse or new creation

**Template**:
```
기존 Agent 분석 중...
- {existingAgent1}.md 발견 ({description}, 충돌 {없음/있음})
- {existingAgent2}.md 발견 ({description}, 충돌 {없음/있음})

기존 Skills 분석 중...
- {existingSkill1}.md 발견 (재사용 {가능/불가능})
- {existingSkill2}.md 발견 (재사용 {가능/불가능})

기존 Rules 분석 중...
- {existingRule1}.mdc 발견 (관련 {있음/없음})

충돌 검사 결과:
- [ ] 이름 충돌: {없음/있음 - 상세 설명}
- [ ] 기능 중복: {없음/있음 - 상세 설명}
- [ ] 규칙 충돌: {없음/있음 - 상세 설명}

재사용 권장사항:
- {recommendation}
```

---

### 3. Detect Conflicts and Contradictions
**Purpose**: Check for naming conflicts, functional overlaps, and contradictions before and during agent creation

**Input**:
- New agent name
- New agent functionality
- Existing agents list
- Existing rules list

**Output**:
- Conflict detection report
- Stop signal if conflict found
- User notification in Korean

**Conflict Types**:
1. **Naming Conflict**: Same agent name exists
2. **Functional Overlap**: Similar functionality in existing agent
3. **Rule Contradiction**: Conflicting rules
4. **Skill Duplication**: Unnecessary skill duplication

**Template (No Conflict)**:
```
✅ 충돌 검사 완료

- 이름 충돌: 없음
- 기능 중복: 없음
- 규칙 충돌: 없음
- Skills 중복: 없음

계속 진행 가능합니다.
```

**Template (Conflict Detected)**:
```
⚠️ 충돌 감지!

다음 충돌이 발견되었습니다:

1. 이름 충돌:
   - {agentName}이라는 이름의 Agent가 이미 존재합니다.
   - 기존 파일: .cursor/agents/{existingAgent}.md

2. 기능 중복:
   - {newAgent}의 기능이 {existingAgent}와 유사합니다.
   - 중복 기능: {overlapping features}

작업을 중단합니다. 다음 중 선택해주세요:
A) Agent 이름 변경
B) 기존 Agent 수정
C) 기능 범위 조정
D) 취소
```

---

### 4. Generate Agent File from Template
**Purpose**: Create agent file using proven template structure

**Input**:
- Collected information (name, persona, tasks, etc.)
- Template structure
- MCP integration requirements

**Output**:
- Complete agent file with all required sections
- Proper language separation
- MCP integration sections
- Examples and templates

**Template Structure**:
```markdown
---
name: {agentName}
model: fast
description: {brief description}
---

# {Agent Title}

## Language Separation (언어 구분 - 중요!)
[Language separation explanation]

## Role (역할)
[English role]

**한글 설명 (사용자용)**: [Korean role]

## Goals (목표)
[English goals]

**한글 설명 (사용자용)**:
[Korean goals]

## Persona
[English persona]

## Core Principles
[English principles]

## Workflow (Internal Processing - English)
[English workflow]

## MCP Tools Usage Strategy
[English MCP strategy]

## Response Template
[Korean templates]

## Important Notes (Internal Processing - English)
[English notes]

## Skills to Use
[Skills references]

## Quality Checklist
[Checklist]
```

---

### 5. Generate Skills File from Template
**Purpose**: Create separated skills file when beneficial for maintainability

**Input**:
- Agent functionality
- Required skills list
- Template structure

**Output**:
- Complete skills file
- All skill definitions
- Examples and templates

**Template Structure**:
```markdown
# {Skill Name} Skills

## Language Separation
[Language separation]

## Overview
[English overview]

**한글 설명 (사용자용)**: [Korean overview]

## Skills

### 1. {Skill Name}
**Purpose**: [English]

**Input**: 
- [parameters]

**Output**: 
- [description]

**Template**:
[Korean template]

**Example**:
[Korean example]
```

---

### 6. Generate Rules File from Template
**Purpose**: Create rules file following Cursor standards (2026-02-24)

**Input**:
- Agent name
- Rule type (alwaysApply, globs, etc.)
- Rule content

**Output**:
- Complete `.mdc` rules file
- Proper frontmatter
- MDC link references

**Template Structure**:
```markdown
---
alwaysApply: true  # or false
description: "{Rule description}"
globs: "*.dart,*.md"  # optional
---

# {Rule Title}

[Rule content in Korean]

Agent 파일 참조: [agentName.md](mdc:.cursor/agents/agentName.md)
Skills 파일 참조: [skillName.md](mdc:.cursor/skills/skillName.md)
```

---

### 7. Verify Cursor Standards Compliance
**Purpose**: Ensure created agent follows Cursor's official standards (2026-02-24)

**Input**:
- Created agent file
- Created skills file (if any)
- Created rules file (if any)

**Output**:
- Compliance checklist results
- Issues found (if any)
- Recommendations

**Checklist**:
- [ ] Uses `.cursor/rules/*.mdc` format (not `.cursorrules`)
- [ ] Agent file has proper frontmatter
- [ ] Skills separated when beneficial
- [ ] MDC links used correctly: `[filename](mdc:path)`
- [ ] Language separation maintained
- [ ] MCP integration documented
- [ ] All required sections present
- [ ] Templates used correctly

---

### 8. Create Implementation Plan
**Purpose**: Generate detailed plan before implementation for user confirmation

**Input**:
- Collected information
- Analysis results
- Conflict check results

**Output**:
- Detailed implementation plan in Korean
- Files to create/modify list
- Reuse recommendations
- Indexing & Docs + MCP integration strategy
- Deep discovery integration plan (if applicable)
- Documentation output structure (if applicable)

**Template**:
```
[Agent: Agent Builder]

📋 생성 계획

수집된 정보:
1. Agent 이름: {name}
2. Agent 카테고리: {category} 🆕
3. Agent 목적: {purpose}
4. 페르소나: {persona}
5. 주요 작업: {tasks}
6. 독립성/협업: {independence} 🆕
7. Indexing & Docs 활용: {indexingDocs} 🆕
8. Deep Discovery 통합: {deepDiscovery} 🆕
9. MCP 도구: {mcpTools}
10. 문서 출력: {docOutput} 🆕
11. Skills 분리: {skillsSeparation}
12. Rules 필요: {rulesNeeded}

기존 코드 분석 결과:
- 기존 Agent: {existingAgents}
- 재사용 가능 Skills: {reusableSkills}
- 충돌 검사: {conflictStatus}

생성 계획:
1. .cursor/agents/{agentName}.md 생성
2. .cursor/skills/{skillName}.md 생성 (필요시)
3. .cursor/rules/{ruleName}.mdc 생성 (필요시)
4. .cursor/docs/{category}/ 디렉토리 생성 (필요시) 🆕

Indexing & Docs + MCP 통합 전략: 🆕
- Indexing & Docs (Primary): {indexingDocsStrategy}
- MCP Context7 (Secondary): {mcpStrategy}
- Deep Discovery 통합: {deepDiscoveryStrategy}

문서 출력 구조: 🆕
- {docOutputStructure}

Orchestrator 통합 계획:
- {orchestratorIntegration}

위 계획이 맞나요? "진행" 또는 "계속"이라고 답변해주시면 생성하겠습니다.
```

---

### 9. Guide Indexing & Docs Integration 🆕
**Purpose**: Guide agents to utilize Cursor IDE's indexed documentation effectively

**Input**:
- Agent purpose and tasks
- Documentation needs

**Output**:
- Indexing & Docs usage strategy
- Priority order documentation
- Access patterns

**Process**:
1. Identify which indexed docs are relevant (Flutter_docs, 아키텍처 가이드, Dart 언어 문서)
2. Determine when to use each doc source
3. Document access patterns (automatic context vs explicit @reference)
4. Establish priority order: Indexing & Docs → MCP Context7 → Codebase Search
5. Provide examples of usage patterns

**Template**:
```
## Indexing & Docs Usage Strategy

### Cursor IDE Indexed Documentation

**Primary Documentation Sources:**
- **Flutter_docs**: {usage_purpose}
  - When to use: {when_to_use}
  - How to access: {access_method}
  - Example queries: {example_queries}

- **Flutter 공식 아키텍처 가이드**: {usage_purpose}
  - When to use: {when_to_use}
  - How to access: {access_method}

**Priority Strategy:**
1. Indexing & Docs (Primary)
2. MCP Context7 (Secondary)
3. Codebase Search (Tertiary)
```

---

### 10. Guide Deep Discovery Integration 🆕
**Purpose**: Guide agents to utilize deepDiscoveryAgent artifacts effectively

**Input**:
- Agent needs project context
- Deep discovery artifact location

**Output**:
- Deep discovery integration strategy
- Artifact usage patterns
- Update frequency guidelines

**Process**:
1. Check if agent needs project structure context
2. Identify which deep discovery artifacts are relevant
3. Document how to read and use artifacts
4. Guide reuse of existing reports (avoid duplicate scanning)
5. Document when to trigger new deep discovery

**Template**:
```
### Deep Discovery Agent Integration

**Artifact Usage:**
- Read from: `.cursor/docs/deep-discovery/deep-discovery_{ref}_{depth}_{mode}.json`
- Use for: {usage_purpose}
- Update frequency: {update_frequency}

**Integration Pattern:**
1. Check for existing deep discovery report
2. Use report as shared context
3. Supplement with additional analysis if needed
4. Document which report was used
```

---

### 11. Guide Category-Based Organization 🆕
**Purpose**: Organize agents by category for better discoverability and management

**Input**:
- Agent purpose and functionality

**Output**:
- Agent category assignment
- Category-based organization guidance

**Categories**:
- 📚 Learning & Support: 학습 보조, 개념 설명, 질문 답변
- 🛠️ Development Automation: 코드 생성, 리팩토링, 자동화
- 🎼 System Management: Agent 관리, 오케스트레이션, 모니터링
- 📤 Documentation & Deployment: 문서화, 포트폴리오, 배포
- 🔍 Quality Assurance: 코드 리뷰, 테스트, 품질 검사

**Template**:
```
Agent 카테고리: {category}

카테고리 설명:
- {category_description}
- 관련 Agent: {related_agents}
- Orchestrator 통합: {orchestrator_integration}
```

---

### 12. Guide Specialization and Extensibility 🆕
**Purpose**: Design agents to be specialized but extensible (tool-like usage)

**Input**:
- Agent purpose
- Usage scenarios

**Output**:
- Specialization guidance
- Extensibility patterns
- Tool-like usage documentation

**Principles**:
- **Specialization**: Focused on specific domain/task
- **Extensibility**: Can be used as a tool in various contexts
- **Independence**: Works standalone but can collaborate
- **Reusability**: Designed to be invoked when needed

**Template**:
```
## Core Principles

- **Specialization**: Focused on {specific_domain/task}
- **Extensibility**: Can be used as a tool in various contexts
- **Independence**: Works standalone but can collaborate
- **Reusability**: Designed to be invoked when needed
- **Tool-like Usage**: Callable by orchestrator or directly by users

## Usage Patterns

**Standalone Usage:**
- {standalone_usage_examples}

**Collaborative Usage:**
- {collaborative_usage_examples}

**Orchestrator Integration:**
- {orchestrator_integration_patterns}
```

---

### 13. Guide Portfolio Agent Templates 🆕
**Purpose**: Provide specialized templates for portfolio/documentation agents

**Input**:
- Agent is for portfolio/documentation
- Output requirements

**Output**:
- Portfolio-specific template sections
- Documentation output structure
- Integration with documentUploader

**Template Sections**:
- Output Structure
- Architecture Documentation Strategy
- Resume Project Description Format
- Integration with documentUploader

**Template**:
```
## Documentation Output Strategy

**Output Structure:**
- Directory: `.cursor/docs/{category}/`
- Files: {file_list}
- Format: {format}

**Integration with documentUploader:**
- Auto-upload to Notion: {yes/no}
- Upload trigger: {trigger_condition}
- Collaboration pattern: {collaboration_pattern}

## Portfolio-Specific Sections

**Architecture Documentation:**
- {architecture_doc_strategy}

**Resume Project Description:**
- {resume_format}
```

---

## Usage Guidelines

### When to Use Each Skill

1. **Collect Required Information**: Always use at the start when user requests agent creation
2. **Analyze Existing Agents**: Use before creating plan to identify reuse opportunities
3. **Detect Conflicts**: Use before and during creation to prevent issues
4. **Generate Agent File**: Use after user confirmation to create agent
5. **Generate Skills File**: Use when skills separation is beneficial
6. **Generate Rules File**: Use when rules are needed
7. **Verify Standards Compliance**: Use after creation to ensure quality
8. **Create Implementation Plan**: Use before implementation for user confirmation
9. **Guide Indexing & Docs Integration**: Use when agent needs documentation access 🆕
10. **Guide Deep Discovery Integration**: Use when agent needs project context 🆕
11. **Guide Category-Based Organization**: Use to organize agent by category 🆕
12. **Guide Specialization and Extensibility**: Use to design tool-like agent 🆕
13. **Guide Portfolio Agent Templates**: Use when creating portfolio/documentation agents 🆕

### Quality Standards

- All information collection must use multiple-choice when possible
- Never proceed without user confirmation
- Always check for conflicts before creating
- Always use templates for consistency
- Always verify standards compliance
- Always provide Korean explanations for users
- **Always guide Indexing & Docs as primary source** 🆕
- **Always design agents to be specialized but extensible** 🆕
- **Always organize agents by category** 🆕
- **Always guide deep discovery reuse to avoid duplicate scanning** 🆕

---

## Integration with MCP Tools

### Codebase Search
- Use `codebase_search` to find existing agent patterns
- Use `grep` to find specific patterns in agent files
- Use `list_dir` to explore directory structure

### Context7 (if needed)
- Use for Cursor documentation queries
- Verify latest standards and best practices
- **Note**: Use as secondary source after Indexing & Docs 🆕

### Indexing & Docs Integration 🆕
- Guide agents to use Cursor IDE's indexed documentation
- Reference Flutter_docs, Flutter 공식 아키텍처 가이드 automatically
- Document access patterns (automatic context vs explicit @reference)
- Establish priority: Indexing & Docs → MCP Context7 → Codebase Search

### Deep Discovery Integration 🆕
- Check for existing deep discovery artifacts in `.cursor/docs/deep-discovery/`
- Guide agents to reuse existing reports instead of duplicate scanning
- Document which report was used

---

## Example Workflow

### Scenario: User requests "코드 리뷰 Agent 만들어줘"

1. **Collect Information** (Skill 1)
   - Ask multiple-choice questions
   - Collect all required information

2. **Analyze Existing** (Skill 2)
   - Check existing agents
   - Check existing skills
   - Check existing rules

3. **Detect Conflicts** (Skill 3)
   - Check naming conflicts
   - Check functional overlaps
   - Report if conflicts found

4. **Create Plan** (Skill 8)
   - Generate detailed plan
   - Present to user
   - Wait for confirmation

5. **After Confirmation**:
   - Generate Agent File (Skill 4)
   - Generate Skills File (Skill 5) - if separated
   - Generate Rules File (Skill 6) - if needed

6. **Verify Compliance** (Skill 7)
   - Check standards compliance
   - Ensure quality

7. **Complete**
   - Report completion
   - Provide usage instructions
