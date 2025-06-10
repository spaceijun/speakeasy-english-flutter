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
import 'package:speak_english/ad_manager.dart'; // Import ad manager

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late InterstitialAdManager _interstitialAdManager;
  int _menuTapCount = 0; // Counter untuk menampilkan interstitial ad

  @override
  void initState() {
    super.initState();
    // Inisialisasi interstitial ad manager
    _interstitialAdManager = InterstitialAdManager();
    _interstitialAdManager.loadAd();
  }

  @override
  void dispose() {
    _interstitialAdManager.dispose();
    super.dispose();
  }

  // Fungsi untuk menghapus session
  Future<void> _clearLoginSession() async {
    final prefs = await SharedPreferences.getInstance();

    // Hapus semua data session
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('sessionExpireTime');
    await prefs.remove('userToken');
    await prefs.remove('userEmail');
  }

  // Fungsi untuk menampilkan interstitial ad setiap 3 kali tap menu
  void _handleMenuTap(VoidCallback originalOnTap) {
    _menuTapCount++;

    // Tampilkan interstitial ad setiap 3 kali tap
    if (_menuTapCount % 3 == 0 && _interstitialAdManager.isLoaded) {
      _interstitialAdManager.showAd(
        onAdClosed: () {
          // Setelah ad ditutup, jalankan fungsi navigasi asli
          originalOnTap();
        },
      );
    } else {
      // Langsung jalankan fungsi navigasi
      originalOnTap();
    }
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
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
      body: Column(
        children: [
          // Banner Ad di bagian atas
          const BannerAdWidget(),

          // Konten utama
          Expanded(
            child: Padding(
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
                                              () => Navigator.of(
                                                context,
                                              ).pop(false),
                                          child: const Text('Batal'),
                                        ),
                                        TextButton(
                                          onPressed:
                                              () => Navigator.of(
                                                context,
                                              ).pop(true),
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
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
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
                          const Color(0xFFFFBE4DE)!,
                          'assets/images/hafalan.png',
                          onTap: () {
                            _handleMenuTap(() {
                              print('Hafalan tapped');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HafalanScreen(),
                                ),
                              );
                            });
                          },
                        ),
                        _buildMenuItem(
                          context,
                          const Color(0xFFFEDDED)!,
                          'assets/images/grammar.png',
                          onTap: () {
                            _handleMenuTap(() {
                              print('Grammar tapped');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GrammarScreen(),
                                ),
                              );
                            });
                          },
                        ),
                        _buildMenuItem(
                          context,
                          const Color(0xFFDAD6FB)!,
                          'assets/images/tenses.png',
                          onTap: () {
                            _handleMenuTap(() {
                              print('Tenses tapped');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TensesScreen(),
                                ),
                              );
                            });
                          },
                        ),
                        _buildMenuItem(
                          context,
                          const Color(0xFFDBFFD9)!,
                          'assets/images/kosakata.png',
                          onTap: () {
                            _handleMenuTap(() {
                              print('Kosakata tapped');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => KosakataScreen(),
                                ),
                              );
                            });
                          },
                        ),
                        _buildMenuItem(
                          context,
                          const Color(0xFFFFFACF)!,
                          'assets/images/ujian.png',
                          onTap: () {
                            _handleMenuTap(() {
                              print('Ujian tapped');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ExamScreen(),
                                ),
                              );
                            });
                          },
                        ),
                        _buildMenuItem(
                          context,
                          const Color(0xFFDEF4FF)!,
                          'assets/images/frasa.png',
                          onTap: () {
                            _handleMenuTap(() {
                              print('Frasa dan Idiom tapped');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FrasaScreen(),
                                ),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Banner Ad di bagian bawah
          const BannerAdWidget(),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
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
