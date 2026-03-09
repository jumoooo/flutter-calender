# 🔌 API Integration Skills

## Language Separation (언어 구분)
**Internal Processing (Agent reads)**: All instructions, logic, and internal operations are in English.
**User-Facing Content (User sees)**: All explanations, code comments, examples, and responses shown to users are in Korean.

## Overview
This skill provides core functions for the API Integration agent. It includes functions for API requirement analysis, pattern research using Indexing & Docs and MCP tools, model design and generation, service layer design, error handling implementation, and retry logic implementation.

**한글 설명 (사용자용)**: 이 스킬은 API Integration이 사용하는 핵심 기능들을 제공합니다. API 요구사항 분석, Indexing & Docs 및 MCP 도구를 활용한 패턴 연구, 모델 설계 및 생성, 서비스 레이어 설계, 에러 처리 구현, 재시도 로직 구현 등의 기능을 포함합니다.

---

## Skills

### 1. Analyze API Requirements
**Purpose**: Understand user requirements for API integration

**Input**: 
- User request text
- API endpoint information
- API method requirements
- Authentication requirements

**Output**: 
- API endpoint details
- Required methods (GET, POST, PUT, DELETE)
- Data model requirements
- Authentication needs
- Error handling requirements
- Retry logic needs

**Process**:
1. Parse request to identify API endpoints
2. Extract required HTTP methods
3. Identify data models needed
4. Determine authentication requirements
5. Assess error handling needs
6. Determine retry logic requirements

**Template (for agents, in English)**:
```
API Requirements:
- Endpoint: {api_endpoint}
- Methods: {GET/POST/PUT/DELETE}
- Authentication: {required/not_required}
- Models: {model_list}
- Error Handling: {requirements}
- Retry: {needed/not_needed}
```

---

### 2. Research HTTP Patterns (Indexing & Docs First)
**Purpose**: Find official Flutter HTTP patterns using Indexing & Docs as primary source

**Input**:
- API requirements
- HTTP client preferences

**Output**:
- Official Flutter HTTP patterns from Flutter_docs
- Async/await patterns from Dart 언어 문서
- Best practices for HTTP clients
- Latest patterns from MCP Context7 (if needed)

**Priority Order**:
1. **Indexing & Docs (Primary)**: Flutter_docs, Dart 언어 문서
2. **MCP Context7 (Secondary)**: 최신 HTTP 패턴 확인
3. **Codebase Search (Tertiary)**: 프로젝트 내 패턴

**Process**:
1. Check Flutter_docs (Indexing & Docs) for HTTP client patterns
2. Check Dart 언어 문서 for async/await patterns
3. Use MCP Context7 if Indexing & Docs insufficient
4. Search codebase for existing API patterns

**Template (for agents, in English)**:
```
HTTP Pattern Research:
- Primary (Indexing & Docs): {patterns_found}
- Secondary (MCP Context7): {latest_patterns}
- Tertiary (Codebase): {existing_patterns}
- Selected Pattern: {chosen_pattern} - Reason: {reason}
```

---

### 3. Check Project Structure (Deep Discovery)
**Purpose**: Understand project API integration patterns

**Input**:
- Deep discovery report location
- API requirements

**Output**:
- Project structure information
- Existing API integration patterns
- HTTP client approach
- API service structure
- Error handling patterns

**Process**:
1. Check for existing deep discovery report in `.cursor/docs/deep-discovery/`
2. Read project structure information
3. Identify existing API integration patterns
4. Understand HTTP client approach
5. Check API service structure
6. Understand error handling patterns

**Template (for agents, in English)**:
```
Project Structure Analysis:
- Report Used: {report_file}
- Existing API Patterns: {patterns}
- HTTP Client: {http/dio/custom}
- Service Structure: {structure}
- Error Handling: {approach}
- Consistency Check: {matches/needs_adjustment}
```

---

### 4. Design API Models
**Purpose**: Design type-safe data models for API requests and responses

