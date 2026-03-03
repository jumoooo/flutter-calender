import 'package:flutter/material.dart';
import 'package:flutter_calender/providers/calendar_provider.dart';
import 'package:flutter_calender/utils/date_utils.dart' as korean_date;
import 'package:flutter_calender/widgets/calendar_widget.dart';
import 'package:provider/provider.dart';

/// 캘린더 메인 화면
///
/// 캘린더와 할일을 관리하는 메인 화면입니다.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('캘린더')),
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
          Navigator.of(
            context,
          ).pushNamed('/todo-input', arguments: calendarProvider.selectedDate);
        },
        tooltip: '할일 추가',
        child: const Icon(Icons.add),
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
          bottom: 24,
          child: Center(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  // 살짝 떠 있는 느낌을 주기 위한 그림자
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
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
                    vertical: 10,
                  ),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
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
