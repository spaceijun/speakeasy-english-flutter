import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';

class DetailTenses extends StatefulWidget {
  final int id;
  final String title;

  const DetailTenses({Key? key, required this.id, required this.title})
    : super(key: key);

  @override
  State<DetailTenses> createState() => _DetailTensesState();
}

class _DetailTensesState extends State<DetailTenses> {
  bool _isLoading = true;
  String _errorMessage = '';
  String _name = '';
  String _description = '';

  @override
  void initState() {
    super.initState();
    _fetchDetailData();
  }

  // Helper function to safely convert to int
  int _safeParseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }

  Future<void> _fetchDetailData() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://speakeasy-english.web.id/api/materi-tenses?detail_tenses_id=${widget.id}',
        ),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        /// helper untuk meng-assign state
        void _setDetail(Map<String, dynamic> item) {
          setState(() {
            _name = item['name'] ?? '';
            _description = item['description'] ?? '';
            _isLoading = false;
          });
        }

        /// 1) Jika API berupa objek dengan key `data`
        if (jsonData is Map<String, dynamic> && jsonData['data'] is List) {
          final List list = jsonData['data'];

          // cari item dengan id yang cocok - dengan konversi type yang aman
          final item = list.cast<Map>().firstWhere(
            (e) => _safeParseInt(e['detail_tenses_id']) == widget.id,
            orElse: () => {},
          );

          if (item.isNotEmpty) {
            _setDetail(item as Map<String, dynamic>);
          } else {
            setState(() {
              _errorMessage = 'Data dengan ID ${widget.id} tidak ditemukan';
              _isLoading = false;
            });
          }
        }
        /// 2) Jika API langsung mengembalikan array
        else if (jsonData is List) {
          final item = jsonData.cast<Map>().firstWhere(
            (e) => _safeParseInt(e['detail_tenses_id']) == widget.id,
            orElse: () => {},
          );

          if (item.isNotEmpty) {
            _setDetail(item as Map<String, dynamic>);
          } else {
            setState(() {
              _errorMessage = 'Data dengan ID ${widget.id} tidak ditemukan';
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _errorMessage = 'Format data dari API tidak sesuai';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Gagal memuat data: Server error ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFCE4EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _errorMessage = '';
                          });
                          _fetchDetailData();
                        },
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              )
              : _buildContentView(),
    );
  }

  Widget _buildContentView() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                _name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF000000),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Divider
            Container(
              height: 2,
              color: const Color(0xFFFCE4EC),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
            ),

            // Description with HTML rendering
            Container(
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.symmetric(vertical: 8.0),

              child: Html(
                data: _description,
                style: {
                  "body": Style(
                    fontSize: FontSize(16),
                    lineHeight: LineHeight(1.5),
                  ),

                  "h1": Style(
                    fontSize: FontSize(20),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF9C27B0),
                    margin: Margins.only(bottom: 16),
                  ),

                  "h2": Style(
                    fontSize: FontSize(18),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF9C27B0),
                    margin: Margins.only(top: 16, bottom: 12),
                  ),

                  "p": Style(margin: Margins.only(bottom: 10)),

                  "table": Style(
                    border: const Border(
                      bottom: BorderSide(color: Colors.black),
                      top: BorderSide(color: Colors.black),
                      left: BorderSide(color: Colors.black),
                      right: BorderSide(color: Colors.black),
                    ),
                  ),

                  "th": Style(
                    backgroundColor: const Color(0xFFF8BBD0),
                    padding: HtmlPaddings.all(8),
                    alignment: Alignment.center,
                    fontWeight: FontWeight.bold,
                  ),

                  "td": Style(
                    padding: HtmlPaddings.all(8),
                    alignment: Alignment.center,
                  ),

                  "tr": Style(
                    border: const Border(
                      bottom: BorderSide(color: Colors.grey),
                    ),
                  ),

                  // daftar tak berurutan
                  "ul": Style(
                    margin: Margins.only(left: 20, top: 10, bottom: 10),
                  ),

                  // daftar bernomor
                  "ol": Style(
                    margin: Margins.only(left: 20, top: 10, bottom: 10),
                  ),

                  // item daftar
                  "li": Style(margin: Margins.only(bottom: 8)),

                  "strong": Style(fontWeight: FontWeight.bold),
                  "em": Style(fontStyle: FontStyle.italic),

                  "code": Style(
                    backgroundColor: const Color(0xFFEEEEEE),
                    padding: HtmlPaddings.symmetric(horizontal: 4),
                    fontFamily: 'monospace',
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
