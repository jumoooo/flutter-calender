import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_calender/models/todo.dart';
import 'package:flutter_calender/models/todo_adapter.dart';
import 'package:flutter_calender/providers/todo_provider.dart';

void main() {
  group('TodoProvider Hive 통합 테스트', () {
    late TodoProvider provider;
    late Directory tempDir;

    setUpAll(() async {
      // 테스트용 Hive 초기화 (임시 디렉토리 사용)
      tempDir = Directory.systemTemp.createTempSync('hive_test_');
      Hive.init(tempDir.path);
      Hive.registerAdapter(TodoAdapter());
    });

    setUp(() async {
      // 각 테스트 전에 새로운 Provider와 Box 생성
      provider = TodoProvider();
      // 테스트용 Box 초기화
      await provider.initialize();
      // 기존 데이터 정리
      await provider.clearAll();
    });

    tearDown(() async {
      // 각 테스트 후 Box 정리
      await provider.clearAll();
    });

    tearDownAll(() async {
      // 모든 테스트 후 Hive 정리
      await Hive.close();
      // 임시 디렉토리 정리
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('Hive 초기화 및 할일 로드 테스트', () async {
      // Given: 할일 추가
      final todo = Todo(id: '1', title: '테스트 할일', date: DateTime(2026, 3, 15));
      await provider.addTodo(todo);

      // When: 새로운 Provider로 다시 초기화
      final newProvider = TodoProvider();
      await newProvider.initialize();

      // Then: 이전에 저장한 할일이 로드되었는지 확인
      expect(newProvider.todos.length, 1);
      expect(newProvider.todos.first.id, '1');
      expect(newProvider.todos.first.title, '테스트 할일');

      // 정리
      await newProvider.clearAll();
    });

    test('할일 추가 및 Hive 저장 테스트', () async {
      // Given: 새로운 할일
      final todo = Todo(
        id: '1',
        title: 'Hive에 저장될 할일',
        description: '설명',
        date: DateTime(2026, 3, 15),
        completed: false,
        priority: TodoPriority.high,
      );

      // When: 할일 추가
      await provider.addTodo(todo);

      // Then: 메모리에 추가되었는지 확인
      expect(provider.todos.length, 1);
      expect(provider.todos.first.id, '1');
      expect(provider.todos.first.title, 'Hive에 저장될 할일');

      // Then: Hive에 저장되었는지 확인 (새 Provider로 로드)
      final newProvider = TodoProvider();
      await newProvider.initialize();
      expect(newProvider.todos.length, 1);
      expect(newProvider.todos.first.id, '1');
      expect(newProvider.todos.first.title, 'Hive에 저장될 할일');
      expect(newProvider.todos.first.description, '설명');
      expect(newProvider.todos.first.priority, TodoPriority.high);

      // 정리
      await newProvider.clearAll();
    });

    test('할일 업데이트 및 Hive 저장 테스트', () async {
      // Given: 할일 추가
      final todo = Todo(id: '1', title: '원래 제목', date: DateTime(2026, 3, 15));
      await provider.addTodo(todo);

      // When: 할일 업데이트
      final updatedTodo = todo.copyWith(title: '업데이트된 제목', completed: true);
      await provider.updateTodo(updatedTodo);

      // Then: 메모리에서 업데이트 확인
      expect(provider.todos.first.title, '업데이트된 제목');
      expect(provider.todos.first.completed, true);

      // Then: Hive에 저장되었는지 확인
      final newProvider = TodoProvider();
      await newProvider.initialize();
      expect(newProvider.todos.first.title, '업데이트된 제목');
      expect(newProvider.todos.first.completed, true);

      // 정리
      await newProvider.clearAll();
    });

    test('할일 삭제 및 Hive에서 제거 테스트', () async {
      // Given: 여러 할일 추가
      final todo1 = Todo(id: '1', title: '할일 1', date: DateTime(2026, 3, 15));
      final todo2 = Todo(id: '2', title: '할일 2', date: DateTime(2026, 3, 15));
      await provider.addTodo(todo1);
      await provider.addTodo(todo2);

      // When: 할일 삭제
      await provider.deleteTodo('1');

      // Then: 메모리에서 삭제 확인
      expect(provider.todos.length, 1);
      expect(provider.todos.first.id, '2');

      // Then: Hive에서도 삭제되었는지 확인
      final newProvider = TodoProvider();
      await newProvider.initialize();
      expect(newProvider.todos.length, 1);
      expect(newProvider.todos.first.id, '2');

      // 정리
      await newProvider.clearAll();
    });

    test('할일 완료 상태 토글 및 Hive 저장 테스트', () async {
      // Given: 완료되지 않은 할일
      final todo = Todo(
        id: '1',
        title: '할일',
        date: DateTime(2026, 3, 15),
        completed: false,
      );
      await provider.addTodo(todo);

      // When: 완료 상태 토글
      await provider.toggleTodo('1');

      // Then: 메모리에서 상태 변경 확인
      expect(provider.todos.first.completed, true);

      // Then: Hive에 저장되었는지 확인
      final newProvider = TodoProvider();
      await newProvider.initialize();
      expect(newProvider.todos.first.completed, true);

      // When: 다시 토글
      await newProvider.toggleTodo('1');

      // Then: 다시 미완료 상태로 변경
      expect(newProvider.todos.first.completed, false);

      // 정리
      await newProvider.clearAll();
    });

    test('할일 날짜 변경 및 Hive 저장 테스트', () async {
      // Given: 특정 날짜의 할일
      final todo = Todo(id: '1', title: '할일', date: DateTime(2026, 3, 15));
      await provider.addTodo(todo);

      // When: 날짜 변경
      final newDate = DateTime(2026, 3, 20);
      await provider.moveTodo('1', newDate);

      // Then: 메모리에서 날짜 변경 확인
      expect(provider.todos.first.date, newDate);

      // Then: Hive에 저장되었는지 확인
      final newProvider = TodoProvider();
      await newProvider.initialize();
      expect(newProvider.todos.first.date, newDate);

      // 정리
      await newProvider.clearAll();
    });

    test('여러 할일 추가 및 날짜별 조회 테스트', () async {
      // Given: 여러 날짜의 할일들
      final todo1 = Todo(id: '1', title: '할일 1', date: DateTime(2026, 3, 15));
      final todo2 = Todo(id: '2', title: '할일 2', date: DateTime(2026, 3, 15));
      final todo3 = Todo(id: '3', title: '할일 3', date: DateTime(2026, 3, 20));

      // When: 할일들 추가
      await provider.addTodo(todo1);
      await provider.addTodo(todo2);
      await provider.addTodo(todo3);

      // Then: 전체 할일 수 확인
      expect(provider.todos.length, 3);

      // Then: 특정 날짜의 할일만 조회
      final todos15 = provider.getTodosByDate(DateTime(2026, 3, 15));
      expect(todos15.length, 2);
      expect(todos15.map((t) => t.id), containsAll(['1', '2']));

      final todos20 = provider.getTodosByDate(DateTime(2026, 3, 20));
      expect(todos20.length, 1);
      expect(todos20.first.id, '3');

      // Then: Hive에서도 동일하게 로드되는지 확인
      final newProvider = TodoProvider();
      await newProvider.initialize();
      expect(newProvider.todos.length, 3);
      expect(newProvider.getTodosByDate(DateTime(2026, 3, 15)).length, 2);
      expect(newProvider.getTodosByDate(DateTime(2026, 3, 20)).length, 1);

      // 정리
      await newProvider.clearAll();
    });

    test('우선순위별 할일 저장 및 로드 테스트', () async {
      // Given: 다양한 우선순위의 할일들
      final todo1 = Todo(
        id: '1',
        title: '낮은 우선순위',
        date: DateTime(2026, 3, 15),
        priority: TodoPriority.low,
      );
      final todo2 = Todo(
        id: '2',
        title: '높은 우선순위',
        date: DateTime(2026, 3, 15),
        priority: TodoPriority.high,
      );
      final todo3 = Todo(
        id: '3',
        title: '매우 높은 우선순위',
        date: DateTime(2026, 3, 15),
        priority: TodoPriority.veryHigh,
      );

      // When: 할일들 추가
      await provider.addTodo(todo1);
      await provider.addTodo(todo2);
      await provider.addTodo(todo3);

      // Then: 우선순위가 올바르게 저장되었는지 확인
      expect(
        provider.todos.firstWhere((t) => t.id == '1').priority,
        TodoPriority.low,
      );
      expect(
        provider.todos.firstWhere((t) => t.id == '2').priority,
        TodoPriority.high,
      );
      expect(
        provider.todos.firstWhere((t) => t.id == '3').priority,
        TodoPriority.veryHigh,
      );

      // Then: Hive에서도 올바르게 로드되는지 확인
      final newProvider = TodoProvider();
      await newProvider.initialize();
      expect(
        newProvider.todos.firstWhere((t) => t.id == '1').priority,
        TodoPriority.low,
      );
      expect(
        newProvider.todos.firstWhere((t) => t.id == '2').priority,
        TodoPriority.high,
      );
      expect(
        newProvider.todos.firstWhere((t) => t.id == '3').priority,
        TodoPriority.veryHigh,
      );

      // 정리
      await newProvider.clearAll();
    });
  });
}
