import 'package:flutter/material.dart';
import 'package:flutter_calender/constants/app_constants.dart';
import 'package:flutter_calender/constants/priority_colors.dart';
import 'package:flutter_calender/models/todo.dart';
import 'package:flutter_calender/providers/category_provider.dart';
import 'package:flutter_calender/providers/todo_provider.dart';
import 'package:flutter_calender/utils/date_utils.dart' as korean_date;
import 'package:flutter_calender/widgets/todo_input_dialog.dart';
import 'package:provider/provider.dart';

/// Todo 상세 보기 다이얼로그를 표시합니다.
Future<void> showTodoDetailDialog(BuildContext context, Todo todo) {
  return showDialog(
    context: context,
    builder: (_) => TodoDetailDialog(todo: todo),
  );
}

class TodoDetailDialog extends StatefulWidget {
  final Todo todo;

  const TodoDetailDialog({super.key, required this.todo});

  @override
  State<TodoDetailDialog> createState() => _TodoDetailDialogState();
}

class _TodoDetailDialogState extends State<TodoDetailDialog> {
  late Todo _todo;

  @override
  void initState() {
    super.initState();
    _todo = widget.todo;
  }

  Future<void> _toggleComplete() async {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    await provider.toggleTodo(_todo.id);
    if (mounted) {
      setState(() {
        _todo = _todo.copyWith(completed: !_todo.completed);
      });
    }
  }

