import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_calender/constants/app_config.dart';
import 'package:flutter_calender/models/todo.dart';
import 'package:flutter_calender/utils/error_messages.dart';
import 'package:flutter_calender/utils/hive_migration.dart';

/// 할일 상태 관리 Provider
///
/// Hive를 사용하여 할일 데이터를 영구 저장합니다.
/// 날짜별 인덱스를 유지하여 getTodosByDate가 O(1)로 동작합니다.
class TodoProvider with ChangeNotifier {
  /// Hive Box 이름
  static const String _boxName = 'todos';

  /// Hive Box 인스턴스
  Box<Todo>? _box;

  /// 할일 목록 (메모리 캐시)
  List<Todo> _todos = [];

  /// 날짜별 인덱스: 'yyyy-M-d' → 해당 날짜의 할일 목록
  final Map<String, List<Todo>> _dateIndex = {};

  /// 삭제 취소용 스택 (최대 5개)
  final List<Todo> _undoStack = [];

  /// 현재 정렬 방식
  TodoSortType _sortType = TodoSortType.byCreation;

  /// 완료된 할일 숨기기 여부
  bool _hideCompleted = false;

  /// 할일 개수 제한 (null이면 제한 없음)
  int? _maxTodoCount = AppConfig.defaultMaxTodoCount;

  /// 경고 스트림 컨트롤러 (할일 개수 경고용)
  final StreamController<int> _warningController =
      StreamController<int>.broadcast();

  // ─── Getters ────────────────────────────────────────────────────────────────

  /// 할일 목록 getter (읽기 전용)
  List<Todo> get todos => List.unmodifiable(_todos);

  /// 현재 정렬 방식
  TodoSortType get sortType => _sortType;

  /// 완료 숨기기 여부
  bool get hideCompleted => _hideCompleted;

  /// 되돌릴 수 있는 삭제가 있는지 여부
  bool get canUndo => _undoStack.isNotEmpty;

  /// 할일 개수 제한
  int? get maxTodoCount => _maxTodoCount;

  /// 할일 개수 제한 설정
  void setMaxTodoCount(int? count) {
    _maxTodoCount = count;
    notifyListeners();
  }

  /// 현재 할일 개수
  int get todoCount => _todos.length;

  /// 에러 스트림 컨트롤러
  final StreamController<AppError> _errorController =
      StreamController<AppError>.broadcast();

  /// 에러 스트림 (읽기 전용)
  Stream<AppError> get errorStream => _errorController.stream;

  /// 경고 스트림 (읽기 전용) - 할일 개수 경고용
  Stream<int> get warningStream => _warningController.stream;

  // ─── 인덱스 유틸리티 ────────────────────────────────────────────────────────

  /// 날짜를 인덱스 키로 변환
  String _key(DateTime date) => '${date.year}-${date.month}-${date.day}';

  /// 인덱스에 할일 추가
  void _addToIndex(Todo todo) {
    final key = _key(todo.date);
    _dateIndex.putIfAbsent(key, () => []).add(todo);
  }

  /// 인덱스에서 할일 제거
  void _removeFromIndex(Todo todo) {
    final key = _key(todo.date);
    _dateIndex[key]?.remove(todo);
    if (_dateIndex[key]?.isEmpty ?? false) {
      _dateIndex.remove(key);
    }
  }

  /// _todos 전체를 기반으로 인덱스 재구성
  void _rebuildIndex() {
    _dateIndex.clear();
    for (final todo in _todos) {
      _addToIndex(todo);
    }
  }

  // ─── 초기화 ─────────────────────────────────────────────────────────────────

  /// Hive Box 초기화 및 데이터 로드
  Future<void> initialize() async {
    try {
      final migrationSuccess = await HiveMigration.migrate(_boxName);
      if (!migrationSuccess) {
        debugPrint('마이그레이션 실패: 계속 진행하지만 데이터 손실 가능성 있음');
        final error = AppError.fromType(AppErrorType.migrationFailed);
        _errorController.add(error);
      }

      _box = await Hive.openBox<Todo>(_boxName);
      await _loadTodos();
    } catch (e) {
      debugPrint('Hive 초기화 오류: $e');
      _todos = [];
      final error = e is Exception
          ? AppError.fromException(e)
          : AppError.fromType(AppErrorType.hiveInitFailed);
      _errorController.add(error);
    }
  }

  /// Hive에서 할일 목록 로드
  Future<void> _loadTodos() async {
    if (_box == null) return;

    try {
      final loadedTodos = <Todo>[];
      for (final value in _box!.values) {
        try {
          loadedTodos.add(value);
        } catch (e) {
          debugPrint('손상된 할일 데이터 건너뛰기: $e');
        }
      }

      _todos = loadedTodos;
      _rebuildIndex();
      notifyListeners();
    } catch (e) {
      debugPrint('할일 목록 로드 오류: $e');
      _todos = [];
      final error = e is Exception
          ? AppError.fromException(e)
          : AppError.fromType(AppErrorType.dataLoadFailed);
      _errorController.add(error);
    }
  }

