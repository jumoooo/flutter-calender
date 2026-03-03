import 'package:flutter/material.dart';
import 'package:flutter_calender/models/todo.dart';
import 'package:flutter_calender/providers/calendar_provider.dart';
import 'package:flutter_calender/providers/todo_provider.dart';
import 'package:flutter_calender/utils/date_utils.dart' as korean_date;
import 'package:provider/provider.dart';

/// 캘린더 날짜 셀 위젯
/// 
/// 캘린더의 각 날짜를 표시하는 셀입니다.
class CalendarDateCell extends StatelessWidget {
  /// 표시할 날짜
  final DateTime date;
  
  /// 선택된 날짜인지 여부
  final bool isSelected;
  
  /// 현재 월에 속하는 날짜인지 여부
  final bool isCurrentMonth;
  
  /// 드래그 타겟으로 사용할지 여부
  final bool isDragTarget;

  /// 달력만 표시 모드에서, 셀 안에 간단한 일정 텍스트(약 5글자)를 보여줄지 여부
  final bool showMiniTodoPreview;

  const CalendarDateCell({
    super.key,
    required this.date,
    this.isSelected = false,
    this.isCurrentMonth = true,
    this.isDragTarget = false,
    this.showMiniTodoPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        // 해당 날짜의 할일 목록
        final todos = todoProvider.getTodosByDate(date);
        final hasTodos = todos.isNotEmpty;
        final completedCount = todos.where((t) => t.completed).length;
        final isToday = korean_date.KoreanDateUtils.isToday(date);

        return DragTarget<Todo>(
          onAcceptWithDetails: (details) {
            // 드롭 시 날짜 변경
            final todo = details.data;
            todoProvider.moveTodo(todo.id, date);
          },
          builder: (context, candidateData, rejectedData) {
            final isDragOver = candidateData.isNotEmpty;
            
            return GestureDetector(
              onTap: () {
                // 날짜 선택만 수행 (하단 일정 영역이 갱신됨)
                Provider.of<CalendarProvider>(context, listen: false)
                    .selectDate(date);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(
                    isSelected,
                    isToday,
                    isDragOver,
                    isCurrentMonth,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).primaryColor
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Builder(
                  builder: (context) {
                    // 요일 확인 (일요일 = 0, 토요일 = 6)
                    final weekday = date.weekday % 7;
                    final isSunday = weekday == 0;
                    final isSaturday = weekday == 6;

                    return Padding(
                      padding: const EdgeInsets.all(4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 날짜 번호 (맨 위에 위치, 가로 중앙 정렬)
                          if (isToday)
                            // 오늘 날짜: 동그라미(검정 배경 + 흰색 숫자)로 강조
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${date.day}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          else
                            Center(
                              child: Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isToday
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  // 일요일은 빨간색, 토요일은 파란색으로 표시
                                  color: isSunday
                                      ? Colors.red
                                      : isSaturday
                                          ? Colors.blue
                                          : _getTextColor(
                                              isSelected,
                                              isToday,
                                              isDragOver,
                                              isCurrentMonth,
                                            ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
                        // 할일 표시
                        if (hasTodos)
                          Builder(
                            builder: (context) {
                              if (showMiniTodoPreview) {
                                // 달력만 모드: 여러 일정을 왼쪽 색상 바와 함께 표시
                                // 최대 3개까지만 표시하고 나머지는 생략
                                final maxDisplayCount = 3;
                                final displayTodos = todos.take(maxDisplayCount).toList();
                                final hasMore = todos.length > maxDisplayCount;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ...displayTodos.map((todo) {
                                      final priorityColor = _getPriorityColor(todo.priority);
                                      final title = todo.title;
                                      final preview = title.length > 5
                                          ? '${title.substring(0, 5)}…'
                                          : title;

                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 2),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // 왼쪽 색상 바 (|)
                                            Container(
                                              width: 2,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: priorityColor,
                                                borderRadius: BorderRadius.circular(1),
                                              ),
                                            ),
                                            const SizedBox(width: 3),
                                            // 일정 제목
                                            Flexible(
                                              child: Text(
                                                preview,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  color: Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                    // 더 많은 일정이 있을 때 표시
                                    if (hasMore)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 5),
                                        child: Text(
                                          '+${todos.length - maxDisplayCount}',
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              }

                              // 기본 모드: 점 두 개로 완료/미완료 표시
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // 완료된 할일 개수
                                  if (completedCount > 0)
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  // 미완료 할일 개수
                                  if (todos.length - completedCount > 0)
                                    Container(
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 배경색 결정
  Color _getBackgroundColor(
    bool isSelected,
    bool isToday,
    bool isDragOver,
    bool isCurrentMonth,
  ) {
    if (isDragOver) {
      return Colors.blue.withValues(alpha: 0.3);
    }
    if (isSelected) {
      return Colors.blue.withValues(alpha: 0.2);
    }
    // 오늘 날짜는 동그라미 배경을 따로 사용하므로 셀 배경은 투명하게 유지
    if (!isCurrentMonth) {
      return Colors.grey.withValues(alpha: 0.1);
    }
    return Colors.transparent;
  }

  /// 텍스트 색상 결정
  Color _getTextColor(
    bool isSelected,
    bool isToday,
    bool isDragOver,
    bool isCurrentMonth,
  ) {
    if (isDragOver) {
      return Colors.blue;
    }
    if (isSelected || isToday) {
      return Colors.blue;
    }
    if (!isCurrentMonth) {
      return Colors.grey;
    }
    return Colors.black;
  }

  /// 우선순위별 색상 (calendar_widget.dart와 동일한 색상 사용)
  Color _getPriorityColor(TodoPriority priority) {
    switch (priority) {
      case TodoPriority.veryHigh:
        return const Color(0xFFFF8A80); // 파스텔 레드
      case TodoPriority.high:
        return const Color(0xFFFFB74D); // 파스텔 오렌지
      case TodoPriority.normal:
        return const Color(0xFFFFF176); // 파스텔 옐로우
      case TodoPriority.low:
        return const Color(0xFFA5D6A7); // 파스텔 그린
      case TodoPriority.veryLow:
        return const Color(0xFFB0BEC5); // 파스텔 블루그레이
    }
  }
}
