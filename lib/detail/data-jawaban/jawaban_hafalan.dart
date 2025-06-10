import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Model untuk JawabanTugas
class JawabanTugas {
  final int id;
  final int tugasHafalanId;
  final int userId;
  final String bodyAnswers;
  final String nilai;
  final String status;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic>? tugasHafalan;

  JawabanTugas({
    required this.id,
    required this.tugasHafalanId,
    required this.userId,
    required this.bodyAnswers,
    required this.nilai,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.tugasHafalan,
  });

  factory JawabanTugas.fromJson(Map<String, dynamic> json) {
    return JawabanTugas(
      id: _parseInt(json['id']),
      tugasHafalanId: _parseInt(json['tugas_hafalan_id']),
      userId: _parseInt(json['user_id']),
      bodyAnswers: json['body_answers']?.toString() ?? '',
      nilai: json['nilai']?.toString() ?? '0',
      status: json['status']?.toString() ?? 'Belum Dikoreksi',
      createdAt: json['created_at']?.toString() ?? DateTime.now().toString(),
      updatedAt: json['updated_at']?.toString() ?? DateTime.now().toString(),
      tugasHafalan:
          json['tugas_hafalan'] != null
              ? (json['tugas_hafalan'] is Map
                  ? Map<String, dynamic>.from(json['tugas_hafalan'])
                  : null)
              : null,
    );
  }

  // Helper method to safely parse integer values
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}

class DataJawabanPage extends StatefulWidget {
  const DataJawabanPage({Key? key}) : super(key: key);

  @override
  State<DataJawabanPage> createState() => _DataJawabanPageState();
}

class _DataJawabanPageState extends State<DataJawabanPage> {
  late Future<List<JawabanTugas>> _jawabanTugasFuture;
  bool _isShowingJawaban = true; // Track which view is active

  @override
  void initState() {
    super.initState();
    _jawabanTugasFuture = _fetchJawabanTugas();
  }

