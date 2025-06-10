import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';

class DetailGrammar extends StatefulWidget {
  final int id;
  final String title;

  const DetailGrammar({Key? key, required this.id, required this.title})
    : super(key: key);

  @override
  State<DetailGrammar> createState() => _DetailGrammarState();
}

class _DetailGrammarState extends State<DetailGrammar> {
  bool _isLoading = true;
  String _errorMessage = '';
  String _name = '';
  String _description = '';

  @override
  void initState() {
    super.initState();
    _fetchDetailData();
  }

  Future<void> _fetchDetailData() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://speakeasy-english.web.id/api/grammars/${widget.id}/details',
        ),
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

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

          // cari item dengan id yang cocok - handle string dan int
          final item = list.cast<Map>().firstWhere((e) {
            var apiId = e['detailgram_id'];
            // Convert keduanya ke string untuk perbandingan
            return apiId.toString() == widget.id.toString();
          }, orElse: () => {});

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
          final item = jsonData.cast<Map>().firstWhere((e) {
            var apiId = e['detailgram_id'];
            // Convert keduanya ke string untuk perbandingan
            return apiId.toString() == widget.id.toString();
          }, orElse: () => {});

          if (item.isNotEmpty) {
            _setDetail(item as Map<String, dynamic>);
          } else {
            setState(() {
              _errorMessage = 'Data dengan ID ${widget.id} tidak ditemukan';
              _isLoading = false;
            });
          }
        }
        /// 3) Jika API mengembalikan single object (detail untuk ID tertentu)
        else if (jsonData is Map<String, dynamic>) {
          // Jika response adalah single object, langsung set
          if (jsonData.containsKey('name') ||
              jsonData.containsKey('description')) {
            _setDetail(jsonData);
          } else {
            setState(() {
              _errorMessage = 'Format data dari API tidak sesuai';
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
      print('Error: $e');
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
        title: Text(widget.title, style: const TextStyle(color: Colors.black)),
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
            // Description with HTML rendering
            Container(
              padding: const EdgeInsets.all(.0),
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child:
                  _description.isNotEmpty
                      ? Html(
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
                          "ul": Style(
                            margin: Margins.only(left: 20, top: 10, bottom: 10),
                          ),
                          "ol": Style(
                            margin: Margins.only(left: 20, top: 10, bottom: 10),
                          ),
                          "li": Style(margin: Margins.only(bottom: 8)),
                          "strong": Style(fontWeight: FontWeight.bold),
                          "em": Style(fontStyle: FontStyle.italic),
                          "code": Style(
                            backgroundColor: const Color(0xFFEEEEEE),
                            padding: HtmlPaddings.symmetric(horizontal: 4),
                            fontFamily: 'monospace',
                          ),
                        },
                      )
                      : const Text(
                        'Tidak ada deskripsi tersedia',
                        style: TextStyle(fontSize: 16),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
