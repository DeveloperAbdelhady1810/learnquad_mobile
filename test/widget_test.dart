import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learnquad_mobile/features/splash/splash_screen.dart';
import 'package:learnquad_mobile/main.dart';

void main() {
  testWidgets('App boots to the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: LearnQuadApp()));
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
