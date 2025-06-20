import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_english/detail/data-jawaban/jawaban_hafalan.dart';
import 'package:speak_english/detail/form/form_tugas_hafalan.dart';

// Model untuk TugasHafalan - Fixed version
class TugasHafalan {
  final int id;
  final int hafalanId;
  final String kkm;
  final String bodyQuestions;
  final String createdAt;
  final String updatedAt;

  TugasHafalan({
    required this.id,
    required this.hafalanId,
    required this.kkm,
    required this.bodyQuestions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TugasHafalan.fromJson(Map<String, dynamic> json) {
    return TugasHafalan(
      // Safely parse id - handle both String and int
      id: json['id'] is String ? int.parse(json['id']) : json['id'],
      // Safely parse hafalan_id - handle both String and int
      hafalanId:
          json['hafalan_id'] is String
              ? int.parse(json['hafalan_id'])
              : json['hafalan_id'],
      // Safely handle kkm - ensure it's a String
      kkm: json['kkm']?.toString() ?? '',
      // Safely handle body_questions - ensure it's a String
      bodyQuestions: json['body_questions']?.toString() ?? '',
      // Safely handle created_at - ensure it's a String
      createdAt: json['created_at']?.toString() ?? '',
      // Safely handle updated_at - ensure it's a String
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}

class TugasHafalanPage extends StatefulWidget {
  const TugasHafalanPage({Key? key}) : super(key: key);

  @override
  State<TugasHafalanPage> createState() => _TugasHafalanPageState();
}

class _TugasHafalanPageState extends State<TugasHafalanPage> {
  late Future<List<TugasHafalan>> _tugasHafalansFuture;
  bool _isShowingTugas = true;

  @override
  void initState() {
    super.initState();
    _tugasHafalansFuture = _fetchTugasHafalans();
  }

  Future<List<TugasHafalan>> _fetchTugasHafalans() async {
    try {
      // Mendapatkan user_id dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      print('User ID yang sedang login: $userId'); // Log user ID

      if (userId == null) {
        throw Exception('User ID tidak ditemukan, harap login ulang');
      }

      // Buat URL dengan parameter user_id
      final response = await http.get(
        Uri.parse(
          'https://speakeasy-english.web.id/api/tugas-hafalans?user_id=$userId',
        ),
        headers: {'Accept': 'application/json'},
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print('API Response: $responseData'); // Log response

        if (responseData.containsKey('data')) {
          final List<dynamic> data = responseData['data'];
          print('Data count: ${data.length}');

          // Print first item structure for debugging
          if (data.isNotEmpty) {
            print('First item structure: ${data[0]}');
          }

          return data.map((json) {
            try {
              return TugasHafalan.fromJson(json);
            } catch (e) {
              print('Error parsing item: $json');
              print('Parse error: $e');
              rethrow;
            }
          }).toList();
        } else {
          return [];
        }
      } else {
        throw Exception(
          'Failed to load tugas hafalans: ${response.statusCode}',
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
          'Daftar Tugas Hafalan',
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
                _tugasHafalansFuture = _fetchTugasHafalans();
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
                          builder: (context) => const DataJawabanPage(),
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
    return FutureBuilder<List<TugasHafalan>>(
      future: _tugasHafalansFuture,
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
                      _tugasHafalansFuture = _fetchTugasHafalans();
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
                  'Belum Ada Tugas Hafalan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Saat ini tidak ada tugas hafalan yang tersedia untuk Anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          );
        }

        final tugasHafalans = snapshot.data!;

        return ListView.separated(
          itemCount: tugasHafalans.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final tugas = tugasHafalans[index];
            return TugasHafalanTile(
              title: 'Tugas Hafalan ${tugas.id}',
              hafalanId: tugas.hafalanId,
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

  void _showTugasDetail(BuildContext context, TugasHafalan tugas) {
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
                    'Tugas Hafalan ${tugas.id}',
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
                              (context) => FormTugasHafalan(
                                tugasHafalanId: tugas.id,
                                pertanyaan: tugas.bodyQuestions,
                                kkm: tugas.kkm,
                              ),
                        ),
                      );

                      // Jika hasil true, refresh data
                      if (result == true) {
                        setState(() {
                          _tugasHafalansFuture = _fetchTugasHafalans();
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

class TugasHafalanTile extends StatelessWidget {
  final String title;
  final int hafalanId;
  final String kkm;
  final String date;
  final VoidCallback onTap;

  const TugasHafalanTile({
    Key? key,
    required this.title,
    required this.hafalanId,
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
