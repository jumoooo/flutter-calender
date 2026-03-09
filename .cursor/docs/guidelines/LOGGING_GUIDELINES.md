# 로깅 가이드라인 (Logging Guidelines)

## 개요

이 문서는 Agent 시스템에서 표준화된 로깅 전략을 정의합니다.

---

## 로깅 레벨

### ERROR
**사용 시점**: 치명적 오류, 작업 중단 필요

**예시**:
- Agent 실행 실패
- MCP 도구 호출 실패 (fallback 불가)
- Handoff artifact 검증 실패
- 의존성 누락

**로깅 형식**:
```json
{
  "timestamp": "2026-03-07T10:30:00Z",
  "level": "ERROR",
  "agent": "featureImplementation",
  "message": "Agent execution failed",
  "error": "File not found: lib/providers/todo_provider.dart",
  "context": {
    "request": "Add category filter",
    "step": "Phase 4: Component Generation"
  }
}
```

---

### WARNING
**사용 시점**: 경고, 작업 계속 가능하지만 주의 필요

**예시**:
- MCP 도구 호출 실패 (fallback 가능)
- 품질 점수 낮음 (scores.overall < 70)
- 의존성 경고
- 성능 이슈 가능성

**로깅 형식**:
```json
{
  "timestamp": "2026-03-07T10:30:00Z",
  "level": "WARNING",
  "agent": "planner",
  "message": "Plan quality score is low",
  "context": {
    "request": "Add category filter",
    "scores": {
      "overall": 65
    }
  }
}
```

---

### INFO
**사용 시점**: 정보성 메시지, 정상 동작

**예시**:
- Agent 실행 시작
- MCP 도구 호출 시작
- Handoff artifact 전송
- 작업 완료

**로깅 형식**:
```json
{
  "timestamp": "2026-03-07T10:30:00Z",
  "level": "INFO",
  "agent": "testCodeGenerator",
  "message": "Test generation started",
  "context": {
    "request": "Generate tests for TodoProvider",
    "target_files": ["test/providers/todo_provider_test.dart"]
  }
}
```

---

### DEBUG
**사용 시점**: 디버깅 정보, 개발 시에만 사용

**예시**:
- 상세 추론 과정
- 중간 계산 결과
- 내부 상태 정보

**로깅 형식**:
```json
{
  "timestamp": "2026-03-07T10:30:00Z",
  "level": "DEBUG",
  "agent": "planner",
  "message": "Plan evaluation in progress",
  "context": {
    "plan_count": 3,
    "current_plan": 1,
    "evaluation_step": "Quality assessment"
  }
}
```

---

## 로깅 포인트

### 1. Agent 실행

```markdown
**시작**:
- Level: INFO
- Message: "Agent execution started"
- Context: request, agent_name

**완료**:
- Level: INFO
- Message: "Agent execution completed"
- Context: request, agent_name, result_summary

**실패**:
- Level: ERROR
- Message: "Agent execution failed"
- Context: request, agent_name, error_details
```

---

### 2. MCP 도구 호출

```markdown
**시작**:
- Level: INFO
- Message: "MCP tool invocation started"
- Context: tool_name, query/parameters

**성공**:
- Level: INFO (또는 DEBUG)
- Message: "MCP tool invocation succeeded"
- Context: tool_name, result_summary

**실패 (Fallback 가능)**:
- Level: WARNING
- Message: "MCP tool invocation failed, using fallback"
- Context: tool_name, error, fallback_tool

**실패 (Fallback 불가)**:
- Level: ERROR
- Message: "MCP tool invocation failed, no fallback available"
- Context: tool_name, error
```

---

### 3. Handoff Artifact

```markdown
**생성**:
- Level: INFO
- Message: "Handoff artifact created"
- Context: from_agent, to_agent, intent

**전송**:
- Level: INFO
- Message: "Handoff artifact sent"
- Context: from_agent, to_agent, artifact_id

**검증 실패**:
- Level: ERROR
- Message: "Handoff artifact validation failed"
- Context: artifact_id, validation_errors

**수신**:
- Level: INFO
- Message: "Handoff artifact received"
- Context: from_agent, to_agent, artifact_id
```

---

### 4. 품질 게이트

```markdown
**통과**:
- Level: INFO
- Message: "Quality gate passed"
- Context: scores, agent_name

**실패**:
- Level: WARNING
- Message: "Quality gate failed"
- Context: scores, agent_name, recommendation
```

---

## 로깅 형식

### 표준 JSON 형식

```json
{
  "timestamp": "ISO8601 timestamp",
  "level": "ERROR|WARNING|INFO|DEBUG",
  "agent": "agent_name",
  "tool": "tool_name (optional)",
  "message": "로깅 메시지",
  "error": "에러 상세 (optional, ERROR/WARNING 레벨에서만)",
  "context": {
    "request": "사용자 요청",
    "step": "실행 중인 단계",
    "additional_info": "추가 정보"
  }
}
```

---

## 성능 모니터링

### 모니터링 포인트

```markdown
1. **Agent 실행 시간**:
   - 시작 시간 기록
   - 종료 시간 기록
   - 실행 시간 계산
   - INFO 레벨로 로깅

2. **MCP 도구 호출 시간**:
   - 호출 시작 시간
   - 응답 수신 시간
   - 호출 시간 계산
   - INFO 또는 DEBUG 레벨로 로깅

3. **Handoff 전송 시간**:
   - 전송 시작 시간
   - 수신 확인 시간
   - 전송 시간 계산
   - INFO 레벨로 로깅
```

### 성능 로깅 예시

```json
{
  "timestamp": "2026-03-07T10:30:00Z",
  "level": "INFO",
  "agent": "featureImplementation",
  "message": "Agent execution completed",
  "context": {
    "request": "Add category filter",
    "execution_time_ms": 1250,
    "files_modified": 2,
    "lines_added": 45,
    "lines_removed": 12
  }
}
```

---

## 로깅 저장 위치

### 개발 환경
- 콘솔 출력 (stdout/stderr)
- 파일 로그 (선택적): `.cursor/logs/agent_{timestamp}.log`

### 프로덕션 환경
- 구조화된 로그 파일: `.cursor/logs/agent_{date}.jsonl`
- 로그 로테이션: 일별 또는 크기 기반

---

## 로깅 모범 사례

### 1. 적절한 레벨 사용
```markdown
- ERROR: 치명적 오류만
- WARNING: 경고, 작업 계속 가능
- INFO: 정상 동작 정보
- DEBUG: 디버깅 정보 (개발 시에만)
```

### 2. 구조화된 컨텍스트
```markdown
- 항상 context 객체에 관련 정보 포함
- 사용자 요청, 실행 단계, 에러 상세 등
```

### 3. 민감한 정보 제외
```markdown
- API 키, 비밀번호 등 민감한 정보는 로깅하지 않음
- 필요 시 마스킹 처리
```

### 4. 성능 고려
```markdown
- DEBUG 레벨은 개발 시에만 활성화
- 대량 로깅 시 비동기 처리
- 로그 파일 크기 모니터링
```

---

## 참조 문서

- `.cursor/docs/guidelines/ERROR_HANDLING_GUIDELINES.md` - 에러 처리 가이드라인
- `.cursor/docs/guidelines/HANDOFF_ARTIFACT_SCHEMA.md` - Handoff artifact 스키마

---

**문서 버전**: 1.0  
**최종 업데이트**: 2026-03-07  
**작성자**: Agent System Upgrade Team
