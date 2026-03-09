# MCP Context7 사용 가이드라인

## 개요

이 문서는 모든 Agent들이 MCP Context7을 효율적이고 안전하게 사용하기 위한 공통 가이드라인입니다.

## 우선순위 전략

### 1. Indexing & Docs First (Primary)
- **항상 먼저**: Cursor IDE의 Indexing & Docs (Flutter_docs 등)를 먼저 확인
- **자동 컨텍스트**: Cursor IDE가 자동으로 포함하거나 `@Flutter_docs` 명시적 참조
- **충분한 경우**: Indexing & Docs에서 필요한 정보를 찾으면 Context7 호출 **하지 않음**

### 2. MCP Context7 (Secondary)
- **조건부 사용**: Indexing & Docs로 충분하지 않을 때만 사용
- **명확한 필요성**: 다음 경우에만 사용:
  - Indexing & Docs에서 찾을 수 없는 최신 패턴 확인
  - 특정 패키지의 최신 버전 문서 확인
  - Indexing & Docs에 없는 특정 라이브러리 문서 확인

### 3. Codebase Search (Tertiary)
- **프로젝트 패턴**: 프로젝트 내 실제 코드 패턴 확인

## 효율성 개선

### Context7 호출 최소화 전략

**호출하지 말아야 하는 경우:**
1. Indexing & Docs에서 이미 충분한 정보를 얻은 경우
2. 일반적인 Flutter/Dart 패턴 (공식 문서에 있는 경우)
3. 프로젝트 내 코드로 충분히 파악 가능한 경우
4. 이전 Context7 호출 결과를 재사용할 수 있는 경우

**호출해야 하는 경우:**
1. Indexing & Docs에서 명시적으로 찾을 수 없는 경우
2. 특정 패키지의 최신 버전 문서가 필요한 경우
3. 공식 문서에 없는 서드파티 라이브러리 문서가 필요한 경우

### 쿼리 최적화

**좋은 쿼리 예시:**
- ✅ "How to use Provider state management in Flutter with error handling"
- ✅ "Flutter Material Design 3 SegmentedButton styling guidelines"
- ✅ "Dio package error handling and retry logic"

**나쁜 쿼리 예시:**
- ❌ "Flutter" (너무 일반적)
- ❌ "state" (너무 모호)
- ❌ "error" (컨텍스트 부족)

**쿼리 작성 원칙:**
1. 구체적인 기술/패키지명 포함
2. 원하는 정보 타입 명시 (사용법, 에러 처리, 스타일링 등)
3. 최소 5-10단어로 구성
4. 관련 키워드 포함 (Flutter, Dart, 패키지명 등)

## 안전성 개선

### 에러 처리 및 폴백 전략

**Context7 호출 시 에러 처리:**

```python
# 의사코드 예시
try:
    # 1. Library ID 해결
    library_id = resolve_library_id(library_name)
    if not library_id:
        # 폴백: Indexing & Docs 또는 Codebase Search 사용
        return use_indexing_docs_or_codebase_search()
    
    # 2. 문서 쿼리
    docs = query_docs(library_id, query)
    if not docs or docs.is_empty():
        # 폴백: Indexing & Docs 또는 Codebase Search 사용
        return use_indexing_docs_or_codebase_search()
    
    return docs
except Context7Error as e:
    # 에러 로깅 (사용자에게는 노출하지 않음)
    log_error(f"Context7 호출 실패: {e}")
    # 폴백: Indexing & Docs 또는 Codebase Search 사용
    return use_indexing_docs_or_codebase_search()
except TimeoutError:
    # 타임아웃: 폴백 사용
    log_warning("Context7 타임아웃, 폴백 사용")
    return use_indexing_docs_or_codebase_search()
```

**폴백 순서:**
1. Indexing & Docs 재시도 (더 구체적인 쿼리)
2. Codebase Search (프로젝트 내 패턴)
3. 사용자에게 알림 (정보 부족 시)

### 타임아웃 및 재시도

**권장 설정:**
- 타임아웃: 10초
- 최대 재시도: 1회 (타임아웃 시에만)
- 재시도 간격: 즉시 (타임아웃이면 바로 폴백)

**재시도하지 말아야 하는 경우:**
- Library ID 해결 실패 (잘못된 라이브러리명)
- 쿼리 결과 없음 (해당 문서가 없는 경우)
- 네트워크 에러 (즉시 폴백)

## 품질 개선

### 결과 검증

**검증 체크리스트:**
1. 결과가 비어있지 않은지 확인
2. 결과가 쿼리와 관련이 있는지 확인
3. 결과가 최신 정보인지 확인 (버전 정보 확인)
4. 결과가 충분히 구체적인지 확인

**결과가 부족한 경우:**
- 더 구체적인 쿼리로 재시도
- Indexing & Docs로 폴백
- Codebase Search로 폴백

### Library ID 해결 최적화

**효율적인 해결 방법:**
1. 일반적인 라이브러리는 직접 ID 사용 (예: `/flutter/flutter`)
2. 불확실한 경우에만 `resolve-library-id` 사용
3. 한 번 해결한 ID는 캐싱 (같은 세션 내)

**일반적인 Flutter 라이브러리 ID:**
- Flutter: `/flutter/flutter`
- Provider: `/flutter/provider`
- Dio: `/flutter/dio`
- HTTP: `/flutter/http`

## 사용 예시

### 좋은 사용 예시

```python
# 1. Indexing & Docs 먼저 확인
if indexing_docs_has_info():
    return use_indexing_docs()
    
# 2. Context7 조건부 사용
if needs_latest_patterns() or needs_specific_package():
    try:
        library_id = resolve_library_id("provider")
        docs = query_docs(library_id, "Provider state management error handling")
        if docs and docs.is_valid():
            return docs
    except Context7Error:
        pass  # 폴백으로 진행

# 3. 폴백
return use_codebase_search()
```

### 나쁜 사용 예시

```python
# ❌ Indexing & Docs 확인 없이 바로 Context7 호출
docs = query_docs("provider", "state")

# ❌ 에러 처리 없이 호출
library_id = resolve_library_id("unknown-library")
docs = query_docs(library_id, "query")

# ❌ 너무 일반적인 쿼리
docs = query_docs("flutter", "widget")
```

## Agent별 적용

모든 Agent는 이 가이드라인을 따라야 합니다:

1. **Indexing & Docs First**: 항상 먼저 확인
2. **조건부 Context7**: 필요할 때만 사용
3. **에러 처리**: 폴백 전략 포함
4. **쿼리 최적화**: 구체적이고 명확한 쿼리
5. **결과 검증**: 유효성 확인 후 사용

## 모니터링 및 개선

**로깅 (내부용):**
- Context7 호출 횟수
- 성공/실패 비율
- 폴백 사용 빈도
- 평균 응답 시간

**개선 포인트:**
- 폴백 사용이 빈번하면 쿼리 최적화 필요
- 타임아웃이 빈번하면 네트워크 이슈 확인
- 결과가 부족하면 Indexing & Docs 강화 고려
