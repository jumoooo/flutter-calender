# Commit Agent Skills

## Language Separation
**Internal Processing**: English
**User-Facing**: Korean

## Overview

This document describes the core skills used by commitAgent to analyze changes, assess risks, generate commit messages, and execute git operations safely.

**한글 설명 (사용자용)**: commitAgent가 변경 사항을 분석하고, 위험을 평가하며, 커밋 메시지를 생성하고, 안전하게 git 작업을 실행하는 데 사용하는 핵심 스킬을 설명합니다.

---

## Skills

### 1. Change Analysis
**Purpose**: Analyze git status and changes to understand what will be committed

**Input**: 
- `git status` output
- File list from git status
- Optional: `git diff --stat` for change statistics

**Output**: 
- Categorized file list (modified, added, deleted, untracked)
- Change summary by type (code, tests, docs, config)
- File count and scope assessment

**Template**:
```
변경 사항 분석:
- 수정된 파일: {count}개
- 추가된 파일: {count}개
- 삭제된 파일: {count}개
- 추적되지 않은 파일: {count}개

파일 유형별 분류:
- 코드 파일: {list}
- 테스트 파일: {list}
- 문서 파일: {list}
- 설정 파일: {list}
```

**Example**:
```
변경 사항 분석:
- 수정된 파일: 5개
- 추가된 파일: 3개
- 삭제된 파일: 1개
- 추적되지 않은 파일: 2개

파일 유형별 분류:
- 코드 파일: lib/screens/calendar_screen.dart, lib/providers/todo_provider.dart
- 테스트 파일: test/widgets/custom_date_picker_dialog_test.dart
- 문서 파일: README.md
```

---

### 2. Risk Assessment
**Purpose**: Identify potential risks before committing

**Input**: 
- File list from change analysis
- File sizes (if available)
- File content patterns (sensitive keywords)

**Output**: 
- Risk list categorized by severity (high, medium, low)
- Risk descriptions and recommendations

**Template**:
```
위험 사항 평가:

⚠️ 높은 위험:
- {risk_description} → {recommendation}

⚠️ 중간 위험:
- {risk_description} → {recommendation}

⚠️ 낮은 위험:
- {risk_description} → {recommendation}
```

**Example**:
```
위험 사항 평가:

⚠️ 높은 위험:
- .env 파일이 변경됨 → 민감한 정보가 포함되어 있는지 확인 필요

⚠️ 중간 위험:
- 20개 이상의 파일이 변경됨 → 커밋을 여러 개로 나누는 것을 고려

⚠️ 낮은 위험:
- 테스트 파일만 변경됨 → 안전하게 커밋 가능
```

**Risk Detection Patterns**:
- **Sensitive files**: `.env`, `*.key`, `*.pem`, `secrets.*`, `credentials.*`
- **Large files**: Binary files >10MB, large data files
- **Mass changes**: >20 files, >1000 lines changed
- **Deletions**: >5 files deleted
- **Merge conflicts**: `<<<<<<<`, `=======`, `>>>>>>>` markers

---

### 3. Commit Message Generation
**Purpose**: Generate appropriate commit messages following conventional commits format

**Input**: 
- Change analysis results
- File types and change patterns
- Project context (if available)

**Output**: 
- Commit message with type, scope, subject, and body
- Formatted according to conventional commits

**Template**:
```
제안된 커밋 메시지:

{type}({scope}): {subject}

{body_bullet_points}
```

**Type Selection Logic**:
- `feat`: New files added, new functionality
- `fix`: Bug fixes, error corrections
- `docs`: README, comments, documentation
- `style`: Formatting, whitespace, no logic change
- `refactor`: Code restructuring, no behavior change
- `test`: Test files added/modified
- `chore`: Build, config, dependencies

**Example**:
```
제안된 커밋 메시지:

feat: 카테고리/테마/검색 기능 추가 및 테스트 보강

- 카테고리 관리, 테마 관리, 검색/설정 화면 추가
- 할일 입력 화면을 다이얼로그로 전환
- 커스텀 날짜 선택 다이얼로그 및 할일 상세/입력 다이얼로그 추가
- 날짜 파싱, KoreanDateUtils, 날짜 범위 검증 유닛 테스트 추가
- 테마 프로바이더 및 Hive 마이그레이션 테스트 추가
```

---

### 4. Git Operations
**Purpose**: Execute git add, commit, and push operations safely

**Input**: 
- User confirmation
- Commit message
- File list to commit

**Output**: 
- Git command execution results
- Commit hash
- Push status

