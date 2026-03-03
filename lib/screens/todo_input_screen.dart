import 'package:flutter/material.dart';
import 'package:flutter_calender/models/todo.dart';
import 'package:flutter_calender/providers/todo_provider.dart';
import 'package:flutter_calender/utils/date_utils.dart' as korean_date;
import 'package:provider/provider.dart';

/// 할일 입력 화면
/// 
/// 할일을 추가하거나 수정하는 화면입니다.
class TodoInputScreen extends StatefulWidget {
  /// 초기 날짜 (선택사항)
  final DateTime? initialDate;
  
  /// 수정할 할일 (선택사항, 수정 모드일 때 사용)
  final Todo? todo;

  const TodoInputScreen({
    super.key,
    this.initialDate,
    this.todo,
  });

  @override
  State<TodoInputScreen> createState() => _TodoInputScreenState();
}

class _TodoInputScreenState extends State<TodoInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _titleFocusNode = FocusNode();
  DateTime _selectedDate = DateTime.now();
  /// 기본 우선순위는 '보통'으로 설정
  TodoPriority _selectedPriority = TodoPriority.normal;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      // 수정 모드
      _titleController.text = widget.todo!.title;
      _descriptionController.text = widget.todo!.description ?? '';
      _selectedDate = widget.todo!.date;
      _selectedPriority = widget.todo!.priority;
    } else if (widget.initialDate != null) {
      // 초기 날짜 설정
      _selectedDate = widget.initialDate!;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _titleFocusNode.requestFocus();
        }
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _titleFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.todo != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? '할일 수정' : '할일 추가'),
        // 상단 우측에 체크 아이콘을 두어 저장 동작을 실행
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: isEditMode ? '수정 완료' : '추가 완료',
            onPressed: _saveTodo,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 제목 입력
            TextFormField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              decoration: const InputDecoration(
                labelText: '제목',
                hintText: '할일 제목을 입력하세요',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '제목을 입력해주세요';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // 설명 입력
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '설명 (선택사항)',
                hintText: '할일 설명을 입력하세요',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 16),
            
            // 날짜 선택
            ListTile(
              title: const Text('날짜'),
              subtitle: Builder(
                builder: (context) {
                  // 요일 확인 (일요일 = 0, 토요일 = 6)
                  final weekday = _selectedDate.weekday % 7;
                  final isSunday = weekday == 0;
                  final isSaturday = weekday == 6;
                  final weekdayLabel =
                      korean_date.KoreanDateUtils.getKoreanWeekday(
                    _selectedDate,
                  );

                  // 예: "2026년 3월 15일 (화) (음력 1.15)"
                  // 일요일은 빨간색, 토요일은 파란색으로 표시
                  return RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: korean_date.KoreanDateUtils.formatKoreanDate(
                            _selectedDate,
                          ),
                        ),
                        TextSpan(
                          text: ' ($weekdayLabel) ',
                          style: TextStyle(
                            color: isSunday
                                ? Colors.red
                                : isSaturday
                                    ? Colors.blue
                                    : null,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: '(${korean_date.KoreanDateUtils.getLunarDescription(_selectedDate)})',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                },
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final firstDate = DateTime(2020);
                final lastDate = DateTime(2030);
                var initialDate = _selectedDate;
                if (initialDate.isBefore(firstDate)) {
                  initialDate = firstDate;
                } else if (initialDate.isAfter(lastDate)) {
                  initialDate = lastDate;
                }

                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: firstDate,
                  lastDate: lastDate,
                  locale: const Locale('ko', 'KR'),
                );
                if (pickedDate != null) {
                  setState(() {
                    _selectedDate = pickedDate;
                  });
                }
              },
            ),
            
            const SizedBox(height: 16),
            
            // 우선순위 선택
            const Text(
              '우선순위',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<TodoPriority>(
              // 5단계 우선순위 + 색상 구분 (새로운 파스텔 톤)
              style: SegmentedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                minimumSize: const Size(0, 52),
                textStyle: const TextStyle(fontSize: 12),
              ),
              segments: [
                ButtonSegment(
                  value: TodoPriority.veryLow,
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '매우',
                          style: TextStyle(fontSize: 10, height: 1.1),
                        ),
                        Text(
                          '낮음',
                          style: TextStyle(fontSize: 10, height: 1.1),
                        ),
                      ],
                    ),
                  ),
                  icon: const Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Icon(Icons.circle, color: Color(0xFFD3D3D3), size: 12),
                  ),
                ),
                const ButtonSegment(
                  value: TodoPriority.low,
                  label: Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Text('낮음'),
                  ),
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Icon(Icons.circle, color: Color(0xFF90EE90), size: 12),
                  ),
                ),
                const ButtonSegment(
                  value: TodoPriority.normal,
                  label: Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Text('보통'),
                  ),
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Icon(Icons.circle, color: Color(0xFF9BB5FF), size: 12),
                  ),
                ),
                const ButtonSegment(
                  value: TodoPriority.high,
                  label: Padding(
                    padding: EdgeInsets.symmetric(vertical: 2),
                    child: Text('높음'),
                  ),
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Icon(Icons.circle, color: Color(0xFFFFA07A), size: 12),
                  ),
                ),
                ButtonSegment(
                  value: TodoPriority.veryHigh,
                  label: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '매우',
                          style: TextStyle(fontSize: 10, height: 1.1),
                        ),
                        Text(
                          '높음',
                          style: TextStyle(fontSize: 10, height: 1.1),
                        ),
                      ],
                    ),
                  ),
                  icon: const Padding(
                    padding: EdgeInsets.only(bottom: 2),
                    child: Icon(Icons.circle, color: Color(0xFFFF6B9D), size: 12),
                  ),
                ),
              ],
              selected: {_selectedPriority},
              onSelectionChanged: (Set<TodoPriority> newSelection) {
                setState(() {
                  _selectedPriority = newSelection.first;
                });
              },
            ),
            
            const SizedBox(height: 32),

            // 삭제 버튼 (수정 모드일 때만, 하단에 배치)
            if (isEditMode) ...[
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _deleteTodo,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  foregroundColor: Colors.red,
                ),
                child: const Text('삭제하기'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 할일 저장
  void _saveTodo() {
    if (_formKey.currentState!.validate()) {
      final todoProvider = Provider.of<TodoProvider>(context, listen: false);
      
      if (widget.todo != null) {
        // 수정 모드
        final updatedTodo = widget.todo!.copyWith(
          title: _titleController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          date: _selectedDate,
          priority: _selectedPriority,
        );
        todoProvider.updateTodo(updatedTodo);
      } else {
        // 추가 모드
        final newTodo = Todo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: _titleController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          date: _selectedDate,
          priority: _selectedPriority,
        );
        todoProvider.addTodo(newTodo);
      }
      
      Navigator.of(context).pop();
    }
  }

  /// 할일 삭제
  void _deleteTodo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('할일 삭제'),
        content: const Text('정말로 이 할일을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final todoProvider =
                  Provider.of<TodoProvider>(context, listen: false);
              todoProvider.deleteTodo(widget.todo!.id);
              Navigator.of(context).pop(); // 다이얼로그 닫기
              Navigator.of(context).pop(); // 화면 닫기
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
