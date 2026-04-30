import 'package:flutter_test/flutter_test.dart';
import 'package:emergency_medical/main.dart';
import 'package:provider/provider.dart';
import 'package:emergency_medical/services/auth_service.dart';

void main() {
  testWidgets('App builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthService(),
        child: const EmergencyMedicalApp(),
      ),
    );
    expect(find.byType(EmergencyMedicalApp), findsOneWidget);
  });
}
