# 🎼 Orchestrator Skills

## Language Separation (언어 구분)
**Internal Processing (Agent reads)**: All instructions, logic, and internal operations are in English.
**User-Facing Content (User sees)**: All explanations, questions, reports, and responses shown to users are in Korean.

## Overview
This skill provides core functions for the Orchestrator agent. It includes functions for request analysis, agent selection, task distribution, conflict detection, and multi-agent coordination.

**한글 설명 (사용자용)**: 이 스킬은 Orchestrator가 사용하는 핵심 기능들을 제공합니다. 요청 분석, Agent 선택, 작업 배분, 충돌 탐지, 다중 Agent 협업 등의 기능을 포함합니다.

---

## Skills

### 1. Analyze User Request
**Purpose**: Understand user request and classify task type

**Input**: 
- User request text
- Context from conversation

**Output**: 
- Task classification
- Complexity assessment
- Required capabilities
- Task dependencies

**Process**:
1. Parse request to extract key information
2. Classify task type (learning, agent creation, code review, etc.)
3. Assess complexity (simple, moderate, complex)
4. Identify required capabilities
5. Determine if single or multi-agent needed

**Template**:
```
**작업 분석:**
- 작업 유형: {task type}
- 복잡도: {simple/moderate/complex}
- 필요한 기능: {required capabilities}
- Agent 수: {single/multiple}
```

---

### 2. Discover Available Agents
**Purpose**: Dynamically discover and catalog available agents

**Input**:
- None (discovers from filesystem)

**Output**:
- List of available agents
- Agent capabilities
- Agent triggers
- Agent status

**Process**:
1. List files in `.cursor/agents/` directory
2. Read each agent file to extract:
   - Name and description
   - Capabilities and purpose
   - Auto-invocation triggers
   - MCP tools used
3. Build agent registry
4. Check agent status (active/inactive)

**Template**:
```
**사용 가능한 Agent:**
1. {agentName}
   - 목적: {purpose}
   - 기능: {capabilities}
   - 트리거: {triggers}
   - 상태: {active/inactive}
```

---

### 3. Select Appropriate Agent(s)
**Purpose**: Match task requirements with agent capabilities

**Input**:
- Task requirements
- Available agents list
- Task classification

**Output**:
- Selected agent(s)
- Selection reasoning
- Task assignment per agent

**Process**:
1. Match task type with agent specializations
2. Check agent triggers against request
3. Evaluate agent capabilities vs requirements
4. Select primary agent
5. Identify supporting agents if needed
6. Document selection reasoning

**Template**:
```
**선택된 Agent:**
1. {agentName} (주요 Agent)
   - 선택 이유: {reason}
   - 담당 작업: {task}
   
2. {agentName} (보조 Agent, 필요시)
   - 선택 이유: {reason}
   - 담당 작업: {task}
```

---

### 4. Create Distribution Plan
**Purpose**: Create detailed plan for task distribution

**Input**:
- Selected agent(s)
- Task requirements
- Task dependencies

**Output**:
- Distribution plan
- Task sequence
- Expected workflow
- Estimated completion

**Template**:
```
**작업 배분 계획:**

**주요 Agent:** {primaryAgent}
- 담당: {primary task}
- 예상 소요: {time estimate}

**보조 Agent:** {supportingAgents} (필요시)
- 담당: {supporting tasks}

**작업 순서:**
1. {step 1} - {agent}
2. {step 2} - {agent}
...

**예상 결과:**
{expected outcome}
```

---

### 5. Detect Agent Conflicts
**Purpose**: Check for conflicts before distributing tasks

**Input**:
- Selected agents
- Task assignments
- Agent registry

**Output**:
- Conflict detection report
- Conflict details (if any)
- Resolution suggestions

**Conflict Types**:
1. **Overlapping Tasks**: Multiple agents assigned same task
2. **Contradictory Instructions**: Agents with conflicting approaches
3. **Resource Conflicts**: Agents competing for same resources
4. **Dependency Issues**: Circular or broken dependencies

**Template (No Conflict)**:
```
✅ 충돌 검사 완료

- 작업 중복: 없음
- 지시사항 충돌: 없음
- 리소스 충돌: 없음
- 의존성 문제: 없음

배분 가능합니다.
```

**Template (Conflict Detected)**:
```
⚠️ 충돌 감지!

다음 충돌이 발견되었습니다:

1. {conflict type}:
   - {conflict details}
   - 영향받는 Agent: {agents}

작업을 중단합니다. 다음 중 선택해주세요:
A) Agent 재선택
B) 작업 범위 조정
C) 충돌 해결 방법 제시 요청
D) 취소
```

---

### 6. Generate Distribution Report
**Purpose**: Create clear report for user in Korean

**Input**:
- Distribution plan
- Selected agents
- Task analysis

**Output**:
- User-friendly report in Korean
- Clear explanation of plan
- Confirmation request

