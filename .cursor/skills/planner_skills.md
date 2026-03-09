# 📋 Planner Skills

## Language Separation (언어 구분)
**Internal Processing (Agent reads)**: All instructions, logic, and internal operations are in English.
**Agent-to-Agent Communication**: All communication between agents is in English.
**Agent Output (for other agents)**: All outputs that other agents read are in English.
**User-Facing Content (User sees)**: All explanations, questions, plans, and responses shown to users are in Korean.

## Overview
This skill provides core functions for the Planner agent. It includes functions for request analysis, task breakdown, priority management, resource estimation, checklist creation, and progress tracking.

**한글 설명 (사용자용)**: 이 스킬은 Planner가 사용하는 핵심 기능들을 제공합니다. 요청 분석, 작업 분해, 우선순위 관리, 리소스 추정, 체크리스트 생성, 진행 상황 추적 등의 기능을 포함합니다.

---

## Skills

### 1. Analyze User Request
**Purpose**: Understand user request and extract planning requirements

**Input**: 
- User request text
- Context from conversation
- Current project state

**Output**: 
- Project scope and goals
- Requirements and constraints
- Success criteria
- Complexity assessment

**Process**:
1. Parse request to extract key information
2. Identify implicit requirements
3. Determine project scope
4. Assess complexity
5. Identify stakeholders and dependencies

**Template (for agents, in English)**:
```
Request Analysis:
- Scope: {scope description}
- Goals: {goals}
- Requirements: {requirements}
- Constraints: {constraints}
- Complexity: {simple/moderate/complex}
```

**Template (for users, in Korean)**:
```
**프로젝트 분석:**
- 범위: {scope description}
- 목표: {goals}
- 요구사항: {requirements}
- 제약사항: {constraints}
- 복잡도: {simple/moderate/complex}
```

---

### 2. Break Down Tasks
**Purpose**: Decompose complex tasks into manageable, actionable steps

**Input**:
- Main task or project description
- Requirements and constraints
- Current project state

**Output**:
- List of atomic tasks
- Task dependencies
- Task groupings
- Deliverables per task

**Process**:
1. Identify main components
2. Break into sub-tasks
3. Ensure each task is atomic and actionable
4. Identify dependencies
5. Group related tasks
6. Define deliverables

**Template (for agents, in English)**:
```
Task Breakdown:
1. {task_id}: {task_name}
   - Dependencies: {dependencies}
   - Deliverables: {deliverables}
   - Group: {group_name}

2. {task_id}: {task_name}
   ...
```

**Template (for users, in Korean)**:
```
**작업 분해:**
1. {task_name}
   - 의존성: {dependencies}
   - 산출물: {deliverables}
   - 그룹: {group_name}

2. {task_name}
   ...
```

---

### 3. Determine Priorities
**Purpose**: Assign priority levels to tasks based on dependencies, importance, and urgency

**Input**:
- List of tasks
- Dependencies between tasks
- Importance assessment
- Urgency assessment

**Output**:
- Priority levels for each task
- Priority rationale
- Critical path identification

**Priority Levels**:
- **Critical**: Blocking other tasks, must be done first
- **High**: Important and time-sensitive
- **Medium**: Important but not urgent
- **Low**: Can be deferred

**Process**:
1. Analyze dependencies
2. Identify blocking tasks
3. Assess importance
4. Consider urgency
5. Assign priority levels
6. Identify critical path

**Template (for agents, in English)**:
```
Priorities:
- Critical: [{task_ids}]
- High: [{task_ids}]
- Medium: [{task_ids}]
- Low: [{task_ids}]

Critical Path: {task_sequence}
```

**Template (for users, in Korean)**:
```
**우선순위:**
- 🔴 Critical: {critical tasks}
- 🟠 High: {high priority tasks}
- 🟡 Medium: {medium priority tasks}
- 🟢 Low: {low priority tasks}

**중요 경로:** {critical path}
```

---

### 4. Estimate Resources
**Purpose**: Estimate time and resources required for each task

**Input**:
- Task list
- Task complexity
- Available resources
- Historical data (if available)

**Output**:
- Time estimates per task
- Resource requirements
- Total project duration
- Resource allocation

**Process**:
1. Assess task complexity
2. Estimate time per task
3. Identify required resources (tools, agents, data)
4. Consider dependencies
5. Add buffers for uncertainty
6. Calculate total duration

**Template (for agents, in English)**:
```
Resource Estimates:
- Task {id}: {time_estimate}, Resources: {resources}
- Total Duration: {total_duration}
- Buffer: {buffer_percentage}%
```

