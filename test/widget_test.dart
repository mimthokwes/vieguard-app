import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_vie/main.dart';

void main() {
  testWidgets('App loads smoke test', (WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception is NetworkImageLoadException || details.exception.toString().contains('NetworkImage')) {
        return;
      }
      originalOnError?.call(details);
    };

    await tester.pumpWidget(const VieguardAdminApp());
    expect(find.byType(VieguardAdminApp), findsOneWidget);

    FlutterError.onError = originalOnError;
  });
}
