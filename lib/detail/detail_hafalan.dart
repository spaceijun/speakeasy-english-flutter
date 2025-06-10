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
      title: 'Indonesian Phrases',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: const HafalanSelectionScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

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
    // Debug print untuk melihat struktur data
    print('Parsing phrase JSON: $json');

    return PhraseModel(
      id: _parseToInt(json['id']),
      hafalanId: _parseToInt(json['hafalan_id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  // Helper method untuk mengkonversi ke int dengan aman
  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    if (value is double) return value.toInt();
    return 0;
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
          'https://speakeasy-english.web.id/api/hafalan/${widget.hafalanId}/details',
        ),
        headers: {'Accept': 'application/json'},
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);
        print('Parsed JSON Data: $jsonData');

        List<PhraseModel> phrases = [];

        // Handle different response formats
        if (jsonData is Map) {
          // Check for 'data' key first
          if (jsonData.containsKey('data')) {
            final data = jsonData['data'];
            if (data is List) {
              phrases =
                  data
                      .map((item) {
                        try {
                          return PhraseModel.fromJson(
                            Map<String, dynamic>.from(item),
                          );
                        } catch (e) {
                          print('Error parsing item: $item, Error: $e');
                          return null;
                        }
                      })
                      .where((item) => item != null)
                      .cast<PhraseModel>()
                      .toList();
            } else if (data is Map) {
              // If data is a map, look for lists inside it
              for (var key in data.keys) {
                if (data[key] is List) {
                  phrases =
                      (data[key] as List)
                          .map((item) {
                            try {
                              return PhraseModel.fromJson(
                                Map<String, dynamic>.from(item),
                              );
                            } catch (e) {
                              print('Error parsing item: $item, Error: $e');
                              return null;
                            }
                          })
                          .where((item) => item != null)
                          .cast<PhraseModel>()
                          .toList();
                  break;
                }
              }
            }
          } else {
            // Look for any list in the root object
            for (var key in jsonData.keys) {
              if (jsonData[key] is List) {
                phrases =
                    (jsonData[key] as List)
                        .map((item) {
                          try {
                            return PhraseModel.fromJson(
                              Map<String, dynamic>.from(item),
                            );
                          } catch (e) {
                            print('Error parsing item: $item, Error: $e');
                            return null;
                          }
                        })
                        .where((item) => item != null)
                        .cast<PhraseModel>()
                        .toList();
                break;
              }
            }
          }
        } else if (jsonData is List) {
          // Direct array response
          phrases =
              jsonData
                  .map((item) {
                    try {
                      return PhraseModel.fromJson(
                        Map<String, dynamic>.from(item),
                      );
                    } catch (e) {
                      print('Error parsing item: $item, Error: $e');
                      return null;
                    }
                  })
                  .where((item) => item != null)
                  .cast<PhraseModel>()
                  .toList();
        }

        print('Total phrases found: ${phrases.length}');

        // Filter phrases by hafalan_id (but only if we have multiple hafalan data)
        final filteredPhrases =
            phrases.where((phrase) {
              print(
                'Phrase hafalan_id: ${phrase.hafalanId}, Target hafalan_id: ${widget.hafalanId}',
              );
              return phrase.hafalanId == widget.hafalanId;
            }).toList();

        print('Filtered phrases count: ${filteredPhrases.length}');

        // If no phrases match the filter, return all phrases
        // (this handles cases where the API only returns phrases for the requested hafalan)
        if (filteredPhrases.isEmpty && phrases.isNotEmpty) {
          print('No matching hafalan_id found, returning all phrases');
          return phrases;
        }

        return filteredPhrases;
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
                    'No phrases available for this hafalan',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hafalan ID: ${widget.hafalanId}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                  isEven: index % 2 == 0,
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
  final bool isEven;

  const PhraseItem({
    Key? key,
    required this.number,
    required this.englishPhrase,
    required this.indonesianPhrase,
    required this.isEven,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color:
                isEven
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
}
