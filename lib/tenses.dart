import 'package:flutter/material.dart';
import 'package:speak_english/detail/detail_tenses.dart';
import 'package:speak_english/home.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(Tenses());
}

class Tenses extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: TensesScreen(),
    );
  }
}

// Model class for our API data
class TensesItem {
  final int id;
  final String name;
  final String images;
  final String description;

  TensesItem({
    required this.id,
    required this.name,
    required this.images,
    required this.description,
  });

  factory TensesItem.fromJson(Map<String, dynamic> json) {
    return TensesItem(
      id: json['id'],
      name: json['name'],
      images: json['images'],
      description: json['description'],
    );
  }
}

class TensesScreen extends StatefulWidget {
  @override
  _TensesScreenState createState() => _TensesScreenState();
}

class _TensesScreenState extends State<TensesScreen> {
  List<TensesItem> _tensesItems = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTensesData();
  }

  Future<void> _fetchTensesData() async {
    try {
      final response = await http.get(
        Uri.parse('https://speakeasy-english.web.id/api/detail-tenses'),
      );

      if (response.statusCode == 200) {
        // Print response body for debugging
        print('API Response: ${response.body}');

        // Parse the response
        final jsonData = json.decode(response.body);

        // Check if the response is a map (object) or list (array)
        if (jsonData is Map<String, dynamic> && jsonData.containsKey('data')) {
          // If it's a map with a 'data' key that contains our array
          final List<dynamic> items = jsonData['data'];
          setState(() {
            _tensesItems =
                items.map((item) => TensesItem.fromJson(item)).toList();
            _isLoading = false;
          });
        } else if (jsonData is List) {
          // If it's directly a list
          setState(() {
            _tensesItems =
                jsonData.map((item) => TensesItem.fromJson(item)).toList();
            _isLoading = false;
          });
        } else {
          // If it's some other structure
          setState(() {
            _errorMessage = 'Unexpected data format from API';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage =
              'Failed to load data: Server error ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load data: $e';
        _isLoading = false;
      });
      print('Error fetching data: $e');
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
        title: Text(
          'Tenses',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage, textAlign: TextAlign.center),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _errorMessage = '';
                          });
                          _fetchTensesData();
                        },
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
              : ListView.builder(
                itemCount: _tensesItems.length,
                itemBuilder: (context, index) {
                  final item = _tensesItems[index];
                  return ChapterItem(
                    number: item.id,
                    name: item.name,
                    title: item.description,
                    imageUrl:
                        'https://speakeasy-english.web.id/assets/tenses/${item.images}',
                  );
                },
              ),
    );
  }
}

class ChapterItem extends StatelessWidget {
  final int number;
  final String name;
  final String title;
  final String imageUrl;

  const ChapterItem({
    Key? key,
    required this.number,
    required this.name,
    required this.title,
    required this.imageUrl,
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Image error: $error');
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
                  ),
                );
              },
            ),
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // Navigate to detail chapter with the item data
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailTenses(id: number, title: title),
            ),
          );
        },
      ),
    );
  }
}
