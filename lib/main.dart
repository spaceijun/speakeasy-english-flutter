import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:speak_english/discover_page.dart';
import 'package:speak_english/home.dart';
import 'package:speak_english/login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Mobile Ads sebelum menjalankan app
  await MobileAds.instance.initialize();

  final isValidSession = await checkLoginSession();
  runApp(MainApp(isLoggedIn: isValidSession));
}

// Fungsi untuk memeriksa status login dan validitas session
Future<bool> checkLoginSession() async {
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  if (!isLoggedIn) return false;

  // Cek expired time dari session
  final sessionExpireTime = prefs.getInt('sessionExpireTime') ?? 0;
  final currentTime = DateTime.now().millisecondsSinceEpoch;

  // Jika waktu saat ini sudah melewati waktu expire
  if (currentTime > sessionExpireTime) {
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('sessionExpireTime');
    await prefs.remove('userToken');
    await prefs.remove('userEmail');
    return false;
  }

  return true;
}

class MainApp extends StatelessWidget {
  final bool isLoggedIn;

  const MainApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const Home() : const LoginScreen(),
    );
  }
}
