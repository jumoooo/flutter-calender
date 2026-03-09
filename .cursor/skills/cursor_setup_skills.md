# 🔧 Cursor Setup Skills

## Language Separation (언어 구분)
**Internal Processing (Agent reads)**: All instructions, logic, and internal operations are in English.
**User-Facing Content (User sees)**: All explanations, questions, and responses shown to users are in Korean.

## Overview
This skill provides core functions for the Cursor Setup agent. It includes functions for cursor_zip folder detection, folder structure creation, file copying and verification, project type detection, configuration file creation, and setup verification.

**한글 설명 (사용자용)**: 이 스킬은 Cursor Setup이 사용하는 핵심 기능들을 제공합니다. cursor_zip 폴더 감지, 폴더 구조 생성, 파일 복사 및 검증, 프로젝트 타입 감지, 설정 파일 생성, 설치 검증 등의 기능을 포함합니다.

---

## Skills

### 1. Detect cursor_zip Folder
**Purpose**: Verify cursor_zip folder exists and validate its structure

**Input**: 
- Project root path
- Expected folder structure

**Output**: 
- cursor_zip folder existence status
- Folder structure validation
- Required folders list
- Missing folders list (if any)

**Process**:
1. Check if `cursor_zip` folder exists in project root
2. List folder contents
3. Verify required folders exist (agents, skills, rules)
4. Check for optional folders (templates, docs)
5. Validate structure completeness

**Template (for agents, in English)**:
```
cursor_zip Detection:
- Exists: {yes/no}
- Location: {path}
- Required Folders: {agents: yes/no, skills: yes/no, rules: yes/no}
- Optional Folders: {templates: yes/no, docs: yes/no}
- Status: {valid/invalid}
```

---

### 2. Check Existing .cursor Folder
**Purpose**: Check if .cursor folder already exists and handle conflicts

**Input**:
- Project root path
- User preferences

**Output**:
- .cursor folder existence status
- Conflict detection
- Backup recommendation
- User confirmation request

**Process**:
1. Check if `.cursor` folder exists
2. If exists, list contents
3. Detect potential conflicts
4. Ask user for confirmation
5. Offer backup option

**Template (for users, in Korean)**:
```
**기존 .cursor 폴더 확인:**
- 상태: {존재함/없음}
- 내용: {agent_count}개 Agent, {skill_count}개 Skill, {rule_count}개 Rule

**충돌 검사:**
- {충돌 없음/충돌 발견}

**처리 방법:**
- {덮어쓰기/백업 후 설치/취소}
```

---

### 3. Create Folder Structure
**Purpose**: Create complete .cursor folder structure

**Input**:
- Project root path
- Required folder list

**Output**:
- Created folder structure
- Verification status

**Process**:
1. Create `.cursor/` root folder
2. Create `.cursor/agents/` folder
3. Create `.cursor/skills/` folder
4. Create `.cursor/rules/` folder
5. Create `.cursor/docs/` folder
6. Create `.cursor/config/` folder
7. Verify all folders created

**Template (for agents, in English)**:
```
Folder Structure Created:
- .cursor/agents/ ✅
- .cursor/skills/ ✅
- .cursor/rules/ ✅
- .cursor/docs/ ✅
- .cursor/config/ ✅
Status: {complete/incomplete}
```

---

### 4. Copy Files from cursor_zip
**Purpose**: Copy all files from cursor_zip to .cursor maintaining structure

**Input**:
- Source path (cursor_zip)
- Destination path (.cursor)
- File list

**Output**:
- Copied files count
- Copy status for each file
- Verification results

**Process**:
1. List all files in cursor_zip/agents/
2. Copy each file to .cursor/agents/
3. List all files in cursor_zip/skills/
4. Copy each file to .cursor/skills/
5. List all files in cursor_zip/rules/
6. Copy each file to .cursor/rules/
7. Copy optional folders if exist
8. Verify each copy operation

