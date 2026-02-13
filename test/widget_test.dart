import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Phase 2+ 에서 실제 위젯 테스트 추가
    expect(1 + 1, equals(2));
  });
}
