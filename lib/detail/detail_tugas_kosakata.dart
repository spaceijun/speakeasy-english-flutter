import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_english/detail/data-jawaban/jawaban_grammars.dart';
import 'package:speak_english/detail/data-jawaban/jawaban_hafalan.dart';
import 'package:speak_english/detail/data-jawaban/jawaban_kosakata.dart';
import 'package:speak_english/detail/form/form_tugas_grammar.dart';
import 'package:speak_english/detail/form/form_tugas_kosakata.dart';

// Model untuk TugasKosakatas
class TugasKosakatas {
  final int id;
  final int kosakataId;
  final String kkm;
  final String bodyQuestions;
  final String createdAt;
  final String updatedAt;

  TugasKosakatas({
    required this.id,
    required this.kosakataId,
    required this.kkm,
    required this.bodyQuestions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TugasKosakatas.fromJson(Map<String, dynamic> json) {
    return TugasKosakatas(
      id: json['id'],
      kosakataId: json['kosakatas_id'],
      kkm: json['kkm'],
      bodyQuestions: json['body_questions'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class TugasKosakatasPage extends StatefulWidget {
  const TugasKosakatasPage({Key? key}) : super(key: key);

  @override
  State<TugasKosakatasPage> createState() => _TugasKosakatasPageState();
}

class _TugasKosakatasPageState extends State<TugasKosakatasPage> {
  late Future<List<TugasKosakatas>> _TugasKosakatassFuture;
  bool _isShowingTugas = true;

  @override
  void initState() {
    super.initState();
    _TugasKosakatassFuture = _fetchTugasKosakatass();
  }

  Future<List<TugasKosakatas>> _fetchTugasKosakatass() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      print('User ID yang sedang login: $userId'); // Log user ID

      if (userId == null) {
        throw Exception('User ID tidak ditemukan, harap login ulang');
      }
      final response = await http.get(
        Uri.parse(
          'https://speakeasy-english.web.id/api/tugas-kosakatas?user_id=$userId',
        ),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('API Response: $responseData'); // Log response

        if (responseData.containsKey('data')) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => TugasKosakatas.fromJson(json)).toList();
        } else {
          return [];
        }
      } else {
        throw Exception(
          'Failed to load tugas grammars: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('API Error: $e');
      throw Exception('Failed to connect to API: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Daftar Tugas Kosakata',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              setState(() {
                _TugasKosakatassFuture = _fetchTugasKosakatass();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Navigation Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isShowingTugas = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isShowingTugas ? Colors.blue : Colors.white,
                      foregroundColor:
                          _isShowingTugas ? Colors.white : Colors.grey.shade700,
                      elevation: _isShowingTugas ? 2 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment,
                          size: 16,
                          color:
                              _isShowingTugas
                                  ? Colors.white
                                  : Colors.grey.shade700,
                        ),
                        const SizedBox(width: 8),
                        const Text('Data Tugas'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to data_jawaban.dart
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const JawabanKosakatas(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !_isShowingTugas ? Colors.blue : Colors.white,
                      foregroundColor:
                          !_isShowingTugas
                              ? Colors.white
                              : Colors.grey.shade700,
                      elevation: !_isShowingTugas ? 2 : 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.question_answer,
                          size: 16,
                          color:
                              !_isShowingTugas
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade700,
                        ),
                        const SizedBox(width: 8),
                        const Text('Data Jawaban'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content area
          Expanded(
            child:
                _isShowingTugas
                    ? _buildTugasContent()
                    : const Center(
                      child: Text(
                        'Sedang mengalihkan ke halaman Data Jawaban...',
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildTugasContent() {
    return FutureBuilder<List<TugasKosakatas>>(
      future: _TugasKosakatassFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _TugasKosakatassFuture = _fetchTugasKosakatass();
                    });
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 80,
                  color: Colors.amber.shade300,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Belum Ada Tugas Kosakata',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Saat ini tidak ada tugas kosakata yang tersedia untuk Anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          );
        }

        final TugasKosakatass = snapshot.data!;

        return ListView.separated(
          itemCount: TugasKosakatass.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final tugas = TugasKosakatass[index];
            return TugasKosakatasTile(
              title: 'Tugas Kosakata ${tugas.id}',
              kosakataId: tugas.kosakataId,
              kkm: tugas.kkm,
              date: _formatDate(tugas.createdAt),
              onTap: () {
                _showTugasDetail(context, tugas);
              },
            );
          },
        );
      },
    );
  }

  void _showTugasDetail(BuildContext context, TugasKosakatas tugas) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tugas Grammar ${tugas.id}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              // Tanggal dan KKM
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Panduan:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildGuideItem(
                      icon: Icons.check_circle_outline,
                      text: 'Pastikan jawaban Anda jelas dan lengkap',
                    ),
                    _buildGuideItem(
                      icon: Icons.check_circle_outline,
                      text: 'Jawaban akan diperiksa oleh pengajar',
                    ),
                    _buildGuideItem(
                      icon: Icons.calendar_today,
                      text: 'Dibuat: ${_formatDate(tugas.createdAt)}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Pertanyaan
              const Text(
                'Pertanyaan:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    child: _buildHtmlContent(tugas.bodyQuestions),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Tombol aksi
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit_note, size: 16),
                    label: const Text('Jawab Tugas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context); // Tutup modal

                      // Navigasi ke halaman jawab tugas
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => FormTugasKosakata(
                                tugasKosakataId: tugas.id,
                                pertanyaan: tugas.bodyQuestions,
                                kkm: tugas.kkm,
                              ),
                        ),
                      );

                      // Jika hasil true, refresh data
                      if (result == true) {
                        setState(() {
                          _TugasKosakatassFuture = _fetchTugasKosakatass();
                        });
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget untuk menampilkan HTML content
  Widget _buildHtmlContent(String htmlContent) {
    // Dalam implementasi asli Anda perlu menggunakan package flutter_html
    // untuk render HTML dengan benar
    return Text(
      // Menghapus tag HTML sederhana
      htmlContent.replaceAll(RegExp(r'<[^>]*>'), ''),
      style: const TextStyle(fontSize: 14),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}

Widget _buildGuideItem({required IconData icon, required String text}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.green),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
          ),
        ),
      ],
    ),
  );
}

class TugasKosakatasTile extends StatelessWidget {
  final String title;
  final int kosakataId;
  final String kkm;
  final String date;
  final VoidCallback onTap;

  const TugasKosakatasTile({
    Key? key,
    required this.title,
    required this.kosakataId,
    required this.kkm,
    required this.date,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        color: Colors.white,
        child: Row(
          children: [
            // Icon dengan background berwarna
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: const Icon(
                Icons.assignment,
                color: Colors.amber,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            // Detail tugas
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Arrow icon
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
