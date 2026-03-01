import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_patient/main.dart';

void main() {
  testWidgets('App builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: HealthPatientApp()));
    await tester.pump();
    expect(find.byType(HealthPatientApp), findsOneWidget);
  });
}
