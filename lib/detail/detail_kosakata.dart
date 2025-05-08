import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class KosakataDetail {
  final int id;
  final int kosakataId;
  final String englishWord;
  final String indonesianWord;
  final String example;
  final String audio;

  KosakataDetail({
    required this.id,
    required this.kosakataId,
    required this.englishWord,
    required this.indonesianWord,
    required this.example,
    required this.audio,
  });

  factory KosakataDetail.fromJson(Map<String, dynamic> json) {
    return KosakataDetail(
      id: json['id'] ?? 0,
      kosakataId: json['kosakata_id'] ?? 0,
      englishWord: json['english_word'] ?? '',
      indonesianWord: json['indonesian_word'] ?? '',
      example: json['example'] ?? '',
      audio: json['audio'] ?? '',
    );
  }
}

class DetailKosakata extends StatefulWidget {
  final String categoryTitle;
  final String categoryImage;
  final int categoryId;

  const DetailKosakata({
    Key? key,
    required this.categoryTitle,
    required this.categoryImage,
    required this.categoryId,
  }) : super(key: key);

  @override
  State<DetailKosakata> createState() => _DetailKosakataState();
}

class _DetailKosakataState extends State<DetailKosakata> {
  late Future<List<KosakataDetail>> _detailsFuture;

  @override
  void initState() {
    super.initState();
    _detailsFuture = fetchKosakataDetails();
  }

  Future<List<KosakataDetail>> fetchKosakataDetails() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://speakeasy-english.web.id/api/materi-kosakatas?kosakatas_id=${widget.categoryId}',
        ),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('API Response: ${response.body}');
        // JSON Response
        final dynamic jsonData = json.decode(response.body);

        // Penanganan untuk kedua format response yang mungkin
        if (jsonData is List) {
          // Format lama: langsung berupa list
          return jsonData
              .where((item) => item['kosakatas_id'] == widget.categoryId)
              .map((item) => KosakataDetail.fromJson(item))
              .toList();
        } else if (jsonData is Map &&
            jsonData.containsKey('data') &&
            jsonData['data'] is List) {
          // Format baru: memiliki wrapper "data" seperti DetailHafalan
          final List<dynamic> detailsList = jsonData['data'];

          return detailsList
              .where((item) => item['kosakata_id'] == widget.categoryId)
              .map((item) => KosakataDetail.fromJson(item))
              .toList();
        }

        return [];
      } else {
        throw Exception('Gagal memuat detail kosakata: ${response.statusCode}');
      }
    } catch (e) {
      print('Error mengambil detail kosakata: $e');
      throw Exception('Gagal memuat detail kosakata: $e');
    }
  }

  // Helper method untuk mendapatkan terjemahan kategori dalam bahasa Indonesia
  String _getCategoryTranslation(String category) {
    final Map<String, String> translations = {
      'Pronoun': 'Kata Ganti',
      'Family': 'Keluarga',
      'Personality': 'Kepribadian',
      'Country': 'Negara',
      'Body Shape': 'Bentuk Tubuh',
      'Housekeeping': 'Rumah Tangga',
      'Home Section': 'Bagian Rumah',
      'School Major': 'Jurusan Sekolah',
      'Shopping': 'Berbelanja',
      'Transportation': 'Transportasi',
      'Season': 'Musim',
      'Weather': 'Cuaca',
      'Nature': 'Alam',
      'Body Move': 'Gerakan Tubuh',
      'Education': 'Pendidikan',
      'Propotion Of Place': 'Proporsi Tempat',
      'Preposition Of Manner': 'Kata Depan Cara',
      'Conjunction': 'Kata Penghubung',
    };

    return translations[category] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDBFFD9), // Latar belakang hijau muda
      appBar: AppBar(
        backgroundColor: const Color(0xFFDBFFD9),
        elevation: 0,
        title: Text(
          "${widget.categoryTitle} (${_getCategoryTranslation(widget.categoryTitle)})",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<KosakataDetail>>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _detailsFuture = fetchKosakataDetails();
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
                  const Text(
                    'Data Detail Kosakata Belum Tersedia.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _detailsFuture = fetchKosakataDetails();
                      });
                    },
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          } else {
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: snapshot.data!.length,
              separatorBuilder:
                  (context, index) =>
                      Divider(height: 1, color: Colors.green.withOpacity(0.3)),
              itemBuilder: (context, index) {
                final item = snapshot.data![index];
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.englishWord,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.indonesianWord,
                          style: const TextStyle(fontSize: 15),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      if (item.audio.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.volume_up, size: 20),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Memutar audio untuk ${item.englishWord}',
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