**Template (for users, in Korean)**:
```
**리소스 추정:**
- {task_name}: {time_estimate}, 필요한 리소스: {resources}
- 총 소요 시간: {total_duration}
- 여유 시간: {buffer_percentage}%
```

---

### 5. Create Checklist
**Purpose**: Generate actionable checklist for task tracking

**Input**:
- Task list
- Priorities
- Dependencies
- Milestones

**Output**:
- Structured checklist
- Acceptance criteria
- Milestones
- Progress tracking format

**Process**:
1. Convert tasks to checklist items
2. Add acceptance criteria
3. Set milestones
4. Organize by priority or phase
5. Create tracking format

**Template (for users, in Korean)**:
```
**체크리스트:**

**Phase 1: {phase_name}**
- [ ] {task 1} - {acceptance_criteria}
- [ ] {task 2} - {acceptance_criteria}

**마일스톤:**
- {milestone_name}: {date} - {tasks_completed}
```

---

### 6. Track Progress
**Purpose**: Monitor task completion and update plan status

**Input**:
- Current checklist status
- Completed tasks
- In-progress tasks
- Blocked tasks

**Output**:
- Progress report
- Updated checklist
- Next steps
- Risk identification

**Process**:
1. Check task completion status
2. Update checklist
3. Calculate progress percentage
4. Identify blockers
5. Update priorities if needed
6. Generate progress report

**Template (for agents, in English)**:
```
Progress Status:
- Completed: {task_ids}
- In Progress: {task_ids}
- Blocked: {task_ids} (blockers: {blockers})
- Progress: {percentage}%
- Next: {next_task_id}
```

**Template (for users, in Korean)**:
```
**진행 상황:**
- ✅ 완료: {completed tasks}
- ⏳ 진행 중: {in-progress tasks}
- ⏸️ 대기 중: {blocked tasks} (블로커: {blockers})
- 📊 진행률: {percentage}%
- 📌 다음 작업: {next task}
```

---

### 7. Use Sequential Thinking for Complex Planning
**Purpose**: Apply sequential thinking tool for complex planning scenarios

**Input**:
- Complex planning problem
- Multiple interdependent factors
- Need for deep analysis

**Output**:
- Structured thought process
- Planning hypothesis
- Evaluated approaches
- Refined plan

**Process**:
1. Identify complexity requiring sequential thinking
2. Use `mcp_sequential-thinking_sequentialthinking` tool
3. Break down into thought steps
4. Consider multiple approaches
5. Evaluate trade-offs
6. Generate planning hypothesis
7. Verify and refine

**When to use**:
- Multi-phase projects
- Complex dependencies
- Multiple implementation approaches
- Risk assessment needed
- Resource optimization required

**Template**:
```
Sequential Thinking Analysis:
- Problem: {problem_description}
- Approach 1: {approach} - Pros: {pros}, Cons: {cons}
- Approach 2: {approach} - Pros: {pros}, Cons: {cons}
- Selected Approach: {selected} - Reason: {reason}
- Refined Plan: {plan_structure}
```

---

### 8. Integrate with Other Agents
**Purpose**: Collaborate with other agents when their expertise is needed

**Input**:
- Planning task requiring specialized knowledge
- Agent capabilities registry

**Output**:
- Agent consultation results
- Integrated plan
- Agent recommendations

**Process**:
1. Identify need for agent expertise
2. Consult appropriate agent (studyAgent, agentBuilder, etc.)
3. Integrate agent input into plan
4. Update plan based on agent recommendations

**Example Scenarios**:
- Planning learning path → Consult studyAgent
- Planning agent creation → Consult agentBuilder
- Planning code implementation → Consult studyAgent for Flutter patterns

**Template (for agents, in English)**:
```
Agent Consultation:
- Consulted: {agent_name}
- Input: {agent_input}
- Integrated: {how_integrated}
```

---

### 9. Generate Multiple Plan Alternatives 🆕
**Purpose**: Create multiple plan approaches for comparison and optimization

**Input**:
- User request analysis
- Project context
- Requirements and constraints
- Deep discovery artifacts (if available)
- Historical plan patterns (from memory)

**Output**:
- 3-5 different plan alternatives
- Each with different focus (conservative, balanced, aggressive, hybrid, context-optimized)
- Complete task breakdown for each alternative
- Dependency mapping for each
- Resource estimates for each

**Process**:
1. **Conservative Plan Generation**
   - Focus: Maximum stability, minimum risk
   - Approach: More detailed steps, extensive error handling, multiple checkpoints
   - Risk level: Low
   - Use when: Critical systems, high-stakes projects, uncertain requirements

