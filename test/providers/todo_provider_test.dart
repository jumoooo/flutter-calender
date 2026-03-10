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
      final todo = Todo(id: '1', title: '테스트 할일', date: DateTime(2026, 3, 15));

      // When: 할일 추가
      await provider.addTodo(todo);

      // Then: 할일이 추가되었는지 확인
      expect(provider.todos.length, 1);
      expect(provider.todos.first.id, '1');
    });

    test('특정 날짜의 할일 목록 조회 테스트', () async {
      // Given: 여러 날짜의 할일들
      final todo1 = Todo(id: '1', title: '할일 1', date: DateTime(2026, 3, 15));
      final todo2 = Todo(id: '2', title: '할일 2', date: DateTime(2026, 3, 15));
      final todo3 = Todo(id: '3', title: '할일 3', date: DateTime(2026, 3, 20));

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
      final todo = Todo(id: '1', title: '원래 제목', date: DateTime(2026, 3, 15));
      await provider.addTodo(todo);

      // When: 할일 업데이트
      final updatedTodo = todo.copyWith(title: '업데이트된 제목');
      await provider.updateTodo(updatedTodo);

      // Then: 할일이 업데이트되었는지 확인
      expect(provider.todos.first.title, '업데이트된 제목');
    });

    test('할일 삭제 테스트', () async {
      // Given: 할일 추가
      final todo = Todo(id: '1', title: '삭제될 할일', date: DateTime(2026, 3, 15));
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
      final todo = Todo(id: '1', title: '할일', date: DateTime(2026, 3, 15));
      await provider.addTodo(todo);

      // When: 날짜 변경
      final newDate = DateTime(2026, 3, 20);
      await provider.moveTodo('1', newDate);

      // Then: 날짜가 변경되었는지 확인
      expect(provider.todos.first.date, newDate);
    });

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
        await provider.addTodo(
          Todo(id: '1', title: '할일', date: date, completed: false),
        );
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

    group('할일 개수 제한 경고 테스트', () {
      test('기본 제한값 확인', () {
        // Given: 새 Provider
        // When: 제한값 확인
        // Then: 기본값이 100개인지 확인
        expect(provider.maxTodoCount, 100);
      });

      test('제한값 설정 및 조회', () {
        // Given: 새 Provider
        // When: 제한값을 50으로 설정
        provider.setMaxTodoCount(50);
        // Then: 제한값이 50으로 변경되었는지 확인
        expect(provider.maxTodoCount, 50);

        // When: 제한값을 null로 설정 (제한 없음)
        provider.setMaxTodoCount(null);
        // Then: 제한값이 null인지 확인
        expect(provider.maxTodoCount, null);
      });

      test('제한 초과 시 할일 추가 실패', () async {
        // Given: 제한값을 5로 설정하고 5개의 할일 추가
        provider.setMaxTodoCount(5);
        for (int i = 0; i < 5; i++) {
          await provider.addTodo(
            Todo(id: 'todo_$i', title: '할일 $i', date: DateTime(2026, 3, 15)),
          );
        }
        expect(provider.todoCount, 5);

        // When: 6번째 할일 추가 시도
        // Then: 예외가 발생하고 할일이 추가되지 않아야 함
        expect(
          () => provider.addTodo(
            Todo(id: 'todo_6', title: '할일 6', date: DateTime(2026, 3, 15)),
          ),
          throwsException,
        );
        expect(provider.todoCount, 5); // 여전히 5개
      });

      test('경고 임계값 도달 시 경고 스트림 알림', () async {
        // Given: 제한값을 100으로 설정 (기본값)
        provider.setMaxTodoCount(100);
        // 경고 임계값은 AppConfig.todoCountWarningThreshold = 80

        bool warningReceived = false;
        final subscription = provider.warningStream.listen((count) {
          warningReceived = true;
          expect(count, greaterThanOrEqualTo(80));
        });

        // When: 80개의 할일 추가 (경고 임계값 도달)
        for (int i = 0; i < 80; i++) {
          await provider.addTodo(
            Todo(id: 'todo_$i', title: '할일 $i', date: DateTime(2026, 3, 15)),
          );
        }

        // Then: 경고 스트림에 알림이 전송되었는지 확인
        // 약간의 지연을 주어 스트림이 처리되도록 함
        await Future.delayed(const Duration(milliseconds: 100));
        expect(warningReceived, true);
        await subscription.cancel();
      });

      test('제한 없음 설정 시 무제한 추가 가능', () async {
        // Given: 제한값을 null로 설정
        provider.setMaxTodoCount(null);

        // When: 많은 할일 추가 (예: 200개)
        for (int i = 0; i < 200; i++) {
          await provider.addTodo(
            Todo(id: 'todo_$i', title: '할일 $i', date: DateTime(2026, 3, 15)),
          );
        }

        // Then: 모든 할일이 추가되었는지 확인
        expect(provider.todoCount, 200);
      });

      test('현재 할일 개수 조회', () async {
        // Given: 할일이 없는 상태
        expect(provider.todoCount, 0);

        // When: 3개의 할일 추가
        for (int i = 0; i < 3; i++) {
          await provider.addTodo(
            Todo(id: 'todo_$i', title: '할일 $i', date: DateTime(2026, 3, 15)),
          );
        }

        // Then: 할일 개수가 3개인지 확인
        expect(provider.todoCount, 3);
      });
    });

    group('일괄 삭제 테스트', () {
      test('여러 할일 일괄 삭제 성공', () async {
        // Given: 5개의 할일 추가
        final todoIds = <String>[];
        for (int i = 0; i < 5; i++) {
          final todo = Todo(
            id: 'todo_$i',
            title: '할일 $i',
            date: DateTime(2026, 3, 15),
          );
          await provider.addTodo(todo);
          todoIds.add(todo.id);
        }
        expect(provider.todoCount, 5);

        // When: 3개의 할일 일괄 삭제
        final deletedCount = await provider.deleteTodos(todoIds.sublist(0, 3));

        // Then: 삭제된 개수 확인
        expect(deletedCount, 3);
        expect(provider.todoCount, 2);
      });

      test('일괄 삭제 후 undo 스택 확인', () async {
        // Given: 3개의 할일 추가
        final todoIds = <String>[];
        for (int i = 0; i < 3; i++) {
          final todo = Todo(
            id: 'todo_$i',
            title: '할일 $i',
            date: DateTime(2026, 3, 15),
          );
          await provider.addTodo(todo);
          todoIds.add(todo.id);
        }

        // When: 일괄 삭제 (undo 스택에 추가)
        await provider.deleteTodos(todoIds, addToUndoStack: true);

        // Then: undo 가능 여부 확인
        expect(provider.canUndo, true);
        expect(provider.todoCount, 0);
      });

      test('빈 리스트 삭제 시 0 반환', () async {
        // When: 빈 리스트로 일괄 삭제
        final deletedCount = await provider.deleteTodos([]);

        // Then: 0 반환
        expect(deletedCount, 0);
      });

      test('존재하지 않는 ID 삭제 시 무시', () async {
        // Given: 2개의 할일 추가
        final todo1 = Todo(
          id: 'todo_1',
          title: '할일 1',
          date: DateTime(2026, 3, 15),
        );
        final todo2 = Todo(
          id: 'todo_2',
          title: '할일 2',
          date: DateTime(2026, 3, 15),
        );
        await provider.addTodo(todo1);
        await provider.addTodo(todo2);

        // When: 존재하는 ID와 존재하지 않는 ID를 함께 삭제
        final deletedCount = await provider.deleteTodos([
          'todo_1',
          'nonexistent_id',
          'todo_2',
        ]);

        // Then: 존재하는 ID만 삭제됨
        expect(deletedCount, 2);
        expect(provider.todoCount, 0);
      });
    });
  });
}
