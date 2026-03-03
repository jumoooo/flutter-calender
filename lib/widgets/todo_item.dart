import 'package:flutter/material.dart';
import 'package:flutter_calender/models/todo.dart';
import 'package:flutter_calender/providers/todo_provider.dart';
import 'package:provider/provider.dart';

/// 할일 아이템 위젯
/// 
/// 할일을 표시하고 드래그 가능하게 만드는 위젯입니다.
class TodoItem extends StatelessWidget {
  /// 표시할 할일
  final Todo todo;

  const TodoItem({
    super.key,
    required this.todo,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<Todo>(
      data: todo,
      feedback: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            todo.title,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
      child: Consumer<TodoProvider>(
        builder: (context, todoProvider, child) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              leading: Checkbox(
                value: todo.completed,
                onChanged: (value) {
                  todoProvider.toggleTodo(todo.id);
                },
              ),
              title: Text(
                todo.title,
                style: TextStyle(
                  decoration: todo.completed
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              subtitle: todo.description != null
                  ? Text(todo.description!)
                  : null,
              trailing: _getPriorityIcon(todo.priority),
              onTap: () {
                // 할일 수정 페이지로 이동
                Navigator.of(context).pushNamed(
                  '/todo-input',
                  arguments: todo,
                );
              },
            ),
          );
        },
      ),
    );
  }

  /// 우선순위 아이콘 반환
  Widget? _getPriorityIcon(TodoPriority priority) {
    Color color;
    String label;

    switch (priority) {
      case TodoPriority.veryHigh:
        color = const Color(0xFFFF8A80); // 파스텔 레드
        label = '최상';
        break;
      case TodoPriority.high:
        color = const Color(0xFFFFB74D); // 파스텔 오렌지
        label = '상';
        break;
      case TodoPriority.normal:
        color = const Color(0xFFFFF176); // 파스텔 옐로우
        label = '중';
        break;
      case TodoPriority.low:
        color = const Color(0xFFA5D6A7); // 파스텔 그린
        label = '하';
        break;
      case TodoPriority.veryLow:
        color = const Color(0xFFB0BEC5); // 파스텔 블루그레이
        label = '최하';
        break;
    }

    // 리스트 우측에 작고 정갈한 칩으로 표시
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.7), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
