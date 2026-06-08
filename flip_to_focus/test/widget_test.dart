import 'package:flutter_test/flutter_test.dart';
import 'package:flip_to_focus/main.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    // Zbuduj naszą nową aplikację i wywołaj klatkę animacji
    await tester.pumpWidget(const FlipToFocusApp());

    // Sprawdź, czy na ekranie znajduje się tekst 'Zaloguj się' (z naszego AppBar i przycisku)
    expect(find.text('Zaloguj się'), findsWidgets);

    // Upewnij się, że nie ma tam już starego licznika z cyfrą '0'
    expect(find.text('0'), findsNothing);
  });
}
