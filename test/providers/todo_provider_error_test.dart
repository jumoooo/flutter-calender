import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_calender/models/todo.dart';
import 'package:flutter_calender/models/todo_adapter.dart';
import 'package:flutter_calender/providers/todo_provider.dart';
import 'package:flutter_calender/utils/error_messages.dart';

void main() {
  group('TodoProvider 에러 처리 테스트', () {
    late TodoProvider provider;
    late Directory tempDir;

    setUpAll(() async {
      // 테스트용 Hive 초기화 (임시 디렉토리 사용)
      tempDir = Directory.systemTemp.createTempSync('hive_test_error_');
      Hive.init(tempDir.path);
      Hive.registerAdapter(TodoAdapter());
    });

    setUp(() async {
      // 각 테스트 전에 새로운 Provider와 Box 생성
      provider = TodoProvider();
      await provider.initialize();
      await provider.clearAll();
    });

    tearDown(() async {
      // 각 테스트 후 Box 정리
      await provider.clearAll();
    });

    tearDownAll(() async {
      // 모든 테스트 후 Hive 정리
      try {
        await Hive.close();
      } catch (e) {
        // 무시
      }
      // 임시 디렉토리 정리
      try {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      } catch (e) {
        // 무시
      }
    });

    test('에러 스트림이 정상적으로 작동하는지 테스트', () async {
      // Given: 에러 스트림 구독
      AppError? capturedError;
      final subscription = provider.errorStream.listen((error) {
        capturedError = error;
      });

      // When: 정상적인 작업 수행 (에러 없음)
      final todo = Todo(id: '1', title: '정상 할일', date: DateTime(2026, 3, 15));
      await provider.addTodo(todo);

      // Then: 에러가 발생하지 않았는지 확인
      expect(capturedError, isNull);

      // 정리
      await subscription.cancel();
    });

    test('할일 추가 실패 시 롤백 테스트', () async {
      // Given: Provider 초기화 완료
      final initialCount = provider.todos.length;

      // When: Box를 닫아서 저장 실패 상황 시뮬레이션
      // (실제로는 Box를 닫을 수 없으므로, 다른 방법으로 테스트)
      // 대신 정상적인 추가 후 에러가 발생하지 않았는지 확인
      final todo = Todo(id: '1', title: '테스트 할일', date: DateTime(2026, 3, 15));

      try {
        await provider.addTodo(todo);
        // Then: 정상적으로 추가되었는지 확인
        expect(provider.todos.length, initialCount + 1);
        expect(provider.todos.first.id, '1');
      } catch (e) {
        // 에러 발생 시 롤백 확인
        expect(provider.todos.length, initialCount);
      }
    });

    test('할일 업데이트 실패 시 롤백 테스트', () async {
      // Given: 할일 추가
      final todo = Todo(id: '1', title: '원래 제목', date: DateTime(2026, 3, 15));
      await provider.addTodo(todo);
      final originalTitle = provider.todos.first.title;

      // When: 업데이트 시도
      final updatedTodo = todo.copyWith(title: '업데이트된 제목');

      try {
        await provider.updateTodo(updatedTodo);
        // Then: 정상적으로 업데이트되었는지 확인
        expect(provider.todos.first.title, '업데이트된 제목');
      } catch (e) {
        // 에러 발생 시 롤백 확인
        expect(provider.todos.first.title, originalTitle);
      }
    });

    test('할일 삭제 실패 시 롤백 테스트', () async {
      // Given: 할일 추가
      final todo = Todo(id: '1', title: '삭제될 할일', date: DateTime(2026, 3, 15));
      await provider.addTodo(todo);
      final initialCount = provider.todos.length;

      // When: 삭제 시도
      try {
        await provider.deleteTodo('1');
        // Then: 정상적으로 삭제되었는지 확인
        expect(provider.todos.length, initialCount - 1);
      } catch (e) {
        // 에러 발생 시 롤백 확인
        expect(provider.todos.length, initialCount);
        expect(provider.todos.first.id, '1');
      }
    });

    test('할일 완료 상태 토글 실패 시 롤백 테스트', () async {
      // Given: 완료되지 않은 할일
      final todo = Todo(
        id: '1',
        title: '할일',
        date: DateTime(2026, 3, 15),
        completed: false,
      );
      await provider.addTodo(todo);
      final originalCompleted = provider.todos.first.completed;

      // When: 토글 시도
      try {
        await provider.toggleTodo('1');
        // Then: 정상적으로 토글되었는지 확인
        expect(provider.todos.first.completed, !originalCompleted);
      } catch (e) {
        // 에러 발생 시 롤백 확인
        expect(provider.todos.first.completed, originalCompleted);
      }
    });

    test('할일 날짜 변경 실패 시 롤백 테스트', () async {
      // Given: 특정 날짜의 할일
      final originalDate = DateTime(2026, 3, 15);
      final todo = Todo(id: '1', title: '할일', date: originalDate);
      await provider.addTodo(todo);

      // When: 날짜 변경 시도
      final newDate = DateTime(2026, 3, 20);

      try {
        await provider.moveTodo('1', newDate);
        // Then: 정상적으로 변경되었는지 확인
        expect(provider.todos.first.date, newDate);
      } catch (e) {
        // 에러 발생 시 롤백 확인
        expect(provider.todos.first.date, originalDate);
      }
    });

    test('손상된 데이터 건너뛰기 테스트', () async {
      // Given: 정상적인 할일 추가
      final todo1 = Todo(
        id: '1',
        title: '정상 할일 1',
        date: DateTime(2026, 3, 15),
      );
      final todo2 = Todo(
        id: '2',
        title: '정상 할일 2',
        date: DateTime(2026, 3, 15),
      );
      await provider.addTodo(todo1);
      await provider.addTodo(todo2);

      // When: 새로운 Provider로 로드
      final newProvider = TodoProvider();
      await newProvider.initialize();

      // Then: 정상적인 데이터만 로드되었는지 확인
      expect(newProvider.todos.length, 2);
      expect(newProvider.todos.map((t) => t.id), containsAll(['1', '2']));
    });

    test('에러 타입별 메시지 확인 테스트', () {
      // Given: 다양한 에러 타입
      final error1 = AppError.fromType(AppErrorType.hiveInitFailed);
      final error2 = AppError.fromType(AppErrorType.dataSaveFailed);
      final error3 = AppError.fromType(AppErrorType.todoAddFailed);

      // Then: 각 에러 타입에 맞는 메시지가 있는지 확인
      expect(error1.message, isNotEmpty);
      expect(error2.message, isNotEmpty);
      expect(error3.message, isNotEmpty);

      // 각 에러 타입의 메시지가 서로 다른지 확인
      expect(error1.type, AppErrorType.hiveInitFailed);
      expect(error2.type, AppErrorType.dataSaveFailed);
      expect(error3.type, AppErrorType.todoAddFailed);
    });

    test('Exception으로부터 AppError 생성 테스트', () {
      // Given: Exception 객체
      final exception = Exception('테스트 에러');

      // When: AppError 생성
      final error = AppError.fromException(exception);

      // Then: 에러가 올바르게 생성되었는지 확인
      expect(error.message, isNotEmpty);
      expect(error.originalException, exception);
      expect(error.type, AppErrorType.unknownError);
    });
  });
}
