# AGENTS.md

이 파일은 AI 코딩 에이전트가 프로젝트에서 어떻게 동작해야 하는지 정의합니다.
`.cursor` 폴더와 함께 이식 가능하도록 설계되었습니다.

## Commands (명령어)

### Test Code Generation
- `flutter test` - Run all tests
- `flutter test --coverage` - Measure coverage
- `flutter test test/{directory}/` - Run tests in specific directory
- `flutter test --name {test_name}` - Run specific test
- `dart analyze` - Run static analysis
- `dart analyze --fatal-infos` - Fail on info-level issues
- `genhtml coverage/lcov.info -o coverage/html` - Generate coverage report

### Code Quality
- `flutter analyze` - Flutter-specific analysis
- `dart format .` - Format code
- `dart fix --apply` - Apply automated fixes

## Testing (테스트)

### Framework
- Flutter Test Framework (`package:test`)
- Mockito for mocking (if needed)
- Integration test support

### Structure
- `test/` - All test files
- `test/models/` - Model tests
- `test/providers/` - Provider tests
- `test/widgets/` - Widget tests
- `test/utils/` - Utility tests
- `test/integration/` - Integration tests (if applicable)

### Patterns
- Use `test()` for unit tests
- Use `testWidgets()` for widget tests
- Use `group()` to organize related tests
- Use `setUp()` / `tearDown()` for test isolation
- Use `setUpAll()` / `tearDownAll()` for shared resources (Hive)

### Style
- Test file naming: `{component}_test.dart`
- Test naming: Descriptive Korean or English
- Group naming: `{Component} Tests`
- Include Korean comments for clarity

## Structure (구조)

### Test Directory
```
test/
├── models/
│   └── {model}_test.dart
├── providers/
│   └── {provider}_test.dart
├── widgets/
│   └── {widget}_test.dart
├── utils/
│   └── {utility}_test.dart
└── integration/
    └── {feature}_test.dart
```

### Code Organization
- One test file per implementation file
- Mirror `lib/` structure in `test/`
- Keep tests close to implementation when possible

## Style (스타일)

### Test Code Style
- Use descriptive test names
- Include setup/teardown for isolation
- Use `expect()` with clear assertions
- Include Korean comments for complex logic
- Follow existing test patterns in project

### Code Comments
- Korean comments for user-facing explanations
- English comments for technical details
- Document test assumptions and edge cases

## Git Workflow (Git 워크플로우)

### Test Commits
- Commit tests with implementation code
- Use conventional commits: `test: add tests for {component}`
- Include coverage reports in PR descriptions

### Branch Strategy
- Create test branches: `test/{feature-name}`
- Merge tests with feature branches
- Keep test coverage above 85% for critical logic

## Boundaries (경계)

### ✅ Always Do
- Generate unit tests for all public methods
- Include edge cases in test coverage
- Follow existing test patterns from project
- Use `Hive.init(tempDir.path)` for Hive tests
- Use fixed-duration `pump()` instead of `pumpAndSettle()` for animated widgets
- Add `await` to all async method calls
- Include Korean comments in test code
- Run `dart analyze` before committing

### ⚠️ Ask First
- Creating complex integration tests spanning multiple modules
- Adding new test dependencies (packages)
- Modifying existing passing tests
- Creating test utilities/helpers (unless requested)
- Changing test directory structure
- Adding new test frameworks

### 🚫 Never Do
- Modify production code (lib/ directory) from test generation
- Use `Hive.initFlutter()` in tests
- Use `pumpAndSettle()` with AnimationController
- Skip `await` on async methods
- Modify unrelated test files
- Add unrequested abstractions or utilities
- Change project structure without approval
- Remove existing tests without explicit request

## Success Criteria (완료 기준)

### Priority 1: Test Execution
- ✅ All tests pass: `flutter test` exits with code 0
- ✅ No compilation errors
- ✅ No test failures

### Priority 2: Coverage Target
- ✅ Coverage ≥ 85% for critical logic (providers, services, models)
- ✅ Coverage ≥ 70% for UI components
- ✅ All public methods have at least one test

### Priority 3: Code Quality
- ✅ `dart analyze` passes with no errors
- ✅ All tests follow project patterns
- ✅ Korean comments included for clarity

### Verification Command
```bash
flutter test --coverage && \
dart analyze --fatal-infos && \
genhtml coverage/lcov.info -o coverage/html
```

**Complete when**: All Priority 1, 2, 3 criteria are met.

## Priority Order (우선순위)

When principles conflict, follow this order:

1. **Test Correctness** (Highest)
   - Tests must pass
   - Tests must be accurate
   - Overrides: Simplicity, Pattern Reuse

2. **Code Simplicity**
   - No unrequested abstractions
   - Overrides: Pattern Reuse (if pattern is overly complex)

3. **Pattern Reuse**
   - Follow existing test patterns
   - Overrides: Goal-Driven (if pattern exists)

4. **Goal Achievement**
   - Meet coverage targets
   - Overrides: Surgical Changes (if needed for coverage)

5. **Surgical Changes** (Lowest)
   - Only modify requested files
   - Overrides: None (always respect)

## Documentation References (문서 참조)

### Auto-Reference Documents
- `.cursor/rules/flutter-test.mdc` - Flutter testing guidelines
- `.cursor/AGENTS.md` - This file (project-specific agent rules)
- `.cursor/docs/deep-discovery/*.json` - Project structure context

### External Documentation
- Flutter Testing Guide (Indexing & Docs)
- Flutter Test Framework (Indexing & Docs)
- Dart Language Tour (Indexing & Docs)