  // ─── Hive 내부 저장/삭제 ────────────────────────────────────────────────────

  Future<void> _saveTodo(Todo todo) async {
    if (_box == null) throw Exception('Hive Box가 초기화되지 않았습니다.');
    try {
      await _box!.put(todo.id, todo);
    } catch (e) {
      debugPrint('할일 저장 오류: $e');
      final error = e is Exception
          ? AppError.fromException(e)
          : AppError.fromType(AppErrorType.dataSaveFailed);
      _errorController.add(error);
      rethrow;
    }
  }

  Future<void> _deleteTodoFromBox(String id) async {
    if (_box == null) throw Exception('Hive Box가 초기화되지 않았습니다.');
    try {
      await _box!.delete(id);
    } catch (e) {
      debugPrint('할일 삭제 오류: $e');
      final error = e is Exception
          ? AppError.fromException(e)
          : AppError.fromType(AppErrorType.dataDeleteFailed);
      _errorController.add(error);
      rethrow;
    }
  }

  // ─── 공개 CRUD ───────────────────────────────────────────────────────────────

  /// 특정 날짜의 할일 목록 반환 (O(1), 정렬/필터 적용)
  List<Todo> getTodosByDate(DateTime date) {
    final key = _key(date);
    var todos = List<Todo>.from(_dateIndex[key] ?? []);

    // 완료 숨기기
    if (_hideCompleted) {
      todos = todos.where((t) => !t.completed).toList();
    }

    // 정렬
    switch (_sortType) {
      case TodoSortType.byPriority:
        todos.sort((a, b) => b.priority.index.compareTo(a.priority.index));
      case TodoSortType.byDueDate:
        todos.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
      case TodoSortType.byCreation:
        // ID를 숫자로 변환하여 역순 정렬 (큰 ID = 최신 등록 = 위에)
        todos.sort((a, b) {
          final aId = int.tryParse(a.id) ?? 0;
          final bId = int.tryParse(b.id) ?? 0;
          return bId.compareTo(aId); // 역순 정렬 (최신이 위로)
        });
      case TodoSortType.byTitle:
        todos.sort((a, b) => a.title.compareTo(b.title));
    }

    return List.unmodifiable(todos);
  }

  /// 할일 추가
  /// 
  /// 할일 개수 제한이 설정되어 있고 초과하면 예외를 발생시킵니다.
  /// 경고 임계값에 도달하면 경고 스트림에 알림을 보냅니다.
  Future<void> addTodo(Todo todo) async {
    // 할일 개수 제한 체크
    if (_maxTodoCount != null && _todos.length >= _maxTodoCount!) {
      final error = AppError.fromType(AppErrorType.todoLimitExceeded);
      _errorController.add(error);
      throw Exception('할일 개수 제한($_maxTodoCount개)에 도달했습니다.');
    }

    try {
      _todos.add(todo);
      _addToIndex(todo);
      await _saveTodo(todo);
      notifyListeners();

      // 경고 임계값 체크 (제한의 80% 또는 설정된 임계값)
      final warningThreshold = AppConfig.todoCountWarningThreshold;
      if (warningThreshold != null &&
          _maxTodoCount != null &&
          _todos.length >= warningThreshold &&
          _todos.length < _maxTodoCount!) {
        _warningController.add(_todos.length);
      }
    } catch (e) {
      _todos.remove(todo);
      _removeFromIndex(todo);
      final error = AppError.fromType(AppErrorType.todoAddFailed,
          exception: e is Exception ? e : null);
      _errorController.add(error);
      rethrow;
    }
  }

  /// 할일 업데이트
  Future<void> updateTodo(Todo updatedTodo) async {
    final index = _todos.indexWhere((todo) => todo.id == updatedTodo.id);
    if (index == -1) return;

    final previousTodo = _todos[index];
    try {
      _removeFromIndex(previousTodo);
      _todos[index] = updatedTodo;
      _addToIndex(updatedTodo);
      await _saveTodo(updatedTodo);
      notifyListeners();
    } catch (e) {
      _removeFromIndex(updatedTodo);
      _todos[index] = previousTodo;
      _addToIndex(previousTodo);
      final error = AppError.fromType(AppErrorType.todoUpdateFailed,
          exception: e is Exception ? e : null);
      _errorController.add(error);
      rethrow;
    }
  }

