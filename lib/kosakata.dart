import 'package:flutter/material.dart';
import 'package:speak_english/detail/detail_kosakata.dart';
import 'package:speak_english/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const Kosakata());
}

class Kosakata extends StatelessWidget {
  const Kosakata({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kosakata Categories',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'Roboto'),
      home: const KosakataScreen(),
    );
  }
}

class KosakataCategory {
  final int id;
  final int categoryId;
  final String name;
  final String images;
  final String description;

  KosakataCategory({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.images,
    required this.description,
  });

  factory KosakataCategory.fromJson(Map<String, dynamic> json) {
    print('Processing kosakata item: $json');
    String imageUrl = json['images'] ?? '';

    // Sama seperti di Grammar, pastikan URL gambar lengkap
    if (imageUrl.isNotEmpty &&
        !imageUrl.startsWith('http://') &&
        !imageUrl.startsWith('https://')) {
      imageUrl = 'https://speakeasy-english.web.id/assets/kosakata/$imageUrl';
    }

    print('Image URL processed: $imageUrl');

    // Helper function to safely parse integer values
    int parseIntSafely(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    return KosakataCategory(
      id: parseIntSafely(json['id']),
      categoryId: parseIntSafely(json['category_id']),
      name: json['name']?.toString() ?? '',
      images: imageUrl,
      description: json['description']?.toString() ?? '',
    );
  }
}

class KosakataScreen extends StatefulWidget {
  const KosakataScreen({Key? key}) : super(key: key);

  @override
  State<KosakataScreen> createState() => _KosakataScreenState();
}

class _KosakataScreenState extends State<KosakataScreen> {
  late Future<List<KosakataCategory>> _kosakataFuture;

  @override
  void initState() {
    super.initState();
    _kosakataFuture = fetchKosakataCategories();
  }

  Future<List<KosakataCategory>> fetchKosakataCategories() async {
    try {
      final response = await http.get(
        Uri.parse('https://speakeasy-english.web.id/api/kosakatas'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        print('API Response: ${response.body}');

        final dynamic jsonData = json.decode(response.body);

        // Logika yang sama dengan Grammar untuk menangani berbagai format response
        if (jsonData is List) {
          return jsonData
              .map((item) => KosakataCategory.fromJson(item))
              .toList();
        } else if (jsonData is Map) {
          if (jsonData.containsKey('data') && jsonData['data'] is List) {
            final List<dynamic> kosakataList = jsonData['data'];
            return kosakataList
                .map((item) => KosakataCategory.fromJson(item))
                .toList();
          } else {
            // Mencari list data di response
            for (var key in jsonData.keys) {
              if (jsonData[key] is List) {
                final List<dynamic> kosakataList = jsonData[key];
                return kosakataList
                    .map((item) => KosakataCategory.fromJson(item))
                    .toList();
              }
            }
          }
        }

        return [];
      } else {
        throw Exception(
          'Failed to load kosakata categories: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching kosakata categories: $e');
      throw Exception('Failed to load kosakata categories: $e');
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
        title: const Text('Kosakata', style: TextStyle(color: Colors.black)),
      ),
      body: FutureBuilder<List<KosakataCategory>>(
        future: _kosakataFuture,
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
                        _kosakataFuture = fetchKosakataCategories();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return CategoryItem(category: snapshot.data![index]);
              },
            );
          }
        },
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final KosakataCategory category;

  const CategoryItem({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => DetailKosakata(
                  categoryTitle: category.name,
                  categoryImage: category.images,
                  categoryId: category.id,
                ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFDBFFD9),
                borderRadius: BorderRadius.circular(16),
                // Menambahkan shadow seperti di Grammar
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                // Menambahkan loading dan error handling seperti di Grammar
                child: Image.network(
                  category.images,
                  width: 48,
                  height: 48,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    print(
                      'Error loading image from ${category.images}: $error',
                    );
                    return const Icon(
                      Icons.image_not_supported,
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
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category.name,
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
