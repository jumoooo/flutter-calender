# 에러 처리 가이드라인 (Error Handling Guidelines)

## 개요

이 문서는 Agent 시스템에서 MCP 도구 및 Agent 실패 시 에러 처리 전략을 정의합니다.

---

## MCP 도구별 에러 처리

### 1. Context7

#### 에러 유형
- `resolve-library-id` 실패: 라이브러리 ID를 찾을 수 없음
- `query-docs` 실패: 쿼리 실행 실패 또는 타임아웃
- 네트워크 오류: 연결 실패

#### 처리 전략
```markdown
1. **Fallback 순서**:
   - Context7 실패 → Indexing & Docs 사용
   - Indexing & Docs 실패 → Codebase Search 사용
   - Codebase Search 실패 → 사용자에게 정보 요청

2. **타임아웃 처리**:
   - 타임아웃 발생 시 즉시 fallback (재시도 안 함)
   - 타임아웃 시간: 30초 (기본값)

3. **에러 로깅**:
   - ERROR 레벨로 로깅
   - 실패한 쿼리와 fallback 경로 기록
```

#### 예시
```dart
// Context7 사용 시도
try {
  final result = await context7QueryDocs(libraryId, query);
  return result;
} catch (e) {
  // Context7 실패 → Indexing & Docs로 fallback
  logError('Context7 query failed', error: e);
  return await useIndexingDocs(query);
}
```

---

### 2. Notion

#### 에러 유형
- 인증 실패: 토큰 만료 또는 권한 없음
- 페이지 접근 실패: 페이지를 찾을 수 없음
- API 제한: Rate limit 초과

#### 처리 전략
```markdown
1. **인증 실패**:
   - 사용자에게 재인증 요청
   - 자동 재시도 안 함

2. **페이지 접근 실패**:
   - 404 에러: 페이지가 존재하지 않음 → 사용자에게 알림
   - 403 에러: 권한 없음 → 사용자에게 권한 확인 요청

3. **Rate Limit**:
   - Rate limit 초과 시 대기 후 재시도
   - 재시도 횟수: 최대 3회
   - 재시도 간격: 지수 백오프 (1초, 2초, 4초)
```

---

### 3. Browser Tools

#### 에러 유형
- 페이지 로드 실패: 네트워크 오류 또는 타임아웃
- 요소 찾기 실패: 요소가 존재하지 않음
- 스크린샷 실패: 브라우저 오류

#### 처리 전략
```markdown
1. **페이지 로드 실패**:
   - 타임아웃: 30초
   - 재시도: 최대 2회
   - 실패 시 사용자에게 알림

2. **요소 찾기 실패**:
   - 요소가 없으면 사용자에게 알림
   - 대안 요소 제안 (가능한 경우)

3. **스크린샷 실패**:
   - 브라우저 재시작 후 재시도
   - 재시도 실패 시 사용자에게 알림
```

---

### 4. Sequential Thinking

#### 에러 유형
- 추론 실패: 논리 오류 또는 타임아웃
- 메모리 부족: 너무 많은 추론 단계

#### 처리 전략
```markdown
1. **추론 실패**:
   - 단순화된 접근 방식으로 재시도
   - 재시도 실패 시 사용자에게 알림

2. **메모리 부족**:
   - 추론 단계 수 제한 (최대 50단계)
   - 단계 수 초과 시 사용자에게 알림
```

---

### 5. Codebase Search

#### 에러 유형
- 검색 실패: 쿼리 오류 또는 타임아웃
- 결과 없음: 검색 결과가 없음

#### 처리 전략
```markdown
1. **검색 실패**:
   - 쿼리 단순화 후 재시도
   - 재시도 실패 시 사용자에게 알림

2. **결과 없음**:
   - 검색 범위 확대 제안
   - 대안 검색어 제안
```

---

## Agent 실패 시 복구 전략

### 1. Agent 실행 실패

#### 에러 유형
- Agent 파일 없음: Agent 정의 파일이 존재하지 않음
- Agent 로직 오류: Agent 내부 로직 오류
- 의존성 실패: 필수 의존성 누락

