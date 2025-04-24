// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_english/main.dart';
import 'package:speak_english/home.dart'; // ganti sesuai lokasi file

void main() {
  testWidgets('App navigates to Home if already logged in', (
    WidgetTester tester,
  ) async {
    // Inisialisasi SharedPreferences dengan nilai mock
    SharedPreferences.setMockInitialValues({'isLoggedIn': true});

    // Jalankan app
    await tester.pumpWidget(const MainApp(isLoggedIn: true));

    // Verifikasi Home page muncul
    expect(find.byType(Home), findsOneWidget);
  });
}
