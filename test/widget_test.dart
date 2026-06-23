import 'package:flutter_test/flutter_test.dart';
import 'package:sph_offline/main.dart';

void main() {
  testWidgets('App launches with dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const SphApp());
    expect(find.text('SPH Generator'), findsOneWidget);
    expect(find.text('Selamat Datang'), findsOneWidget);
  });
}
