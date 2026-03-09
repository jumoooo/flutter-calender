import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_calender/constants/app_constants.dart';
import 'package:flutter_calender/constants/priority_colors.dart';
import 'package:flutter_calender/models/todo.dart';
import 'package:flutter_calender/providers/category_provider.dart';
import 'package:flutter_calender/providers/todo_provider.dart';
import 'package:flutter_calender/utils/date_utils.dart' as korean_date;
import 'package:flutter_calender/widgets/common/snackbar_helper.dart';
import 'package:flutter_calender/widgets/custom_date_picker_dialog.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 할일 추가/수정 다이얼로그
//
// showTodoInputDialog() 함수를 통해 어디서든 호출 가능.
// 제목, 설명, 날짜, 시간, 기한, 우선순위, 카테고리를 입력/수정합니다.
// ─────────────────────────────────────────────────────────────────────────────

/// 할일 추가/수정 다이얼로그를 표시합니다.
///
/// [todo] 가 있으면 수정 모드, 없으면 추가 모드.
/// [initialDate] 는 추가 모드에서 기본 날짜로 사용됩니다.
Future<void> showTodoInputDialog(
  BuildContext context, {
  Todo? todo,
  DateTime? initialDate,
}) {
  return showDialog(
    context: context,
    // 입력 다이얼로그는 바깥 터치로 닫히지 않도록
    barrierDismissible: false,
    builder: (_) => TodoInputDialog(todo: todo, initialDate: initialDate),
  );
}

class TodoInputDialog extends StatefulWidget {
  final Todo? todo;
  final DateTime? initialDate;

  const TodoInputDialog({super.key, this.todo, this.initialDate});

  @override
  State<TodoInputDialog> createState() => _TodoInputDialogState();
}

