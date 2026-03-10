import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:flutter_calender/models/category_adapter.dart';
import 'package:flutter_calender/models/todo_adapter.dart';
import 'package:flutter_calender/providers/calendar_provider.dart';
import 'package:flutter_calender/providers/category_provider.dart';
import 'package:flutter_calender/providers/theme_provider.dart';
import 'package:flutter_calender/providers/todo_provider.dart';
import 'package:flutter_calender/screens/calendar_screen.dart';

import 'package:flutter_calender/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive 초기화
  await Hive.initFlutter();

  // TypeAdapter 등록 (typeId 순서 주의: 0=Todo, 1=Category)
  Hive.registerAdapter(TodoAdapter());
  Hive.registerAdapter(CategoryAdapter());

  // 한국어 로케일 데이터 초기화
  await initializeDateFormatting('ko_KR', null);

  // Provider 생성 및 초기화
  final todoProvider = TodoProvider();
  await todoProvider.initialize();

  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  final categoryProvider = CategoryProvider();
  await categoryProvider.initialize();

  runApp(
    MyApp(
      todoProvider: todoProvider,
      themeProvider: themeProvider,
      categoryProvider: categoryProvider,
    ),
  );
}

class MyApp extends StatelessWidget {
  final TodoProvider todoProvider;
  final ThemeProvider themeProvider;
  final CategoryProvider categoryProvider;

  const MyApp({
    super.key,
    required this.todoProvider,
    required this.themeProvider,
    required this.categoryProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider.value(value: todoProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: categoryProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, theme, _) => MaterialApp(
          title: 'Flutter 캘린더',
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: theme.themeMode,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('ko', 'KR')],
          builder: (context, child) {
            final width = MediaQuery.of(context).size.width;
            if (width > 800 && child != null) {
              return Container(
                color: Theme.of(context).colorScheme.surfaceContainerLowest,
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Material(elevation: 4, child: child),
                  ),
                ),
              );
            }
            return child ?? const SizedBox.shrink();
          },
          home: const CalendarScreen(),
        ),
      ),
    );
  }
}
