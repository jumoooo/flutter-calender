# 📚 Content Consistency Skills

## Language Separation (언어 구분)

**Internal Processing (Agent reads)**: All skill descriptions, logic, and internal operations are in English.  
**User-Facing Content (User sees)**: All explanations and summaries that users see are in Korean.

---

## Overview

This skill file provides core skills for the `contentConsistencyAgent`.  
It covers:
- Parsing and interpreting the **consistency matrix**
- Mapping features to screens and concrete files
- Running matrix-based audits against implementation artifacts
- Generating human-readable **issue and suggestion lists**
- Updating `consistency-audit.md` with clear, structured reports

**한글 설명 (사용자용)**:  
이 스킬 파일은 `contentConsistencyAgent`가 사용하는 핵심 기능들을 정의합니다.  
기능 × 화면 매트릭스를 해석하고, 실제 코드 파일과 매핑하며, 기준에 맞게 통일성 감사(누락/불일치 찾기)를 수행하고, 결과를 사람이 읽기 쉬운 형식으로 정리하고, `consistency-audit.md` 문서를 업데이트하는 역할을 합니다.

---

## Skills

### 1. Parse Consistency Matrix

**Purpose**: Read and interpret `consistency-matrix.md` into a structured internal representation.

**Input**:
- Path: `.cursor/docs/improvements/consistency-matrix.md`

**Output**:
- Structured data like:
  - Features: `["category", "time", "dueDate", "priority", "completed"]`
  - Screens: `["input", "detail", "list", "search"]`
  - Requirements per feature/screen: `required` / `recommended` / `none`
  - Screen → file path mapping
  - Display format rules

**Process**:
1. Read the Markdown file.
2. Parse the main feature × screen table (Critical/Important flags).
3. Parse screen/file mapping section.
4. Parse display format section (category/time/dueDate/priority/completed).
5. Build an internal matrix model usable by the agent.

**Template (for agents, in English)**:
```text
Matrix Parsed:
- Features: {features}
- Screens: {screens}
- Requirements:
  {feature}:
    input: {required/recommended/none}
    detail: {required/recommended/none}
    list: {required/recommended/none}
    search: {required/recommended/none}
- Screen → File:
  input: {file}
  detail: {file}
  list: {file}
  search: {file}
```

---

### 2. Map Features to Implementation Files

**Purpose**: Connect matrix entries to concrete Dart files and widgets.

**Input**:
- Parsed matrix model
- Optional `modified_files` from feature implementation artifact

**Output**:
- For each `{feature, screen}` pair:
  - Expected file(s)
  - Whether the file is in `modified_files` (for focused audit)

**Process**:
1. For each screen, use the matrix’s file mapping.
2. Intersect with `modified_files` when available to narrow the scope.
3. Produce a mapping structure to drive the audit.

**Template (for agents, in English)**:
```text
Feature-to-File Map:
- category:
  - input: {file}, in_modified_files: {true/false}
  - detail: {file}, in_modified_files: {true/false}
  - list: {file}, in_modified_files: {true/false}
  - search: {file}, in_modified_files: {true/false}
...
```

---

### 3. Run Matrix-Based Audit

**Purpose**: Compare the matrix requirements with actual implementation and detect inconsistencies.

**Input**:
- Parsed matrix
- Feature-to-file map
- Optionally: code snippets or results from lightweight grep/codebase search

**Output**:
- List of issues:
  - `feature`, `screen`, `file`, `severity` (`critical` / `important`), `description`

**Process (high-level)**:
1. For each feature:
   - For each screen:
     - If requirement is `required`:
       - Check if the feature is present in the mapped file (via code patterns or existing report).
       - If missing → record a `critical` issue.
     - If requirement is `recommended`:
       - If missing → record an `important` issue.
2. Also check:
   - Whether proper utilities (`PriorityColors`, `KoreanDateUtils`, `TodoMetaTagsRow`) are used.
3. Summarize all findings.

**Template (for agents, in English)**:
```text
Audit Issues:
- [critical] category missing on detail screen (file: lib/widgets/todo_detail_dialog.dart)
- [important] completed status not shown on search screen (file: lib/screens/search_result_screen.dart)
```

---

### 4. Suggest Concrete Fixes

**Purpose**: Turn issues into actionable, minimal code change suggestions.

**Input**:
- Issue list from matrix-based audit
- Knowledge of project utilities/components

**Output**:
- Suggestion list:
  - `file`, `location_hint`, `severity`, `suggested_change_snippet`

**Process**:
1. For each issue:
   - Identify approximate insertion/adjustment point (e.g., meta info section in a dialog).
   - Reuse existing patterns (e.g., how category/time/dueDate/meta tags are already rendered in other screens).
   - Build a small snippet that the dev agent or user can apply.
2. Group suggestions by file and severity.

**Template (for agents, in English)**:
```text
Suggestions:
1) File: lib/widgets/todo_detail_dialog.dart
   Severity: critical
   Location: meta info section (below due date row)
   Change:
   - Add a category chip row using the same pattern as in calendar_widget.dart or TodoMetaTagsRow.

2) File: lib/screens/search_result_screen.dart
   Severity: important
   Location: inside _SearchResultItem meta tags row
   Change:
   - Add a small \"완료\" badge when todo.completed is true.
```

---

### 5. Update consistency-audit.md

**Purpose**: Persist audit results and suggestions in a human-readable Markdown report.

**Input**:
- Issue list
- Suggestion list
- Context (date, feature_dev summary, modified_files)

**Output**:
- Updated `.cursor/docs/improvements/consistency-audit.md`

**Process**:
1. Append a new section with:
   - Audit date
   - Short context (e.g., which feature was implemented)
   - Summary of issues (count per severity)
   - Detailed list of issues and suggestions
2. Keep previous sections intact.

**Template (for agents, in English)**:
```markdown
## Audit - 2026-03-06 (Feature: {summary})

- Modified files:
  - {file_1}
  - {file_2}

### Issues
- [critical] {description}
- [important] {description}

### Suggestions
1. {file}: {summary of change}
2. ...
```

**한글 설명 (사용자용)**:  
통일성 감사 결과를 사람이 읽기 좋은 마크다운 형태로 `consistency-audit.md`에 기록하여,  
나중에 어떤 기능 추가/수정 후 어떤 통일성 문제가 있었고, 어떻게 해결했는지 추적할 수 있도록 합니다.

---

## Quality Checklist

Before finishing a skill-based operation, ensure:
- [ ] Matrix file was successfully read and parsed
- [ ] Screen/file mappings are correct
- [ ] All `Critical` requirements were checked
- [ ] Suggestions reuse existing patterns/utilities when possible
- [ ] `consistency-audit.md` was updated (or a clear reason given if skipped)
- [ ] User-facing summaries are in Korean and easy to understand

