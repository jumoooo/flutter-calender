import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 커스텀 날짜 선택 다이얼로그
//
// todo_input_screen 에서 사용하던 날짜 선택 다이얼로그를 공용 위젯으로 분리.
// showCustomDatePicker() 함수를 통해 어디서든 호출 가능.
// ─────────────────────────────────────────────────────────────────────────────

/// 커스텀 날짜 선택 다이얼로그를 표시하고 선택된 날짜를 반환합니다.
///
/// 취소 또는 바깥 터치 시 null 반환.
Future<DateTime?> showCustomDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
}) {
  return showDialog<DateTime>(
    context: context,
    builder: (_) => CustomDatePickerDialog(
      initialDate: initialDate,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
    ),
  );
}

/// 커스텀 날짜 선택 다이얼로그 위젯
///
/// 캘린더 뷰 ↔ 텍스트 입력 뷰를 슬라이드 애니메이션으로 전환합니다.
class CustomDatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const CustomDatePickerDialog({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<CustomDatePickerDialog> createState() => _CustomDatePickerDialogState();
}

class _CustomDatePickerDialogState extends State<CustomDatePickerDialog>
    with SingleTickerProviderStateMixin {
  late DateTime _selectedDate;

  /// 캘린더에서 현재 표시 중인 월 (날짜 선택과 독립적으로 관리)
  late DateTime _calendarMonth;

  /// 현재 입력 모드 여부 (false = 캘린더, true = 텍스트 입력)
  bool _isInputMode = false;

  late AnimationController _slideController;

  /// 캘린더: 보임(0,0) → 왼쪽으로 슬라이드 아웃(-1,0)
  late Animation<Offset> _calendarSlideAnim;

  /// 입력 필드: 오른쪽 밖(1,0) → 보임(0,0)
  late Animation<Offset> _inputSlideAnim;

  final _inputController = TextEditingController();
  final _inputFocusNode = FocusNode();
  String? _inputError;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _calendarMonth = DateTime(
      widget.initialDate.year,
      widget.initialDate.month,
    );
    _inputController.text = _formatForInput(_selectedDate);

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _calendarSlideAnim =
        Tween<Offset>(begin: Offset.zero, end: const Offset(-1.0, 0)).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );

    _inputSlideAnim =
        Tween<Offset>(begin: const Offset(1.0, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  // ─── 유틸리티 ─────────────────────────────────────────────────────────────

  /// 날짜 → "YYYY.MM.DD" 형식 문자열
  String _formatForInput(DateTime date) =>
      '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';

  /// 요일 인덱스 (0 = 일, 6 = 토)
  int _weekdayIndex(DateTime date) => date.weekday % 7;

  /// 요일별 색상 (일=빨강, 토=파랑, 그 외=fallback)
  Color _weekdayColor(int weekdayIndex, {Color? fallback, required BuildContext ctx}) {
    if (weekdayIndex == 0) return Colors.red;
    if (weekdayIndex == 6) return Colors.blue;
    return fallback ?? Theme.of(ctx).colorScheme.onSurface;
  }

  // ─── 모드 전환 ────────────────────────────────────────────────────────────

  void _switchToInputMode() {
    _inputController.text = _formatForInput(_selectedDate);
    _inputError = null;
    setState(() => _isInputMode = true);
    _slideController.forward().then((_) {
      if (mounted) _inputFocusNode.requestFocus();
    });
  }

  void _switchToCalendarMode() {
    _tryParseInput(silent: true);
    setState(() => _isInputMode = false);
    _slideController.reverse();
  }

  // ─── 입력 파싱 ────────────────────────────────────────────────────────────

  bool _tryParseInput({bool silent = false}) {
    final text = _inputController.text.trim();
    try {
      final parts = text.split(RegExp(r'[./\-\s]'));
      if (parts.length >= 3) {
        final y = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        final d = int.parse(parts[2]);
        final parsed = DateTime(y, m, d);
        if (!parsed.isBefore(widget.firstDate) && !parsed.isAfter(widget.lastDate)) {
          setState(() {
            _selectedDate = parsed;
            _calendarMonth = DateTime(parsed.year, parsed.month);
            _inputError = null;
          });
          return true;
        } else {
          if (!silent) {
            setState(() => _inputError = '선택 가능 범위를 벗어났습니다');
          }
          return false;
        }
      }
    } catch (_) {}
    if (!silent) {
      setState(() => _inputError = '올바른 형식으로 입력해 주세요 (예: 2026.03.15)');
    }
    return false;
  }

  // ─── 확인 / 월 이동 ───────────────────────────────────────────────────────

  void _confirm() {
    if (_isInputMode) {
      if (_tryParseInput()) Navigator.of(context).pop(_selectedDate);
    } else {
      Navigator.of(context).pop(_selectedDate);
    }
  }

  void _prevMonth() => setState(() {
    _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month - 1);
  });

  void _nextMonth() => setState(() {
    _calendarMonth = DateTime(_calendarMonth.year, _calendarMonth.month + 1);
  });

  // ─── 달력 그리드 ──────────────────────────────────────────────────────────

  List<DateTime> _generateMonthDays(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final firstDayWeekday = firstDay.weekday % 7; // 일요일 = 0

    final days = <DateTime>[];
    for (var i = firstDayWeekday - 1; i >= 0; i--) {
      days.add(firstDay.subtract(Duration(days: i + 1)));
    }
    for (var d = 1; d <= lastDay.day; d++) {
      days.add(DateTime(month.year, month.month, d));
    }
    final remaining = 7 - (days.length % 7);
    if (remaining < 7) {
      for (var d = 1; d <= remaining; d++) {
        days.add(DateTime(month.year, month.month + 1, d));
      }
    }
    return days;
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildCustomCalendar() {
    const weekdayLabels = ['일', '월', '화', '수', '목', '금', '토'];
    final today = DateTime.now();
    final days = _generateMonthDays(_calendarMonth);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── 월 네비게이션 ──
        Row(
          children: [
            IconButton(
              onPressed: _prevMonth,
              icon: const Icon(Icons.chevron_left),
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: Center(
                child: Text(
                  '${_calendarMonth.year}년 ${_calendarMonth.month}월',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ),
            IconButton(
              onPressed: _nextMonth,
              icon: const Icon(Icons.chevron_right),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),

        // ── 요일 헤더 ──
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: List.generate(7, (i) {
              return Expanded(
                child: Center(
                  child: Text(
                    weekdayLabels[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _weekdayColor(i, ctx: context),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // ── 날짜 그리드 ──
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1.1,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final date = days[index];
              final isCurrentMonth = date.month == _calendarMonth.month;
              final isSelected = _isSameDay(date, _selectedDate);
              final isToday = _isSameDay(date, today);
              final wIdx = _weekdayIndex(date);
              final cs = Theme.of(context).colorScheme;

              // 텍스트 색상 (일=빨강, 토=파랑, 그 외=colorScheme 기반)
              Color textColor;
              if (wIdx == 0) {
                textColor = Colors.red.withAlpha(isCurrentMonth ? 255 : 100);
              } else if (wIdx == 6) {
                textColor = Colors.blue.withAlpha(isCurrentMonth ? 255 : 100);
              } else {
                textColor = isSelected
                    ? cs.primary
                    : isCurrentMonth
                        ? cs.onSurface
                        : cs.onSurface.withAlpha(80);
              }

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                    if (!isCurrentMonth) {
                      _calendarMonth = DateTime(date.year, date.month);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? cs.primary.withAlpha(40)
                        : !isCurrentMonth
                            ? cs.onSurface.withAlpha(15)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? cs.primary
                          : cs.outlineVariant.withAlpha(60),
                      width: isSelected ? 2 : 0.5,
                    ),
                  ),
                  child: Center(
                    child: isToday
                        ? Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: cs.onSurface,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: cs.surface,
                              ),
                            ),
                          )
                        : Text(
                            '${date.day}',
                            style: TextStyle(fontSize: 13, color: textColor),
                          ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ─── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final wIdx = _weekdayIndex(_selectedDate);
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekdayLabel = weekdays[_selectedDate.weekday - 1];
    final headerWeekdayColor = wIdx == 0
        ? Colors.red[200]!
        : wIdx == 6
            ? Colors.lightBlue[200]!
            : Colors.white;

    return Dialog(
      backgroundColor: cs.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── 헤더 ──
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
            color: cs.primary,
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '날짜 선택',
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.white.withAlpha((255 * 0.75).round()),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        children: [
                          TextSpan(
                            text: '${_selectedDate.month}월 ${_selectedDate.day}일 ',
                          ),
                          TextSpan(
                            text: '($weekdayLabel)',
                            style: TextStyle(color: headerWeekdayColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  onPressed: _isInputMode ? _switchToCalendarMode : _switchToInputMode,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _isInputMode ? Icons.calendar_month : Icons.edit_outlined,
                      key: ValueKey(_isInputMode),
                      color: Colors.white,
                    ),
                  ),
                  tooltip: _isInputMode ? '캘린더로 전환' : '직접 입력',
                ),
              ],
            ),
          ),

          // ── 콘텐츠 (슬라이드 전환) ──
          ClipRect(
            child: Stack(
              children: [
                IgnorePointer(
                  ignoring: _isInputMode,
                  child: SlideTransition(
                    position: _calendarSlideAnim,
                    child: _buildCustomCalendar(),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: !_isInputMode,
                    child: SlideTransition(
                      position: _inputSlideAnim,
                      child: ColoredBox(
                        color: cs.surface,
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                            child: TextField(
                              controller: _inputController,
                              focusNode: _inputFocusNode,
                              keyboardType: TextInputType.datetime,
                              decoration: InputDecoration(
                                labelText: '날짜',
                                hintText: 'YYYY.MM.DD',
                                errorText: _inputError,
                                border: const OutlineInputBorder(),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                              ),
                              onChanged: (_) {
                                if (_inputError != null) {
                                  setState(() => _inputError = null);
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 하단 버튼 ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text('취소'),
                ),
                const SizedBox(width: 4),
                TextButton(
                  onPressed: _confirm,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text('확인'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
