import 'package:flutter/material.dart';
import 'package:speak_english/detail/detail_hafalan.dart';
import 'package:speak_english/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(Hafalan());
}

class Hafalan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: HafalanScreen(),
    );
  }
}

class HafalanModel {
  final int id;
  final String name;
  final String description;
  final String imagePath;

  HafalanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
  });

  factory HafalanModel.fromJson(Map<String, dynamic> json) {
    // Debug print to see each item structure
    print('Processing hafalan item: $json');

    // Check if the image path needs a base URL prefix
    String imageUrl = json['images'] ?? '';

    // If images value doesn't start with http/https, add the base URL
    if (imageUrl.isNotEmpty &&
        !imageUrl.startsWith('http://') &&
        !imageUrl.startsWith('https://')) {
      imageUrl = 'https://speakeasy-english.web.id/assets/hafalan/$imageUrl';
    }

    print('Hafalan image URL processed: $imageUrl');

    return HafalanModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      imagePath: imageUrl,
    );
  }
}

class HafalanScreen extends StatefulWidget {
  @override
  State<HafalanScreen> createState() => _HafalanScreenState();
}

class _HafalanScreenState extends State<HafalanScreen> {
  late Future<List<HafalanModel>> _hafalanFuture;

  @override
  void initState() {
    super.initState();
    _hafalanFuture = fetchHafalanData();
  }

  Future<List<HafalanModel>> fetchHafalanData() async {
    try {
      final response = await http.get(
        Uri.parse('https://speakeasy-english.web.id/api/hafalans'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        // Print the full response for debugging
        print('API Response: ${response.body}');

        // Parse the JSON response
        final dynamic jsonData = json.decode(response.body);

        // Handle different response formats
        if (jsonData is List) {
          // Direct array response
          return jsonData.map((item) => HafalanModel.fromJson(item)).toList();
        } else if (jsonData is Map) {
          // Object with nested array
          if (jsonData.containsKey('data') && jsonData['data'] is List) {
            final List<dynamic> hafalanList = jsonData['data'];
            return hafalanList
                .map((item) => HafalanModel.fromJson(item))
                .toList();
          } else {
            // Look for any list in the response
            for (var key in jsonData.keys) {
              if (jsonData[key] is List) {
                final List<dynamic> hafalanList = jsonData[key];
                return hafalanList
                    .map((item) => HafalanModel.fromJson(item))
                    .toList();
              }
            }
          }
        }

        // If we can't find a list, return an empty list
        return [];
      } else {
        throw Exception('Failed to load hafalan data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching hafalan data: $e');
      throw Exception('Failed to load hafalan data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Coba gunakan Navigator.pop terlebih dahulu
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // Jika tidak bisa pop, maka navigate ke Home
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              );
            }
          },
        ),
        title: Text(
          'Hafalan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<HafalanModel>>(
        future: _hafalanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
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
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _hafalanFuture = fetchHafalanData();
                      });
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hafalan data available'));
          } else {
            final hafalanItems = snapshot.data!;
            return ListView.builder(
              itemCount: hafalanItems.length,
              itemBuilder: (context, index) {
                final item = hafalanItems[index];
                return ChapterItem(
                  number: item.id,
                  title: item.name,
                  description: item.description,
                  image:
                      item.imagePath.isNotEmpty
                          ? item.imagePath
                          : 'assets/images/hafalan/komen.png',
                );
              },
            );
          }
        },
      ),
    );
  }
}

class ChapterItem extends StatelessWidget {
  final int number;
  final String title;
  final String description;
  final String image;

  const ChapterItem({
    Key? key,
    required this.number,
    required this.title,
    required this.description,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 254, 254).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                image.startsWith('http') || image.startsWith('https')
                    ? Image.network(
                      image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading network image: $error');
                        return Icon(Icons.image_not_supported, size: 20);
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
                            strokeWidth: 2.0,
                          ),
                        );
                      },
                    )
                    : Image.asset(
                      image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading asset image: $error');
                        return Icon(Icons.image_not_supported, size: 20);
                      },
                    ),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          description,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // Navigate to DetailHafalan with the correct parameters
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => DetailHafalan(hafalanId: number, title: title),
            ),
          );
        },
      ),
    );
  }
}
