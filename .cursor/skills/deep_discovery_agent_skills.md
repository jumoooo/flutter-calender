# 🧭 Deep Discovery Agent Skills

## Language Separation (언어 구분)
**Internal Processing (Agent reads)**: All instructions, logic, and internal operations are in English.
**User-Facing Content (User sees)**: All explanations, summaries, and reports shown to users are in Korean.

## Overview
This skill provides core functions for the Deep Discovery Agent. It includes functions for project structure analysis, tech stack detection, hotspot detection, and report generation.

**한글 설명 (사용자용)**: 이 스킬은 Deep Discovery Agent가 사용하는 핵심 기능들을 제공합니다. 프로젝트 구조 분석, 기술 스택 감지, 핫스팟 감지, 리포트 생성 등의 기능을 포함합니다.

---

## Core Skills

### 1. Project Structure Analysis
**Purpose**: Analyze project directory structure and identify key components

**Input**: 
- Project root path
- Analysis scope (paths, exclude_paths)
- Depth level (light, standard, deep)

**Output**: 
- Directory structure tree
- Key component identification
- Role assignments for directories
- Component relationships

**Process**:
1. Scan project directory structure
2. Identify key directories (lib, test, assets, etc.)
3. Assign roles to directories
4. Map component relationships
5. Generate structured directory tree

**Template (for agents, in English)**:
```
Project Structure Analysis:
- Root: {project_root}
- Depth: {light/standard/deep}
- Key Directories: {directory_list}
- Components: {component_list}
```

**한글 예시 (사용자용)**:
```
프로젝트 구조 분석:
- 루트: /flutter_calender
- 깊이: standard
- 주요 디렉터리: lib/, test/, assets/
- 컴포넌트: CalendarWidget, TodoProvider, TodoModel
```

---

### 2. Tech Stack Detection
**Purpose**: Identify technologies, frameworks, and dependencies used in the project

**Input**: 
- Project files (pubspec.yaml, package.json, etc.)
- Source code files
- Configuration files

**Output**: 
- Main tech stack list
- Languages used
- Frameworks identified
- Package managers detected
- Key dependencies

**Process**:
1. Read package manager files (pubspec.yaml, package.json)
2. Analyze source code for framework usage
3. Identify languages from file extensions
4. Detect package managers
5. List key dependencies

**Template (for agents, in English)**:
```
Tech Stack Detection:
- Languages: {language_list}
- Frameworks: {framework_list}
- Package Managers: {package_manager_list}
- Key Dependencies: {dependency_list}
```

**한글 예시 (사용자용)**:
```
기술 스택 감지:
- 언어: Dart
- 프레임워크: Flutter
- 패키지 관리자: pub
- 주요 의존성: provider, hive, intl
```

---

### 3. Hotspot Detection
**Purpose**: Identify complexity hotspots and potential risk areas

**Input**: 
- Source code files
- Complexity metrics
- Code patterns

**Output**: 
- Hotspot locations
- Complexity scores
- Risk assessments
- Recommendations

**Process**:
1. Analyze code complexity
2. Identify large files or functions
3. Detect potential risk patterns
4. Calculate complexity scores
5. Generate risk assessments and recommendations

**Template (for agents, in English)**:
```
Hotspot Detection:
- Hotspots: {hotspot_list}
- Complexity Scores: {score_list}
- Risks: {risk_list}
- Recommendations: {recommendation_list}
```

**한글 예시 (사용자용)**:
```
핫스팟 감지:
- 핫스팟: lib/widgets/calendar_widget.dart (1432 lines)
- 복잡도 점수: 높음
- 리스크: 유지보수 어려움, 테스트 복잡도 증가
- 권장사항: 위젯 분리, 상태 관리 개선
```

---

### 4. Report Generation
**Purpose**: Generate structured JSON and Markdown reports for reuse by other agents

**Input**: 
- Analysis results (structure, tech stack, hotspots)
- Input parameters (depth_level, mode)
- Project metadata

**Output**: 
- JSON report (machine-consumable)
- Markdown report (human-readable)
- File paths for saved reports

**Process**:
1. Compile all analysis results
2. Structure data according to output schema
3. Generate JSON report
4. Generate Markdown summary
5. Save reports to `.cursor/docs/deep-discovery/`
6. Return file paths

**Template (for agents, in English)**:
```
Report Generation:
- JSON Report: {json_file_path}
- Markdown Report: {md_file_path}
- Schema Version: {version}
- Generated At: {timestamp}
```

**한글 예시 (사용자용)**:
```
리포트 생성:
- JSON 리포트: .cursor/docs/deep-discovery/deep-discovery_20260227_1530_HEAD_standard_baseline.json
- Markdown 리포트: .cursor/docs/deep-discovery/deep-discovery_20260227_1530_HEAD_standard_baseline.md
- 스키마 버전: 1.0.0
- 생성 시간: 2026-02-27T15:30:00Z
```

---

## Skills Usage Examples

### Example 1: Baseline Deep Discovery

**Scenario**: New project or branch, need comprehensive project analysis

**Process**:
1. **Project Structure Analysis**: Analyze full directory structure
2. **Tech Stack Detection**: Identify all technologies
3. **Hotspot Detection**: Find complexity hotspots
4. **Report Generation**: Generate baseline report

**Output**:
```
✅ Baseline Deep Discovery 완료

프로젝트 구조 분석 완료
- 주요 디렉터리: lib/, test/, assets/
- 핵심 컴포넌트: CalendarWidget, TodoProvider

기술 스택 감지 완료
- 언어: Dart
- 프레임워크: Flutter
- 주요 의존성: provider, hive, intl

핫스팟 감지 완료
- calendar_widget.dart: 복잡도 높음

리포트 저장:
- JSON: .cursor/docs/deep-discovery/deep-discovery_20260227_1530_HEAD_standard_baseline.json
- Markdown: .cursor/docs/deep-discovery/deep-discovery_20260227_1530_HEAD_standard_baseline.md
```

### Example 2: Focused Discovery

**Scenario**: Analyze specific directory or feature

**Process**:
1. **Project Structure Analysis**: Analyze focused scope
2. **Tech Stack Detection**: Identify relevant technologies
3. **Hotspot Detection**: Find hotspots in scope
4. **Report Generation**: Generate focused report

**Output**:
```
✅ Focused Discovery 완료

분석 범위: lib/providers/
- 분석된 파일: todo_provider.dart, calendar_provider.dart
- 기술 스택: Provider 패턴
- 핫스팟: 없음

리포트 저장:
- JSON: .cursor/docs/deep-discovery/deep-discovery_20260227_1600_HEAD_standard_focused.json
```

---

## Verification Skills

### Analysis Completeness Verification
- All requested targets analyzed
- Report structure matches schema
- No critical information missing

### Report Reusability Verification
- JSON is machine-consumable
- Markdown is human-readable
- Reports are saved in correct location
- File naming follows convention

---

## Important Notes

1. **Efficiency-aware**: Avoid over-scanning for small/local edits
2. **Reusability**: Generate reports that other agents can reuse
3. **Selective depth**: Use depth_level and mode appropriately
4. **Persist artifacts**: Always save reports to `.cursor/docs/deep-discovery/`
5. **Use Korean for users**: All user-facing content must be in Korean