  Future<List<JawabanTugas>> _fetchJawabanTugas() async {
    try {
      // Mendapatkan user_id dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      final token = prefs.getString('token'); // Ambil token juga
      print('User ID yang sedang login: $userId'); // Log user ID

      if (userId == null) {
        throw Exception('User ID tidak ditemukan, harap login ulang');
      }

      // Buat URL dengan parameter user_id
      final response = await http.get(
        Uri.parse(
          'https://speakeasy-english.web.id/api/jawaban-hafalan/user/$userId',
        ),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        print('API Response: $responseData'); // Log response

        List<JawabanTugas> jawabanList = [];

        // Periksa apakah respons adalah Map atau List
        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            // Kasus jika API mengembalikan struktur {"data": [...]}
            final List<dynamic> data = responseData['data'];
            jawabanList =
                data.map((json) => JawabanTugas.fromJson(json)).toList();
          } else if (responseData.containsKey('jawaban')) {
            // Kemungkinan struktur lain {"jawaban": [...]}
            final List<dynamic> data = responseData['jawaban'];
            jawabanList =
                data.map((json) => JawabanTugas.fromJson(json)).toList();
          } else {
            // Jika responseData adalah object tunggal, buat list
            jawabanList = [JawabanTugas.fromJson(responseData)];
          }
        } else if (responseData is List) {
          // Kasus jika API langsung mengembalikan array jawaban
          jawabanList =
              responseData.map((json) => JawabanTugas.fromJson(json)).toList();
        } else {
          print('Format respons API tidak dikenali: $responseData');
          return [];
        }

        // Filter jawaban yang tidak kosong dan sort berdasarkan tanggal terbaru
        jawabanList =
            jawabanList
                .where((jawaban) => jawaban.bodyAnswers.isNotEmpty)
                .toList();

        // Sort berdasarkan tanggal terbaru
        jawabanList.sort(
          (a, b) => DateTime.parse(
            b.createdAt,
          ).compareTo(DateTime.parse(a.createdAt)),
        );

        print('Total jawaban ditemukan: ${jawabanList.length}');
        return jawabanList;
      } else if (response.statusCode == 404) {
        // Tidak ada jawaban ditemukan
        print('Tidak ada jawaban ditemukan untuk user ini');
        return [];
      } else {
        throw Exception('Gagal memuat data jawaban: ${response.statusCode}');
      }
    } catch (e) {
      print('API Error: $e');
      throw Exception('Gagal terhubung ke API: $e');
    }
  }

  String _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'belum dikoreksi':
      case 'pending':
      case 'menunggu koreksi':
        return 'orange';
      case 'sudah dikoreksi':
      case 'selesai':
      case 'corrected':
      case 'completed':
        return 'green';
      case 'lulus':
      case 'diterima':
      case 'approved':
        return 'green';
      case 'tidak lulus':
      case 'ditolak':
      case 'rejected':
        return 'red';
      default:
        return 'grey';
    }
  }

  // Navigate to TugasPage
  void _navigateToTugasPage() {
    // Replace this with your actual navigation to TugasPage
    Navigator.pop(context); // This will go back to previous screen
    // If you need to navigate to a specific page instead, use:
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => const TugasPage()),
    // );
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
          'Data Jawaban Hafalan',
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
                _jawabanTugasFuture = _fetchJawabanTugas();
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
                    onPressed: _navigateToTugasPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !_isShowingJawaban
                              ? Colors.blue
                              : Colors.grey.shade200,
                      foregroundColor:
                          !_isShowingJawaban
                              ? Colors.white
                              : Colors.grey.shade700,
                      elevation: !_isShowingJawaban ? 2 : 0,
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
                              !_isShowingJawaban
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
                      // Already on DataJawabanPage
                      setState(() {
                        _isShowingJawaban = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isShowingJawaban
                              ? Colors.blue
                              : Colors.grey.shade200,
                      foregroundColor:
                          _isShowingJawaban
                              ? Colors.white
                              : Colors.grey.shade700,
                      elevation: _isShowingJawaban ? 2 : 0,
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
                              _isShowingJawaban
                                  ? Colors.white
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
            child: FutureBuilder<List<JawabanTugas>>(
              future: _jawabanTugasFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Container(
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 60,
                            color: Colors.red,
                          ),
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
                                _jawabanTugasFuture = _fetchJawabanTugas();
                              });
                            },
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Container(
                    color: Colors.white,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.question_answer_outlined,
                            size: 80,
                            color: Colors.blue.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Belum Ada Jawaban Tugas',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'Anda belum mengerjakan tugas hafalan apapun atau jawaban sedang diproses',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _jawabanTugasFuture = _fetchJawabanTugas();
                              });
                            },
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final jawabanTugas = snapshot.data!;

                return Container(
                  color: Colors.white,
                  child: ListView.separated(
                    itemCount: jawabanTugas.length,
                    separatorBuilder:
                        (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final jawaban = jawabanTugas[index];

                      // Pastikan jawaban memiliki konten
                      if (jawaban.bodyAnswers.isEmpty) {
                        return const SizedBox.shrink(); // Skip jika jawaban kosong
                      }

                      final String tugasTitle =
                          jawaban.tugasHafalan != null &&
                                  jawaban.tugasHafalan!.containsKey('judul')
                              ? jawaban.tugasHafalan!['judul']
                              : jawaban.tugasHafalan != null
                              ? 'Tugas Hafalan ${jawaban.tugasHafalan!['id'] ?? jawaban.tugasHafalanId}'
                              : 'Tugas Hafalan ${jawaban.tugasHafalanId}';

                      return JawabanTugasTile(
                        title: tugasTitle,
                        nilai: jawaban.nilai,
                        status: jawaban.status,
                        date: _formatDate(jawaban.createdAt),
                        statusColor: _getStatusColor(jawaban.status),
                        onTap: () {
                          _showJawabanDetail(context, jawaban);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showJawabanDetail(BuildContext context, JawabanTugas jawaban) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                    'Jawaban Tugas ${jawaban.id}',
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
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: _getStatusColorIcon(jawaban.status),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Status: ${jawaban.status}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: _getStatusColorIcon(jawaban.status),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildGuideItem(
                      icon: Icons.calendar_today,
                      text: 'Dikirim: ${_formatDate(jawaban.createdAt)}',
                    ),
                    _buildGuideItem(
                      icon: Icons.check_circle_outline,
                      text: 'Nilai: ${jawaban.nilai}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Jawaban
              const Text(
                'Jawaban Anda:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHtmlContent(jawaban.bodyAnswers),
                        // Tampilkan feedback jika ada
                        if (jawaban.status.toLowerCase() == 'sudah dikoreksi' ||
                            jawaban.status.toLowerCase() == 'selesai') ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.feedback,
                                      size: 16,
                                      color: Colors.blue.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Feedback Koreksi:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Nilai: ${jawaban.nilai}/100',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Status: ${jawaban.status}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete Jawaban'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
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
                      _showDeleteConfirmation(context, jawaban);
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

  void _showDeleteConfirmation(BuildContext context, JawabanTugas jawaban) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus jawaban tugas ini?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              onPressed: () {
                // Tutup dialog konfirmasi
                Navigator.of(context).pop();
                // Tutup bottom sheet
                Navigator.of(context).pop();
                // Panggil fungsi untuk menghapus jawaban
                _deleteJawabanTugas(jawaban.id);
              },
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk menghapus jawaban tugas
  Future<void> _deleteJawabanTugas(int jawabanId) async {
    try {
      // Menampilkan loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      // Mendapatkan token dari SharedPreferences jika diperlukan
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Buat request untuk menghapus data
      final response = await http.delete(
        Uri.parse(
          'https://speakeasy-english.web.id/api/jawaban-hafalans/$jawabanId',
        ),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      // Tutup loading indicator
      Navigator.of(context).pop();

      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          _jawabanTugasFuture = _fetchJawabanTugas();
        });

        // Tampilkan pesan sukses
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Jawaban tugas berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Tampilkan pesan error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus jawaban: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Tutup loading indicator jika terjadi error
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }

      // Tampilkan pesan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Widget untuk menampilkan HTML content
  Widget _buildHtmlContent(String htmlContent) {
    // Dalam implementasi sebenarnya, gunakan flutter_html
    // untuk render HTML dengan benar
    return Text(
      // Menghapus tag HTML sederhana
      htmlContent.replaceAll(RegExp(r'<[^>]*>'), ''),
      style: const TextStyle(fontSize: 14),
    );
  }

  Color _getStatusColorIcon(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu penilaian':
      case 'belum dikoreksi':
        return Colors.orange;
      case 'lulus':
      case 'diterima':
      case 'sudah dikoreksi':
        return Colors.green;
      case 'tidak lulus':
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.grey;
    }
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

class JawabanTugasTile extends StatelessWidget {
  final String title;
  final String nilai;
  final String status;
  final String date;
  final String statusColor;
  final VoidCallback onTap;

  const JawabanTugasTile({
    Key? key,
    required this.title,
    required this.nilai,
    required this.status,
    required this.date,
    required this.statusColor,
    required this.onTap,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (statusColor) {
      case 'green':
        return Colors.green;
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            // Icon dengan background berwarna
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.question_answer,
                color: Colors.blue,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            // Detail jawaban
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
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              decoration: BoxDecoration(
                color: _getStatusColor(),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
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
