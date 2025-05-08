import 'package:flutter/material.dart';

void main() {
  runApp(const DetailFrasa());
}

class DetailFrasa extends StatelessWidget {
  const DetailFrasa({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Save Phrases',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        scaffoldBackgroundColor: const Color(
          0xFFFFF9C4,
        ), // Light yellow background
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(
            0xFFFFF176,
          ), // Slightly darker yellow for app bar
          foregroundColor: Colors.black87,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black87),
        ),
      ),
      home: const SavePhrasesScreen(),
    );
  }
}

class SavePhrasesScreen extends StatelessWidget {
  const SavePhrasesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List of save phrases with their translations
    final List<Map<String, String>> phrases = [
      {"phrase": "Save Electricity", "translation": "Hemat listrik"},
      {"phrase": "Save Energy", "translation": "Hemat Energi"},
      {"phrase": "Save Money", "translation": "Hemat uang"},
      {"phrase": "Save Space", "translation": "Hemat ruangan"},
      {"phrase": "Save Time", "translation": "Hemat waktu"},
      {
        "phrase": "Save someone's love",
        "translation": "Menyelamatkan hidup seseorang",
      },
      {
        "phrase": "Save one's strength",
        "translation": "Menghemat kekuatan seseorang",
      },
      {
        "phrase": "Save someone a seat",
        "translation": "Menyediakan kursi bagi seseorang",
      },
      {
        "phrase": "Save something to a disk",
        "translation": "Menyimpan sesuatu kedalam disket",
      },
      {
        "phrase": "Save yourself the trouble",
        "translation": "Menyelamatkan diri dari kesusahan",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text(
          'Frasa penting dengan kata Save',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.only(top: 12, bottom: 24),
        itemCount: phrases.length,
        separatorBuilder:
            (context, index) => const Divider(height: 1, thickness: 0.5),
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: Text(
              "${index + 1}.",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            title: Text(
              phrases[index]["phrase"]!,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            trailing: Text(
              phrases[index]["translation"]!,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
          );
        },
      ),
    );
  }
}