**Input**:
- API requirements
- Response structure
- Request structure

**Output**:
- Data model classes
- JSON serialization/deserialization
- Validation logic
- Error models

**Process**:
1. Design request models
2. Design response models
3. Plan JSON serialization
4. Design error models
5. Add validation logic

**Template (for users, in Korean)**:
```dart
// {Model 설명}
class {ModelName} {
  // {속성 설명}
  final {Type} {propertyName};
  
  {ModelName}({
    required this.{propertyName},
    // ... 다른 속성들
  });
  
  // JSON 직렬화
  factory {ModelName}.fromJson(Map<String, dynamic> json) {
    return {ModelName}(
      {propertyName}: json['{json_key}'],
      // ...
    );
  }
  
  // JSON 역직렬화
  Map<String, dynamic> toJson() {
    return {
      '{json_key}': {propertyName},
      // ...
    };
  }
}
```

---

### 5. Design API Service Layer
**Purpose**: Design API service class with proper structure and error handling

**Input**:
- API requirements
- Models
- HTTP client approach

**Output**:
- API service class structure
- Method signatures
- Error handling approach
- Retry logic design

**Process**:
1. Plan service class structure
2. Design method signatures
3. Plan error handling approach
4. Design retry logic
5. Plan timeout configuration

**Template (for agents, in English)**:
```
API Service Design:
- Class: {ServiceName}
- Methods: {method_list}
- Error Handling: {strategy}
- Retry Logic: {strategy}
- Timeout: {seconds}
```

---

### 6. Generate API Service Code
**Purpose**: Generate complete API service code with error handling and retry logic

**Input**:
- API service design
- Models
- Official patterns
- Project conventions

**Output**:
- Complete API service code
- Error handling implementation
- Retry logic implementation
- Timeout handling
- Korean comments

**Quality Requirements**:
- Type safety with proper models
- Comprehensive error handling
- Retry logic for transient failures
- Timeout handling
- Clear Korean comments
- Proper async/await usage

**Template (for users, in Korean)**:
```dart
// {API Service 설명}
class {ServiceName} {
  final {HttpClient} _client;
  final String _baseUrl;
  
  {ServiceName}({
    required {HttpClient} client,
    required String baseUrl,
  }) : _client = client, _baseUrl = baseUrl;
  
  // {메서드 설명}
  Future<{ReturnType}> {methodName}({parameters}) async {
    try {
      // {요청 로직}
      final response = await _client.{httpMethod}(
        Uri.parse('$_baseUrl/{endpoint}'),
        // ... 요청 설정
      );
      
      // {응답 처리}
      if (response.statusCode == 200) {
        return {ReturnType}.fromJson(jsonDecode(response.body));
      } else {
        throw {ApiException}(message: 'API 오류: ${response.statusCode}');
      }
    } catch (e) {
      // {에러 처리}
      throw {ApiException}(message: '요청 실패: $e');
    }
  }
}
```

---

### 7. Implement Error Handling
**Purpose**: Add comprehensive error handling for API integration

**Input**:
- API service code
- Error scenarios

**Output**:
- Error handling code
- Error models
- Error parsing logic
- User-friendly error messages in Korean

**Error Handling Requirements**:
- Network errors (connection, timeout)
- API errors (4xx, 5xx status codes)
- Parsing errors (malformed JSON)
- Custom error models
- Error messages in Korean

**Template**:
```dart
// 에러 모델
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  
  ApiException({required this.message, this.statusCode});
  
  @override
  String toString() => message;
}

// 에러 처리 예시
try {
  // API 호출
} on SocketException {
  throw ApiException(message: '네트워크 연결을 확인해주세요');
} on TimeoutException {
  throw ApiException(message: '요청 시간이 초과되었습니다');
} on FormatException {
  throw ApiException(message: '응답 데이터 형식이 올바르지 않습니다');
} catch (e) {
  throw ApiException(message: '알 수 없는 오류: $e');
}
```

---

