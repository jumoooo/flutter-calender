# Phase 3.1 일괄 선택/삭제 기능 구현 계획

**작성일**: 2026-01-27  
**작성자**: Orchestrator → Planner  
**목적**: Phase 3.1 일괄 선택/삭제 기능의 상세 구현 계획 수립  
**참조 문서**: 
- `.cursor/agents/planner.md` (Phase 5.5 Handoff Artifact 스키마)
- `.cursor/agents/orchestrator.md` (Intent 분류 및 Agent 라우팅)
- `.cursor/rules/agent-handoff.mdc` (Handoff 규칙 및 품질 게이트)
- `.cursor/docs/improvements/improvement-checklist.md` (Phase 3.1 요구사항)

---

## 📋 목차

1. [개요](#개요)
2. [요구사항 분석](#요구사항-분석)
3. [현재 상태 분석](#현재-상태-분석)
4. [구현 계획](#구현-계획)
5. [Handoff Artifact](#handoff-artifact)
6. [리스크 분석](#리스크-분석)
7. [수용 기준 (Acceptance Criteria)](#수용-기준-acceptance-criteria)
8. [품질 평가](#품질-평가)
9. [Agent 참여 계획](#agent-참여-계획)
10. [작업 체크리스트](#작업-체크리스트)

---

## 개요

### 기능 설명
사용자가 여러 할일을 한 번에 선택하고 일괄 삭제할 수 있는 기능을 구현합니다.

### 목표
- 사용자 편의성 향상 (여러 할일을 개별 삭제하지 않고 한 번에 삭제)
- 직관적인 UI/UX (체크박스 기반 선택 모드)
- 기존 기능과의 호환성 유지 (단일 삭제, 되돌리기 기능 유지)

### 의존성
- ✅ Phase 1.2 에러 처리 강화 (완료)
- ✅ Phase 3.1 되돌리기 기능 (완료) - 일괄 삭제 시 undo 스택 활용 가능

---

## 요구사항 분석

### 기능 요구사항
1. **선택 모드 진입/종료**
   - 사용자가 선택 모드를 활성화/비활성화할 수 있어야 함
   - 선택 모드 진입 버튼 (일정 영역 헤더 또는 AppBar)
   - 선택 모드 종료 버튼

2. **다중 선택**
   - 할일 아이템에 체크박스 표시 (선택 모드일 때만)
   - 개별 선택/해제 가능
   - 전체 선택/해제 기능 (선택사항)

3. **일괄 삭제**
   - 선택된 할일들을 한 번에 삭제
   - 삭제 전 확인 다이얼로그 표시
   - 삭제 후 SnackBar로 결과 표시 (되돌리기 버튼 포함 가능)

4. **기존 기능과의 통합**
   - 선택 모드가 아닐 때는 기존 동작 유지 (탭 → 상세 다이얼로그)
   - 선택 모드일 때는 탭으로 선택/해제, 롱프레스 비활성화

### 비기능 요구사항
- 성능: 선택 모드 진입/종료 시 즉각 반응
- 사용성: 직관적인 UI, 명확한 피드백
- 안정성: 에러 처리, 롤백 가능

---

## 현재 상태 분석

### 기존 구현 확인

#### 1. 할일 표시 위치
- **파일**: `lib/widgets/calendar_widget.dart`
- **위치**: `_buildScheduleColumn` 메서드 (라인 476-648)
- **구현**: `ListView.builder`로 할일 목록 표시
- **상호작용**: `InkWell`로 탭 → `showTodoDetailDialog` 열림

#### 2. 삭제 기능
- **파일**: `lib/providers/todo_provider.dart`
- **메서드**: `deleteTodo(String id, {bool addToUndoStack = true})` (라인 282-309)
- **기능**: 단일 할일 삭제, undo 스택 지원

#### 3. 되돌리기 기능
- **파일**: `lib/providers/todo_provider.dart`
- **메서드**: `undoLastDelete()` (라인 314-324)
- **기능**: 마지막 삭제 취소

#### 4. 복사 기능
- **파일**: `lib/providers/todo_provider.dart`
- **메서드**: `duplicateTodo(String id)` (라인 327-340)
- **기능**: 할일 복사 (롱프레스로 접근 가능)

### 현재 부족한 부분
1. **선택 모드 상태 관리**: 없음
2. **체크박스 UI**: 없음
3. **일괄 삭제 메서드**: 없음
4. **선택 모드 진입/종료 UI**: 없음

---

## 구현 계획

### Phase 1: 상태 관리 설계 및 구현

#### 1.1 선택 모드 상태 관리
**옵션 A: CalendarWidget State에 추가 (권장)**
- **장점**: 간단하고 빠른 구현, 추가 의존성 없음
- **단점**: 다른 화면에서 재사용 어려움
- **적용 범위**: 현재는 일정 영역에서만 사용하므로 충분

**옵션 B: 별도 SelectionProvider 생성**
- **장점**: 재사용 가능, 확장성 높음
- **단점**: 과도한 복잡도, 현재 요구사항에 비해 과함

**결정**: **옵션 A 선택** (간단한 구현)

**구현 내용**:
```dart
// lib/widgets/calendar_widget.dart
class _CalendarWidgetState extends State<CalendarWidget> {
  // 선택 모드 상태
  bool _isSelectionMode = false;
  Set<String> _selectedTodoIds = {};
  
  // 선택 모드 토글
  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedTodoIds.clear();
      }
    });
  }
  
  // 할일 선택/해제
  void _toggleTodoSelection(String todoId) {
    setState(() {
      if (_selectedTodoIds.contains(todoId)) {
        _selectedTodoIds.remove(todoId);
      } else {
        _selectedTodoIds.add(todoId);
      }
    });
  }
  
  // 전체 선택/해제
  void _toggleSelectAll(List<Todo> todos) {
    setState(() {
      if (_selectedTodoIds.length == todos.length) {
        _selectedTodoIds.clear();
      } else {
        _selectedTodoIds = todos.map((t) => t.id).toSet();
      }
    });
  }
}
```

#### 1.2 TodoProvider 확장
**파일**: `lib/providers/todo_provider.dart`

**추가 메서드**:
```dart
/// 여러 할일 일괄 삭제
/// 
/// [ids] 삭제할 할일 ID 목록
/// [addToUndoStack] true이면 각 삭제를 undo 스택에 추가 (기본값: true)
/// 
/// 반환값: 성공적으로 삭제된 할일 개수
Future<int> deleteTodos(List<String> ids, {bool addToUndoStack = true}) async {
  if (ids.isEmpty) return 0;
  
  final deletedTodos = <Todo>[];
  final deletedIndices = <int>[];
  
  try {
    // 역순으로 삭제하여 인덱스 문제 방지
    for (int i = _todos.length - 1; i >= 0; i--) {
      if (ids.contains(_todos[i].id)) {
        deletedTodos.add(_todos[i]);
        deletedIndices.add(i);
        _todos.removeAt(i);
        _removeFromIndex(_todos[i]);
        await _deleteTodoFromBox(_todos[i].id);
      }
    }
    
    // Undo 스택에 추가 (역순으로 추가하여 나중에 복원 시 올바른 순서 유지)
    if (addToUndoStack && deletedTodos.isNotEmpty) {
      for (final todo in deletedTodos.reversed) {
        _undoStack.add(todo);
        if (_undoStack.length > AppConfig.maxUndoStackSize) {
          _undoStack.removeAt(0);
        }
      }
    }
    
    notifyListeners();
    return deletedTodos.length;
  } catch (e) {
    // 롤백: 삭제된 항목들을 원래 위치에 복원
    for (int i = 0; i < deletedTodos.length; i++) {
      final index = deletedIndices[i];
      _todos.insert(index, deletedTodos[i]);
      _addToIndex(deletedTodos[i]);
    }
    
    final error = AppError.fromType(AppErrorType.todoDeleteFailed,
        exception: e is Exception ? e : null);
    _errorController.add(error);
    rethrow;
  }
}
```

**에러 타입 추가** (필요 시):
- `AppErrorType.todoBatchDeleteFailed` (선택사항, 기존 `todoDeleteFailed` 재사용 가능)

---

### Phase 2: UI 구현

#### 2.1 선택 모드 진입 버튼
**위치**: 일정 영역 헤더 (`_SortFilterButtons` 옆 또는 아래)

**구현**:
```dart
// lib/widgets/calendar_widget.dart의 _buildScheduleColumn 내부
// 헤더 Row에 추가
if (!_isSelectionMode)
  IconButton(
    icon: const Icon(Icons.check_box_outline_blank),
    tooltip: '선택 모드',
    onPressed: _toggleSelectionMode,
  )
else
  Row(
    children: [
      // 선택된 개수 표시
      Text('${_selectedTodoIds.length}개 선택'),
      const SizedBox(width: 8),
      // 전체 선택/해제
      IconButton(
        icon: Icon(_selectedTodoIds.length == todos.length 
            ? Icons.check_box 
            : Icons.check_box_outline_blank),
        tooltip: '전체 선택/해제',
        onPressed: () => _toggleSelectAll(todos),
      ),
      // 선택 모드 종료
      IconButton(
        icon: const Icon(Icons.close),
        tooltip: '선택 모드 종료',
        onPressed: _toggleSelectionMode,
      ),
    ],
  ),
```

#### 2.2 할일 아이템에 체크박스 추가
**위치**: `_buildScheduleColumn`의 `ListView.builder` 내부

**구현**:
```dart
// lib/widgets/calendar_widget.dart
ListView.builder(
  itemCount: todos.length,
  itemBuilder: (context, index) {
    final todo = todos[index];
    final isSelected = _isSelectionMode && _selectedTodoIds.contains(todo.id);
    
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, _) {
        final category = categoryProvider.getById(todo.categoryId);
        return InkWell(
          onTap: _isSelectionMode
              ? () => _toggleTodoSelection(todo.id)
              : () => showTodoDetailDialog(context, todo),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            // 선택 모드일 때 배경색 변경
            decoration: isSelected
                ? BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 체크박스 (선택 모드일 때만 표시)
                  if (_isSelectionMode) ...[
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => _toggleTodoSelection(todo.id),
                    ),
                    const SizedBox(width: 4),
                  ],
                  _priorityIcon(todo.priority),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todo.title,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w500,
                                decoration: todo.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: todo.completed
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                    : null,
                              ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        // 카테고리/시간/기한 메타 태그
                        if (category != null ||
                            todo.todoTime != null ||
                            todo.dueDate != null) ...[
                          const SizedBox(height: 3),
                          TodoMetaTagsRow(
                            todo: todo,
                            category: category,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (todo.completed)
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: Colors.green[400],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  },
),
```

#### 2.3 일괄 삭제 버튼
**위치**: 선택 모드일 때 일정 영역 하단 또는 헤더

**구현**:
```dart
// lib/widgets/calendar_widget.dart의 _buildScheduleColumn 내부
// 선택 모드이고 선택된 항목이 있을 때만 표시
if (_isSelectionMode && _selectedTodoIds.isNotEmpty)
  Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      border: Border(
        top: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 1,
        ),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${_selectedTodoIds.length}개 선택됨',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton.icon(
          onPressed: () => _showBatchDeleteDialog(context, todoProvider),
          icon: const Icon(Icons.delete_outline, size: 18),
          label: const Text('일괄 삭제'),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
        ),
      ],
    ),
  ),
```

#### 2.4 일괄 삭제 확인 다이얼로그
**구현**:
```dart
// lib/widgets/calendar_widget.dart
Future<void> _showBatchDeleteDialog(
  BuildContext context,
  TodoProvider todoProvider,
) async {
  final count = _selectedTodoIds.length;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('일괄 삭제'),
      content: Text('선택한 $count개의 할일을 삭제하시겠어요?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('삭제'),
        ),
      ],
    ),
  );
  
  if (confirmed != true || !mounted) return;
  
  try {
    final deletedCount = await todoProvider.deleteTodos(
      _selectedTodoIds.toList(),
    );
    
    if (mounted) {
      setState(() {
        _selectedTodoIds.clear();
        _isSelectionMode = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$deletedCount개의 할일이 삭제되었습니다.'),
          action: todoProvider.canUndo
              ? SnackBarAction(
                  label: '되돌리기',
                  onPressed: () async {
                    await todoProvider.undoLastDelete();
                  },
                )
              : null,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('삭제 중 오류가 발생했습니다: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
```

---

### Phase 3: 테스트 작성

#### 3.1 Provider 테스트
**파일**: `test/providers/todo_provider_batch_delete_test.dart`

**테스트 케이스**:
1. 일괄 삭제 성공 테스트
2. 일괄 삭제 실패 시 롤백 테스트
3. 일괄 삭제 후 undo 스택 확인 테스트
4. 빈 리스트 삭제 테스트
5. 존재하지 않는 ID 삭제 테스트

#### 3.2 위젯 테스트 (선택사항)
**파일**: `test/widgets/calendar_widget_selection_test.dart`

**테스트 케이스**:
1. 선택 모드 진입/종료 테스트
2. 할일 선택/해제 테스트
3. 전체 선택/해제 테스트
4. 일괄 삭제 다이얼로그 표시 테스트

---

## Handoff Artifact

### JSON 스키마 (planner.md Phase 5.5 준수)

```json
{
  "intent": "feature_dev",
  "summary": "Implement batch selection and delete functionality for todos in calendar widget",
  "plan_steps": [
    {
      "id": "S1",
      "title": "Add selection mode state management to CalendarWidget",
      "critical": true,
      "description": "Add _isSelectionMode boolean and _selectedTodoIds Set<String> to _CalendarWidgetState"
    },
    {
      "id": "S2",
      "title": "Implement selection mode toggle methods",
      "critical": true,
      "description": "Add _toggleSelectionMode, _toggleTodoSelection, _toggleSelectAll methods"
    },
    {
      "id": "S3",
      "title": "Add deleteTodos method to TodoProvider",
      "critical": true,
      "description": "Implement batch delete with rollback support and undo stack integration"
    },
    {
      "id": "S4",
      "title": "Add selection mode entry button to schedule header",
      "critical": true,
      "description": "Add icon button to enter selection mode in _buildScheduleColumn header"
    },
    {
      "id": "S5",
      "title": "Add checkbox to todo items in selection mode",
      "critical": true,
      "description": "Modify ListView.builder to show checkbox when _isSelectionMode is true"
    },
    {
      "id": "S6",
      "title": "Add batch delete button and dialog",
      "critical": true,
      "description": "Implement _showBatchDeleteDialog and add delete button when items are selected"
    },
    {
      "id": "S7",
      "title": "Update InkWell onTap behavior for selection mode",
      "critical": true,
      "description": "Change tap behavior: selection mode = toggle selection, normal mode = show detail dialog"
    },
    {
      "id": "S8",
      "title": "Write unit tests for deleteTodos method",
      "critical": false,
      "description": "Create test file for batch delete functionality"
    }
  ],
  "impact_scope": {
    "files": [
      "lib/widgets/calendar_widget.dart",
      "lib/providers/todo_provider.dart",
      "test/providers/todo_provider_batch_delete_test.dart"
    ],
    "state_management": [
      "CalendarWidget._isSelectionMode",
      "CalendarWidget._selectedTodoIds",
      "TodoProvider.deleteTodos()"
    ],
    "ui_components": [
      "일정 영역 헤더 (선택 모드 진입 버튼)",
      "할일 아이템 (체크박스)",
      "일괄 삭제 버튼 및 다이얼로그"
    ]
  },
  "risks": [
    "선택 모드 상태가 다른 화면으로 이동 시 유지될 수 있음 (CalendarWidget이 dispose되면 자동 해결)",
    "일괄 삭제 중 일부 실패 시 롤백이 복잡할 수 있음 (try-catch로 처리)",
    "대량 할일 삭제 시 성능 이슈 가능성 (현재 구현으로는 문제 없음, 향후 최적화 가능)",
    "기존 단일 삭제 기능과의 일관성 유지 필요"
  ],
  "acceptance_criteria": [
    "사용자가 선택 모드 진입 버튼을 탭하면 선택 모드가 활성화됨",
    "선택 모드일 때 할일 아이템에 체크박스가 표시됨",
    "체크박스를 탭하면 할일이 선택/해제됨",
    "전체 선택/해제 버튼이 정상 작동함",
    "선택된 할일이 있을 때 일괄 삭제 버튼이 표시됨",
    "일괄 삭제 버튼 탭 시 확인 다이얼로그가 표시됨",
    "확인 후 선택된 모든 할일이 삭제됨",
    "삭제 후 SnackBar에 결과가 표시되고 되돌리기 버튼이 표시됨 (가능한 경우)",
    "선택 모드가 아닐 때는 기존 동작 유지 (탭 → 상세 다이얼로그)",
    "일괄 삭제 실패 시 롤백이 정상 작동함"
  ],
  "scores": {
    "quality": 85,
    "efficiency": 80,
    "stability": 90,
    "overall": 85
  },
  "evaluation_notes": "Quality: 요구사항을 잘 충족하고 사용자 경험을 고려한 설계. Efficiency: 간단한 구현으로 빠른 개발 가능, 다만 향후 확장 시 리팩토링 필요할 수 있음. Stability: 기존 기능과의 호환성 유지, 에러 처리 및 롤백 로직 포함.",
  "agent_plan": [
    {
      "agent": "orchestrator",
      "role": "Intent classification and task distribution"
    },
    {
      "agent": "planner",
      "role": "Plan creation and handoff artifact generation"
    },
    {
      "agent": "featureImplementation",
      "role": "Code implementation (CalendarWidget, TodoProvider, UI components)"
    },
    {
      "agent": "testCodeGenerator",
      "role": "Unit test generation for deleteTodos method (optional)"
    }
  ]
}
```

---

## 리스크 분석

### 높은 리스크
없음

### 중간 리스크
1. **선택 모드 상태 관리**: CalendarWidget이 dispose되면 자동으로 해결되지만, 다른 화면으로 이동 시 상태 유지 여부 확인 필요
   - **완화 방안**: CalendarWidget이 dispose되면 상태가 자동으로 초기화됨

2. **일괄 삭제 중 일부 실패**: 롤백 로직이 복잡할 수 있음
   - **완화 방안**: try-catch로 전체 롤백 처리, 각 삭제를 역순으로 수행하여 인덱스 문제 방지

### 낮은 리스크
1. **성능**: 대량 할일 삭제 시 성능 이슈 가능성
   - **완화 방안**: 현재 구현으로는 문제 없음, 향후 최적화 가능

2. **UI 일관성**: 기존 단일 삭제와의 일관성 유지 필요
   - **완화 방안**: 기존 패턴을 따르도록 설계

---

## 수용 기준 (Acceptance Criteria)

### 필수 기준
1. ✅ 사용자가 선택 모드 진입 버튼을 탭하면 선택 모드가 활성화됨
2. ✅ 선택 모드일 때 할일 아이템에 체크박스가 표시됨
3. ✅ 체크박스를 탭하면 할일이 선택/해제됨
4. ✅ 전체 선택/해제 버튼이 정상 작동함
5. ✅ 선택된 할일이 있을 때 일괄 삭제 버튼이 표시됨
6. ✅ 일괄 삭제 버튼 탭 시 확인 다이얼로그가 표시됨
7. ✅ 확인 후 선택된 모든 할일이 삭제됨
8. ✅ 삭제 후 SnackBar에 결과가 표시되고 되돌리기 버튼이 표시됨 (가능한 경우)
9. ✅ 선택 모드가 아닐 때는 기존 동작 유지 (탭 → 상세 다이얼로그)
10. ✅ 일괄 삭제 실패 시 롤백이 정상 작동함

### 선택 기준
- [ ] 위젯 테스트 작성 (선택사항)
- [ ] 선택 모드 진입 시 애니메이션 추가 (선택사항)

---

## 품질 평가

### Quality (품질): 85/100
- **강점**: 요구사항을 잘 충족하고 사용자 경험을 고려한 설계
- **약점**: 향후 확장 시 리팩토링 필요할 수 있음 (SelectionProvider로 분리)

### Efficiency (효율성): 80/100
- **강점**: 간단한 구현으로 빠른 개발 가능
- **약점**: 향후 확장 시 리팩토링 필요할 수 있음

### Stability (안정성): 90/100
- **강점**: 기존 기능과의 호환성 유지, 에러 처리 및 롤백 로직 포함
- **약점**: 일괄 삭제 중 일부 실패 시 롤백 복잡도

### Overall (종합): 85/100
- **계산**: (85 × 0.4) + (80 × 0.35) + (90 × 0.25) = 34 + 28 + 22.5 = 84.5 ≈ 85

---

## Agent 참여 계획

### 1. Orchestrator
- **역할**: Intent 분류 (`feature_dev`), Agent 라우팅
- **시점**: 작업 시작 시
- **출력**: Planner에게 작업 위임

### 2. Planner
- **역할**: 상세 계획 수립, Handoff Artifact 생성
- **시점**: Orchestrator 이후
- **출력**: Handoff Artifact JSON

### 3. featureImplementation
- **역할**: 실제 코드 구현
  - `CalendarWidget` 수정 (선택 모드 상태, UI)
  - `TodoProvider` 확장 (일괄 삭제 메서드)
  - UI 컴포넌트 구현 (체크박스, 버튼, 다이얼로그)
- **시점**: Planner Handoff Artifact 수신 후
- **입력**: Handoff Artifact의 `plan_steps`, `impact_scope`, `acceptance_criteria`
- **출력**: 구현된 코드, 테스트 결과

### 4. testCodeGenerator (선택사항)
- **역할**: 단위 테스트 생성
- **시점**: featureImplementation 완료 후
- **출력**: 테스트 파일

---

## 작업 체크리스트

### Phase 1: 상태 관리
- [ ] `CalendarWidget`에 선택 모드 상태 추가 (`_isSelectionMode`, `_selectedTodoIds`)
- [ ] 선택 모드 토글 메서드 구현 (`_toggleSelectionMode`)
- [ ] 할일 선택/해제 메서드 구현 (`_toggleTodoSelection`)
- [ ] 전체 선택/해제 메서드 구현 (`_toggleSelectAll`)

### Phase 2: Provider 확장
- [ ] `TodoProvider`에 `deleteTodos` 메서드 추가
- [ ] 일괄 삭제 시 롤백 로직 구현
- [ ] undo 스택 통합 확인

### Phase 3: UI 구현
- [ ] 선택 모드 진입 버튼 추가 (일정 영역 헤더)
- [ ] 선택 모드 헤더 UI 추가 (선택 개수, 전체 선택, 종료 버튼)
- [ ] 할일 아이템에 체크박스 추가 (선택 모드일 때만)
- [ ] 선택 모드일 때 할일 아이템 배경색 변경
- [ ] `InkWell` onTap 동작 수정 (선택 모드 vs 일반 모드)
- [ ] 일괄 삭제 버튼 추가 (선택된 항목이 있을 때만)
- [ ] 일괄 삭제 확인 다이얼로그 구현
- [ ] 삭제 후 SnackBar 표시 (되돌리기 버튼 포함)

### Phase 4: 테스트
- [ ] `deleteTodos` 메서드 단위 테스트 작성
- [ ] 일괄 삭제 성공 케이스 테스트
- [ ] 일괄 삭제 실패 시 롤백 테스트
- [ ] undo 스택 통합 테스트

### Phase 5: 검증
- [ ] 모든 수용 기준 확인
- [ ] 기존 기능 동작 확인 (단일 삭제, 되돌리기)
- [ ] UI/UX 일관성 확인
- [ ] 에러 처리 확인
- [ ] `dart analyze` 통과 확인
- [ ] 기존 테스트 통과 확인

---

## 예상 소요 시간

- **계획 수립**: 30분
- **구현**: 2-3시간
  - 상태 관리: 30분
  - Provider 확장: 30분
  - UI 구현: 1-1.5시간
  - 테스트: 30분
- **검증**: 30분
- **총 예상 시간**: 3.5-4.5시간

---

## 다음 단계

1. **Orchestrator 확인**: 이 계획을 검토하고 Intent 분류 확인
2. **Planner 실행**: Handoff Artifact 생성 (위 JSON 스키마 사용)
3. **featureImplementation 실행**: 실제 코드 구현
4. **검증**: 수용 기준 확인 및 테스트 실행

---

## 참조 문서

- `.cursor/agents/planner.md` - Planner Agent 정의 및 Handoff Artifact 스키마
- `.cursor/agents/orchestrator.md` - Orchestrator Agent 정의 및 Intent 분류
- `.cursor/agents/featureImplementation.md` - Feature Implementation Agent 정의
- `.cursor/rules/agent-handoff.mdc` - Handoff 규칙 및 품질 게이트
- `.cursor/docs/improvements/improvement-checklist.md` - Phase 3.1 요구사항
- `.cursor/rules/flutter-test.mdc` - Flutter 테스트 작성 가이드라인

---

**문서 버전**: 1.0  
**마지막 업데이트**: 2026-01-27  
**상태**: 계획 완료, 구현 대기
