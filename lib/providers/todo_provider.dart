import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_calender/models/todo.dart';

/// 할일 상태 관리 Provider
/// 
/// Hive를 사용하여 할일 데이터를 영구 저장합니다.
class TodoProvider with ChangeNotifier {
  /// Hive Box 이름
  static const String _boxName = 'todos';

  /// Hive Box 인스턴스
  Box<Todo>? _box;

  /// 할일 목록 (메모리 캐시)
  List<Todo> _todos = [];

  /// 할일 목록 getter (읽기 전용)
  List<Todo> get todos => List.unmodifiable(_todos);

  /// Hive Box 초기화
  /// 
  /// 앱 시작 시 한 번 호출하여 Hive Box를 열고 데이터를 로드합니다.
  Future<void> initialize() async {
    try {
      _box = await Hive.openBox<Todo>(_boxName);
      await _loadTodos();
    } catch (e) {
      debugPrint('Hive 초기화 오류: $e');
      // 오류 발생 시 빈 리스트로 시작
      _todos = [];
    }
  }

  /// Hive에서 할일 목록 로드
  Future<void> _loadTodos() async {
    if (_box == null) return;
    
    _todos = _box!.values.toList();
    notifyListeners();
  }

  /// Hive에 할일 저장 (개별 저장)
  Future<void> _saveTodo(Todo todo) async {
    if (_box == null) return;
    
    try {
      await _box!.put(todo.id, todo);
    } catch (e) {
      debugPrint('할일 저장 오류: $e');
    }
  }

  /// Hive에서 할일 삭제
  Future<void> _deleteTodo(String id) async {
    if (_box == null) return;
    
    try {
      await _box!.delete(id);
    } catch (e) {
      debugPrint('할일 삭제 오류: $e');
    }
  }

  /// 특정 날짜의 할일 목록 반환
  List<Todo> getTodosByDate(DateTime date) {
    return _todos.where((todo) {
      return todo.date.year == date.year &&
          todo.date.month == date.month &&
          todo.date.day == date.day;
    }).toList();
  }

  /// 할일 추가
  /// 
  /// 메모리와 Hive에 모두 저장합니다.
  Future<void> addTodo(Todo todo) async {
    _todos.add(todo);
    await _saveTodo(todo);
    notifyListeners();
  }

  /// 할일 업데이트
  /// 
  /// 메모리와 Hive에 모두 업데이트합니다.
  Future<void> updateTodo(Todo updatedTodo) async {
    final index = _todos.indexWhere((todo) => todo.id == updatedTodo.id);
    if (index != -1) {
      _todos[index] = updatedTodo;
      await _saveTodo(updatedTodo);
      notifyListeners();
    }
  }

  /// 할일 삭제
  /// 
  /// 메모리와 Hive에서 모두 삭제합니다.
  Future<void> deleteTodo(String id) async {
    _todos.removeWhere((todo) => todo.id == id);
    await _deleteTodo(id);
    notifyListeners();
  }

  /// 할일 완료 상태 토글
  /// 
  /// 완료 상태를 변경하고 Hive에 저장합니다.
  Future<void> toggleTodo(String id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      final updatedTodo = _todos[index].copyWith(
        completed: !_todos[index].completed,
      );
      _todos[index] = updatedTodo;
      await _saveTodo(updatedTodo);
      notifyListeners();
    }
  }

  /// 할일 날짜 변경 (드래그 앤 드롭용)
  /// 
  /// 날짜를 변경하고 Hive에 저장합니다.
  Future<void> moveTodo(String id, DateTime newDate) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      final updatedTodo = _todos[index].copyWith(date: newDate);
      _todos[index] = updatedTodo;
      await _saveTodo(updatedTodo);
      notifyListeners();
    }
  }

  /// 모든 할일 삭제 (테스트/디버깅용)
  Future<void> clearAll() async {
    if (_box == null) return;
    
    try {
      await _box!.clear();
      _todos.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('전체 삭제 오류: $e');
    }
  }
}
