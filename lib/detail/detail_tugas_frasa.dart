import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speak_english/detail/data-jawaban/jawaban_frasa.dart';
import 'package:speak_english/detail/form/form_tugas_frasa.dart';

// Model untuk TugasFrasa dengan improved type handling
class TugasFrasa {
  final int id;
  final int frasaId;
  final String kkm;
  final String bodyQuestions;
  final String createdAt;
  final String updatedAt;

  TugasFrasa({
    required this.id,
    required this.frasaId,
    required this.kkm,
    required this.bodyQuestions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TugasFrasa.fromJson(Map<String, dynamic> json) {
    return TugasFrasa(
      // Safe parsing for integers - handle both int and string types
      id: _parseToInt(json['id']),
      frasaId: _parseToInt(json['frasa_id']),
      // Safe parsing for strings with null handling
      kkm: _parseToString(json['kkm']),
      bodyQuestions: _parseToString(json['body_questions']),
      createdAt: _parseToString(json['created_at']),
      updatedAt: _parseToString(json['updated_at']),
    );
  }

  // Helper method to safely parse integer values
  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  // Helper method to safely parse string values
  static String _parseToString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }
}

class TugasFrasaPage extends StatefulWidget {
  const TugasFrasaPage({Key? key}) : super(key: key);

  @override
  State<TugasFrasaPage> createState() => _TugasFrasaPageState();
}

class _TugasFrasaPageState extends State<TugasFrasaPage> {
  late Future<List<TugasFrasa>> _TugasFrasasFuture;
  bool _isShowingTugas = true;

  @override
  void initState() {
    super.initState();
    _TugasFrasasFuture = _fetchTugasFrasas();
  }

  Future<List<TugasFrasa>> _fetchTugasFrasas() async {
    try {
      // Mendapatkan user_id dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');
      print('User ID yang sedang login: $userId');

      if (userId == null) {
        throw Exception('User ID tidak ditemukan, harap login ulang');
      }

      // Buat URL dengan parameter user_id
      final response = await http.get(
        Uri.parse(
          'https://speakeasy-english.web.id/api/tugas-frasas?user_id=$userId',
        ),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = json.decode(response.body);
        print('Parsed Response: $responseData');

        // Handle different response structures
        List<dynamic> dataList = [];

        if (responseData is Map<String, dynamic>) {
          if (responseData.containsKey('data')) {
            dataList = responseData['data'] as List<dynamic>? ?? [];
          } else if (responseData.containsKey('tugas_frasa')) {
            dataList = responseData['tugas_frasa'] as List<dynamic>? ?? [];
          } else {
            // If the response structure is unexpected, try to use the response as is
            print('Unexpected response structure: $responseData');
            return [];
          }
        } else if (responseData is List<dynamic>) {
          dataList = responseData;
        }

        print('Data List Length: ${dataList.length}');

        // Parse each item with error handling
        List<TugasFrasa> tugasList = [];
        for (int i = 0; i < dataList.length; i++) {
          try {
            final item = dataList[i];
            print('Processing item $i: $item');

            if (item is Map<String, dynamic>) {
              tugasList.add(TugasFrasa.fromJson(item));
            } else {
              print('Item $i is not a Map: ${item.runtimeType}');
            }
          } catch (e) {
            print('Error parsing item $i: $e');
            // Continue with next item instead of failing completely
          }
        }

        return tugasList;
      } else {
        throw Exception(
          'Failed to load tugas Frasa: ${response.statusCode}\nResponse: ${response.body}',
        );
      }
    } catch (e) {
      print('API Error: $e');
      // Provide more specific error information
      if (e is FormatException) {
        throw Exception('Invalid JSON response from server');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('No internet connection');
      } else {
        throw Exception('Failed to connect to API: $e');
      }
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
          'Daftar Tugas Frasa',
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
                _TugasFrasasFuture = _fetchTugasFrasas();
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
                          builder: (context) => const JawabanFrasa(),
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
                          color: Colors.grey.shade700,
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
    return FutureBuilder<List<TugasFrasa>>(
      future: _TugasFrasasFuture,
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _TugasFrasasFuture = _fetchTugasFrasas();
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
                  'Belum Ada Tugas Frasa',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'Saat ini tidak ada tugas Frasa yang tersedia untuk Anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          );
        }

        final TugasFrasas = snapshot.data!;

        return ListView.separated(
          itemCount: TugasFrasas.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final tugas = TugasFrasas[index];
            return TugasFrasaTile(
              title: 'Tugas Frasa ${tugas.id}',
              frasaId: tugas.frasaId,
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

  void _showTugasDetail(BuildContext context, TugasFrasa tugas) {
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
                    'Tugas Frasa ${tugas.id}',
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
                      Navigator.pop(context);

                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => FormTugasFrasa(
                                tugasFrasaId: tugas.id,
                                pertanyaan: tugas.bodyQuestions,
                                kkm: tugas.kkm,
                              ),
                        ),
                      );

                      if (result == true) {
                        setState(() {
                          _TugasFrasasFuture = _fetchTugasFrasas();
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

  Widget _buildHtmlContent(String htmlContent) {
    return Text(
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

class TugasFrasaTile extends StatelessWidget {
  final String title;
  final int frasaId;
  final String kkm;
  final String date;
  final VoidCallback onTap;

  const TugasFrasaTile({
    Key? key,
    required this.title,
    required this.frasaId,
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
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
