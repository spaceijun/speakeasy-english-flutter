import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

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
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Small image above the header text
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: Image.asset(
                        'assets/images/exit.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'English',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const Text(
                      'Learning',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'QUICK VIEW',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                // Books stack image
                SizedBox(
                  width: 250,
                  height: 250,
                  child: Image.asset(
                    'assets/images/book.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Grid of menu items
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildMenuItem(
                    context,
                    'Hafalan',
                    Colors.pink[100]!,
                    'assets/images/hafalan.png',
                    // subtitle: "Hafalan",
                    onTap: () {
                      print('Hafalan tapped');
                      // Navigate to Hafalan screen
                      // Navigator.push(context, MaterialPageRoute(builder: (context) => HafalanScreen()));
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Grammar',
                    Colors.purple[100]!,
                    'assets/images/grammar.png',
                    // subtitle: "Learning grammar",
                    onTap: () {
                      print('Grammar tapped');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Tenses',
                    Colors.blue[100]!,
                    'assets/images/tenses.png',
                    // subtitle: "All tenses",
                    onTap: () {
                      print('Tenses tapped');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Kosakata',
                    Colors.green[100]!,
                    'assets/images/kosakata.png',
                    // subtitle: "Vocabulary",
                    onTap: () {
                      print('Kosakata tapped');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Ujian',
                    Colors.yellow[100]!,
                    'assets/images/ujian.png',
                    // subtitle: "Test",
                    onTap: () {
                      print('Ujian tapped');
                    },
                  ),
                  _buildMenuItem(
                    context,
                    'Frasa dan Idiom',
                    Colors.blue[100]!,
                    'assets/images/frasa.png',
                    // subtitle: "Phrases and Idioms",
                    onTap: () {
                      print('Frasa dan Idiom tapped');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    String title,
    Color color,
    String imagePath, {
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 167,
              height: 182,
              decoration: BoxDecoration(
                // color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(imagePath, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
