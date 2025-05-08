import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FormTugasTenses extends StatefulWidget {
  final int tugasTensesId;
  final String pertanyaan;
  final String kkm;

  const FormTugasTenses({
    Key? key,
    required this.tugasTensesId,
    required this.pertanyaan,
    required this.kkm,
  }) : super(key: key);

  @override
  State<FormTugasTenses> createState() => _FormTugasTensesState();
}

class _FormTugasTensesState extends State<FormTugasTenses> {
  final TextEditingController _jawabanController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _jawabanController.dispose();
    super.dispose();
  }

  Future<void> _submitJawaban() async {
    if (_jawabanController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Jawaban tidak boleh kosong';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User ID tidak ditemukan, harap login ulang';
        });
        return;
      }

      final response = await http.post(
        Uri.parse('https://speakeasy-english.web.id/api/jawaban-tenses'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'user_id': userId.toString(),
          'tugas_tenses_id': widget.tugasTensesId,
          'body_answers': _jawabanController.text,
        }),
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Berhasil
        setState(() {
          _isSubmitted = true;
        });

        // Tampilkan snackbar sukses
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jawaban berhasil dikirim!'),
            backgroundColor: Colors.green,
          ),
        );

        // Kembali ke halaman sebelumnya setelah 2 detik
        Future.delayed(const Duration(seconds: 2), () {
          if (!mounted) return;
          Navigator.pop(
            context,
            true,
          ); // Return true untuk refresh halaman tugas
        });
      } else {
        // Error
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          _errorMessage =
              responseData['message'] ??
              'Terjadi kesalahan saat mengirim jawaban';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Tugas Kosakata',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: _isSubmitted ? _buildSuccessScreen() : _buildFormScreen(),
    );
  }

  Widget _buildSuccessScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
          const SizedBox(height: 16),
          const Text(
            'Jawaban Terkirim!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Jawaban Anda telah berhasil dikirim',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          const Text(
            'Mengarahkan kembali ke halaman tugas...',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade300),
          ),
        ],
      ),
    );
  }

  Widget _buildFormScreen() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Petunjuk
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(16),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFFFE9BD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Petunjuk: Jawablah pertanyaan di bawah ini dengan menggunakan ungkapan yang sesuai dari daftar Tenses!.',
              style: TextStyle(fontSize: 14),
            ),
          ),

          SizedBox(height: 16),

          // Jawaban Section
          Container(
            width: double.infinity,
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Color(0xFFFFDC80),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Jawaban',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 160,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _jawabanController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Tulis jawaban Anda di sini...',
                      errorText: _errorMessage,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Submit Button
          Center(
            child: Container(
              width: 120,
              height: 40,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitJawaban,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFFD175),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 1,
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black54,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          'Tambah',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
