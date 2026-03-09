import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_calender/constants/app_constants.dart';
import 'package:flutter_calender/providers/calendar_provider.dart';
import 'package:flutter_calender/providers/todo_provider.dart';
import 'package:flutter_calender/screens/category_screen.dart';
import 'package:flutter_calender/screens/search_result_screen.dart';
import 'package:flutter_calender/screens/settings_screen.dart';
import 'package:flutter_calender/utils/date_utils.dart' as korean_date;
import 'package:flutter_calender/widgets/calendar_widget.dart';
import 'package:flutter_calender/widgets/todo_input_dialog.dart';
import 'package:provider/provider.dart';

/// 캘린더 메인 화면
///
/// 캘린더와 할일을 관리하는 메인 화면입니다.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  StreamSubscription? _errorSubscription;

  @override
  void initState() {
    super.initState();
    // TodoProvider의 에러 스트림 구독
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    _errorSubscription = todoProvider.errorStream.listen((error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: '확인',
              textColor: Colors.white,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _errorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('캘린더'),
        actions: [
          // 검색 화면으로 이동
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: '검색',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SearchResultScreen()),
              );
            },
          ),
          // 카테고리 관리 화면으로 이동
          IconButton(
            icon: const Icon(Icons.label_outline),
            tooltip: '카테고리 관리',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CategoryScreen()),
              );
            },
          ),
          // 설정 화면으로 이동
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '설정',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: const [
          // 메인 캘린더 영역
          CalendarWidget(),
          // 화면 중간 하단 플로팅 '오늘' 버튼
          _TodayFloatingButton(),
        ],
      ),
      // 우측 하단 할일 추가 버튼
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final calendarProvider = Provider.of<CalendarProvider>(
            context,
            listen: false,
          );
          // 할일 추가 — 다이얼로그로 표시
          showTodoInputDialog(
            context,
            initialDate: calendarProvider.selectedDate,
          );
        },
        tooltip: '할일 추가',
        // 다크 모드에서도 잘 보이도록 colorScheme 기반 색상 명시
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 4,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}

/// 화면 중간 하단에 노출되는 '오늘로 이동' 플로팅 버튼
///
/// - 오늘이 아닌 날짜를 선택했을 때만 표시
/// - + 버튼과 비슷하게 그림자/둥근 모양을 주어 가시성을 높임
class _TodayFloatingButton extends StatelessWidget {
  const _TodayFloatingButton();

  @override
  Widget build(BuildContext context) {
    return Consumer<CalendarProvider>(
      builder: (context, calendarProvider, child) {
        final selectedDate = calendarProvider.selectedDate;
        final isToday = korean_date.KoreanDateUtils.isToday(selectedDate);

        // 이미 오늘인 경우에는 버튼을 숨김
        if (isToday) {
          return const SizedBox.shrink();
        }

        return Positioned(
          left: 0,
          right: 0,
          bottom: AppConstants.iconSizeMedium,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: AppConstants.dialogBorderRadius,
                boxShadow: [
                  // 살짝 떠 있는 느낌을 주기 위한 그림자
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.18),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextButton.icon(
                onPressed: () {
                  calendarProvider.goToToday();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: AppConstants.spacingMedium,
                  ),
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppConstants.dialogBorderRadius,
                  ),
                ),
                icon: const Icon(Icons.today, size: 18),
                label: const Text(
                  '오늘',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
