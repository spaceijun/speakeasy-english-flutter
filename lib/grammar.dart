import 'package:flutter/material.dart';
import 'package:speak_english/detail/detail_grammar.dart';
import 'package:speak_english/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const Grammar());
}

class Grammar extends StatelessWidget {
  const Grammar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Grammar Categories',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: const GrammarScreen(),
    );
  }
}

class GrammarCategory {
  final int id;
  final String title;
  final String imagePath;

  const GrammarCategory({
    required this.id,
    required this.title,
    required this.imagePath,
  });

  factory GrammarCategory.fromJson(Map<String, dynamic> json) {
    print('Processing item: $json');
    String imageUrl = json['images'] ?? '';

    if (imageUrl.isNotEmpty &&
        !imageUrl.startsWith('http://') &&
        !imageUrl.startsWith('https://')) {
      imageUrl = 'https://speakeasy-english.web.id/assets/grammar/$imageUrl';
    }

    print('Image URL processed: $imageUrl');
    print(
      'detailgram_id from JSON: ${json['detailgram_id']}, type: ${json['detailgram_id'].runtimeType}',
    );
    print('Converted ID: ${int.tryParse(json['detailgram_id'].toString())}');

    return GrammarCategory(
      title: json['name'] ?? 'Unknown',
      imagePath:
          imageUrl.isNotEmpty ? imageUrl : 'assets/images/grammar/book-1.png',
      id:
          int.tryParse(json['detailgram_id'].toString()) ??
          json['id'] ??
          0, // Convert detailgram_id ke int
    );
  }
}

class GrammarScreen extends StatefulWidget {
  const GrammarScreen({Key? key}) : super(key: key);

  @override
  State<GrammarScreen> createState() => _GrammarScreenState();
}

class _GrammarScreenState extends State<GrammarScreen> {
  late Future<List<GrammarCategory>> _grammarCategoriesFuture;

  @override
  void initState() {
    super.initState();
    _grammarCategoriesFuture = fetchGrammarCategories();
  }

  Future<List<GrammarCategory>> fetchGrammarCategories() async {
    try {
      final response = await http.get(
        Uri.parse('https://speakeasy-english.web.id/api/detail-grammars'),
        headers: {'Accept': 'application/json'},
      );

      print('API Response Status: ${response.statusCode}');
      print('API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic jsonData = json.decode(response.body);

        List<GrammarCategory> categories = [];

        if (jsonData is List) {
          // Jika response langsung berupa array
          categories =
              jsonData.map((item) => GrammarCategory.fromJson(item)).toList();
        } else if (jsonData is Map<String, dynamic>) {
          // Jika response berupa object dengan berbagai kemungkinan struktur
          if (jsonData.containsKey('data') && jsonData['data'] is List) {
            // Struktur: {"data": [...]}
            final List<dynamic> grammarList = jsonData['data'];
            categories =
                grammarList
                    .map((item) => GrammarCategory.fromJson(item))
                    .toList();
          } else {
            // Cari key yang berisi array
            for (var key in jsonData.keys) {
              if (jsonData[key] is List) {
                final List<dynamic> grammarList = jsonData[key];
                categories =
                    grammarList
                        .map((item) => GrammarCategory.fromJson(item))
                        .toList();
                break;
              }
            }
          }
        }

        print('Total categories found: ${categories.length}');
        for (var category in categories) {
          print('Category ID: ${category.id}, Title: ${category.title}');
        }

        return categories;
      } else {
        throw Exception(
          'Failed to load grammar categories: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching grammar categories: $e');
      throw Exception('Failed to load grammar categories: $e');
    }
  }

  // Fungsi untuk navigasi ke halaman DetailGrammar
  void _navigateToGrammarDetail(GrammarCategory category) {
    print(
      'Navigating to detail with ID: ${category.id}, Title: ${category.title}',
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => DetailGrammar(id: category.id, title: category.title),
      ),
    );
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
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              );
            }
          },
        ),
        title: const Text(
          'Grammar Categories',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: FutureBuilder<List<GrammarCategory>>(
        future: _grammarCategoriesFuture,
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _grammarCategoriesFuture = fetchGrammarCategories();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No grammar categories available'));
          } else {
            final categories = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return CategoryItem(
                  title: categories[index].title,
                  imagePath: categories[index].imagePath,
                  onTap: () => _navigateToGrammarDetail(categories[index]),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const CategoryItem({
    Key? key,
    required this.title,
    required this.imagePath,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFCE4EC), // Light pink background
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child:
                    imagePath.isNotEmpty &&
                            (imagePath.startsWith('http') ||
                                imagePath.startsWith('https'))
                        ? Image.network(
                          imagePath,
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            print(
                              'Error loading image from $imagePath: $error',
                            );
                            return const Icon(
                              Icons.error,
                              size: 48,
                              color: Colors.red,
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                              ),
                            );
                          },
                        )
                        : Image.asset(
                          imagePath.isEmpty
                              ? 'assets/images/grammar/book-1.png'
                              : imagePath,
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            print(
                              'Error loading asset from $imagePath: $error',
                            );
                            return const Icon(
                              Icons.book,
                              size: 48,
                              color: Colors.blue,
                            );
                          },
                        ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
