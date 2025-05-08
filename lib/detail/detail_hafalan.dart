import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hafalan',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: const HafalanSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Screen to select which hafalan to view
class HafalanSelectionScreen extends StatelessWidget {
  const HafalanSelectionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hafalanTitles = {
      1: 'Ungkapan Penting',
      2: 'Percakapan Harian',
      3: 'Di Tempat Kerja',
      4: 'Traveling',
    };

    return Scaffold(
      backgroundColor: const Color(0xFFFDF3F1),
      appBar: AppBar(
        title: const Text('Pilih Hafalan'),
        elevation: 0,
        backgroundColor: const Color(0xFFFDF3F1),
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: hafalanTitles.length,
        itemBuilder: (context, index) {
          final id = index + 1;
          final title = hafalanTitles[id] ?? 'Hafalan $id';

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => DetailHafalan(hafalanId: id, title: title),
                ),
              );
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Text(
                          '$id',
                          style: const TextStyle(color: Color(0xFFFDF3F1)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(title, style: const TextStyle(fontSize: 18)),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
                const Divider(height: 1),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PhraseModel {
  final int id;
  final int hafalanId;
  final String name;
  final String description;

  PhraseModel({
    required this.id,
    required this.hafalanId,
    required this.name,
    required this.description,
  });

  factory PhraseModel.fromJson(Map<String, dynamic> json) {
    return PhraseModel(
      id: json['id'] ?? 0,
      hafalanId: json['hafalan_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class DetailHafalan extends StatefulWidget {
  final int hafalanId;
  final String title;

  const DetailHafalan({Key? key, required this.hafalanId, required this.title})
    : super(key: key);

  @override
  State<DetailHafalan> createState() => _DetailHafalanState();
}

class _DetailHafalanState extends State<DetailHafalan> {
  late Future<List<PhraseModel>> _phrasesFuture;

  @override
  void initState() {
    super.initState();
    _phrasesFuture = fetchPhrases();
  }

  Future<List<PhraseModel>> fetchPhrases() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://speakeasy-english.web.id/api/detail-hafalans?hafalan_id=${widget.hafalanId}',
        ),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('API Response: ${response.body}');
        // JSON Response
        final dynamic jsonData = json.decode(response.body);

        if (jsonData is Map &&
            jsonData.containsKey('data') &&
            jsonData['data'] is List) {
          final List<dynamic> phrasesList = jsonData['data'];

          // Filter berdasarkan hafalan_id
          return phrasesList
              .where((item) => item['hafalan_id'] == widget.hafalanId)
              .map((item) => PhraseModel.fromJson(item))
              .toList();
        }

        return [];
      } else {
        throw Exception('Failed to load phrases: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching phrases: $e');
      throw Exception('Failed to load phrases: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF3F1),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.title, style: const TextStyle(fontSize: 18)),
        elevation: 0,
        backgroundColor: const Color(0xFFFDF3F1),
        foregroundColor: Colors.black,
      ),
      body: FutureBuilder<List<PhraseModel>>(
        future: _phrasesFuture,
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
                        _phrasesFuture = fetchPhrases();
                      });
                    },
                    child: const Text('Retry'),
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
                    'Data Detail Hafalan Belum Tersedia.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _phrasesFuture = fetchPhrases();
                      });
                    },
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          } else {
            final phrases = snapshot.data!;
            return ListView.builder(
              itemCount: phrases.length,
              padding: const EdgeInsets.only(bottom: 24),
              itemBuilder: (context, index) {
                final phrase = phrases[index];
                return PhraseItem(
                  number: (index + 1).toString(),
                  englishPhrase: phrase.name,
                  indonesianPhrase: phrase.description,
                );
              },
            );
          }
        },
      ),
    );
  }
}

class PhraseItem extends StatelessWidget {
  final String number;
  final String englishPhrase;
  final String indonesianPhrase;

  const PhraseItem({
    Key? key,
    required this.number,
    required this.englishPhrase,
    required this.indonesianPhrase,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color:
                index.isEven
                    ? const Color(0xFFFDF3F1).withOpacity(0.5)
                    : Colors.transparent,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  '$number.',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: Text(
                  englishPhrase,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 5,
                child: Text(
                  indonesianPhrase,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  // Property for alternating row colors
  int get index => int.parse(number) - 1;
}