  Future<void> _deleteTodo() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('할일 삭제'),
        content: const Text('이 할일을 삭제하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final provider = Provider.of<TodoProvider>(context, listen: false);
    await provider.deleteTodo(_todo.id);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _goToEdit() async {
    Navigator.of(context).pop();
    await showTodoInputDialog(context, todo: _todo);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final priorityColor = PriorityColors.getColor(_todo.priority);

    final dateStr = korean_date.KoreanDateUtils.formatKoreanDateWithWeekday(
      _todo.date,
    );

    final isDueOverdue = _todo.isOverdue;
    final isDueToday = _todo.isDueToday;

    return Dialog(
      backgroundColor: cs.surface,
      insetPadding: AppConstants.dialogInsetPadding,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppConstants.dialogBorderRadius,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight:
              MediaQuery.of(context).size.height *
              AppConstants.dialogMinHeightRatio,
          maxHeight:
              MediaQuery.of(context).size.height *
              AppConstants.dialogMaxHeightRatio,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: AppConstants.headerPadding,
              decoration: BoxDecoration(
                color: priorityColor.withAlpha(
                  AppConstants.alphaSemiTransparent,
                ),
                border: Border(
                  left: AppConstants.borderSideEmphasis(priorityColor),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingVerticalSmall,
                            vertical: AppConstants.paddingVerticalTiny,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor.withAlpha(
                              AppConstants.alphaMedium,
                            ),
                            borderRadius: AppConstants.chipBorderRadius,
                            border: Border.all(
                              color: priorityColor.withAlpha(
                                AppConstants.alphaVeryOpaque,
                              ),
                              width: AppConstants.borderWidth,
                            ),
                          ),
                          child: Text(
                            PriorityColors.label(_todo.priority),
                            style: TextStyle(
                              fontSize: AppConstants.fontSizeSmall,
                              fontWeight: AppConstants.fontWeightBold,
                              color: priorityColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppConstants.spacing),
                        Text(
                          _todo.title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: AppConstants.fontWeightBold,
                            color: cs.onSurface,
                            decoration: _todo.completed
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _goToEdit,
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: AppConstants.iconSize,
                    ),
                    tooltip: '수정',
                    style: IconButton.styleFrom(
                      foregroundColor: cs.onSurfaceVariant,
                      backgroundColor: cs.surfaceContainerHighest,
                      minimumSize: AppConstants.buttonMinSizeBox,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: AppConstants.contentPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      iconColor: cs.primary,
                      child: Text(
                        dateStr,
                        style: textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface,
                          fontWeight: AppConstants.fontWeightNormal,
                        ),
                      ),
                    ),

                    if (_todo.todoTime != null) ...[
                      const SizedBox(height: AppConstants.spacingMedium),
                      _InfoRow(
                        icon: Icons.access_time_outlined,
                        iconColor: cs.primary,
                        child: Text(
                          _todo.todoTime!.format(context),
                          style: textTheme.bodyMedium?.copyWith(
                            color: cs.onSurface,
                            fontWeight: AppConstants.fontWeightNormal,
                          ),
                        ),
                      ),
                    ],

                    if (_todo.dueDate != null) ...[
                      const SizedBox(height: AppConstants.spacingMedium),
                      _InfoRow(
                        icon: Icons.flag_outlined,
                        iconColor: isDueOverdue
                            ? Colors.red
                            : isDueToday
                            ? Colors.orange
                            : cs.primary,
                        child: Row(
                          children: [
                            Text(
                              korean_date.KoreanDateUtils.formatKoreanDate(
                                _todo.dueDate!,
                              ),
                              style: textTheme.bodyMedium?.copyWith(
                                color: isDueOverdue
                                    ? Colors.red
                                    : isDueToday
                                    ? Colors.orange
                                    : cs.onSurface,
                                fontWeight: AppConstants.fontWeightNormal,
                              ),
                            ),
                            if (isDueOverdue) ...[
                              const SizedBox(width: AppConstants.spacingSmall),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.spacingSmall,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withAlpha(
                                    AppConstants.alphaTransparent,
                                  ),
                                  borderRadius: AppConstants.chipBorderRadius,
                                  border: Border.all(
                                    color: Colors.red.withAlpha(
                                      AppConstants.alphaOpaque,
                                    ),
                                    width: AppConstants.borderWidth,
                                  ),
                                ),
                                child: const Text(
                                  '기한 초과',
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizeTiny,
                                    fontWeight: AppConstants.fontWeightBold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ] else if (isDueToday) ...[
                              const SizedBox(width: AppConstants.spacingSmall),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.spacingSmall,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withAlpha(
                                    AppConstants.alphaTransparent,
                                  ),
                                  borderRadius: AppConstants.chipBorderRadius,
                                  border: Border.all(
                                    color: Colors.orange.withAlpha(
                                      AppConstants.alphaOpaque,
                                    ),
                                    width: AppConstants.borderWidth,
                                  ),
                                ),
                                child: const Text(
                                  '오늘까지',
                                  style: TextStyle(
                                    fontSize: AppConstants.fontSizeTiny,
                                    fontWeight: AppConstants.fontWeightBold,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    if (_todo.categoryId != null) ...[
                      const SizedBox(height: AppConstants.spacingMedium),
                      Consumer<CategoryProvider>(
                        builder: (context, categoryProvider, _) {
                          final category = categoryProvider.getById(
                            _todo.categoryId,
                          );
                          if (category == null) return const SizedBox.shrink();
                          return _InfoRow(
                            icon: category.icon,
                            iconColor: category.color,
                            expand: false,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.spacing,
                                vertical: AppConstants.paddingVerticalTiny,
                              ),
                              decoration: BoxDecoration(
                                color: category.color.withAlpha(30),
                                borderRadius: AppConstants.chipBorderRadius,
                                border: Border.all(
                                  color: category.color.withAlpha(
                                    AppConstants.alphaOpaque,
                                  ),
                                  width: AppConstants.borderWidth,
                                ),
                              ),
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: AppConstants.fontSize,
                                  fontWeight: AppConstants.fontWeightSemiBold,
                                  color: category.color,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],

                    const SizedBox(height: AppConstants.spacingMedium),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _toggleComplete,
                        child: _InfoRow(
                          icon: _todo.completed
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          iconColor: _todo.completed
                              ? Colors.green
                              : cs.outline,
                          child: Text(
                            _todo.completed ? '완료됨' : '미완료',
                            style: textTheme.bodyMedium?.copyWith(
                              color: _todo.completed
                                  ? Colors.green
                                  : cs.onSurfaceVariant,
                              fontWeight: AppConstants.fontWeightNormal,
                            ),
                          ),
                        ),
                      ),
                    ),

                    if (_todo.description != null &&
                        _todo.description!.isNotEmpty) ...[
                      const SizedBox(height: AppConstants.spacingLarge),
                      Divider(
                        color: cs.outlineVariant.withAlpha(100),
                        height: 1,
                      ),
                      const SizedBox(height: AppConstants.spacingLarge),
                      _InfoRow(
                        icon: Icons.notes_rounded,
                        iconColor: cs.onSurfaceVariant,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        child: Text(
                          _todo.description!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: AppConstants.dividerHeight,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            Divider(height: 1, color: cs.outlineVariant.withAlpha(80)),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingHorizontalSmall,
                4,
                AppConstants.paddingHorizontalSmall,
                AppConstants.paddingHorizontalSmall,
              ),
              child: Row(
                children: [
                  TextButton.icon(
                    onPressed: _deleteTodo,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('삭제'),
                    style: TextButton.styleFrom(
                      foregroundColor: cs.error,
                      padding: AppConstants.smallPadding,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: AppConstants.buttonPadding,
                    ),
                    child: const Text('닫기'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final CrossAxisAlignment crossAxisAlignment;

  /// false 로 설정하면 child 를 Expanded 로 감싸지 않아
  /// 컨텐츠 크기만큼만 차지합니다 (예: 카테고리 칩).
  final bool expand;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.child,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: AppConstants.spacingMedium),
        if (expand) Expanded(child: child) else child,
      ],
    );
  }
}
