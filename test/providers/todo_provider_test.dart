import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_calender/models/todo.dart';
import 'package:flutter_calender/models/todo_adapter.dart';
import 'package:flutter_calender/providers/todo_provider.dart';

void main() {
  group('TodoProvider 테스트', () {
    late TodoProvider provider;
    late Directory tempDir;

    setUpAll(() async {
      // 테스트용 Hive 초기화 (임시 디렉토리 사용)
      tempDir = Directory.systemTemp.createTempSync('hive_test_provider_');
      Hive.init(tempDir.path);
      Hive.registerAdapter(TodoAdapter());
    });

    setUp(() async {
      provider = TodoProvider();
      await provider.initialize();
      await provider.clearAll();
    });

    tearDown(() async {
      await provider.clearAll();
    });

    tearDownAll(() async {
      try {
        await Hive.close();
      } catch (e) {
        // 무시
      }
      try {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      } catch (e) {
        // 무시
      }
    });

    test('할일 추가 테스트', () async {
      // Given: 새로운 할일
      final todo = Todo(
        id: '1',
        title: '테스트 할일',
        date: DateTime(2026, 3, 15),
      );

      // When: 할일 추가
      await provider.addTodo(todo);

      // Then: 할일이 추가되었는지 확인
      expect(provider.todos.length, 1);
      expect(provider.todos.first.id, '1');
    });

    test('특정 날짜의 할일 목록 조회 테스트', () async {
      // Given: 여러 날짜의 할일들
      final todo1 = Todo(
        id: '1',
        title: '할일 1',
        date: DateTime(2026, 3, 15),
      );
      final todo2 = Todo(
        id: '2',
        title: '할일 2',
        date: DateTime(2026, 3, 15),
      );
      final todo3 = Todo(
        id: '3',
        title: '할일 3',
        date: DateTime(2026, 3, 20),
      );

      await provider.addTodo(todo1);
      await provider.addTodo(todo2);
      await provider.addTodo(todo3);

      // When: 특정 날짜의 할일 목록 조회
      final todos = provider.getTodosByDate(DateTime(2026, 3, 15));

      // Then: 해당 날짜의 할일만 반환되는지 확인
      expect(todos.length, 2);
      expect(todos.map((t) => t.id), containsAll(['1', '2']));
    });

    test('할일 업데이트 테스트', () async {
      // Given: 할일 추가
      final todo = Todo(
        id: '1',
        title: '원래 제목',
        date: DateTime(2026, 3, 15),
      );
      await provider.addTodo(todo);

      // When: 할일 업데이트
      final updatedTodo = todo.copyWith(title: '업데이트된 제목');
      await provider.updateTodo(updatedTodo);

      // Then: 할일이 업데이트되었는지 확인
      expect(provider.todos.first.title, '업데이트된 제목');
    });

    test('할일 삭제 테스트', () async {
      // Given: 할일 추가
      final todo = Todo(
        id: '1',
        title: '삭제될 할일',
        date: DateTime(2026, 3, 15),
      );
      await provider.addTodo(todo);

      // When: 할일 삭제
      await provider.deleteTodo('1');

      // Then: 할일이 삭제되었는지 확인
      expect(provider.todos.length, 0);
    });

    test('할일 완료 상태 토글 테스트', () async {
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

      // Then: 완료 상태가 변경되었는지 확인
      expect(provider.todos.first.completed, true);

      // When: 다시 토글
      await provider.toggleTodo('1');

      // Then: 다시 미완료 상태로 변경되었는지 확인
      expect(provider.todos.first.completed, false);
    });

    test('할일 날짜 변경 테스트 (드래그 앤 드롭)', () async {
      // Given: 특정 날짜의 할일
      final todo = Todo(
        id: '1',
        title: '할일',
        date: DateTime(2026, 3, 15),
      );
      await provider.addTodo(todo);

      // When: 날짜 변경
      final newDate = DateTime(2026, 3, 20);
      await provider.moveTodo('1', newDate);

      // Then: 날짜가 변경되었는지 확인
      expect(provider.todos.first.date, newDate);
    });

    // ─── 날짜 인덱스 O(1) 조회 테스트 ─────────────────────────────────────
    group('날짜 인덱스 성능 최적화 테스트', () {
      test('getTodosByDate가 O(1)로 동작 — 추가 후 인덱스 즉시 반영', () async {
        // Given: 여러 날짜에 걸친 할일
        final date1 = DateTime(2026, 3, 1);
        final date2 = DateTime(2026, 3, 2);

        await provider.addTodo(Todo(id: 'a', title: '3월1일', date: date1));
        await provider.addTodo(Todo(id: 'b', title: '3월1일B', date: date1));
        await provider.addTodo(Todo(id: 'c', title: '3월2일', date: date2));

        // Then: 각 날짜별로 정확히 반환
        expect(provider.getTodosByDate(date1).length, 2);
        expect(provider.getTodosByDate(date2).length, 1);
        expect(provider.getTodosByDate(DateTime(2026, 3, 3)).length, 0);
      });

      test('삭제 후 인덱스에서도 제거됨', () async {
        final date = DateTime(2026, 3, 10);
        await provider.addTodo(Todo(id: '1', title: '할일', date: date));
        expect(provider.getTodosByDate(date).length, 1);

        await provider.deleteTodo('1');
        expect(provider.getTodosByDate(date).length, 0);
      });

      test('날짜 변경(moveTodo) 후 인덱스 이동', () async {
        final oldDate = DateTime(2026, 3, 5);
        final newDate = DateTime(2026, 3, 15);

        await provider.addTodo(Todo(id: '1', title: '할일', date: oldDate));
        expect(provider.getTodosByDate(oldDate).length, 1);
        expect(provider.getTodosByDate(newDate).length, 0);

        await provider.moveTodo('1', newDate);

        // 이전 날짜 인덱스에서 제거, 새 날짜 인덱스에 추가
        expect(provider.getTodosByDate(oldDate).length, 0);
        expect(provider.getTodosByDate(newDate).length, 1);
      });

      test('완료 토글 후 인덱스 유지', () async {
        final date = DateTime(2026, 3, 7);
        await provider.addTodo(Todo(id: '1', title: '할일', date: date, completed: false));
        await provider.toggleTodo('1');

        // 날짜는 변경되지 않으므로 인덱스 유지
        final result = provider.getTodosByDate(date);
        expect(result.length, 1);
        expect(result.first.completed, true);
      });

      test('clearAll 후 인덱스 초기화', () async {
        final date = DateTime(2026, 3, 20);
        await provider.addTodo(Todo(id: '1', title: '할일', date: date));
        expect(provider.getTodosByDate(date).length, 1);

        await provider.clearAll();
        expect(provider.getTodosByDate(date).length, 0);
        expect(provider.todos.length, 0);
      });
    });
  });
}
