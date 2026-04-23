import 'package:amanah_ui/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Check if Checkout Screen loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AmanahBotApp());

    // Verify that the title is present.
    expect(find.text('Amanah-Bot Checkout'), findsOneWidget);
    expect(find.text('Zero-Trust Escrow Payment'), findsOneWidget);
  });
}
