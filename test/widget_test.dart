import 'package:flutter_test/flutter_test.dart';
import 'package:doctor_appointment_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Basic build test
    await tester.pumpWidget(const PulseCareApp());
    expect(find.byType(PulseCareApp), findsOneWidget);
  });
}
