# 테스트 작성 지침

이 디렉터리의 테스트 작성 시 적용되는 규칙입니다.

## 필수 규칙

- `Hive.init(tempDir.path)` 사용, `Hive.initFlutter()` 금지
- `AnimationController` 포함 위젯: `pumpAndSettle()` 금지, `pump(Duration(...))` 사용
- 비동기 메서드 항상 `await`
- 생성자 타이머: `tearDown`에서 `Future.delayed(300ms)` 대기

## 상세

`.cursor/rules/flutter-test.mdc` 참조