class _TodoInputDialogState extends State<TodoInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleFocusNode = FocusNode();

  late DateTime _selectedDate;
  late TodoPriority _selectedPriority;

  // 새로 추가된 필드
  String? _selectedCategoryId;
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedTime;

  // 경고 스트림 구독
  StreamSubscription<int>? _warningSubscription;

  bool get _isEditMode => widget.todo != null;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      // 수정 모드: 기존 데이터 바인딩
      _titleController.text = widget.todo!.title;
      _descriptionController.text = widget.todo!.description ?? '';
      _selectedDate = widget.todo!.date;
      _selectedPriority = widget.todo!.priority;
      _selectedCategoryId = widget.todo!.categoryId;
      _selectedDueDate = widget.todo!.dueDate;
      _selectedTime = widget.todo!.todoTime;
    } else {
      // 추가 모드
      _selectedDate = widget.initialDate ?? DateTime.now();
      _selectedPriority = TodoPriority.normal;
      // 다이얼로그 열린 후 제목 필드에 자동 포커스
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _titleFocusNode.requestFocus();
      });
    }

    // 경고 스트림 구독 (할일 개수 경고)
    final provider = Provider.of<TodoProvider>(context, listen: false);
    _warningSubscription = provider.warningStream.listen((count) {
      if (mounted) {
        _showWarningDialog(count, provider.maxTodoCount);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    _warningSubscription?.cancel();
    super.dispose();
  }

  // ─── 경고 다이얼로그 ──────────────────────────────────────────────────────────

  /// 할일 개수 경고 다이얼로그 표시
  Future<void> _showWarningDialog(int currentCount, int? maxCount) async {
    if (maxCount == null) return;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('할일 개수 경고'),
          ],
        ),
        content: Text(
          '현재 할일 개수가 $currentCount개입니다.\n'
          '제한($maxCount개)에 가까워지고 있습니다.\n\n'
          '일부 할일을 완료하거나 삭제하는 것을 권장합니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // ─── 저장 ─────────────────────────────────────────────────────────────────

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = Provider.of<TodoProvider>(context, listen: false);
    try {
      if (_isEditMode) {
        final updated = widget.todo!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          date: _selectedDate,
          priority: _selectedPriority,
          categoryId: _selectedCategoryId,
          dueDate: _selectedDueDate,
          todoTime: _selectedTime,
          // 명시적으로 null 지우기 플래그
          clearDescription: _descriptionController.text.trim().isEmpty,
          clearCategoryId: _selectedCategoryId == null,
          clearDueDate: _selectedDueDate == null,
          clearTodoTime: _selectedTime == null,
        );
        await provider.updateTodo(updated);
      } else {
        final newTodo = Todo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          date: _selectedDate,
          priority: _selectedPriority,
          categoryId: _selectedCategoryId,
          dueDate: _selectedDueDate,
          todoTime: _selectedTime,
        );
        await provider.addTodo(newTodo);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        // 할일 개수 제한 초과 에러인 경우 특별 처리
        final errorMessage = e.toString().contains('할일 개수 제한')
            ? '할일 개수 제한(${provider.maxTodoCount ?? '제한 없음'}개)에 도달했습니다.\n일부 할일을 삭제한 후 다시 시도해주세요.'
            : '저장 중 오류가 발생했습니다.';

        // 에러 메시지 표시
        SnackbarHelper.showError(context, errorMessage);
      }
    }
  }

  // ─── 삭제 ─────────────────────────────────────────────────────────────────

  Future<void> _delete() async {
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
    try {
      await provider.deleteTodo(widget.todo!.id);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      // 에러는 스트림으로 처리됨
    }
  }

  // ─── 날짜 선택 ────────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showCustomDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  // ─── 기한(dueDate) 선택 ────────────────────────────────────────────────────

  Future<void> _pickDueDate() async {
    final picked = await showCustomDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDueDate = picked);
    }
  }

  // ─── 시간 선택 ────────────────────────────────────────────────────────────

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setState(() => _selectedTime = picked);
    }
  }

  // ─── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final priorityColor = PriorityColors.getColor(_selectedPriority);

    // 날짜 요일 정보
    final weekday = _selectedDate.weekday % 7;
    final isSunday = weekday == 0;
    final isSaturday = weekday == 6;
    final weekdayLabel = korean_date.KoreanDateUtils.getKoreanWeekday(
      _selectedDate,
    );
    final dateStr = korean_date.KoreanDateUtils.formatKoreanDate(_selectedDate);
    final lunarStr = korean_date.KoreanDateUtils.getLunarDescription(
      _selectedDate,
    );

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
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 헤더 ─────────────────────────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              decoration: BoxDecoration(
                color: priorityColor.withAlpha(26),
                border: Border(
                  left: BorderSide(color: priorityColor, width: 4),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isEditMode ? Icons.edit_outlined : Icons.add_task_rounded,
                    color: priorityColor,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _isEditMode ? '할일 수정' : '새 할일',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            // ── 본문 (스크롤 가능) ────────────────────────────────────────
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목 입력
                      TextFormField(
                        controller: _titleController,
                        focusNode: _titleFocusNode,
                        decoration: InputDecoration(
                          labelText: '제목',
                          hintText: '할일 제목을 입력하세요',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: priorityColor,
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.title_rounded,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        textInputAction: TextInputAction.next,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? '제목을 입력해주세요'
                            : null,
                      ),

                      const SizedBox(height: 14),

                      // 설명 입력
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: '설명 (선택)',
                          hintText: '할일 설명을 입력하세요',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: priorityColor,
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.notes_rounded,
                            color: cs.onSurfaceVariant,
                            size: 20,
                          ),
                        ),
                        maxLines: 3,
                        textInputAction: TextInputAction.newline,
                      ),

                      const SizedBox(height: 14),

                      // ── 날짜 선택 ─────────────────────────────────────
                      _PickerRow(
                        icon: Icons.calendar_today_outlined,
                        iconColor: cs.primary,
                        onTap: _pickDate,
                        child: RichText(
                          text: TextSpan(
                            style: textTheme.bodyMedium?.copyWith(
                              color: cs.onSurface,
                            ),
                            children: [
                              TextSpan(text: dateStr),
                              TextSpan(
                                text: ' ($weekdayLabel)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isSunday
                                      ? Colors.red
                                      : isSaturday
                                      ? Colors.blue
                                      : cs.onSurface,
                                ),
                              ),
                              TextSpan(
                                text: '  $lunarStr',
                                style: textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── 시간 선택 ─────────────────────────────────────
                      _PickerRow(
                        icon: Icons.access_time_outlined,
                        iconColor: cs.primary,
                        onTap: _pickTime,
                        trailingClear: _selectedTime != null
                            ? () => setState(() => _selectedTime = null)
                            : null,
                        child: Text(
                          _selectedTime != null
                              ? _selectedTime!.format(context)
                              : '시간 없음',
                          style: textTheme.bodyMedium?.copyWith(
                            color: _selectedTime != null
                                ? cs.onSurface
                                : cs.onSurfaceVariant,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // ── 기한 선택 ─────────────────────────────────────
                      Builder(
                        builder: (context) {
                          final isOverdue =
                              _selectedDueDate != null &&
                              _selectedDueDate!.isBefore(
                                DateTime(
                                  DateTime.now().year,
                                  DateTime.now().month,
                                  DateTime.now().day,
                                ),
                              );
                          return _PickerRow(
                            icon: Icons.flag_outlined,
                            iconColor: isOverdue ? Colors.red : cs.primary,
                            borderColor: isOverdue
                                ? Colors.red.withAlpha(180)
                                : null,
                            onTap: _pickDueDate,
                            trailingClear: _selectedDueDate != null
                                ? () => setState(() => _selectedDueDate = null)
                                : null,
                            child: Text(
                              _selectedDueDate != null
                                  ? korean_date
                                        .KoreanDateUtils.formatKoreanDate(
                                      _selectedDueDate!,
                                    )
                                  : '기한 없음',
                              style: textTheme.bodyMedium?.copyWith(
                                color: isOverdue
                                    ? Colors.red
                                    : _selectedDueDate != null
                                    ? cs.onSurface
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 18),

                      // ── 우선순위 레이블 ────────────────────────────────
                      Text(
                        '우선순위',
                        style: textTheme.labelLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // 우선순위 선택 — 5개 버튼 한 줄
                      Row(
                        children: TodoPriority.values.map((p) {
                          final isSelected = _selectedPriority == p;
                          final color = PriorityColors.getColor(p);
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 3,
                              ),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _selectedPriority = p),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 150),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? color.withAlpha(40)
                                          : cs.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected
                                            ? color
                                            : cs.outlineVariant.withAlpha(80),
                                        width: isSelected ? 2 : 0.8,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.circle,
                                          size: 10,
                                          color: color,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          // 중앙화된 label 메서드 사용
                                          PriorityColors.label(p),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w400,
                                            color: isSelected
                                                ? color
                                                : cs.onSurfaceVariant,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 18),

                      // ── 카테고리 선택 ──────────────────────────────────
                      Text(
                        '카테고리',
                        style: textTheme.labelLarge?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Consumer<CategoryProvider>(
                        builder: (context, categoryProvider, _) {
                          return Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              // "없음" 선택 칩
                              _CategoryChip(
                                label: '없음',
                                isSelected: _selectedCategoryId == null,
                                color: cs.outlineVariant,
                                onTap: () =>
                                    setState(() => _selectedCategoryId = null),
                              ),
                              // 카테고리 칩 목록
                              ...categoryProvider.categories.map(
                                (cat) => _CategoryChip(
                                  label: cat.name,
                                  icon: cat.icon,
                                  isSelected: _selectedCategoryId == cat.id,
                                  color: cat.color,
                                  onTap: () => setState(
                                    () => _selectedCategoryId = cat.id,
                                  ),
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
            ),

            // ── 하단 버튼 ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  // 수정 모드: 삭제 버튼
                  if (_isEditMode)
                    TextButton.icon(
                      onPressed: _delete,
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('삭제'),
                      style: TextButton.styleFrom(
                        foregroundColor: cs.error,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                    ),
                  const Spacer(),
                  // 취소
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 4),
                  // 저장
                  FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: priorityColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(_isEditMode ? '수정 완료' : '추가'),
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
// 날짜/시간/기한 선택 공통 행 위젯
// ─────────────────────────────────────────────────────────────────────────────
class _PickerRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color? borderColor;
  final VoidCallback onTap;
  final VoidCallback? trailingClear; // X 버튼 (null이면 → 화살표 표시)
  final Widget child;

  const _PickerRow({
    required this.icon,
    required this.iconColor,
    required this.onTap,
    required this.child,
    this.borderColor,
    this.trailingClear,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor ?? cs.outlineVariant, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 12),
            Expanded(child: child),
            if (trailingClear != null)
              GestureDetector(
                onTap: trailingClear,
                child: Icon(Icons.clear, size: 16, color: cs.onSurfaceVariant),
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: cs.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 카테고리 선택 칩 위젯
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withAlpha(36)
                : cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: isSelected ? color : cs.outlineVariant.withAlpha(80),
              width: isSelected ? 1.5 : 0.8,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 13,
                  color: isSelected ? color : cs.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  color: isSelected ? color : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
