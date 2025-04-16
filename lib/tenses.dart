import 'package:flutter/material.dart';
import 'package:speak_english/home.dart';

void main() {
  runApp(Tenses()); // Nama kelas dengan huruf kapital
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

class TensesScreen extends StatelessWidget {
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
          ChapterItem(
            number: 1,
            title: 'Simple Present',
            image: 'assets/images/detail-tenses.png',
          ),
          ChapterItem(
            number: 2,
            title: 'Present Contonous',
            image: 'assets/images/detail-tenses.png',
          ),
          ChapterItem(
            number: 3,
            title: 'Present Perfect',
            image: 'assets/images/detail-tenses.png',
          ),
          ChapterItem(
            number: 4,
            title: 'Present Perfect Continous',
            image: 'assets/images/detail-tenses.png',
          ),
          ChapterItem(
            number: 5,
            title: 'Meminta Menunggu',
            image: 'assets/images/detail-tenses.png',
          ),
          ChapterItem(
            number: 6,
            title: 'Meminta Tolong',
            image: 'assets/images/detail-tenses.png',
          ),
          ChapterItem(
            number: 7,
            title: 'Mengajukan Seseorang',
            image: 'assets/images/detail-tenses.png',
          ),
          ChapterItem(
            number: 8,
            title: 'Mengajukan Ya',
            image: 'assets/images/detail-tenses.png',
          ),
          ChapterItem(
            number: 9,
            title: 'Saya Mengerti',
            image: 'assets/images/detail-tenses.png',
          ),
          ChapterItem(
            number: 10,
            title: 'Sampai Jumpa',
            image: 'assets/images/detail-tenses.png',
          ),
          ChapterItem(
            number: 11,
            title: 'Menyatakan Aktivitas',
            image: 'assets/images/detail-tenses.png',
          ),
          ChapterItem(
            number: 12,
            title: 'Menyatakan Cinta',
            image: 'assets/images/detail-tenses.png',
          ),
        ],
      ),
    );
  }
}

class ChapterItem extends StatelessWidget {
  final int number;
  final String title;
  final String image;

  const ChapterItem({
    Key? key,
    required this.number,
    required this.title,
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
        title: Text(
          'Materi $number',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // Navigasi ke detail chapter
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      ChapterDetailScreen(number: number, title: title),
            ),
          );
        },
      ),
    );
  }
}

class ChapterDetailScreen extends StatelessWidget {
  final int number;
  final String title;

  const ChapterDetailScreen({
    Key? key,
    required this.number,
    required this.title,
  }) : super(key: key);

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
          'Materi $number',
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
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
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
