import 'package:flutter/material.dart';
import 'package:flutter_calender/providers/todo_provider.dart';
import 'package:flutter_calender/utils/date_utils.dart' as korean_date;
import 'package:flutter_calender/widgets/todo_item.dart';
import 'package:provider/provider.dart';

/// 할일 다이얼로그
/// 
/// 특정 날짜의 할일 목록을 표시하고 관리하는 다이얼로그입니다.
class TodoDialog extends StatelessWidget {
  /// 표시할 날짜
  final DateTime date;

  const TodoDialog({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        final todos = todoProvider.getTodosByDate(date);

        return Dialog(
          child: Container(
            width: double.maxFinite,
            constraints: const BoxConstraints(maxHeight: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 헤더
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        korean_date.KoreanDateUtils.formatKoreanDate(date),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pushNamed(
                            '/todo-input',
                            arguments: date,
                          );
                        },
                        tooltip: '할일 추가',
                      ),
                    ],
                  ),
                ),
                
                // 할일 목록
                Flexible(
                  child: todos.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.event_note,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '할일이 없습니다',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: todos.length,
                          itemBuilder: (context, index) {
                            return TodoItem(todo: todos[index]);
                          },
                        ),
                ),
                
                // 닫기 버튼
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('닫기'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
