import 'package:flutter/material.dart';
import 'package:flutter_calender/constants/priority_colors.dart';
import 'package:flutter_calender/models/todo.dart';
import 'package:flutter_calender/providers/category_provider.dart';
import 'package:flutter_calender/providers/todo_provider.dart';
import 'package:flutter_calender/utils/date_utils.dart' as korean_date;
import 'package:flutter_calender/widgets/custom_date_picker_dialog.dart';
import 'package:flutter_calender/widgets/todo_detail_dialog.dart';
import 'package:flutter_calender/widgets/todo_meta_tags.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// 검색 결과 화면
///
/// 검색어 / 우선순위 / 날짜 범위 필터를 조합하여
/// 할일을 검색하고 날짜별로 그룹핑하여 표시합니다.
class SearchResultScreen extends StatefulWidget {
  const SearchResultScreen({super.key});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  // ─── 검색 상태 ────────────────────────────────────────────────────────────
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _query = '';

  /// 선택된 우선순위 필터 (빈 Set = 전체)
  final Set<TodoPriority> _selectedPriorities = {};

  DateTime? _startDate;
  DateTime? _endDate;

  // ─── 필터 패널 표시 여부 ──────────────────────────────────────────────────
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 키보드 자동 포커스
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ─── 날짜 선택기 (커스텀 다이얼로그 사용) ────────────────────────────────
  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart
        ? (_startDate ?? DateTime.now())
        : (_endDate ?? DateTime.now());
    // 할일 추가 화면과 동일한 커스텀 날짜 선택 다이얼로그 사용
    final picked = await showCustomDatePicker(
      context: context,
      initialDate: initial,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        // 시작일이 종료일보다 늦으면 종료일 초기화
        if (_endDate != null && picked.isAfter(_endDate!)) _endDate = null;
      } else {
        _endDate = picked;
        // 종료일이 시작일보다 빠르면 시작일 초기화
        if (_startDate != null && picked.isBefore(_startDate!)) _startDate = null;
      }
    });
  }

  // ─── 검색 실행 ────────────────────────────────────────────────────────────
  List<Todo> _getResults(TodoProvider provider) {
    return provider.searchTodos(
      query: _query,
      priorities: _selectedPriorities.isEmpty ? null : _selectedPriorities.toList(),
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  /// 결과를 날짜별로 그룹핑 (날짜 내림차순)
  Map<String, List<Todo>> _groupByDate(List<Todo> todos) {
    final Map<String, List<Todo>> grouped = {};
    for (final todo in todos) {
      final key = DateFormat('yyyy-MM-dd').format(todo.date);
      grouped.putIfAbsent(key, () => []).add(todo);
    }
    return grouped;
  }

  // ─── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        // 뒤로가기 버튼만 유지 (title 없음)
        title: const SizedBox.shrink(),
      ),
      body: Column(
        children: [
          // ── 검색 입력 + 필터 버튼 한 열 ───────────────────────────────
          _buildSearchRow(colorScheme),
          // ── 필터 패널 ──────────────────────────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _showFilters ? _buildFilterPanel(colorScheme) : const SizedBox.shrink(),
          ),
          // ── 검색 결과 ──────────────────────────────────────────────────
          Expanded(
            child: Consumer<TodoProvider>(
              builder: (context, provider, _) {
                final results = _getResults(provider);
                if (_query.isEmpty &&
                    _selectedPriorities.isEmpty &&
                    _startDate == null &&
                    _endDate == null) {
                  return _buildEmptyHint(colorScheme);
                }
                if (results.isEmpty) {
                  return _buildNoResults(colorScheme);
                }
                return _buildResultList(results, colorScheme);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── 검색 입력 + 필터 버튼 한 열 ────────────────────────────────────────
  Widget _buildSearchRow(ColorScheme colorScheme) {
    final hasFilter = _selectedPriorities.isNotEmpty ||
        _startDate != null ||
        _endDate != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Row(
        children: [
          // 검색 입력 필드 (Expanded로 나머지 공간 차지)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                // 살짝 줄인 radius (28 → 14)
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: '할일 검색...',
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: (value) => setState(() => _query = value),
                textInputAction: TextInputAction.search,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // 필터 버튼 (검색창과 간격 후 배치)
          Badge(
            isLabelVisible: hasFilter,
            child: IconButton(
              icon: Icon(
                Icons.tune,
                // 필터 활성 시 primary 색으로 강조
                color: hasFilter ? colorScheme.primary : null,
              ),
              tooltip: '필터',
              onPressed: () => setState(() => _showFilters = !_showFilters),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 필터 패널 ────────────────────────────────────────────────────────────
  Widget _buildFilterPanel(ColorScheme colorScheme) {
    final dateFormat = DateFormat('yyyy.MM.dd');

    return Padding(
      // 배경 제거, 좌우 마진으로 본문과 구분
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 우선순위 칩
          Text('우선순위', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: TodoPriority.values.map((priority) {
              final selected = _selectedPriorities.contains(priority);
              final color = PriorityColors.getColor(priority);
              return               FilterChip(
                label: Text(
                  PriorityColors.labelFull(priority),
                  style: TextStyle(
                    color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
                    fontSize: 12,
                  ),
                ),
                selected: selected,
                selectedColor: color,
                checkmarkColor: colorScheme.onPrimary,
                onSelected: (_) => setState(() {
                  selected
                      ? _selectedPriorities.remove(priority)
                      : _selectedPriorities.add(priority);
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          // 날짜 범위
          Text('날짜 범위', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 6),
          Row(
            children: [
              // 시작일
              _DateChip(
                label: _startDate != null ? dateFormat.format(_startDate!) : '시작일',
                isSet: _startDate != null,
                onTap: () => _pickDate(isStart: true),
                onClear: () => setState(() => _startDate = null),
                colorScheme: colorScheme,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text('~', style: TextStyle(color: colorScheme.onSurfaceVariant)),
              ),
              // 종료일
              _DateChip(
                label: _endDate != null ? dateFormat.format(_endDate!) : '종료일',
                isSet: _endDate != null,
                onTap: () => _pickDate(isStart: false),
                onClear: () => setState(() => _endDate = null),
                colorScheme: colorScheme,
              ),
              const Spacer(),
              // 필터 전체 초기화
              if (_selectedPriorities.isNotEmpty || _startDate != null || _endDate != null)
                TextButton(
                  onPressed: () => setState(() {
                    _selectedPriorities.clear();
                    _startDate = null;
                    _endDate = null;
                  }),
                  child: const Text('초기화'),
                ),
            ],
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ─── 결과 목록 ────────────────────────────────────────────────────────────
  Widget _buildResultList(List<Todo> results, ColorScheme colorScheme) {
    final grouped = _groupByDate(results);
    // 날짜 내림차순 정렬된 키 목록
    final keys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: keys.length,
      itemBuilder: (context, index) {
        final key = keys[index];
        final todos = grouped[key]!;
        final date = DateTime.parse(key);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Text(
                korean_date.KoreanDateUtils.formatKoreanDateWithWeekday(date),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            // 해당 날짜의 할일 목록
            ...todos.map((todo) => _SearchResultItem(
                  todo: todo,
                  query: _query,
                  colorScheme: colorScheme,
                  // 검색 결과 클릭 시 상세 보기 다이얼로그
                  onTap: () => showTodoDetailDialog(context, todo),
                )),
          ],
        );
      },
    );
  }

  // ─── 빈 상태 (검색 전) ────────────────────────────────────────────────────
  Widget _buildEmptyHint(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 64, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            '검색어를 입력하세요',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '제목, 설명, 우선순위, 날짜로 필터링할 수 있습니다.',
            style: TextStyle(color: colorScheme.outlineVariant, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ─── 결과 없음 ────────────────────────────────────────────────────────────
  Widget _buildNoResults(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(
            '검색 결과가 없습니다',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '검색어 또는 필터를 변경해 보세요.',
            style: TextStyle(color: colorScheme.outlineVariant, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ─── 날짜 칩 위젯 (호버 효과 + 손가락 커서 포함) ─────────────────────────────
class _DateChip extends StatefulWidget {
  final String label;
  final bool isSet;
  final VoidCallback onTap;
  final VoidCallback onClear;
  final ColorScheme colorScheme;

  const _DateChip({
    required this.label,
    required this.isSet,
    required this.onTap,
    required this.onClear,
    required this.colorScheme,
  });

  @override
  State<_DateChip> createState() => _DateChipState();
}

class _DateChipState extends State<_DateChip> {
  /// 칩 전체 호버 여부
  bool _isChipHovered = false;
  /// X 버튼 호버 여부
  bool _isCloseHovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = widget.colorScheme;
    // 호버 시 배경 살짝 어둡게
    final bgColor = widget.isSet
        ? (_isChipHovered ? cs.primary.withAlpha(60) : cs.primaryContainer)
        : (_isChipHovered ? cs.surfaceContainerHigh : cs.surfaceContainerHighest);

    return MouseRegion(
      // 손가락 모양 커서
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isChipHovered = true),
      onExit: (_) => setState(() => _isChipHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  color: widget.isSet ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                ),
              ),
              if (widget.isSet) ...[
                const SizedBox(width: 4),
                // X 버튼에 별도 호버 효과
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) => setState(() => _isCloseHovered = true),
                  onExit: (_) => setState(() => _isCloseHovered = false),
                  child: GestureDetector(
                    onTap: widget.onClear,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        // 호버 시 배경 원형으로 강조
                        color: _isCloseHovered
                            ? cs.onPrimaryContainer.withAlpha(40)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        // 호버 시 아이콘 색 강조
                        color: _isCloseHovered
                            ? cs.error
                            : cs.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 검색 결과 아이템 (하이라이팅 포함) ────────────────────────────────────────
class _SearchResultItem extends StatelessWidget {
  final Todo todo;
  final String query;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _SearchResultItem({
    required this.todo,
    required this.query,
    required this.colorScheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final priorityColor = PriorityColors.getColor(todo.priority);

    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, _) {
        final category = categoryProvider.getById(todo.categoryId);

        return InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 우선순위 색상 바
                Container(
                  width: 4,
                  height: 44,
                  decoration: BoxDecoration(
                    color: priorityColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목 (하이라이팅)
                      _highlightText(
                        text: todo.title,
                        query: query,
                        baseStyle: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(
                              color: todo.completed
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.onSurface,
                              decoration: todo.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                        highlightColor: colorScheme.primary,
                      ),
                      // 카테고리/시간/기한 메타 태그
                      if (category != null ||
                          todo.todoTime != null ||
                          todo.dueDate != null) ...[
                        const SizedBox(height: 4),
                        TodoMetaTagsRow(todo: todo, category: category),
                      ],
                      // 설명 (있는 경우)
                      if (todo.description?.isNotEmpty == true) ...[
                        const SizedBox(height: 2),
                        _highlightText(
                          text: todo.description!,
                          query: query,
                          baseStyle: Theme.of(context)
                              .textTheme
                              .bodySmall!
                              .copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                          highlightColor: colorScheme.primary,
                        ),
                      ],
                    ],
                  ),
                ),
                if (todo.completed)
                  Icon(Icons.check_circle, size: 18, color: Colors.green[400]),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 검색어 하이라이팅 RichText
  Widget _highlightText({
    required String text,
    required String query,
    required TextStyle baseStyle,
    required Color highlightColor,
  }) {
    if (query.isEmpty) return Text(text, style: baseStyle, maxLines: 1, overflow: TextOverflow.ellipsis);

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final idx = lowerText.indexOf(lowerQuery, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx)));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: TextStyle(
          color: highlightColor,
          fontWeight: FontWeight.bold,
          backgroundColor: highlightColor.withAlpha(30),
        ),
      ));
      start = idx + query.length;
    }

    return RichText(
      text: TextSpan(style: baseStyle, children: spans),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
