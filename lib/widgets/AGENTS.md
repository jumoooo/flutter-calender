# Widget 작성 지침

이 디렉터리의 위젯 작성 시 적용되는 규칙입니다.

## 기본 원칙

- StatelessWidget / StatefulWidget 적절히 구분
- `const` 키워드 적극 활용
- 한글 주석으로 복잡한 로직 설명

## 애니메이션 관련

- `AnimationController` 사용 시 `.cursor/rules/flutter-animation.mdc` 체크리스트 준수
- 프레임 순서: 로컬 상태 리셋 → Provider notify 순서 보장

## 상태 관리

- UI 전용 상태 vs 비즈니스 상태 분리 (`.cursor/rules/state-management.mdc` 참조)