2. **Balanced Plan Generation**
   - Focus: Efficiency + Stability balance
   - Approach: Optimized step count, balanced risk, good error handling
   - Risk level: Medium
   - Use when: Standard projects, clear requirements, moderate complexity

3. **Aggressive Plan Generation**
   - Focus: Maximum speed, minimum steps
   - Approach: Fewer steps, assumes minimal issues, streamlined process
   - Risk level: High
   - Use when: Time-critical, well-understood tasks, low complexity

4. **Hybrid Plan Generation**
   - Focus: Combines best elements from different approaches
   - Approach: Mix of conservative and aggressive elements strategically
   - Risk level: Variable
   - Use when: Complex projects with mixed requirements

5. **Context-Optimized Plan Generation**
   - Focus: Based on project-specific patterns
   - Approach: Uses deep discovery artifacts, historical patterns, project conventions
   - Risk level: Optimized for context
   - Use when: Project has clear patterns, historical data available

**Template (for agents, in English)**:
```
Plan Alternatives Generated:
1. Conservative Plan:
   - Focus: {stability}
   - Steps: {count}
   - Risk Level: Low
   - Key Features: {features}

2. Balanced Plan:
   - Focus: {efficiency + stability}
   - Steps: {count}
   - Risk Level: Medium
   - Key Features: {features}

3. Aggressive Plan:
   - Focus: {speed}
   - Steps: {count}
   - Risk Level: High
   - Key Features: {features}

4. Hybrid Plan:
   - Focus: {combined approach}
   - Steps: {count}
   - Risk Level: {level}
   - Key Features: {features}

5. Context-Optimized Plan:
   - Focus: {project-specific}
   - Steps: {count}
   - Risk Level: {level}
   - Key Features: {features}
```

**When to use**:
- Complex planning requests (moderate to high complexity)
- Multiple valid approaches exist
- User requirements are ambiguous or have trade-offs
- Project has significant risks or constraints

**When to skip** (for efficiency):
- Simple, straightforward requests
- Single obvious approach
- Very low complexity tasks

---

### 10. Evaluate Plans 🆕
**Purpose**: Score each plan on quality, efficiency, and stability dimensions

**Input**:
- Multiple plan alternatives
- Evaluation criteria
- User requirements
- Project constraints

**Output**:
- Score for each plan (Quality, Efficiency, Stability, Total)
- Ranking of plans
- Strengths and weaknesses of each plan
- Best use cases for each approach

**Evaluation Formula**:

**Quality Score** (0-100):
- Requirements Coverage (0-40):
  - All explicit requirements included: 40 points
  - Most requirements included: 25-35 points
  - Some requirements missing: 10-20 points
  - Many requirements missing: 0-10 points
- Completeness (0-30):
  - All necessary steps included: 30 points
  - Most steps included: 20-25 points
  - Some steps missing: 10-15 points
  - Many steps missing: 0-10 points
- Clarity (0-30):
  - All steps clear and actionable: 30 points
  - Most steps clear: 20-25 points
  - Some steps vague: 10-15 points
  - Many steps vague: 0-10 points

**Efficiency Score** (0-100):
- Step Count Optimization (0-40):
  - Minimal steps without sacrificing quality: 40 points
  - Reasonable step count: 25-35 points
  - Too many or too few steps: 10-20 points
  - Extremely inefficient: 0-10 points
- Time Estimation Accuracy (0-30):
  - Realistic and detailed estimates: 30 points
  - Generally realistic: 20-25 points
  - Somewhat unrealistic: 10-15 points
  - Very unrealistic: 0-10 points
- Resource Utilization (0-30):
  - Optimal resource usage: 30 points
  - Good resource usage: 20-25 points
  - Inefficient resource usage: 10-15 points
  - Very inefficient: 0-10 points

**Stability Score** (0-100):
- Dependency Conflict Risk (0-40):
  - No dependency conflicts: 40 points
  - Low risk of conflicts: 25-35 points
  - Medium risk: 15-25 points
  - High risk: 0-15 points
- Rollback Possibility (0-30):
  - Easy rollback at each step: 30 points
  - Some rollback points: 20-25 points
  - Limited rollback: 10-15 points
  - Difficult to rollback: 0-10 points
- Error Handling (0-30):
  - Comprehensive error handling: 30 points
  - Basic error handling: 20-25 points
  - Minimal error handling: 10-15 points
  - No error handling: 0-10 points

**Total Score Calculation**:
- Total Score = (Quality × 0.4) + (Efficiency × 0.35) + (Stability × 0.25)
- Weighting prioritizes quality while balancing efficiency and stability

