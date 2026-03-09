import 'package:flutter/material.dart';
import 'package:flutter_calender/constants/app_constants.dart';
import 'package:flutter_calender/constants/priority_colors.dart';
import 'package:flutter_calender/models/todo.dart';
import 'package:flutter_calender/providers/calendar_provider.dart';
import 'package:flutter_calender/providers/category_provider.dart';
import 'package:flutter_calender/providers/todo_provider.dart';
import 'package:flutter_calender/utils/date_utils.dart' as korean_date;
import 'package:flutter_calender/widgets/calendar_date_cell.dart';
import 'package:flutter_calender/widgets/todo_detail_dialog.dart';
import 'package:flutter_calender/widgets/todo_meta_tags.dart';
import 'package:provider/provider.dart';

/// 화면 표시 모드
enum _ViewMode {
  /// 달력 + 일정 (기본)
  both,

  /// 달력만
  calendarOnly,

  /// 일정만
  scheduleOnly,
}

/// 캘린더 위젯
///
/// 한국 기준 월별 캘린더를 표시하는 위젯입니다.
/// 상단 달력/하단 일정 모두 좌우 드래그 시 손가락을 따라 움직이도록
/// 드래그 오프셋을 로컬 상태로 관리합니다.
class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget>
    with SingleTickerProviderStateMixin {
  /// 현재 화면 표시 모드
  _ViewMode _viewMode = _ViewMode.both;

  /// 상단 달력 영역 가로 드래그 오프셋
  double _monthDragOffset = 0;

  /// 하단 일정 영역 가로 드래그 오프셋
  double _dayDragOffset = 0;

  /// 세로 드래그 오프셋 (화면 모드 전환용)
  double _verticalDragOffset = 0;

  /// 상단 달력 뷰포트 가로 폭 (버튼 클릭 애니메이션용)
  double _monthViewportWidth = 0;

  /// 상단 달력 월 전환 애니메이션 컨트롤러
  late final AnimationController _monthAnimationController;

  /// 부드러운 애니메이션을 위한 CurvedAnimation
  late final Animation<double> _monthCurvedAnimation;

  /// 애니메이션 종료 시 목표 오프셋 (양수: 이전 달, 음수: 다음 달)
  double _monthAnimationEndOffset = 0;

  /// 선택 모드 활성화 여부
  bool _isSelectionMode = false;

  /// 선택된 할일 ID 목록
  Set<String> _selectedTodoIds = {};

  @override
  void initState() {
    super.initState();
    _monthAnimationController = AnimationController(
      vsync: this,
      duration: AppConstants.animationDuration,
    );

    _monthCurvedAnimation = CurvedAnimation(
      parent: _monthAnimationController,
      curve: Curves.easeInOutCubic,
    );

    _monthCurvedAnimation.addListener(() {
      // curve가 적용된 값을 목표 오프셋에 곱해 현재 오프셋으로 사용
      setState(() {
        _monthDragOffset =
            _monthAnimationEndOffset * _monthCurvedAnimation.value;
      });
    });

    _monthCurvedAnimation.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        // 애니메이션이 끝난 시점에 실제 월 변경 처리
        final calendarProvider = Provider.of<CalendarProvider>(
          context,
          listen: false,
        );

        if (_monthAnimationEndOffset < 0) {
          // 화면이 왼쪽으로 이동 → 다음 달로 넘어가는 효과
          await calendarProvider.nextMonth();
        } else if (_monthAnimationEndOffset > 0) {
          // 화면이 오른쪽으로 이동 → 이전 달로 넘어가는 효과
          await calendarProvider.previousMonth();
        }

        // 상태 리셋
        _monthAnimationController.reset();
        setState(() {
          _monthDragOffset = 0;
          _monthAnimationEndOffset = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _monthAnimationController.dispose();
    super.dispose();
  }

  /// 선택 모드 토글
  void _toggleSelectionMode() {
    setState(() {
      _isSelectionMode = !_isSelectionMode;
      if (!_isSelectionMode) {
        _selectedTodoIds.clear();
      }
    });
  }

  /// 할일 선택/해제 토글
  void _toggleTodoSelection(String todoId) {
    setState(() {
      if (_selectedTodoIds.contains(todoId)) {
        _selectedTodoIds.remove(todoId);
      } else {
        _selectedTodoIds.add(todoId);
      }
    });
  }

  /// 전체 선택/해제 토글
  void _toggleSelectAll(List<Todo> todos) {
    setState(() {
      if (_selectedTodoIds.length == todos.length) {
        _selectedTodoIds.clear();
      } else {
        _selectedTodoIds = todos.map((t) => t.id).toSet();
      }
    });
  }

  /// 일괄 삭제 확인 다이얼로그 표시
  Future<void> _showBatchDeleteDialog(
    BuildContext context,
    TodoProvider todoProvider,
  ) async {
    final count = _selectedTodoIds.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('일괄 삭제'),
        content: Text('선택한 $count개의 할일을 삭제하시겠어요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    try {
      final deletedCount = await todoProvider.deleteTodos(
        _selectedTodoIds.toList(),
      );

      if (!mounted) return;
      
      setState(() {
        _selectedTodoIds.clear();
        _isSelectionMode = false;
      });

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$deletedCount개의 할일이 삭제되었습니다.'),
          action: todoProvider.canUndo
              ? SnackBarAction(
                  label: '되돌리기',
                  onPressed: () async {
                    await todoProvider.undoLastDelete();
                  },
                )
              : null,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('삭제 중 오류가 발생했습니다: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 상단 달력을 버튼으로 월 전환할 때 사용할 애니메이션 헬퍼
  ///
  /// - [toNext] 가 true 이면 다음 달, false 이면 이전 달로 전환
  Future<void> _animateMonthChange({required bool toNext}) async {
    if (_monthViewportWidth <= 0) {
      // 폭 정보를 아직 모르면 그냥 바로 전환
      final calendarProvider = Provider.of<CalendarProvider>(
        context,
        listen: false,
      );
      if (toNext) {
        await calendarProvider.nextMonth();
      } else {
        await calendarProvider.previousMonth();
      }
      return;
    }

    if (_monthAnimationController.isAnimating) {
      // 이미 애니메이션 중이면 중복 실행 방지
      return;
    }

    // 다음 달: 왼쪽으로 슬라이드, 이전 달: 오른쪽으로 슬라이드
    _monthAnimationEndOffset = toNext
        ? -_monthViewportWidth
        : _monthViewportWidth;
    _monthAnimationController.forward(from: 0);
  }

  /// 공통 드래그 종료 처리 헬퍼
  ///
  /// - offset 이 임계값 이상이면 direction 에 따라 콜백 실행
  /// - 콜백 실행 후에는 오프셋을 0 으로 초기화
  Future<void> _handleHorizontalDragEnd({
    required double offset,
    required Future<void> Function() onSwipeLeft,
    required Future<void> Function() onSwipeRight,
  }) async {
    const threshold = 60.0; // 드래그 판정 임계값 (px)

    // 충분히 움직이지 않으면 이동 처리 없이 종료
    if (offset.abs() < threshold) {
      setState(() {
        _monthDragOffset = 0;
        _dayDragOffset = 0;
      });
      return;
    }

    // 왼쪽으로 더 많이 끌면 → 다음으로 이동
    if (offset < 0) {
      await onSwipeLeft();
    } else {
      await onSwipeRight();
    }

    // 이동 후에는 오프셋 초기화 (AnimatedSwitcher 가 새 화면을 슬라이드)
    setState(() {
      _monthDragOffset = 0;
      _dayDragOffset = 0;
    });
  }

  /// 세로 드래그 종료 처리 헬퍼 (화면 모드 전환)
  ///
  /// 일정이 달력을 덮는 컨셉:
  /// - both 모드에서 일정을 위로 드래그 → scheduleOnly (일정이 달력을 완전히 덮음)
  /// - both 모드에서 일정을 아래로 드래그 → calendarOnly (일정이 내려가서 달력만 보임)
  /// - scheduleOnly 모드에서 일정을 아래로 드래그 → both (일정이 내려가서 달력이 드러남)
  /// - calendarOnly 모드에서 위로 드래그 → both (일정이 올라와서 달력을 덮음)
  void _handleVerticalDragEnd(DragEndDetails details) {
    const threshold = 80.0; // 세로 드래그 판정 임계값 (px)
    final velocityY = details.velocity.pixelsPerSecond.dy;

    // 충분히 움직이지 않으면 원래 상태로 복귀
    if (_verticalDragOffset.abs() < threshold && velocityY.abs() < 200) {
      setState(() {
        _verticalDragOffset = 0;
      });
      return;
    }

    // 아래로 드래그 (양수) → 일정이 내려감
    if (_verticalDragOffset > 0 || velocityY > 200) {
      setState(() {
        if (_viewMode == _ViewMode.scheduleOnly) {
          // 일정만 → 달력+일정 (일정이 내려가서 달력이 드러남)
          _viewMode = _ViewMode.both;
        } else if (_viewMode == _ViewMode.both) {
          // 달력+일정 → 달력만 (일정이 완전히 내려감)
          _viewMode = _ViewMode.calendarOnly;
        }
        // calendarOnly 모드에서는 아래로 드래그 불가 (이미 막혀있음)
        _verticalDragOffset = 0;
      });
    }
    // 위로 드래그 (음수) → 일정이 올라감
    else if (_verticalDragOffset < 0 || velocityY < -200) {
      setState(() {
        if (_viewMode == _ViewMode.calendarOnly) {
          // 달력만 → 달력+일정 (일정이 올라와서 달력을 덮음)
          _viewMode = _ViewMode.both;
        } else if (_viewMode == _ViewMode.both) {
          // 달력+일정 → 일정만 (일정이 완전히 올라가서 달력을 덮음)
          _viewMode = _ViewMode.scheduleOnly;
        } else {
          // 일정만 → 달력+일정 (일정이 내려가서 달력이 드러남)
          _viewMode = _ViewMode.both;
        }
        _verticalDragOffset = 0;
      });
    } else {
      setState(() {
        _verticalDragOffset = 0;
      });
    }
  }

  /// 현재 모드에 따른 일정 영역 높이 비율 (0.0 ~ 1.0)
  double _getScheduleHeightRatio() {
    switch (_viewMode) {
      case _ViewMode.both:
        return 0.5; // 일정이 화면의 절반
      case _ViewMode.calendarOnly:
        return 0.0; // 달력만 표시 (일정 숨김)
      case _ViewMode.scheduleOnly:
        return 1.0; // 일정이 전체 화면 (달력을 완전히 덮음)
    }
  }

  /// 일정 영역의 Y 오프셋 비율 (0.0 ~ 1.0)
  /// 일정만 모드일 때는 0 (화면 맨 위)
  /// 달력+일정 모드일 때는 달력 높이만큼 아래
  double _getScheduleYOffsetRatio() {
    switch (_viewMode) {
      case _ViewMode.both:
        // 달력 높이만큼 아래에 위치 (화면 높이의 50%)
        return 0.5;
      case _ViewMode.calendarOnly:
        return 1.0; // 화면 밖 (보이지 않음)
      case _ViewMode.scheduleOnly:
        return 0.0; // 화면 맨 위 (달력을 완전히 덮음)
    }
  }

  /// 주어진 월 기준으로 6주(42칸)를 채우는 날짜 리스트 생성
  ///
  /// - 이전/다음 달 일부 날짜를 포함하여 항상 6 * 7 그리드를 유지합니다.
  List<DateTime> _generateCalendarDays(DateTime month) {
    final firstDay = korean_date.KoreanDateUtils.getFirstDayOfMonth(month);
    final lastDay = korean_date.KoreanDateUtils.getLastDayOfMonth(month);
    final firstDayWeekday = firstDay.weekday % 7; // 일요일 = 0

    final days = <DateTime>[];

    // 이전 달의 마지막 날들 추가 (첫 주를 채우기 위해)
    final prevMonth = DateTime(month.year, month.month - 1, 1);
    final prevMonthLastDay = korean_date.KoreanDateUtils.getLastDayOfMonth(
      prevMonth,
    );
    for (var i = firstDayWeekday - 1; i >= 0; i--) {
      days.add(
        DateTime(
          prevMonthLastDay.year,
          prevMonthLastDay.month,
          prevMonthLastDay.day - i,
        ),
      );
    }

    // 현재 달의 모든 날짜 추가
    for (var day = firstDay.day; day <= lastDay.day; day++) {
      days.add(DateTime(month.year, month.month, day));
    }

    // 다음 달의 첫 날들 추가 (마지막 주를 채우기 위해)
    final remainingDays = 42 - days.length; // 6주 * 7일 = 42일
    for (var day = 1; day <= remainingDays; day++) {
      days.add(DateTime(month.year, month.month + 1, day));
    }

    return days;
  }

  /// 단일 월 그리드 위젯 생성
  Widget _buildMonthGrid({
    required List<DateTime> calendarDays,
    required DateTime month,
    required DateTime selectedDate,
  }) {
    final isCalendarOnly = _viewMode == _ViewMode.calendarOnly;

    // 달력만 모드일 때: 해당 월의 실제 날짜(최대 31일)만 표시하고,
    // 화면 최하단까지 늘어나며 모든 셀이 같은 크기로 늘어남
    if (isCalendarOnly) {
      return LayoutBuilder(
        builder: (context, constraints) {
          // 최소 셀 높이 계산: 일정 3개가 보일 수 있는 최소 높이
          // 날짜 번호: 약 20px + 패딩 4px = 24px
          // 일정 3개: 각 12px (텍스트 9px + 패딩 2px + 간격) = 약 40px
          // 여유 공간: 8px
          // 총 최소 높이: 약 72px
          const minCellHeight = 72.0;
          const cellMarginVertical =
              8.0; // CalendarDateCell의 상하 margin (3 * 2) + 여유 공간 2px

          // 달력만 모드에서도 기본 모드와 동일하게
          // 현재 월의 마지막 날짜가 포함된 주(week)의 나머지 날짜들(다음 달 날짜)도 표시
          final lastDayOfMonth = korean_date.KoreanDateUtils.getLastDayOfMonth(
            month,
          );
          int? lastDayIndex;
          for (int i = 0; i < calendarDays.length; i++) {
            if (korean_date.KoreanDateUtils.isSameDay(
              calendarDays[i],
              lastDayOfMonth,
            )) {
              lastDayIndex = i;
              break;
            }
          }

          final itemCount = lastDayIndex != null
              ? ((lastDayIndex ~/ 7) + 1) * 7
              : calendarDays.length;

          // 필요한 행 수 계산
          final rowsNeeded = (itemCount / 7).ceil();

          // 최소 높이를 보장하기 위해 필요한 최소 화면 높이 계산
          final minRequiredHeight =
              (minCellHeight + cellMarginVertical) * rowsNeeded;

          // 화면 높이를 최소값 이상으로 제한 (일정 크기 이하로 줄이지 못하게)
          final availableHeight = constraints.maxHeight.clamp(
            minRequiredHeight,
            double.infinity,
          );
          final availableWidth = constraints.maxWidth;

          // 패딩과 간격 고려
          const horizontalPadding = 16.0; // 좌우 패딩
          // CalendarDateCell의 margin으로 간격 처리하므로 GridView spacing은 0

          // 사용 가능한 너비 계산 (패딩 제외)
          final usableWidth = availableWidth - horizontalPadding;

          // 셀 너비 계산 (7개 열, CalendarDateCell margin 2 * 2 = 4 고려)
          // 실제 간격은 CalendarDateCell의 margin으로 처리되므로
          // 사용 가능한 너비를 7로 나눔
          final cellWidth = usableWidth / 7;

          // 최종 셀 높이 계산 (availableHeight는 이미 최소값으로 제한됨)
          final cellHeight =
              ((availableHeight / rowsNeeded) - cellMarginVertical).clamp(
                minCellHeight,
                double.infinity,
              );

          // childAspectRatio 계산 (셀 너비 / 셀 높이)
          final aspectRatio = cellWidth / cellHeight;

          // 해당 월의 실제 날짜만 표시 (최대 31일)
          // 최소 크기 제한을 위해 ConstrainedBox로 감싸기
          return ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: minRequiredHeight,
              maxHeight: availableHeight,
            ),
            child: GridView.builder(
              key: ValueKey('${month.year}-${month.month}-calendarOnly'),
              physics:
                  const NeverScrollableScrollPhysics(), // 스크롤 비활성화 (화면에 맞춤)
              shrinkWrap: true, // 동적 크기 조정을 위해 shrinkWrap 사용
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                // 화면 높이에 맞춰 계산된 비율 사용
                childAspectRatio: aspectRatio,
                // 간격은 CalendarDateCell의 margin으로 처리하므로 0
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
              ),
              itemCount: itemCount, // 현재 월의 마지막 날짜가 포함된 row까지 표시
              itemBuilder: (context, index) {
                final date = calendarDays[index];
                final isSelected = korean_date.KoreanDateUtils.isSameDay(
                  date,
                  selectedDate,
                );

                // 현재 월인지 다음 달인지 판단
                final isCurrentMonth =
                    date.month == month.month && date.year == month.year;

                return CalendarDateCell(
                  date: date,
                  isSelected: isSelected,
                  isCurrentMonth: isCurrentMonth, // 다음 달 날짜는 회색으로 표시
                  isDragTarget: true,
                  // 달력만 모드에서는 미니 일정 프리뷰 표시 (5글자)
                  showMiniTodoPreview: true,
                );
              },
            ),
          );
        },
      );
    }

    // 기본 모드 (달력+일정 또는 일정만): 해당 달의 마지막 날짜가 포함된 row까지만 표시
    // 현재 월의 마지막 날짜를 찾아서 그 row까지만 표시
    final lastDayOfMonth = korean_date.KoreanDateUtils.getLastDayOfMonth(month);
    int? lastDayIndex;
    for (int i = 0; i < calendarDays.length; i++) {
      if (korean_date.KoreanDateUtils.isSameDay(
        calendarDays[i],
        lastDayOfMonth,
      )) {
        lastDayIndex = i;
        break;
      }
    }

    // 마지막 날짜가 포함된 row의 마지막 인덱스 계산 (7의 배수로 올림)
    final itemCount = lastDayIndex != null
        ? ((lastDayIndex ~/ 7) + 1) * 7
        : calendarDays.length;

    return GridView.builder(
      key: ValueKey('${month.year}-${month.month}'),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        // 항상 동일 비율(정사각형)
        childAspectRatio: 1.0,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        final date = calendarDays[index];
        final isCurrentMonth =
            date.month == month.month && date.year == month.year;
        final isSelected = korean_date.KoreanDateUtils.isSameDay(
          date,
          selectedDate,
        );

        return CalendarDateCell(
          date: date,
          isSelected: isSelected,
          isCurrentMonth: isCurrentMonth,
          isDragTarget: true,
          // 기본 모드에서는 점 표시 스타일 사용
          showMiniTodoPreview: false,
        );
      },
    );
  }

  /// 단일 날짜의 일정 컬럼 위젯 생성
  Widget _buildScheduleColumn({
    required BuildContext context,
    required DateTime date,
    required String weekdayLabel,
    required String lunarDescription,
    required List<Todo> todos,
  }) {
    final isScheduleOnly = _viewMode == _ViewMode.scheduleOnly;

    return Consumer<TodoProvider>(
      builder: (context, todoProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 드래그 가능 표시 (회색 작은 가로선)
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // 헤더 행: 날짜 정보 + 정렬/필터 컨트롤
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '선택된 날짜 일정',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // 일정만 모드가 아닐 때만 날짜/요일/음력 표시
                      if (!isScheduleOnly) ...[
                        const SizedBox(height: 4),
                        Builder(
                          builder: (context) {
                            final weekday = date.weekday % 7;
                            final isSunday = weekday == 0;
                            final isSaturday = weekday == 6;

                            return RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodyMedium,
                                children: [
                                  TextSpan(
                                    text: '${date.day}.$weekdayLabel ',
                                    style: TextStyle(
                                      color: isSunday
                                          ? Colors.red
                                          : isSaturday
                                          ? Colors.blue
                                          : null,
                                    ),
                                  ),
                                  TextSpan(
                                    text: lunarDescription,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                // ── 선택 모드 진입 버튼 (선택 모드가 아닐 때만 표시) ─────────────
                if (!_isSelectionMode)
                  IconButton(
                    icon: const Icon(Icons.check_box_outline_blank),
                    tooltip: '선택 모드',
                    onPressed: _toggleSelectionMode,
                  )
                else
                  // ── 선택 모드 헤더 (선택 개수, 전체 선택, 종료 버튼) ─────────
                  Row(
                    children: [
                      Text(
                        '${_selectedTodoIds.length}개 선택',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // 전체 선택/해제 버튼
                      IconButton(
                        icon: Icon(
                          _selectedTodoIds.length == todos.length
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                        ),
                        tooltip: '전체 선택/해제',
                        onPressed: () => _toggleSelectAll(todos),
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 4),
                      // 선택 모드 종료 버튼
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: '선택 모드 종료',
                        onPressed: _toggleSelectionMode,
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                // ── 정렬 + 필터 컨트롤 (선택 모드가 아닐 때만 표시) ─────────────
                if (!_isSelectionMode)
                  _SortFilterButtons(todoProvider: todoProvider),
              ],
            ),

            const SizedBox(height: 8),
            if (todos.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    '등록된 일정이 없습니다.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    final isSelected = _isSelectionMode && _selectedTodoIds.contains(todo.id);
                    return Consumer<CategoryProvider>(
                      builder: (context, categoryProvider, _) {
                        final category =
                            categoryProvider.getById(todo.categoryId);
                        return InkWell(
                          onTap: _isSelectionMode
                              ? () => _toggleTodoSelection(todo.id)
                              : () => showTodoDetailDialog(context, todo),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            // 선택 모드일 때 배경색 변경
                            decoration: isSelected
                                ? BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                        .withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(8),
                                  )
                                : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 2,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // 체크박스 (선택 모드일 때만 표시)
                                  if (_isSelectionMode) ...[
                                    Checkbox(
                                      value: isSelected,
                                      onChanged: (_) => _toggleTodoSelection(todo.id),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  _priorityIcon(todo.priority),
                                  const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        todo.title,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w500,
                                              decoration: todo.completed
                                                  ? TextDecoration.lineThrough
                                                  : null,
                                              color: todo.completed
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant
                                                  : null,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      // 카테고리/시간/기한 메타 태그
                                      if (category != null ||
                                          todo.todoTime != null ||
                                          todo.dueDate != null) ...[
                                        const SizedBox(height: 3),
                                        TodoMetaTagsRow(
                                          todo: todo,
                                          category: category,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (todo.completed)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 16,
                                    color: Colors.green[400],
                                  ),
                              ],
                            ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            // ── 일괄 삭제 버튼 (선택 모드이고 선택된 항목이 있을 때만 표시) ─────
            if (_isSelectionMode && _selectedTodoIds.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedTodoIds.length}개 선택됨',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton.icon(
                      onPressed: () => _showBatchDeleteDialog(context, todoProvider),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('일괄 삭제'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<CalendarProvider, TodoProvider>(
      builder: (context, calendarProvider, todoProvider, child) {
        final currentMonth = calendarProvider.currentMonth;
        final selectedDate = calendarProvider.selectedDate;
        final isTransitioning = calendarProvider.isTransitioning;

        // 현재 월 캘린더에 표시할 날짜 리스트 (6주 고정)
        final calendarDays = _generateCalendarDays(currentMonth);

        // 전체가 아닌, 상단 "달력 영역" 과 하단 "일정 영역" 을 분리해서
        // 제스처를 다르게 처리한다.
        //
        // - 상단 달력: 좌우 스와이프 시 "월 단위"로 이동
        // - 하단 일정: 좌우 스와이프 시 "일 단위"로 이동
        return Column(
          children: [
            // 월 네비게이션 및 월 표시
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      if (_viewMode == _ViewMode.scheduleOnly) {
                        // 일정만 모드: 1일 이전으로 이동
                        calendarProvider.goToPreviousDay();
                      } else {
                        // 기본/달력만 모드: 이전 달로 이동 (애니메이션 포함)
                        _animateMonthChange(toNext: false);
                      }
                    },
                  ),
                  Builder(
                    builder: (context) {
                      if (_viewMode != _ViewMode.scheduleOnly) {
                        // 기본/달력만 모드: "년 월" 형식
                        return Text(
                          calendarProvider.currentMonthFormatted,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        );
                      }
                      // 일정만 모드: "월.일.요일" — 요일에 색상 적용
                      final wd = selectedDate.weekday % 7;
                      final isSun = wd == 0;
                      final isSat = wd == 6;
                      final weekdayLabel =
                          korean_date.KoreanDateUtils.getKoreanWeekday(
                            selectedDate,
                          );
                      return RichText(
                        text: TextSpan(
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text:
                                  '${selectedDate.month}.${selectedDate.day}.',
                            ),
                            TextSpan(
                              text: weekdayLabel,
                              style: TextStyle(
                                color: isSun
                                    ? Colors.red
                                    : isSat
                                        ? Colors.blue
                                        : null,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      if (_viewMode == _ViewMode.scheduleOnly) {
                        // 일정만 모드: 1일 다음으로 이동
                        calendarProvider.goToNextDay();
                      } else {
                        // 기본/달력만 모드: 다음 달로 이동 (애니메이션 포함)
                        _animateMonthChange(toNext: true);
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 요일 헤더 (일정만 모드일 때는 숨김)
            if (_viewMode != _ViewMode.scheduleOnly)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: ['일', '월', '화', '수', '목', '금', '토']
                      .map(
                        (day) => Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: day == '일'
                                        ? Colors.red
                                        : day == '토'
                                        ? Colors.blue
                                        : Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

            if (_viewMode != _ViewMode.scheduleOnly) const SizedBox(height: 8),

            // 전환 중이면 스켈레톤, 아니면 실제 캘린더/일정 표시
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isTransitioning
                    ? const _CalendarSkeleton()
                    : GestureDetector(
                        // 세로 드래그로 화면 모드 전환
                        // 달력만 모드일 때는 아래로 드래그 막기
                        onVerticalDragUpdate: (details) {
                          // 달력만 모드이고 아래로 드래그하는 경우 무시
                          if (_viewMode == _ViewMode.calendarOnly &&
                              details.delta.dy > 0) {
                            return;
                          }
                          setState(() {
                            // 좌우 스와이프처럼, 손가락을 따라 화면이 같이 이동하도록
                            _verticalDragOffset += details.delta.dy;
                          });
                        },
                        onVerticalDragEnd: (details) {
                          _handleVerticalDragEnd(details);
                        },
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final screenHeight = constraints.maxHeight;
                            final scheduleHeight =
                                screenHeight * _getScheduleHeightRatio();
                            final scheduleYOffsetRatio =
                                _getScheduleYOffsetRatio();

                            // 드래그 중일 때는 오프셋을 적용
                            // 일정이 달력을 덮는 컨셉: 일정을 위로 드래그하면 일정만 위로 올라가고 달력은 그대로
                            // 일정만 모드일 때는 top을 0으로 설정하여 요일 헤더까지 덮음 (요일 헤더는 조건부로 숨김)
                            final baseScheduleY =
                                _viewMode == _ViewMode.scheduleOnly
                                ? 0.0 // 일정만 모드: 화면 맨 위부터 시작 (요일 헤더는 숨김)
                                : screenHeight * scheduleYOffsetRatio;
                            final currentScheduleY =
                                baseScheduleY +
                                (_viewMode == _ViewMode.both ||
                                        _viewMode == _ViewMode.scheduleOnly
                                    ? _verticalDragOffset
                                    : 0);

                            // 달력 영역의 높이 계산 (일정 높이를 제외한 나머지)
                            final calendarHeight =
                                screenHeight - scheduleHeight;

                            return Stack(
                              children: [
                                // 달력 영역 (일정 높이에 따라 크기가 변경됨)
                                // 일정만 모드여도 달력은 그대로 있음 (덮혀있을 뿐)
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOutCubic,
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  height: calendarHeight,
                                  child: GestureDetector(
                                    // 상단 달력: 좌우 드래그 시 손가락을 따라 달력이 이동하도록 처리
                                    // 달력만 모드와 기본 모드 모두 월 단위로 이동
                                    onHorizontalDragUpdate: (details) {
                                      setState(() {
                                        // 달력만 모드와 기본 모드 모두 월 단위 드래그
                                        _monthDragOffset += details.delta.dx;
                                      });
                                    },
                                    onHorizontalDragEnd: (details) {
                                      // 달력만 모드와 기본 모드 모두 월 단위 이동
                                      _handleHorizontalDragEnd(
                                        offset: _monthDragOffset,
                                        onSwipeLeft: () =>
                                            calendarProvider.nextMonth(),
                                        onSwipeRight: () =>
                                            calendarProvider.previousMonth(),
                                      );
                                    },
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final width = constraints.maxWidth;
                                        // 버튼/제스처 공통에서 사용할 뷰포트 폭 저장
                                        if (width > 0 &&
                                            _monthViewportWidth != width) {
                                          _monthViewportWidth = width;
                                        }

                                        // 달력만 모드와 기본 모드 모두 월 단위 드래그
                                        final dragOffset = _monthDragOffset;
                                        final isDraggingToNext = dragOffset < 0;

                                        // 월 단위 이동
                                        // 이웃 월 (왼쪽으로 드래그 → 다음 달, 오른쪽으로 드래그 → 이전 달)
                                        final neighborMonth = isDraggingToNext
                                            ? DateTime(
                                                currentMonth.year,
                                                currentMonth.month + 1,
                                                1,
                                              )
                                            : DateTime(
                                                currentMonth.year,
                                                currentMonth.month - 1,
                                                1,
                                              );
                                        final neighborDays =
                                            _generateCalendarDays(
                                              neighborMonth,
                                            );

                                        return Stack(
                                          children: [
                                            // 현재 월 그리드
                                            Transform.translate(
                                              offset: Offset(dragOffset, 0),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                    ),
                                                child: _buildMonthGrid(
                                                  calendarDays: calendarDays,
                                                  month: currentMonth,
                                                  selectedDate: selectedDate,
                                                ),
                                              ),
                                            ),
                                            // 옆에 살짝 보이는 다음/이전 월 그리드
                                            Transform.translate(
                                              offset: Offset(
                                                dragOffset +
                                                    (isDraggingToNext
                                                        ? width
                                                        : -width),
                                                0,
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                    ),
                                                child: _buildMonthGrid(
                                                  calendarDays: neighborDays,
                                                  month: neighborMonth,
                                                  selectedDate: selectedDate,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                // 일정 영역 (달력을 덮는 형태) - 크기 변경 시 애니메이션 적용
                                if (_getScheduleHeightRatio() > 0)
                                  AnimatedPositioned(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOutCubic,
                                    top: currentScheduleY.clamp(
                                      0.0,
                                      screenHeight,
                                    ),
                                    left: 0,
                                    right: 0,
                                    height: scheduleHeight,
                                    child: GestureDetector(
                                      // 하단 일정: 좌우 드래그 시 손가락을 따라 리스트가 이동하도록 처리
                                      onHorizontalDragUpdate: (details) {
                                        setState(() {
                                          _dayDragOffset += details.delta.dx;
                                        });
                                      },
                                      onHorizontalDragEnd: (details) {
                                        _handleHorizontalDragEnd(
                                          offset: _dayDragOffset,
                                          onSwipeLeft: () =>
                                              calendarProvider.goToNextDay(),
                                          onSwipeRight: () => calendarProvider
                                              .goToPreviousDay(),
                                        );
                                      },
                                      // 일정 영역: 위/아래 드래그로 일정이 달력을 덮거나 드러나게
                                      onVerticalDragUpdate: (details) {
                                        setState(() {
                                          _verticalDragOffset +=
                                              details.delta.dy;
                                        });
                                      },
                                      onVerticalDragEnd: (details) {
                                        _handleVerticalDragEnd(details);
                                      },
                                      child: LayoutBuilder(
                                        builder: (context, constraints) {
                                          final width = constraints.maxWidth;
                                          final dragOffset = _dayDragOffset;
                                          final isDraggingToNext =
                                              dragOffset < 0;

                                          // 현재 선택된 날짜의 요일/음력/일정 정보
                                          final currentWeekdayLabel =
                                              korean_date
                                                  .KoreanDateUtils.getKoreanWeekday(
                                                selectedDate,
                                              );
                                          final currentLunarDescription =
                                              korean_date
                                                  .KoreanDateUtils.getLunarDescription(
                                                selectedDate,
                                              );
                                          // getTodosByDate()가 이미 정렬을 적용하므로 추가 정렬 불필요
                                          final currentTodos =
                                              todoProvider.getTodosByDate(
                                                selectedDate,
                                              );

                                          // 이웃 날짜 (왼쪽으로 드래그 → 다음 날짜, 오른쪽으로 드래그 → 이전 날짜)
                                          final neighborDate = isDraggingToNext
                                              ? selectedDate.add(
                                                  const Duration(days: 1),
                                                )
                                              : selectedDate.subtract(
                                                  const Duration(days: 1),
                                                );

                                          // 이웃 날짜의 요일/음력/일정 정보
                                          final neighborWeekdayLabel =
                                              korean_date
                                                  .KoreanDateUtils.getKoreanWeekday(
                                                neighborDate,
                                              );
                                          final neighborLunarDescription =
                                              korean_date
                                                  .KoreanDateUtils.getLunarDescription(
                                                neighborDate,
                                              );
                                          // getTodosByDate()가 이미 정렬을 적용하므로 추가 정렬 불필요
                                          final neighborTodos =
                                              todoProvider.getTodosByDate(
                                                neighborDate,
                                              );

                                          return Container(
                                            width: double.infinity,
                                            padding: const EdgeInsets.fromLTRB(
                                              16,
                                              8,
                                              16,
                                              16,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.surface,
                                              boxShadow: [
                                                // 달력을 덮는 느낌을 위한 그림자
                                                BoxShadow(
                                                  color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, -2),
                                                ),
                                              ],
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    topLeft: Radius.circular(
                                                      16,
                                                    ),
                                                    topRight: Radius.circular(
                                                      16,
                                                    ),
                                                  ),
                                            ),
                                            child: Stack(
                                              children: [
                                                // 현재 선택된 날짜 일정
                                                Transform.translate(
                                                  offset: Offset(dragOffset, 0),
                                                  child: _buildScheduleColumn(
                                                    context: context,
                                                    date: selectedDate,
                                                    weekdayLabel:
                                                        currentWeekdayLabel,
                                                    lunarDescription:
                                                        currentLunarDescription,
                                                    todos: currentTodos,
                                                  ),
                                                ),
                                                // 이웃 날짜 일정 (다음/이전)
                                                Transform.translate(
                                                  offset: Offset(
                                                    dragOffset +
                                                        (isDraggingToNext
                                                            ? width
                                                            : -width),
                                                    0,
                                                  ),
                                                  child: _buildScheduleColumn(
                                                    context: context,
                                                    date: neighborDate,
                                                    weekdayLabel:
                                                        neighborWeekdayLabel,
                                                    lunarDescription:
                                                        neighborLunarDescription,
                                                    todos: neighborTodos,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 정렬/완료 필터 버튼 위젯
// ─────────────────────────────────────────────────────────────────────────────
class _SortFilterButtons extends StatelessWidget {
  final TodoProvider todoProvider;

  const _SortFilterButtons({required this.todoProvider});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 완료 항목 숨기기 토글
        Tooltip(
          message: todoProvider.hideCompleted ? '완료 항목 표시' : '완료 항목 숨기기',
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => todoProvider.toggleHideCompleted(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Icon(
                todoProvider.hideCompleted
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: todoProvider.hideCompleted
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        // 정렬 버튼
        Tooltip(
          message: '정렬 방식 변경',
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _showSortMenu(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sort,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    _sortLabel(todoProvider.sortType),
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 현재 정렬 방식 짧은 라벨
  String _sortLabel(TodoSortType sortType) {
    switch (sortType) {
      case TodoSortType.byPriority:
        return '우선순위';
      case TodoSortType.byDueDate:
        return '기한순';
      case TodoSortType.byCreation:
        return '등록순';
      case TodoSortType.byTitle:
        return '이름순';
    }
  }

  /// 정렬 방식 선택 메뉴
  void _showSortMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                '정렬 방식',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...TodoSortType.values.map((sortType) {
              final isSelected = todoProvider.sortType == sortType;
              return ListTile(
                leading: Icon(
                  _sortIcon(sortType),
                  color: isSelected
                      ? Theme.of(ctx).colorScheme.primary
                      : null,
                ),
                title: Text(
                  _sortLabelFull(sortType),
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(ctx).colorScheme.primary
                        : null,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check,
                        color: Theme.of(ctx).colorScheme.primary)
                    : null,
                onTap: () {
                  todoProvider.setSortType(sortType);
                  Navigator.of(ctx).pop();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  /// 정렬 방식 아이콘
  IconData _sortIcon(TodoSortType sortType) {
    switch (sortType) {
      case TodoSortType.byPriority:
        return Icons.priority_high;
      case TodoSortType.byDueDate:
        return Icons.flag_outlined;
      case TodoSortType.byCreation:
        return Icons.access_time;
      case TodoSortType.byTitle:
        return Icons.sort_by_alpha;
    }
  }

  /// 정렬 방식 전체 라벨
  String _sortLabelFull(TodoSortType sortType) {
    switch (sortType) {
      case TodoSortType.byPriority:
        return '우선순위 높은 순';
      case TodoSortType.byDueDate:
        return '기한 가까운 순';
      case TodoSortType.byCreation:
        return '등록 순서';
      case TodoSortType.byTitle:
        return '이름 가나다 순';
    }
  }
}

/// 캘린더/일정 전환 시 보여줄 간단한 스켈레톤 위젯
class _CalendarSkeleton extends StatelessWidget {
  const _CalendarSkeleton();

  @override
  Widget build(BuildContext context) {
    // 스켈레톤은 과도하게 눈에 띄지 않도록 연한 회색 블록들로 구성
    return Column(
      children: [
        // 상단 캘린더 영역 스켈레톤
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 1,
              ),
              itemCount: 42,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                );
              },
            ),
          ),
        ),
        // 하단 일정 리스트 스켈레톤
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: 4,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final skeletonColor = Theme.of(context).colorScheme.surfaceContainerHighest;
                      return Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: skeletonColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: skeletonColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: 120,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: skeletonColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 우선순위별 대표 색상
/// 
/// 중앙 상수 파일에서 색상을 가져옵니다.
Color _priorityColor(TodoPriority priority) {
  return PriorityColors.getColor(priority);
}

/// 우선순위 표시용 칩 위젯
Widget _priorityIcon(TodoPriority priority) {
  final color = _priorityColor(priority);
  // 중앙화된 PriorityColors.label() 사용 (중복 switch 제거)
  final label = PriorityColors.label(priority);

  // 캘린더 하단 리스트에서 사용할 작고 둥근 칩
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: color.withValues(alpha: 0.7), width: 0.8),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
    ),
  );
}
