import 'package:flutter/material.dart';
import 'package:speak_english/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  // final TextEditingController _telephoneController = TextEditingController();
  // final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _passwordConfirmationController =
      TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _register() async {
    // Validasi password match
    if (_passwordController.text != _passwordConfirmationController.text) {
      setState(() {
        _errorMessage = 'Password dan konfirmasi password tidak cocok';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Ganti URL ini dengan URL API register Laravel Anda
      final String apiUrl = 'https://speakeasy-english.web.id/api/register';

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': _nameController.text,
          'email': _emailController.text,
          // 'telephone': _telephoneController.text,
          // 'address': _addressController.text,
          'password': _passwordController.text,
          'password_confirmation': _passwordConfirmationController.text,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Registrasi berhasil
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String token = data['token'] ?? '';

        // Simpan token untuk digunakan nanti
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        // Navigasi ke halaman home
        if (mounted) {
          // Tampilkan snackbar berhasil
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registrasi berhasil!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigasi ke home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const Home()),
          );
        }
      } else {
        // Registrasi gagal
        final Map<String, dynamic> data = jsonDecode(response.body);
        String errorMsg = 'Registrasi gagal.';

        // Cek jika ada pesan error spesifik dari server
        if (data.containsKey('message')) {
          errorMsg = data['message'];
        } else if (data.containsKey('errors')) {
          final errors = data['errors'] as Map<String, dynamic>;
          final List<String> errorMessages = [];

          errors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errorMessages.add(value.first);
            }
          });

          if (errorMessages.isNotEmpty) {
            errorMsg = errorMessages.join("\n");
          }
        }

        setState(() {
          _errorMessage = errorMsg;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8A56FF),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Registration title
                const Text(
                  'Register your account now!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // Username field
                const Text(
                  'Username',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Email field
                const Text(
                  'Email',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // // Telephone field
                // const Text(
                //   'Telephone',
                //   style: TextStyle(color: Colors.white, fontSize: 16),
                // ),
                // const SizedBox(height: 8),
                // TextField(
                //   controller: _telephoneController,
                //   keyboardType: TextInputType.phone,
                //   decoration: const InputDecoration(
                //     filled: true,
                //     fillColor: Colors.white,
                //     contentPadding: EdgeInsets.symmetric(
                //       horizontal: 20,
                //       vertical: 16,
                //     ),
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.all(Radius.circular(8)),
                //       borderSide: BorderSide.none,
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 16),

                // // Address field
                // const Text(
                //   'Address',
                //   style: TextStyle(color: Colors.white, fontSize: 16),
                // ),
                // const SizedBox(height: 8),
                // TextField(
                //   controller: _addressController,
                //   maxLines: 3,
                //   decoration: const InputDecoration(
                //     filled: true,
                //     fillColor: Colors.white,
                //     contentPadding: EdgeInsets.symmetric(
                //       horizontal: 20,
                //       vertical: 16,
                //     ),
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.all(Radius.circular(8)),
                //       borderSide: BorderSide.none,
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 16),

                // Password field
                const Text(
                  'Password',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Confirmation field
                const Text(
                  'Konfirmasi Password',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordConfirmationController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
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
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                const SizedBox(height: 30),

                // Register button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
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
                              'Register',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