#### 처리 전략
```markdown
1. **Agent 파일 없음**:
   - Orchestrator가 대체 Agent 제안
   - 사용자에게 알림

2. **Agent 로직 오류**:
   - 에러 로깅 (ERROR 레벨)
   - 사용자에게 에러 내용 보고
   - 복구 옵션 제시 (범위 축소, 단계 건너뛰기 등)

3. **의존성 실패**:
   - 누락된 의존성 식별
   - 사용자에게 의존성 설치 요청
```

---

### 2. Handoff 실패

#### 에러 유형
- Handoff artifact 형식 오류: 스키마 불일치
- 필수 필드 누락: Required fields missing
- Agent 간 통신 실패: Agent가 artifact를 이해하지 못함

#### 처리 전략
```markdown
1. **Artifact 형식 오류**:
   - 스키마 검증 실패 시 에러 로깅
   - 사용자에게 artifact 수정 요청
   - agentBuilder에게 artifact 수정 위임

2. **필수 필드 누락**:
   - 누락된 필드 목록 보고
   - planner에게 계획 보강 요청

3. **통신 실패**:
   - Agent가 artifact를 이해하지 못하면
   - Orchestrator가 중재
   - 사용자에게 상황 보고
```

---

## 에러 로깅 표준

### 로깅 레벨

```markdown
- **ERROR**: 치명적 오류, 작업 중단 필요
- **WARNING**: 경고, 작업 계속 가능하지만 주의 필요
- **INFO**: 정보성 메시지, 정상 동작
- **DEBUG**: 디버깅 정보, 개발 시에만 사용
```

### 로깅 형식

```json
{
  "timestamp": "ISO8601",
  "level": "ERROR|WARNING|INFO|DEBUG",
  "agent": "agentName",
  "tool": "toolName (optional)",
  "message": "에러 메시지",
  "error": "에러 상세 (optional)",
  "context": {
    "request": "사용자 요청",
    "step": "실행 중인 단계"
  }
}
```

### 로깅 포인트

```markdown
1. **MCP 도구 호출 전**:
   - INFO: 도구 호출 시작

2. **MCP 도구 호출 실패**:
   - ERROR: 도구 호출 실패, fallback 경로 기록

3. **Agent 실행 시작**:
   - INFO: Agent 실행 시작

4. **Agent 실행 실패**:
   - ERROR: Agent 실행 실패, 에러 상세 기록

5. **Handoff 전송**:
   - INFO: Handoff artifact 전송

6. **Handoff 실패**:
   - ERROR: Handoff 실패, 스키마 검증 오류 기록
```

---

## 복구 전략 우선순위

### Priority 1: 자동 복구
- MCP 도구 fallback (Context7 → Indexing & Docs → Codebase Search)
- 타임아웃 재시도 (최대 2회)

### Priority 2: 사용자 확인 후 복구
- Agent 실행 실패 시 대체 Agent 제안
- Handoff 실패 시 artifact 수정 요청

### Priority 3: 사용자 개입 필요
- 인증 실패 (Notion 등)
- 의존성 누락
- 치명적 오류

---

## 예외 처리 패턴

### Pattern 1: Try-Catch-Fallback
```dart
try {
  result = await primaryTool();
} catch (e) {
  logError('Primary tool failed', error: e);
  result = await fallbackTool();
}
```

### Pattern 2: Retry with Backoff
```dart
int retries = 0;
while (retries < maxRetries) {
  try {
    return await tool();
  } catch (e) {
    retries++;
    if (retries >= maxRetries) throw e;
    await Future.delayed(Duration(seconds: pow(2, retries).toInt()));
  }
}
```

### Pattern 3: Graceful Degradation
```dart
try {
  return await fullFeature();
} catch (e) {
  logWarning('Full feature failed, using basic feature', error: e);
  return await basicFeature();
}
```

---

## 참조 문서

- `.cursor/docs/guidelines/MCP_CONTEXT7_GUIDELINES.md` - Context7 사용 가이드라인
- `.cursor/docs/guidelines/HANDOFF_ARTIFACT_SCHEMA.md` - Handoff artifact 스키마
- `.cursor/docs/guidelines/LOGGING_GUIDELINES.md` - 로깅 가이드라인

---

**문서 버전**: 1.0  
**최종 업데이트**: 2026-03-07  
**작성자**: Agent System Upgrade Team
