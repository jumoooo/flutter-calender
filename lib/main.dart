import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_calender/models/todo.dart';
import 'package:flutter_calender/models/todo_adapter.dart';
import 'package:flutter_calender/providers/calendar_provider.dart';
import 'package:flutter_calender/providers/todo_provider.dart';
import 'package:flutter_calender/screens/calendar_screen.dart';
import 'package:flutter_calender/screens/todo_input_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive 초기화
  await Hive.initFlutter();
  
  // Todo TypeAdapter 등록
  Hive.registerAdapter(TodoAdapter());
  
  // 한국어 로케일 데이터 초기화
  await initializeDateFormatting('ko_KR', null);
  
  // TodoProvider 생성 및 초기화
  final todoProvider = TodoProvider();
  await todoProvider.initialize();
  
  runApp(MyApp(todoProvider: todoProvider));
}

class MyApp extends StatelessWidget {
  final TodoProvider todoProvider;

  const MyApp({
    super.key,
    required this.todoProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider.value(value: todoProvider),
      ],
      child: MaterialApp(
        title: 'Flutter 캘린더',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        // MaterialLocalizations / WidgetsLocalizations / CupertinoLocalizations 등록
        // - DatePickerDialog, TimePicker 등에서 한국어 문자열/레이블을 사용하기 위함
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ko', 'KR'),
        ],
        // 웹에서 너무 넓게 퍼지지 않도록 중앙 정렬 + 최대 폭 제한
        // - 데스크톱/웹 큰 화면에서는 480~600px 정도로 가운데 카드처럼 보이게 함
        // - 모바일 폭에서는 기존처럼 전체 화면 사용
        builder: (context, child) {
          final width = MediaQuery.of(context).size.width;

          // 넓은 화면(예: 웹 데스크톱)에서만 중앙 정렬 + 여백 적용
          if (width > 800 && child != null) {
            return Container(
              color: Colors.grey[100], // 웹 배경을 살짝 연한 그레이로
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Material(
                    elevation: 4,
                    child: child,
                  ),
                ),
              ),
            );
          }

          // 모바일/태블릿 등 기본 폭에서는 기존 레이아웃 유지
          return child ?? const SizedBox.shrink();
        },
        home: const CalendarScreen(),
        routes: {
          '/todo-input': (context) {
            final args = ModalRoute.of(context)!.settings.arguments;
            if (args is Todo) {
              // 수정 모드
              return TodoInputScreen(todo: args);
            } else if (args is DateTime) {
              // 추가 모드 (날짜 지정)
              return TodoInputScreen(initialDate: args);
            } else {
              // 추가 모드 (날짜 미지정)
              return const TodoInputScreen();
            }
          },
        },
      ),
    );
  }
}
