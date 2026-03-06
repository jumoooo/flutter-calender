import 'package:flutter/material.dart';
import 'package:flutter_calender/constants/priority_colors.dart';
import 'package:flutter_calender/models/todo.dart';
import 'package:flutter_calender/providers/category_provider.dart';
import 'package:flutter_calender/providers/todo_provider.dart';
import 'package:flutter_calender/utils/date_utils.dart' as korean_date;
import 'package:flutter_calender/widgets/todo_input_dialog.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Todo 상세보기 다이얼로그
//
// 기존 할일을 팝업으로 확인하는 전용 다이얼로그.
// 우측 상단 펜 아이콘으로 수정 화면으로 이동 가능.
// ─────────────────────────────────────────────────────────────────────────────

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

  // ─── 완료 토글 ────────────────────────────────────────────────────────────
  Future<void> _toggleComplete() async {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    await provider.toggleTodo(_todo.id);
    if (mounted) {
      setState(() {
        _todo = _todo.copyWith(completed: !_todo.completed);
      });
    }
  }

  // ─── 삭제 ─────────────────────────────────────────────────────────────────
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

  // ─── 수정 다이얼로그 열기 ────────────────────────────────────────────────
  Future<void> _goToEdit() async {
    Navigator.of(context).pop();
    await showTodoInputDialog(context, todo: _todo);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final priorityColor = PriorityColors.getColor(_todo.priority);

    // 날짜 포맷: KoreanDateUtils로 통일 (intl.DateFormat 직접 사용 제거)
    final dateStr = korean_date.KoreanDateUtils.formatKoreanDateWithWeekday(_todo.date);

    // 기한 초과 여부 판단
    final isDueOverdue = _todo.isOverdue;
    final isDueToday = _todo.isDueToday;

    return Dialog(
      backgroundColor: cs.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height * 0.55,
          maxHeight: MediaQuery.of(context).size.height * 0.80,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 헤더: 우선순위 색상 강조 바 + 수정 버튼 ──────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 12, 16),
              decoration: BoxDecoration(
                color: priorityColor.withAlpha(26),
                border: Border(
                  left: BorderSide(color: priorityColor, width: 4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 우선순위 뱃지 — 중앙화된 label 메서드 사용
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: priorityColor.withAlpha(36),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: priorityColor.withAlpha(180),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            PriorityColors.label(_todo.priority),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: priorityColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // 제목
                        Text(
                          _todo.title,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
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
                  // 수정 버튼
                  IconButton(
                    onPressed: _goToEdit,
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    tooltip: '수정',
                    style: IconButton.styleFrom(
                      foregroundColor: cs.onSurfaceVariant,
                      backgroundColor: cs.surfaceContainerHighest,
                      minimumSize: const Size(36, 36),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),

            // ── 본문 ──────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 날짜 — 요일 포함 통일 포맷
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      iconColor: cs.primary,
                      child: Text(
                        dateStr,
                        style: textTheme.bodyMedium?.copyWith(
                          color: cs.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // 시간 (설정된 경우만)
                    if (_todo.todoTime != null) ...[
                      const SizedBox(height: 10),
                      _InfoRow(
                        icon: Icons.access_time_outlined,
                        iconColor: cs.primary,
                        child: Text(
                          _todo.todoTime!.format(context),
                          style: textTheme.bodyMedium?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],

                    // 기한 (설정된 경우만)
                    if (_todo.dueDate != null) ...[
                      const SizedBox(height: 10),
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
                                  _todo.dueDate!),
                              style: textTheme.bodyMedium?.copyWith(
                                color: isDueOverdue
                                    ? Colors.red
                                    : isDueToday
                                        ? Colors.orange
                                        : cs.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (isDueOverdue) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.withAlpha(24),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                      color: Colors.red.withAlpha(160),
                                      width: 0.8),
                                ),
                                child: const Text(
                                  '기한 초과',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ] else if (isDueToday) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withAlpha(24),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                      color: Colors.orange.withAlpha(160),
                                      width: 0.8),
                                ),
                                child: const Text(
                                  '오늘까지',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],

                    // 카테고리 (설정된 경우만)
                    if (_todo.categoryId != null) ...[
                      const SizedBox(height: 10),
                      Consumer<CategoryProvider>(
                        builder: (context, categoryProvider, _) {
                          final category =
                              categoryProvider.getById(_todo.categoryId);
                          if (category == null) return const SizedBox.shrink();
                          return _InfoRow(
                            icon: category.icon,
                            iconColor: category.color,
                            // 칩 너비를 텍스트 크기에 맞게 제한
                            expand: false,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: category.color.withAlpha(30),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: category.color.withAlpha(160),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                category.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: category.color,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],

                    // 완료 상태 — 클릭으로 토글
                    const SizedBox(height: 10),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _toggleComplete,
                        child: _InfoRow(
                          icon: _todo.completed
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          iconColor:
                              _todo.completed ? Colors.green : cs.outline,
                          child: Text(
                            _todo.completed ? '완료됨' : '미완료',
                            style: textTheme.bodyMedium?.copyWith(
                              color: _todo.completed
                                  ? Colors.green
                                  : cs.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 설명 (있는 경우만)
                    if (_todo.description != null &&
                        _todo.description!.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Divider(
                          color: cs.outlineVariant.withAlpha(100), height: 1),
                      const SizedBox(height: 14),
                      _InfoRow(
                        icon: Icons.notes_rounded,
                        iconColor: cs.onSurfaceVariant,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        child: Text(
                          _todo.description!,
                          style: textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // ── 구분선 ────────────────────────────────────────────────────────
            Divider(
                height: 1,
                color: cs.outlineVariant.withAlpha(80)),

            // ── 하단 버튼 ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  // 삭제 버튼
                  TextButton.icon(
                    onPressed: _deleteTodo,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('삭제'),
                    style: TextButton.styleFrom(
                      foregroundColor: cs.error,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                  const Spacer(),
                  // 닫기 버튼
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
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

// ─────────────────────────────────────────────────────────────────────────────
// 아이콘 + 내용 한 줄 레이아웃
// ─────────────────────────────────────────────────────────────────────────────
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
        const SizedBox(width: 10),
        // expand=false 이면 글자 크기에 맞게 줄어듦
        if (expand) Expanded(child: child) else child,
      ],
    );
  }
}
