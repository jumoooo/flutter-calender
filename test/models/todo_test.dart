import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_calender/models/todo.dart';

void main() {
  group('Todo 모델 테스트', () {
    test('Todo 생성 테스트', () {
      // Given: Todo 생성에 필요한 데이터
      final todo = Todo(
        id: '1',
        title: '테스트 할일',
        description: '테스트 설명',
        date: DateTime(2026, 3, 15),
        completed: false,
        priority: TodoPriority.normal,
      );

      // Then: Todo가 올바르게 생성되었는지 확인
      expect(todo.id, '1');
      expect(todo.title, '테스트 할일');
      expect(todo.description, '테스트 설명');
      expect(todo.date, DateTime(2026, 3, 15));
      expect(todo.completed, false);
      expect(todo.priority, TodoPriority.normal);
    });

    test('Todo 완료 상태 변경 테스트', () {
      // Given: 완료되지 않은 Todo
      final todo = Todo(id: '1', title: '테스트 할일', date: DateTime(2026, 3, 15));

      // When: 완료 상태로 변경
      final completedTodo = todo.copyWith(completed: true);

      // Then: 완료 상태가 변경되었는지 확인
      expect(completedTodo.completed, true);
      expect(todo.completed, false); // 원본은 변경되지 않음
    });

    test('Todo 날짜 변경 테스트', () {
      // Given: 특정 날짜의 Todo
      final todo = Todo(id: '1', title: '테스트 할일', date: DateTime(2026, 3, 15));

      // When: 날짜 변경
      final newDate = DateTime(2026, 3, 20);
      final updatedTodo = todo.copyWith(date: newDate);

      // Then: 날짜가 변경되었는지 확인
      expect(updatedTodo.date, newDate);
      expect(todo.date, DateTime(2026, 3, 15)); // 원본은 변경되지 않음
    });

    test('Todo JSON 직렬화 테스트', () {
      // Given: Todo 객체
      final todo = Todo(
        id: '1',
        title: '테스트 할일',
        description: '테스트 설명',
        date: DateTime(2026, 3, 15),
        completed: false,
        priority: TodoPriority.high,
      );

      // When: JSON으로 변환
      final json = todo.toJson();

      // Then: JSON이 올바르게 생성되었는지 확인
      expect(json['id'], '1');
      expect(json['title'], '테스트 할일');
      expect(json['description'], '테스트 설명');
      expect(json['completed'], false);
      expect(json['priority'], 'high');
    });

    test('Todo JSON 역직렬화 테스트', () {
      // Given: JSON 데이터
      final json = {
        'id': '1',
        'title': '테스트 할일',
        'description': '테스트 설명',
        'date': '2026-03-15T00:00:00.000',
        'completed': false,
        'priority': 'high',
      };

      // When: JSON에서 Todo 생성
      final todo = Todo.fromJson(json);

      // Then: Todo가 올바르게 생성되었는지 확인
      expect(todo.id, '1');
      expect(todo.title, '테스트 할일');
      expect(todo.description, '테스트 설명');
      expect(todo.completed, false);
      expect(todo.priority, TodoPriority.high);
    });
  });
}
