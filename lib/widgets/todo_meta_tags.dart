import 'package:flutter/material.dart';
import 'package:flutter_calender/constants/app_constants.dart';
import 'package:flutter_calender/models/category.dart';
import 'package:flutter_calender/models/todo.dart';
import 'package:flutter_calender/utils/date_utils.dart' as korean_date;

/// 할일의 카테고리·시간·기한을 미니 칩 태그 행으로 표시하는 공용 위젯.
///
/// 세 필드가 모두 null이면 빈 `SizedBox`를 반환합니다.
class TodoMetaTagsRow extends StatelessWidget {
  final Todo todo;

  /// CategoryProvider에서 미리 조회한 Category 객체 (없으면 null)
  final Category? category;

  const TodoMetaTagsRow({super.key, required this.todo, this.category});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tags = <Widget>[];

    if (category != null) {
      tags.add(
        _MiniTag(
          label: category!.name,
          color: category!.color,
          icon: category!.icon,
        ),
      );
    }

    if (todo.todoTime != null) {
      tags.add(
        _MiniTag(
          label: todo.todoTime!.format(context),
          color: cs.primary,
          icon: Icons.access_time_outlined,
        ),
      );
    }

    if (todo.dueDate != null) {
      final dueColor = todo.isOverdue
          ? Colors.red
          : todo.isDueToday
          ? Colors.orange
          : cs.onSurfaceVariant;
      tags.add(
        _MiniTag(
          label: korean_date.KoreanDateUtils.formatKoreanDate(todo.dueDate!),
          color: dueColor,
          icon: Icons.flag_outlined,
        ),
      );
    }

    if (tags.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 4, runSpacing: 2, children: tags);
  }
}

class _MiniTag extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _MiniTag({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppConstants.microPadding,
      decoration: BoxDecoration(
        color: color.withAlpha(AppConstants.alphaVeryTransparent),
        borderRadius: AppConstants.chipBorderRadius,
        border: Border.all(
          color: color.withAlpha(120),
          width: AppConstants.borderWidthThin,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 9, color: color),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: color,
              fontWeight: AppConstants.fontWeightSemiBold,
            ),
          ),
        ],
      ),
    );
  }
}