**Template (for agents, in English)**:
```
Plan Evaluation Results:

Plan 1 (Conservative):
- Quality: {q_score}/100
  - Requirements Coverage: {rc}/40
  - Completeness: {c}/30
  - Clarity: {cl}/30
- Efficiency: {e_score}/100
  - Step Optimization: {so}/40
  - Time Accuracy: {ta}/30
  - Resource Utilization: {ru}/30
- Stability: {s_score}/100
  - Dependency Risk: {dr}/40
  - Rollback Capability: {rb}/30
  - Error Handling: {eh}/30
- Total: {total_score}/100
- Strengths: {strengths}
- Weaknesses: {weaknesses}
- Best Use Case: {use_case}

[Similar for other plans...]

Ranking: Plan {X} ({score}) > Plan {Y} ({score}) > Plan {Z} ({score})
Selected Base Plan: Plan {X}
Selection Rationale: {reason}
```

**Template (for users, in Korean)**:
```
**계획 평가 결과:**

1. 보수적 계획:
   - 품질: {q_score}/100
   - 효율성: {e_score}/100
   - 안정성: {s_score}/100
   - 총점: {total_score}/100
   - 강점: {strengths}
   - 약점: {weaknesses}

[다른 계획들도 동일 형식...]

**순위:** {plan_name_1} > {plan_name_2} > {plan_name_3}
**선택된 기본 계획:** {plan_name}
**선택 이유:** {reason}
```

---

### 11. Synthesize Optimal Plan 🆕
**Purpose**: Merge best elements from multiple plans into final optimized plan

**Input**:
- Selected base plan (highest score)
- Other plan alternatives
- Identified strengths from each plan
- Evaluation results

**Output**:
- Final synthesized plan
- Documentation of merged elements
- Verification of no conflicts
- Improved total score

**Process**:
1. **Base Plan Selection**
   - Use highest-scoring plan as foundation
   - Document why this plan was selected
   - Preserve core structure and logic
   - Maintain valid dependencies

2. **Element Extraction from Other Plans**
   - Analyze each alternative plan systematically
   - Identify unique strengths:
     - **Better task granularity**: More detailed or more appropriate task breakdown
     - **More efficient sequencing**: Better task ordering or parallelization opportunities
     - **Better risk mitigation**: Superior error handling or rollback strategies
     - **More comprehensive coverage**: Additional important steps or considerations
     - **Better resource allocation**: More efficient use of time or tools
     - **Superior dependency management**: Better handling of task dependencies
   - Document each strength with rationale

3. **Synthesis Process**
   - Merge best elements into base plan:
     - Replace or enhance tasks with better versions from other plans
     - Integrate superior sequencing where it doesn't conflict
     - Add missing important steps from other plans
     - Incorporate better risk mitigation strategies
     - Optimize resource allocation based on best practices
   - After each merge, verify:
     - No logical conflicts introduced
     - Dependencies remain valid
     - No duplicate tasks created
     - Timeline remains realistic
     - Resource requirements still feasible

4. **Conflict Resolution**
   - If conflicts arise during synthesis:
     - Prefer base plan elements (highest score)
     - But consider if alternative is significantly better
     - Document resolution decisions
     - Verify no contradictions remain
   - If cannot resolve, keep base plan element

5. **Final Optimization**
   - Re-evaluate synthesized plan:
     - Recalculate scores (should be higher than base)
     - Verify all requirements still met
     - Check dependencies are correct
     - Optimize resource allocation
   - Final quality check:
     - Completeness
     - Clarity
     - Feasibility
     - Risk assessment

6. **Documentation**
   - Document which elements came from which plans
   - Record synthesis decisions
   - Store in memory for learning (Aim-Memory-Bank with context: "planning")

**Template (for agents, in English)**:
```
Plan Synthesis:
- Base Plan: {plan_name} (Score: {base_score})
- Base Plan Selection Reason: {reason}

Elements Merged:
- From Plan A ({plan_name}):
  - Element: {element_description}
  - Reason: {why_better}
  - Impact: {improvement_description}
  
- From Plan B ({plan_name}):
  - Element: {element_description}
  - Reason: {why_better}
  - Impact: {improvement_description}

[Continue for other plans...]

Synthesis Verification:
- Conflicts: {none/found_and_resolved}
- Dependencies: {all_valid}
- Duplicates: {none/found_and_removed}
- Timeline: {realistic}
- Resources: {feasible}

Final Optimized Plan:
- Structure: {plan_structure}
- Recalculated Score: {new_score} (improvement: +{delta})
- Quality: {q}/100
- Efficiency: {e}/100
- Stability: {s}/100
```