### 8. Implement Retry Logic
**Purpose**: Add retry logic for transient API failures

**Input**:
- API service code
- Retry requirements

**Output**:
- Retry logic implementation
- Exponential backoff (if needed)
- Retry condition logic

**Retry Requirements**:
- Retry count configuration
- Retry conditions (network errors, 5xx errors)
- Exponential backoff for rate limiting
- Maximum retry limit

**Template**:
```dart
// 재시도 로직 예시
Future<{ReturnType}> {methodName}WithRetry({parameters}) async {
  int retryCount = 0;
  const maxRetries = 3;
  
  while (retryCount < maxRetries) {
    try {
      return await {methodName}({parameters});
    } catch (e) {
      retryCount++;
      if (retryCount >= maxRetries || !_shouldRetry(e)) {
        rethrow;
      }
      // 지수 백오프
      await Future.delayed(Duration(seconds: pow(2, retryCount).toInt()));
    }
  }
  throw ApiException(message: '최대 재시도 횟수 초과');
}

bool _shouldRetry(dynamic error) {
  // 재시도 가능한 에러인지 확인
  return error is SocketException || 
         error is TimeoutException ||
         (error is ApiException && error.statusCode != null && error.statusCode! >= 500);
}
```

---

## Usage Guidelines

### When to Use Each Skill

1. **Analyze API Requirements**: Always use at the start
2. **Research HTTP Patterns**: Use Indexing & Docs first, then MCP if needed
3. **Check Project Structure**: Use deep discovery report for context
4. **Design API Models**: Use after requirements understood
5. **Design API Service Layer**: Use after models designed
6. **Generate API Service Code**: Use after service layer designed
7. **Implement Error Handling**: Always include in API generation
8. **Implement Retry Logic**: Use when retry logic needed

### Quality Standards

- Always check Indexing & Docs (Flutter_docs) first for HTTP patterns
- Use deep discovery report to understand project structure
- Include comprehensive error handling (network, API, parsing errors)
- Implement retry logic for transient failures
- Provide Korean comments for better readability
- Use strong typing with proper models
- Ensure proper async/await usage
- Follow Flutter HTTP best practices
- Use English for agent communication
- Use Korean for user-facing content and code comments

---

## Integration with MCP Tools

### Indexing & Docs (Primary)
- Flutter_docs: HTTP 클라이언트 사용법, 비동기 처리 패턴
- Dart 언어 문서: async/await, Future, 타입 시스템

### Context7 (Secondary)
- Use for latest HTTP package patterns
- Check specific package documentation (http, dio)
- Verify new Flutter version features

### Codebase Search (Tertiary)
- Find existing API integration patterns
- Maintain consistency with project
- Understand project HTTP client approach

---

## Example Workflow

### Scenario: User requests "사용자 API 연동해줘 - GET /users, POST /users"

1. **Analyze Requirements** (Skill 1)
   - Endpoint: /users
   - Methods: GET, POST
   - Models: User model needed
   - Authentication: Required

2. **Research Patterns** (Skill 2)
   - Check Flutter_docs for HTTP patterns
   - Check Dart 언어 문서 for async/await
   - Use MCP Context7 if needed

3. **Check Project Structure** (Skill 3)
   - Read deep discovery report
   - Check existing API patterns
   - Understand HTTP client approach

4. **Design Models** (Skill 4)
   - Create User model
   - Add JSON serialization
   - Create error models

5. **Design Service Layer** (Skill 5)
   - Plan UserApiService class
   - Design method signatures
   - Plan error handling

6. **Generate Service Code** (Skill 6)
   - Create API service
   - Implement GET and POST methods
   - Add error handling

7. **Implement Error Handling** (Skill 7)
   - Add error models
   - Implement error parsing
   - Create user-friendly messages

8. **Implement Retry Logic** (Skill 8)
   - Add retry logic
   - Implement exponential backoff

9. **Present Integration** (in Korean for users)
   - Show API service structure
   - Provide usage guidance
   - Explain key features