**Template (for agents, in English)**:
```
File Copy Results:
- Agents: {copied_count}/{total_count} ✅
- Skills: {copied_count}/{total_count} ✅
- Rules: {copied_count}/{total_count} ✅
- Templates: {copied_count}/{total_count} (optional)
- Docs: {copied_count}/{total_count} (optional)
Status: {complete/incomplete}
```

---

### 5. Detect Project Type
**Purpose**: Determine if project is learning-focused or production-focused

**Input**:
- Project root path
- Project structure

**Output**:
- Project type (learning/production)
- Detection rationale
- Optional components recommendation

**Process**:
1. Check for `mockdowns/` folder
2. Check for standard Flutter structure
3. Analyze project structure
4. Determine project type
5. Recommend optional components

**Template (for agents, in English)**:
```
Project Type Detection:
- Type: {learning/production}
- Indicators: {mockdowns_folder: yes/no, standard_structure: yes/no}
- Recommendation: {optional_components}
```

---

### 6. Create Project Configuration
**Purpose**: Create project-config.json with appropriate settings

**Input**:
- Project type
- Detected features
- User preferences

**Output**:
- Configuration file created
- Configuration content

**Process**:
1. Determine project type
2. Set default configuration
3. Create `.cursor/config/project-config.json`
4. Write configuration content
5. Verify file created

**Template (for users, in Korean)**:
```json
{
  "project_type": "{learning/production}",
  "features": {
    "studyAgent": false,
    "documentUploader": false
  },
  "paths": {
    "learning_materials": null
  },
  "setup_date": "{date}",
  "version": "1.0.0"
}
```

---

### 7. Verify Installation
**Purpose**: Verify complete installation and system readiness

**Input**:
- .cursor folder structure
- Expected files list

**Output**:
- Verification results
- Missing files list (if any)
- System readiness status

**Process**:
1. Count copied files
2. Verify file integrity
3. Check folder structure
4. Validate agent file formats
5. Check for missing files
6. Report verification results

**Template (for agents, in English)**:
```
Installation Verification:
- Agents: {count} files ✅
- Skills: {count} files ✅
- Rules: {count} files ✅
- Structure: {valid/invalid}
- File Integrity: {all_valid/missing_files}
- System Ready: {yes/no}
```

---

## Usage Guidelines

### When to Use Each Skill

1. **Detect cursor_zip Folder**: Always use at the start
2. **Check Existing .cursor Folder**: Use before creating structure
3. **Create Folder Structure**: Use after validation
4. **Copy Files**: Use after structure created
5. **Detect Project Type**: Use during configuration
6. **Create Project Configuration**: Use after project type detected
7. **Verify Installation**: Always use at the end

### Quality Standards

- Always verify cursor_zip folder exists before proceeding
- Check for existing .cursor folder and handle conflicts
- Verify all files copied correctly
- Detect project type accurately
- Create appropriate configuration
- Verify complete installation
- Provide clear user guidance
- Use English for agent communication
- Use Korean for user-facing content

---

## Integration with MCP Tools

### Codebase Search
- Use to detect project structure
- Check for mockdowns folder
- Verify Flutter project structure

### List Directory
- List cursor_zip folder contents
- Verify folder structure
- Check .cursor folder after creation

---

## Example Workflow

### Scenario: User requests "@cursor_zip 폴더 안에 있는 내용으로 .cursor 구축해줘"

1. **Detect cursor_zip** (Skill 1)
   - Check cursor_zip folder exists
   - Verify structure

2. **Check Existing .cursor** (Skill 2)
   - Check if .cursor exists
   - Handle conflicts if any

3. **Create Structure** (Skill 3)
   - Create all required folders

4. **Copy Files** (Skill 4)
   - Copy all agents, skills, rules

5. **Detect Project Type** (Skill 5)
   - Check for mockdowns folder
   - Determine type

6. **Create Configuration** (Skill 6)
   - Create project-config.json

7. **Verify Installation** (Skill 7)
   - Verify all files
   - Check structure
   - Report results

8. **Present Results** (in Korean for users)
   - Show installed components
   - Provide next steps