**Template (for users, in Korean)**:
```
**계획 통합 완료:**

**기본 계획:** {plan_name} (점수: {base_score})
**선택 이유:** {reason}

**통합된 요소:**
- {plan_A}에서: {element} - {reason}
- {plan_B}에서: {element} - {reason}
- {plan_C}에서: {element} - {reason}

**통합 검증:**
- ✅ 충돌 없음
- ✅ 의존성 유효
- ✅ 중복 없음
- ✅ 타임라인 현실적
- ✅ 리소스 가능

**최종 최적화 계획 점수:** {new_score}/100 (개선: +{delta})
```

**When to use**:
- After generating multiple plans
- After evaluating plans
- When base plan can be improved by other plans' strengths

**Quality check**:
- Synthesized plan should score higher than base plan
- All requirements must still be met
- No logical conflicts
- Dependencies must be valid

---

## Usage Guidelines

### When to Use Each Skill

1. **Analyze User Request**: Always use at the start
2. **Use Sequential Thinking**: Use for complex planning scenarios
3. **Generate Multiple Plan Alternatives** 🆕: Use for complex/moderate complexity requests (skip for simple requests)
4. **Evaluate Plans** 🆕: Use after generating multiple plans
5. **Synthesize Optimal Plan** 🆕: Use after evaluating plans to create final optimized plan
6. **Break Down Tasks**: Use after plan synthesis (or directly after request analysis for simple requests)
7. **Determine Priorities**: Use after task breakdown
8. **Estimate Resources**: Use after priorities determined
9. **Create Checklist**: Use after all planning complete
10. **Track Progress**: Use during plan execution
11. **Integrate with Other Agents**: Use when specialized knowledge needed

### Quality Standards

- Always analyze request fully before planning
- **Generate multiple plans for complex requests** 🆕
- **Evaluate plans objectively using defined criteria** 🆕
- **Synthesize best elements into final plan** 🆕
- Break tasks into atomic, actionable steps
- Consider all dependencies
- Provide realistic estimates with buffers
- Create trackable checklists
- Update plans based on progress
- Use English for agent communication
- Use Korean for user-facing content
- **Store plan evaluation results in memory for learning** 🆕

---

## Integration with MCP Tools

### Sequential Thinking
- Use `mcp_sequential-thinking_sequentialthinking` for complex planning
- Break down complex problems into thought steps
- Evaluate multiple approaches

### Context7
- Use for technology documentation
- Understand framework capabilities
- Plan technical implementations

### Codebase Search
- Use to understand current project state
- Identify existing implementations
- Plan modifications

### Browser Tools
- Use for external documentation
- Research best practices
- Verify resource availability

---

## Example Workflow

### Scenario: User requests "Flutter 앱에 로그인 기능 추가하는 계획 세워줘"

1. **Analyze Request** (Skill 1)
   - Scope: Add login feature to Flutter app
   - Goals: User authentication
   - Complexity: Moderate

2. **Use Sequential Thinking** (Skill 7) - if needed for complex analysis
   - Evaluate different authentication approaches
   - Consider security implications
   - Plan implementation phases

3. **Generate Multiple Plan Alternatives** (Skill 9) 🆕
   - Conservative Plan: Detailed steps, extensive error handling
   - Balanced Plan: Optimized approach
   - Aggressive Plan: Fast implementation
   - Hybrid Plan: Combines approaches
   - Context-Optimized Plan: Based on project patterns

4. **Evaluate Plans** (Skill 10) 🆕
   - Score each plan on Quality, Efficiency, Stability
   - Rank plans by total score
   - Identify strengths and weaknesses

5. **Synthesize Optimal Plan** (Skill 11) 🆕
   - Select highest-scoring plan as base
   - Merge best elements from other plans
   - Verify no conflicts
   - Final optimization

6. **Break Down Tasks** (Skill 2)
   - Use synthesized plan structure
   - UI implementation
   - API integration
   - State management
   - Security validation

7. **Determine Priorities** (Skill 3)
   - Critical: UI, API
   - High: State management, Security

8. **Estimate Resources** (Skill 4)
   - Time per task
   - Required packages
   - Agent consultations needed

9. **Create Checklist** (Skill 5)
   - Actionable items
   - Acceptance criteria
   - Milestones

10. **Present Plan** (in Korean for users)
    - Show multi-plan comparison
    - Show selected and synthesized plan
    - Clear structure
    - All information in Korean
    - Agent-readable version in English

11. **Track Progress** (Skill 6) - during execution
    - Monitor completion
    - Update status
    - Report to user
