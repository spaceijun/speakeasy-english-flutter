import 'package:flutter/material.dart';
import 'package:speak_english/detail/detail_tugas_frasa.dart';
import 'package:speak_english/detail/detail_tugas_grammar.dart';
import 'package:speak_english/detail/detail_tugas_hafalan.dart';
import 'package:speak_english/detail/detail_tugas_idiom.dart';
import 'package:speak_english/detail/detail_tugas_kosakata.dart';
import 'package:speak_english/detail/detail_tugas_tenses.dart';
import 'package:speak_english/home.dart';

void main() {
  runApp(Exam());
}

class Exam extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: ExamScreen(),
    );
  }
}

class ExamScreen extends StatelessWidget {
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
      ),
      body: ListView(
        children: [
          CategoryItem(title: 'Hafalan', image: 'assets/images/exam.png'),
          CategoryItem(title: 'Grammar', image: 'assets/images/exam.png'),
          CategoryItem(title: 'Kosakata', image: 'assets/images/exam.png'),
          CategoryItem(title: 'Tenses', image: 'assets/images/exam.png'),
          CategoryItem(title: 'Frasa', image: 'assets/images/exam.png'),
          CategoryItem(title: 'Idiom', image: 'assets/images/exam.png'),
        ],
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String title;
  final String image;

  const CategoryItem({Key? key, required this.title, required this.image})
    : super(key: key);

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
            child: Image.asset(
              image,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback jika gambar tidak ditemukan
                return Icon(Icons.image_not_supported, size: 20);
              },
            ),
          ),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // Navigasi ke halaman sesuai dengan title
          navigateToDetailPage(context, title);
        },
      ),
    );
  }

  // Function untuk navigasi ke halaman yang sesuai berdasarkan title
  void navigateToDetailPage(BuildContext context, String title) {
    Widget page;

    // Menentukan halaman yang sesuai berdasarkan title
    switch (title) {
      case 'Hafalan':
        page = TugasHafalanPage();
        break;
      case 'Grammar':
        page = TugasGrammarPage();
        break;
      case 'Kosakata':
        page = TugasKosakatasPage();
        break;
      case 'Tenses':
        page = TugasTensesPage();
        break;
      case 'Frasa':
        page = TugasFrasaPage();
        break;
      case 'Idiom':
        page = TugasIdiomPage();
        break;
      default:
        // Default ke halaman hafalan jika title tidak dikenali
        page = Home();
    }

    // Navigasi ke halaman yang sesuai
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}

class ChapterDetailScreen extends StatelessWidget {
  final int number;

  const ChapterDetailScreen({Key? key, required this.number}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Exam $number',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const SizedBox(height: 20),
            const Text(
              'Kontenya nanti ditampilkan disini pak dosen.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
