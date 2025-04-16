import 'package:flutter/material.dart';
import 'package:speak_english/home.dart';

void main() {
  runApp(Frasa());
}

class Frasa extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: FrasaScreen(),
    );
  }
}

class FrasaScreen extends StatelessWidget {
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
            image: 'assets/images/detail-frasa.png',
            type: 'Frasa',
          ),
          ChapterItem(
            number: 2,
            title: 'Present Continuous',
            image: 'assets/images/detail-frasa.png',
            type: 'Frasa',
          ),
          ChapterItem(
            number: 3,
            title: 'Present Perfect',
            image: 'assets/images/detail-frasa.png',
            type: 'Frasa',
          ),
          ChapterItem(
            number: 4,
            title: 'Present Perfect Continuous',
            image: 'assets/images/detail-frasa.png',
            type: 'Frasa',
          ),
          ChapterItem(
            number: 5,
            title: 'Meminta Menunggu',
            image: 'assets/images/detail-frasa.png',
            type: 'Frasa',
          ),
          ChapterItem(
            number: 6,
            title: 'Meminta Tolong',
            image: 'assets/images/detail-frasa.png',
            type: 'Frasa',
          ),
          ChapterItem(
            number: 7,
            title: 'Mengajukan Seseorang',
            image: 'assets/images/detail-frasa.png',
            type: 'Frasa',
          ),
          ChapterItem(
            number: 1,
            title: 'Break a leg',
            image: 'assets/images/detail-frasa.png',
            type: 'Idiom',
          ),
          ChapterItem(
            number: 2,
            title: 'Piece of cake',
            image: 'assets/images/detail-frasa.png',
            type: 'Idiom',
          ),
          ChapterItem(
            number: 3,
            title: 'Hit the road',
            image: 'assets/images/detail-frasa.png',
            type: 'Idiom',
          ),
          ChapterItem(
            number: 4,
            title: 'Under the weather',
            image: 'assets/images/detail-frasa.png',
            type: 'Idiom',
          ),
          ChapterItem(
            number: 5,
            title: 'Cost an arm and a leg',
            image: 'assets/images/detail-frasa.png',
            type: 'Idiom',
          ),
          ChapterItem(
            number: 6,
            title: 'Once in a blue moon',
            image: 'assets/images/detail-frasa.png',
            type: 'Idiom',
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
  final String type;

  const ChapterItem({
    Key? key,
    required this.number,
    required this.title,
    required this.image,
    required this.type,
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
                return Icon(Icons.image_not_supported, size: 20);
              },
            ),
          ),
        ),
        title: Text(
          '$type $number',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ChapterDetailScreen(
                    number: number,
                    title: title,
                    type: type,
                  ),
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
  final String type;

  const ChapterDetailScreen({
    Key? key,
    required this.number,
    required this.title,
    required this.type,
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
          '$type $number',
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
