# Phase 1.3 코드 품질 개선 작업 롤백 가이드

이 문서는 Phase 1.3 코드 품질 개선 작업을 롤백하는 방법을 안내합니다.

---

## 🚨 롤백 전 확인사항

1. **현재 작업 상태 확인**
   ```bash
   git status
   git diff --name-only
   ```

2. **변경사항 백업 (선택사항)**
   ```bash
   # 변경사항을 패치 파일로 저장
   git diff > phase-1.3-changes.patch
   ```

---

## 🔄 롤백 방법

### 방법 1: Git을 사용한 롤백 (권장)

#### 전체 롤백
```bash
# 모든 변경사항 취소
git checkout HEAD -- lib/

# 새로 생성된 파일 삭제
rm lib/constants/app_constants.dart
rm lib/constants/app_config.dart
```

#### 선택적 롤백
```bash
# 특정 파일만 롤백
git checkout HEAD -- lib/providers/todo_provider.dart
git checkout HEAD -- lib/utils/date_utils.dart
git checkout HEAD -- lib/widgets/calendar_widget.dart
git checkout HEAD -- lib/widgets/todo_detail_dialog.dart
git checkout HEAD -- lib/widgets/todo_input_dialog.dart

# 새로 생성된 파일 삭제
rm lib/constants/app_constants.dart
rm lib/constants/app_config.dart
```

### 방법 2: 수동 롤백

Git을 사용할 수 없는 경우, 각 파일을 수동으로 복원해야 합니다.

#### 1. 새로 생성된 파일 삭제

```bash
rm lib/constants/app_constants.dart
rm lib/constants/app_config.dart
```

#### 2. lib/providers/todo_provider.dart 복원

**제거할 import**:
```dart
import 'package:flutter_calender/constants/app_config.dart';
```

**변경할 코드**:
```dart
// 변경 전
if (_undoStack.length > AppConfig.maxUndoStackSize) {
  _undoStack.removeAt(0);
}

// 변경 후
if (_undoStack.length > 5) _undoStack.removeAt(0);
```

#### 3. lib/utils/date_utils.dart 복원

**제거할 import**:
```dart
import 'package:flutter_calender/constants/app_config.dart';
```

**변경할 코드**:
```dart
// 변경 전
if (_lunarCache.length >= AppConfig.maxLunarCacheSize) {
  _lunarCache.remove(_lunarCache.keys.first);
}

// 변경 후
if (_lunarCache.length >= 500) {
  _lunarCache.remove(_lunarCache.keys.first);
}
```

#### 4. lib/widgets/todo_detail_dialog.dart 복원

**제거할 import**:
```dart
import 'package:flutter_calender/constants/app_constants.dart';
```

**주요 변경사항**:
- `AppConstants.dialogInsetPadding` → `const EdgeInsets.symmetric(horizontal: 24, vertical: 48)`
- `AppConstants.dialogBorderRadius` → `BorderRadius.circular(24)`
- `AppConstants.headerPadding` → `const EdgeInsets.fromLTRB(20, 18, 12, 16)`
- `AppConstants.contentPadding` → `const EdgeInsets.fromLTRB(20, 16, 20, 8)`
- `AppConstants.spacing` → `8`
- `AppConstants.spacingMedium` → `10`
- `AppConstants.spacingLarge` → `14`
- `AppConstants.fontSizeSmall` → `11`
- `AppConstants.fontSizeTiny` → `10`
- `AppConstants.fontSize` → `12`
- `AppConstants.fontWeightNormal` → `FontWeight.w500`
- `AppConstants.fontWeightSemiBold` → `FontWeight.w600`
- `AppConstants.fontWeightBold` → `FontWeight.w700`
- `AppConstants.borderWidth` → `0.8`
- `AppConstants.borderWidthMedium` → `1.5`
- `AppConstants.borderWidthEmphasis` → `4`
- `AppConstants.alphaSemiTransparent` → `26`
- `AppConstants.alphaMedium` → `36`
- `AppConstants.alphaTransparent` → `24`
- `AppConstants.alphaOpaque` → `160`
- `AppConstants.alphaVeryOpaque` → `180`
- `AppConstants.chipBorderRadius` → `BorderRadius.circular(999)`
- `AppConstants.iconSize` → `20`
- `AppConstants.buttonMinSizeBox` → `const Size(36, 36)`
- `AppConstants.dialogMinHeightRatio` → `0.55`
- `AppConstants.dialogMaxHeightRatio` → `0.80`
- `AppConstants.dividerHeight` → `1.5`

#### 5. lib/widgets/todo_input_dialog.dart 복원

**제거할 import**:
```dart
import 'package:flutter_calender/constants/app_constants.dart';
```

**주요 변경사항**:
- `AppConstants.dialogInsetPadding` → `const EdgeInsets.symmetric(horizontal: 24, vertical: 48)`
- `AppConstants.dialogBorderRadius` → `BorderRadius.circular(24)`
- `AppConstants.dialogMinHeightRatio` → `0.55`

#### 6. lib/widgets/calendar_widget.dart 복원

**제거할 import**:
```dart
import 'package:flutter_calender/constants/app_constants.dart';
```

**주요 변경사항**:
- `AppConstants.animationDuration` → `const Duration(milliseconds: 300)`

---

## ✅ 롤백 확인

롤백 후 다음 명령어로 확인:

```bash
# 변경사항 확인
git status

# 코드 분석
dart analyze

# 테스트 실행
flutter test
```

---

## 📝 롤백 후 다음 단계

롤백 후에도 다음 작업을 계속 진행할 수 있습니다:

1. **부분적 적용**: 필요한 부분만 선택적으로 적용
2. **점진적 개선**: 한 파일씩 천천히 개선
3. **대안 접근**: 다른 방식으로 코드 품질 개선

---

**참고**: 롤백은 되돌릴 수 없으므로, 롤백 전에 현재 작업 상태를 백업하는 것을 권장합니다.
