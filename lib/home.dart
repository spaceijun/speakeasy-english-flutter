import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_english/api_service.dart';
import 'package:speak_english/discover_page.dart';
import 'package:speak_english/exam.dart';
import 'package:speak_english/frasa.dart';
import 'package:speak_english/grammar.dart';
import 'package:speak_english/hafalan.dart';
import 'package:speak_english/kosakata.dart';
import 'package:speak_english/login.dart'; // Import halaman login
import 'package:speak_english/tenses.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  // Fungsi untuk menghapus session
  Future<void> _clearLoginSession() async {
    final prefs = await SharedPreferences.getInstance();

    // Hapus semua data session
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('sessionExpireTime');
    await prefs.remove('userToken');
    await prefs.remove('userEmail');
  }

  @override
  Widget build(BuildContext context) {
    final ApiService apiService = ApiService();

    // Fungsi untuk menangani proses logout
    Future<void> handleLogout(BuildContext context) async {
      try {
        // Tampilkan indikator loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(child: CircularProgressIndicator());
          },
        );

        // Panggil API logout
        final bool logoutSuccess = await apiService.logout();

        // Hapus data session dari SharedPreferences
        await _clearLoginSession();

        // Tutup dialog loading
        Navigator.pop(context);

        if (logoutSuccess) {
          // Jika logout berhasil, navigasi ke LoginScreen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false, // Hapus semua halaman dari stack
          );
        } else {
          // Jika API logout gagal, tetap hapus session local dan navigasi ke login
          // Ini untuk menghindari kondisi user terjebak di dalam aplikasi
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );

          // Tampilkan pesan error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Gagal keluar dari server, tetapi sesi lokal telah dihapus.',
              ),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (e) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        // Hapus session local meskipun terjadi error
        await _clearLoginSession();

        // Navigasi ke login screen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );

        // Tampilkan pesan error yang lebih spesifik
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Terjadi kesalahan: ${e.toString()}, sesi lokal telah dihapus.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );

        print('Error saat logout: $e');
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.black),
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        // ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Small image above the header text
                    GestureDetector(
                      onTap: () async {
                        final bool? confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Keluar'),
                                content: const Text(
                                  'Yakin mau keluar dari aplikasi?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(false),
                                    child: const Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.of(context).pop(true),
                                    child: const Text('Keluar'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                        );

                        // Jika user mengkonfirmasi logout
                        if (confirm == true) {
                          // Panggil fungsi handleLogout
                          await handleLogout(context);
                        }
                      },
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Image.asset(
                          'assets/images/exit.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'English',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      'Learning',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'QUICK VIEW',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                // Books stack image
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Image.asset(
                    'assets/images/book.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Grid of menu items
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildMenuItem(
                    context,
                    // 'Hafalan',
                    const Color(0xFFFFBE4DE)!,
                    'assets/images/hafalan.png',
                    // subtitle: "Hafalan",
                    onTap: () {
                      print('Hafalan tapped');
                      // Navigate to Hafalan screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HafalanScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    // 'Grammar',
                    const Color(0xFFFEDDED)!,
                    'assets/images/grammar.png',
                    // subtitle: "Learning grammar",
                    onTap: () {
                      print('Grammar tapped');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GrammarScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    // 'Tenses',
                    const Color(0xFFDAD6FB)!,
                    'assets/images/tenses.png',
                    // subtitle: "All tenses",
                    onTap: () {
                      print('Tenses tapped');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TensesScreen()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    // 'Kosakata',
                    const Color(0xFFDBFFD9)!,
                    'assets/images/kosakata.png',
                    // subtitle: "Vocabulary",
                    onTap: () {
                      print('Kosakata tapped');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => KosakataScreen(),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    const Color(0xFFFFFACF)!,
                    'assets/images/ujian.png',
                    onTap: () {
                      print('Ujian tapped');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ExamScreen()),
                      );
                    },
                  ),
                  _buildMenuItem(
                    context,
                    // 'Frasa dan Idiom',
                    const Color(0xFFDEF4FF)!,
                    'assets/images/frasa.png',
                    // subtitle: "Phrases and Idioms",
                    onTap: () {
                      print('Frasa dan Idiom tapped');
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FrasaScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    // String title,
    Color color,
    String imagePath, {
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 135.5,
              height: 135.5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 8),
            // Text(
            //   // title,
            //   style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            //   textAlign: TextAlign.center,
            // ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