**Template**:
```
[Agent: Orchestrator]

📋 작업 분석 및 Agent 배분 계획

**사용자 요청:**
{user request}

**작업 분석:**
- 작업 유형: {task type}
- 복잡도: {complexity}
- 필요한 Agent: {number}개

**선택된 Agent:**
1. {agentName}
   - 선택 이유: {reason}
   - 담당 작업: {task description}
   - 예상 소요: {estimate}

**작업 순서:**
1. {step 1}
2. {step 2}

**예상 결과:**
{expected outcome}

위 배분 계획이 맞나요? "진행" 또는 "계속"이라고 답변해주시면 작업을 시작하겠습니다.
```

---

### 7. Coordinate Multi-Agent Tasks
**Purpose**: Coordinate when multiple agents need to work together

**Input**:
- Multiple agents
- Task dependencies
- Data flow requirements

**Output**:
- Coordination plan
- Task sequence
- Data flow definition

**Process**:
1. Identify task dependencies
2. Determine execution order (sequential/parallel)
3. Define data flow between agents
4. Set coordination checkpoints
5. Create coordination plan

**Template**:
```
**다중 Agent 협업 계획:**

**작업 순서:**
1. {agent1} → {task1} → 결과 전달
2. {agent2} → {task2} (agent1 결과 사용)
3. {agent3} → {task3} (agent2 결과 사용)

**데이터 흐름:**
{agent1} 결과 → {agent2} 입력
{agent2} 결과 → {agent3} 입력

**조율 지점:**
- {checkpoint1}: {agent1} 완료 후
- {checkpoint2}: {agent2} 완료 후
```

---

### 8. Monitor Task Progress
**Purpose**: Track task execution and report progress

**Input**:
- Distributed tasks
- Agent execution status

**Output**:
- Progress updates
- Completion status
- Issues or blockers

**Template**:
```
**작업 진행 상황:**

✅ {agent1}: {task1} 완료
⏳ {agent2}: {task2} 진행 중...
⏸️ {agent3}: {task3} 대기 중

**현재 단계:** {current step} / {total steps}
**예상 완료:** {estimated completion}
```

---

### 9. Update Agent Registry
**Purpose**: Update orchestrator's agent registry when new agents are added

**Input**:
- New agent file
- Agent metadata

**Output**:
- Updated registry
- Conflict check results
- Integration plan

**Process**:
1. Read new agent file
2. Extract agent information
3. Check for conflicts with existing agents
4. Update registry
5. Update distribution rules if needed
6. Report integration status

**Template**:
```
**Agent Registry 업데이트:**

새로운 Agent 추가됨: {newAgentName}

**Agent 정보:**
- 목적: {purpose}
- 기능: {capabilities}
- 트리거: {triggers}

**충돌 검사:**
- {conflict check results}

**통합 상태:**
- Registry 업데이트: 완료
- Distribution Rules 업데이트: {status}
```

---

## Usage Guidelines

### When to Use Each Skill

1. **Analyze User Request**: Always use at the start
2. **Discover Available Agents**: Use when registry needs update or at start
3. **Select Appropriate Agent(s)**: Use after request analysis
4. **Create Distribution Plan**: Use after agent selection
5. **Detect Agent Conflicts**: Use before finalizing distribution
6. **Generate Distribution Report**: Use to present plan to user
7. **Coordinate Multi-Agent Tasks**: Use when multiple agents needed
8. **Monitor Task Progress**: Use during task execution
9. **Update Agent Registry**: Use when new agents are added

### Quality Standards

- Always analyze request before distribution
- Always check for conflicts
- Always get user confirmation
- Always report clearly in Korean
- Always maintain agent independence
- Always update registry when agents change

---

## Integration with MCP Tools

### Codebase Search
- Use `codebase_search` to find agent files
- Use `list_dir` to discover agents dynamically
- Use `grep` to find agent triggers and capabilities

### Context7 (if needed)
- Use for Cursor documentation queries
- Verify agent creation standards

---

## Example Workflow

### Scenario: User requests "Flutter 학습하면서 코드도 리뷰받고 싶어"

1. **Analyze Request** (Skill 1)
   - Task type: Multi-task (learning + code review)
   - Complexity: Moderate
   - Requires: studyAgent + codeReviewer (if exists)

2. **Discover Agents** (Skill 2)
   - studyAgent: Available
   - codeReviewer: Not found
   - agentBuilder: Available

3. **Select Agents** (Skill 3)
   - Primary: studyAgent (learning)
   - Note: codeReviewer doesn't exist yet

4. **Detect Conflicts** (Skill 5)
   - No conflicts

5. **Generate Report** (Skill 6)
   - Present plan to user
   - Suggest creating codeReviewer if needed

6. **After Confirmation**:
   - Delegate to studyAgent
   - Suggest creating codeReviewer via agentBuilder if user wants
