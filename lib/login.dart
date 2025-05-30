import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_english/api_service.dart';
import 'package:speak_english/home.dart';
import 'package:speak_english/register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _authService = ApiService();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _saveLoginSession({
    int durationInDays = 7,
    String? token,
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    if (token != null) {
      await prefs.setString('userToken', token);
      print('Token saved: $token'); // Log token yang disimpan
    }
    if (userId != null) {
      await prefs.setString('userId', userId);
      print('User ID saved: $userId'); // Log user ID yang disimpan
    }
    final currentTime = DateTime.now();
    final expireTime = currentTime.add(Duration(days: durationInDays));
    await prefs.setInt('sessionExpireTime', expireTime.millisecondsSinceEpoch);
    await prefs.setString('userEmail', _emailController.text);
    print(
      'Login session saved, expires at: $expireTime',
    ); // Log waktu kedaluwarsa sesi
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Email dan password tidak boleh kosong';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    print('Attempting to log in with email: ${_emailController.text}');

    try {
      final response = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      print('Login response: $response'); // Log response dari API

      if (response['success'] == true) {
        final token = response['token'] as String?;
        print('Login successful, token: $token'); // Log token yang diterima
        await _saveLoginSession(durationInDays: 7, token: token);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        }
      } else {
        // Login gagal
        setState(() {
          _errorMessage =
              response['message'] ?? 'Login gagal. Silakan coba lagi.';
        });
        print('Login failed: ${_errorMessage}'); // Log pesan kesalahan
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
      });
      print('Error during login: $e'); // Log kesalahan
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF5E1DDB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                // Illustration and icons
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Column(
                      children: [
                        const SizedBox(height: 10),
                        Image.asset(
                          'assets/images/bg_login.png',
                          width: 250,
                          height: 250,
                          fit: BoxFit.contain,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade200,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                ),
                              ),
                        ),
                      ],
                    ),
                    // Floating icons
                    Positioned(
                      top: 30,
                      right: 50,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade300,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.search,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      right: 60,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.book,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                // Email field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Email',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Password field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    hintText: 'Password',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Error message
                if (_errorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                const SizedBox(height: 24),
                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      elevation: 0,
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            )
                            : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 16),
                // "Belum Punya Akun?" text
                const Text(
                  'Belum Punya Akun ?',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 16),
                // Register button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Register(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