**Template**:
```
Git 작업 실행:
1. 파일 스테이징: git add {files}
2. 커밋 생성: git commit -m "{subject}" -m "{body}"
3. 원격 푸시: git push origin {branch}

결과:
- 커밋 해시: {hash}
- 푸시 상태: {success/failure}
```

**Error Handling**:
- **Commit fails**: Report error, suggest fixes
- **Push fails**: Check for conflicts, suggest resolution
- **Network error**: Retry suggestion
- **Permission error**: Check authentication

---

### 5. GitHub Link Generation
**Purpose**: Generate GitHub commit URL after successful push

**Input**: 
- Repository remote URL (from `git remote -v`)
- Commit hash
- Branch name

**Output**: 
- GitHub commit URL

**Template**:
```
GitHub 링크 생성:
- 저장소: {owner}/{repo}
- 브랜치: {branch}
- 커밋 해시: {hash}

링크: https://github.com/{owner}/{repo}/commit/{hash}
```

**URL Format**:
```
https://github.com/{owner}/{repo}/commit/{hash}
```

**Example**:
```
GitHub 링크 생성:
- 저장소: jumoooo/flutter-calender
- 브랜치: main
- 커밋 해시: 0df6f42

링크: https://github.com/jumoooo/flutter-calender/commit/0df6f42
```

---

### 6. Auto-Detection
**Purpose**: Detect git-related requests even without explicit keywords

**Input**: 
- User request text
- Context (recent changes, git status)

**Output**: 
- Boolean: Is this a git-related request?
- Confidence level: high, medium, low

**Detection Patterns**:
- **Explicit**: "커밋", "푸시", "올려줘", "git", "commit", "push"
- **Implicit**: "작업 정리", "변경사항 저장", "저장소에 올리기", "올리기"
- **Context-based**: Recent file changes + request to "정리" or "저장"

**Examples**:
- "커밋 메시지 줘" → High confidence, git-related
- "올려줘" → Medium confidence (check git status first)
- "작업한 내역 정리" → Medium confidence (check context)
- "변경사항 저장" → High confidence, git-related

---

## Usage Examples

### Example 1: Standard Commit Flow

**User**: "커밋 메시지 줘"

**Agent**:
1. Run `git status` → Analyze changes
2. Assess risks → Check for sensitive files, large changes
3. Generate commit message → Format with conventional commits
4. Present report → Show summary, risks, message
5. Wait for confirmation → User approves
6. Execute git operations → Add, commit, push
7. Generate GitHub link → Provide commit URL

### Example 2: Auto-Detection

**User**: "작업한 내역 정리해서 올려줘"

**Agent**:
1. Auto-detect git need → Recognize implicit git request
2. Run `git status` → Analyze changes
3. Continue with standard flow → Same as Example 1

### Example 3: Risk Detection

**User**: "커밋해줘"

**Agent**:
1. Analyze changes → Find `.env` file modified
2. Assess risk → High risk: sensitive file
3. Report risk → Warn user about `.env` file
4. Wait for confirmation → User confirms (aware of risk)
5. Execute with caution → Proceed after confirmation

---

## Best Practices

1. **Always analyze before committing**: Never commit without understanding changes
2. **Always assess risks**: Check for sensitive files, large changes, deletions
3. **Always get confirmation**: Never proceed without user approval
4. **Always generate good messages**: Follow conventional commits format
5. **Always provide links**: Give GitHub commit URL after push
6. **Always handle errors**: Report errors clearly and suggest fixes
7. **Always auto-detect**: Recognize git needs even without explicit keywords

---

## Integration with Other Agents

- **Orchestrator**: Routes git-related requests to commitAgent
- **planner**: May coordinate with commitAgent for project milestones
- **featureImplementation**: May trigger commitAgent after feature completion

---

## Error Scenarios

### Scenario 1: Commit Fails
**Cause**: Merge conflicts, invalid message, etc.
**Response**: Report error clearly, suggest resolution steps

### Scenario 2: Push Fails
**Cause**: Remote conflicts, authentication issues, etc.
**Response**: Check for conflicts, suggest `git pull` or authentication check

### Scenario 3: No Changes
**Cause**: Nothing to commit
**Response**: Inform user, suggest checking git status

### Scenario 4: Sensitive File Detected
**Cause**: `.env` or credentials file in changes
**Response**: Warn user, suggest excluding from commit

---

## Future Enhancements

Potential skill additions:
- Multi-commit splitting (large changes → multiple commits)
- Branch management (create, switch, merge)
- Commit history analysis
- Commit message templates
- CI/CD integration checks
