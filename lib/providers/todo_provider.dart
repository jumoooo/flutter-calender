import 'package:flutter/foundation.dart';
import 'package:flutter_calender/models/todo.dart';

/// 할일 상태 관리 Provider
class TodoProvider with ChangeNotifier {
  /// 할일 목록
  final List<Todo> _todos = [];

  /// 할일 목록 getter (읽기 전용)
  List<Todo> get todos => List.unmodifiable(_todos);

  /// 특정 날짜의 할일 목록 반환
  List<Todo> getTodosByDate(DateTime date) {
    return _todos.where((todo) {
      return todo.date.year == date.year &&
          todo.date.month == date.month &&
          todo.date.day == date.day;
    }).toList();
  }

  /// 할일 추가
  void addTodo(Todo todo) {
    _todos.add(todo);
    notifyListeners();
  }

  /// 할일 업데이트
  void updateTodo(Todo updatedTodo) {
    final index = _todos.indexWhere((todo) => todo.id == updatedTodo.id);
    if (index != -1) {
      _todos[index] = updatedTodo;
      notifyListeners();
    }
  }

  /// 할일 삭제
  void deleteTodo(String id) {
    _todos.removeWhere((todo) => todo.id == id);
    notifyListeners();
  }

  /// 할일 완료 상태 토글
  void toggleTodo(String id) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(
        completed: !_todos[index].completed,
      );
      notifyListeners();
    }
  }

  /// 할일 날짜 변경 (드래그 앤 드롭용)
  void moveTodo(String id, DateTime newDate) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(date: newDate);
      notifyListeners();
    }
  }
}