  /// 할일 삭제
  ///
  /// [addToUndoStack] true이면 실행 취소 스택에 추가 (기본값: true)
  Future<void> deleteTodo(String id, {bool addToUndoStack = true}) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) return;

    final todoToDelete = _todos[index];
    try {
      _todos.removeAt(index);
      _removeFromIndex(todoToDelete);
      await _deleteTodoFromBox(id);

      // Undo 스택에 추가 (최대 개수 제한)
      if (addToUndoStack) {
        _undoStack.add(todoToDelete);
        if (_undoStack.length > AppConfig.maxUndoStackSize) {
          _undoStack.removeAt(0);
        }
      }

      notifyListeners();
    } catch (e) {
      _todos.insert(index, todoToDelete);
      _addToIndex(todoToDelete);
      final error = AppError.fromType(AppErrorType.todoDeleteFailed,
          exception: e is Exception ? e : null);
      _errorController.add(error);
      rethrow;
    }
  }

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
          _removeFromIndex(_todos[i]);
          await _deleteTodoFromBox(_todos[i].id);
          _todos.removeAt(i);
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

  /// 마지막 삭제 취소 (Undo)
  ///
  /// 반환값: 복원된 Todo (없으면 null)
  Future<Todo?> undoLastDelete() async {
    if (_undoStack.isEmpty) return null;
    final todo = _undoStack.removeLast();
    try {
      await addTodo(todo);
      return todo;
    } catch (e) {
      debugPrint('Undo 실패: $e');
      return null;
    }
  }

  /// 할일 복사 (날짜는 오늘, 완료 상태 초기화)
  Future<void> duplicateTodo(String id) async {
    final original = _todos.firstWhere(
      (t) => t.id == id,
      orElse: () => throw Exception('할일을 찾을 수 없습니다.'),
    );

    final copy = original.copyWith(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      completed: false,
    );

    await addTodo(copy);
  }

  /// 할일 완료 상태 토글
  Future<void> toggleTodo(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) return;

    final previousTodo = _todos[index];
    final updatedTodo =
        previousTodo.copyWith(completed: !previousTodo.completed);

    try {
      _removeFromIndex(previousTodo);
      _todos[index] = updatedTodo;
      _addToIndex(updatedTodo);
      await _saveTodo(updatedTodo);
      notifyListeners();
    } catch (e) {
      _removeFromIndex(updatedTodo);
      _todos[index] = previousTodo;
      _addToIndex(previousTodo);
      final error = AppError.fromType(AppErrorType.todoToggleFailed,
          exception: e is Exception ? e : null);
      _errorController.add(error);
      rethrow;
    }
  }

  /// 할일 날짜 변경 (드래그 앤 드롭용)
  Future<void> moveTodo(String id, DateTime newDate) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) return;

    final previousTodo = _todos[index];
    final updatedTodo = previousTodo.copyWith(date: newDate);

    try {
      _removeFromIndex(previousTodo);
      _todos[index] = updatedTodo;
      _addToIndex(updatedTodo);
      await _saveTodo(updatedTodo);
      notifyListeners();
    } catch (e) {
      _removeFromIndex(updatedTodo);
      _todos[index] = previousTodo;
      _addToIndex(previousTodo);
      final error = AppError.fromType(AppErrorType.todoMoveFailed,
          exception: e is Exception ? e : null);
      _errorController.add(error);
      rethrow;
    }
  }

  // ─── 정렬 / 필터 ─────────────────────────────────────────────────────────────

  /// 정렬 방식 변경
  void setSortType(TodoSortType type) {
    if (_sortType == type) return;
    _sortType = type;
    notifyListeners();
  }

  /// 완료 숨기기 토글
  void toggleHideCompleted() {
    _hideCompleted = !_hideCompleted;
    notifyListeners();
  }

  // ─── 검색 ────────────────────────────────────────────────────────────────────

  /// 할일 검색 (제목/설명, 우선순위 필터, 날짜 범위)
  List<Todo> searchTodos({
    required String query,
    List<TodoPriority>? priorities,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final q = query.trim().toLowerCase();

    return _todos.where((todo) {
      if (q.isNotEmpty) {
        final titleMatch = todo.title.toLowerCase().contains(q);
        final descMatch =
            todo.description?.toLowerCase().contains(q) ?? false;
        if (!titleMatch && !descMatch) return false;
      }

      if (priorities != null && priorities.isNotEmpty) {
        if (!priorities.contains(todo.priority)) return false;
      }

      if (startDate != null) {
        final start =
            DateTime(startDate.year, startDate.month, startDate.day);
        final todoDate =
            DateTime(todo.date.year, todo.date.month, todo.date.day);
        if (todoDate.isBefore(start)) return false;
      }
      if (endDate != null) {
        final end = DateTime(endDate.year, endDate.month, endDate.day);
        final todoDate =
            DateTime(todo.date.year, todo.date.month, todo.date.day);
        if (todoDate.isAfter(end)) return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        final dateCmp = b.date.compareTo(a.date);
        if (dateCmp != 0) return dateCmp;
        return b.priority.index.compareTo(a.priority.index);
      });
  }

  // ─── 유틸리티 ────────────────────────────────────────────────────────────────

  /// 모든 할일 삭제 (테스트/디버깅용)
  Future<void> clearAll() async {
    if (_box == null) return;
    try {
      await _box!.clear();
      _todos.clear();
      _dateIndex.clear();
      _undoStack.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('전체 삭제 오류: $e');
      final error = e is Exception
          ? AppError.fromException(e)
          : AppError.fromType(AppErrorType.dataDeleteFailed);
      _errorController.add(error);
    }
  }

  @override
  void dispose() {
    _errorController.close();
    _box?.close();
    super.dispose();
  }
}
