import 'package:flutter/material.dart';
import 'package:speak_english/home.dart';

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
  final String title;
  final String imagePath;

  const GrammarCategory({required this.title, required this.imagePath});
}

class GrammarScreen extends StatelessWidget {
  const GrammarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<GrammarCategory> categories = [
      const GrammarCategory(
        title: 'Pronoun',
        imagePath: 'assets/images/grammar/book-1.png',
      ),
      const GrammarCategory(
        title: 'Article',
        imagePath: 'assets/images/grammar/book-2.png',
      ),
      const GrammarCategory(
        title: 'Demonstrative',
        imagePath: 'assets/images/grammar/book-3.png',
      ),
      const GrammarCategory(
        title: 'Noun',
        imagePath: 'assets/images/grammar/book-4.png',
      ),
      const GrammarCategory(
        title: 'Singular & Plural',
        imagePath: 'assets/images/grammar/book-5.png',
      ),
      const GrammarCategory(
        title: 'Adjective',
        imagePath: 'assets/images/grammar/book-6.png',
      ),
      const GrammarCategory(
        title: 'Noun Phrase',
        imagePath: 'assets/images/grammar/book-7.png',
      ),
      const GrammarCategory(
        title: 'Quantifier',
        imagePath: 'assets/images/grammar/book-8.png',
      ),
      const GrammarCategory(
        title: 'Verb',
        imagePath: 'assets/images/grammar/book-9.png',
      ),
      const GrammarCategory(
        title: 'Preposition',
        imagePath: 'assets/images/grammar/book-10.png',
      ),
      const GrammarCategory(
        title: 'Conjunction',
        imagePath: 'assets/images/grammar/book-11.png',
      ),
      const GrammarCategory(
        title: 'Interjection',
        imagePath: 'assets/images/grammar/book-12.png',
      ),
      const GrammarCategory(
        title: 'To Be',
        imagePath: 'assets/images/grammar/book-13.png',
      ),
      const GrammarCategory(
        title: 'Was & Were',
        imagePath: 'assets/images/grammar/book-14.png',
      ),
      const GrammarCategory(
        title: 'Determiner',
        imagePath: 'assets/images/grammar/book-15.png',
      ),
      const GrammarCategory(
        title: 'Regular Verb',
        imagePath: 'assets/images/grammar/book-16.png',
      ),
      const GrammarCategory(
        title: 'Irregular Verb',
        imagePath: 'assets/images/grammar/book-17.png',
      ),
      const GrammarCategory(
        title: 'Auxiliary Verb',
        imagePath: 'assets/images/grammar/book-18.png',
      ),
    ];

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
      ),
      body: GridView.builder(
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
          );
        },
      ),
    );
  }
}

class CategoryItem extends StatelessWidget {
  final String title;
  final String imagePath;

  const CategoryItem({Key? key, required this.title, required this.imagePath})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFCE4EC), // Light pink background
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              // Using Image.asset to load the image from assets
              child: Image.asset(
                imagePath,
                width: 48,
                height: 48,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
