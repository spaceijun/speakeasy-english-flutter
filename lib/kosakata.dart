import 'package:flutter/material.dart';
import 'package:speak_english/home.dart';

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
  final String title;
  final String imagePath;

  const KosakataCategory({required this.title, required this.imagePath});
}

class KosakataScreen extends StatelessWidget {
  const KosakataScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<KosakataCategory> categories = [
      const KosakataCategory(
        title: 'Pronoun',
        imagePath: 'assets/images/kosakata/boy.png',
      ),
      const KosakataCategory(
        title: 'Family',
        imagePath: 'assets/images/kosakata/family.png',
      ),
      const KosakataCategory(
        title: 'Personality',
        imagePath: 'assets/images/kosakata/user.png',
      ),
      const KosakataCategory(
        title: 'Country',
        imagePath: 'assets/images/kosakata/indonesia.png',
      ),
      const KosakataCategory(
        title: 'Body Shape',
        imagePath: 'assets/images/kosakata/man.png',
      ),
      const KosakataCategory(
        title: 'Housekeeping',
        imagePath: 'assets/images/kosakata/household.png',
      ),
      const KosakataCategory(
        title: 'Home Section',
        imagePath: 'assets/images/kosakata/house.png',
      ),
      const KosakataCategory(
        title: 'School Major',
        imagePath: 'assets/images/kosakata/graduating-student.png',
      ),
      const KosakataCategory(
        title: 'Shopping',
        imagePath: 'assets/images/kosakata/trolley.png',
      ),
      const KosakataCategory(
        title: 'Transportation',
        imagePath: 'assets/images/kosakata/vehicles.png',
      ),
      const KosakataCategory(
        title: 'Season',
        imagePath: 'assets/images/kosakata/tree.png',
      ),
      const KosakataCategory(
        title: 'Weather',
        imagePath: 'assets/images/kosakata/weather.png',
      ),
      const KosakataCategory(
        title: 'Nature',
        imagePath: 'assets/images/kosakata/lake.png',
      ),
      const KosakataCategory(
        title: 'Body Move',
        imagePath: 'assets/images/kosakata/woman.png',
      ),
      const KosakataCategory(
        title: 'Education',
        imagePath: 'assets/images/kosakata/education.png',
      ),
      const KosakataCategory(
        title: 'Propotion Of Place',
        imagePath: 'assets/images/kosakata/market-positioning.png',
      ),
      const KosakataCategory(
        title: 'Preposition Of Manner',
        imagePath: 'assets/images/kosakata/map.png',
      ),

      const KosakataCategory(
        title: 'Conjunction',
        imagePath: 'assets/images/kosakata/bookk.png',
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
              color: const Color(0xFFDBFFD9),
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
