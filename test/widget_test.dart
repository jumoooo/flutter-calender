import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_calender/main.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    // 한국어 로케일 데이터 초기화
    await initializeDateFormatting('ko_KR', null);
  });

  testWidgets('캘린더 화면이 표시되는지 테스트', (WidgetTester tester) async {
    // 앱 빌드
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 캘린더 제목이 표시되는지 확인
    expect(find.text('캘린더'), findsOneWidget);
  });
}
