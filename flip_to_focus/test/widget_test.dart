import 'package:flutter_test/flutter_test.dart';
import 'package:flip_to_focus/main.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const FlipToFocusApp());
    expect(find.text('Zaloguj się'), findsWidgets);
    expect(find.text('0'), findsNothing);
  });
}
