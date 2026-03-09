import 'package:flutter/material.dart';
import 'package:flutter_calender/constants/app_constants.dart';
import 'package:flutter_calender/constants/priority_colors.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        final todos = todoProvider.getTodosByDate(date);
        final hasTodos = todos.isNotEmpty;
        final completedCount = todos.where((t) => t.completed).length;
        final isToday = korean_date.KoreanDateUtils.isToday(date);

        // 요일 확인 (일요일 = 0, 토요일 = 6)
        final weekday = date.weekday % 7;
        final isSunday = weekday == 0;
        final isSaturday = weekday == 6;

        return DragTarget<Todo>(
          onAcceptWithDetails: (details) {
            final todo = details.data;
            todoProvider.moveTodo(todo.id, date);
          },
          builder: (context, candidateData, rejectedData) {
            final isDragOver = candidateData.isNotEmpty;

            return GestureDetector(
              onTap: () {
                Provider.of<CalendarProvider>(context, listen: false)
                    .selectDate(date);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: _getBackgroundColor(
                    isSelected,
                    isToday,
                    isDragOver,
                    isCurrentMonth,
                    colorScheme,
                  ),
                  borderRadius: BorderRadius.circular(8),
                  // 선택 시: 진한 테두리 / 미선택 시: 연한 구분선
                  border: Border.all(
                    color: isSelected || isDragOver
                        ? colorScheme.primary
                        : colorScheme.outlineVariant.withValues(alpha: 0.45),
                    width: isSelected || isDragOver
                        ? AppConstants.borderWidthThick
                        : AppConstants.borderWidthThin,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 날짜 번호
                      if (isToday)
                        // 오늘: colorScheme.onSurface 배경 + surface 텍스트 (라이트/다크 자동 대응)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: colorScheme.onSurface,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: AppConstants.fontWeightBold,
                                color: colorScheme.surface,
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
                              fontWeight: FontWeight.normal,
                              // 일=빨강, 토=파랑, 그 외=테마 색상
                              color: isSunday
                                  ? Colors.red
                                  : isSaturday
                                      ? Colors.blue
                                      : _getTextColor(
                                          isSelected,
                                          isDragOver,
                                          isCurrentMonth,
                                          colorScheme,
                                        ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 2),

                      // 할일 표시
                      if (hasTodos)
                        Builder(
                          builder: (context) {
                            if (showMiniTodoPreview) {
                              // 달력만 모드: 색상 바 + 제목 텍스트
                              const maxDisplayCount = 3;
                              final displayTodos =
                                  todos.take(maxDisplayCount).toList();
                              final hasMore = todos.length > maxDisplayCount;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ...displayTodos.map((todo) {
                                    final priorityColor =
                                        _getPriorityColor(todo.priority);
                                    final title = todo.title;
                                    final preview = title.length > 5
                                        ? '${title.substring(0, 5)}…'
                                        : title;

                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 2),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // 왼쪽 색상 바
                                          Container(
                                            width: 2,
                                            height: 10,
                                            decoration: BoxDecoration(
                                              color: priorityColor,
                                              borderRadius:
                                                  BorderRadius.circular(1),
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                          Flexible(
                                            child: Text(
                                              preview,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 9,
                                                // 다크 모드 대응: onSurfaceVariant
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                  if (hasMore)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Text(
                                        '+${todos.length - maxDisplayCount}',
                                        style: TextStyle(
                                          fontSize: 8,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            }

                            // 기본 모드: 완료/미완료 점 표시
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (completedCount > 0)
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: Colors.green[400],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                if (completedCount > 0 &&
                                    todos.length - completedCount > 0)
                                  const SizedBox(width: 2),
                                if (todos.length - completedCount > 0)
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      // primaryContainer: 라이트/다크 모두 잘 보임
                                      color: colorScheme.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 배경색 결정 (다크 모드 대응)
  Color _getBackgroundColor(
    bool isSelected,
    bool isToday,
    bool isDragOver,
    bool isCurrentMonth,
    ColorScheme colorScheme,
  ) {
    if (isDragOver) return colorScheme.primary.withValues(alpha: 0.2);
    if (isSelected) return colorScheme.primary.withValues(alpha: 0.15);
    if (!isCurrentMonth) return colorScheme.onSurface.withValues(alpha: 0.05);
    return Colors.transparent;
  }

  /// 텍스트 색상 결정 (다크 모드 대응)
  Color _getTextColor(
    bool isSelected,
    bool isDragOver,
    bool isCurrentMonth,
    ColorScheme colorScheme,
  ) {
    if (isDragOver || isSelected) return colorScheme.primary;
    if (!isCurrentMonth) return colorScheme.onSurface.withValues(alpha: 0.35);
    return colorScheme.onSurface;
  }

  /// 우선순위별 색상
  Color _getPriorityColor(TodoPriority priority) {
    return PriorityColors.getColor(priority);
  }
}
