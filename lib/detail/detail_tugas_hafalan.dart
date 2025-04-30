import 'package:flutter/material.dart';
import 'package:speak_english/exam.dart';

void main() {
  runApp(const DetailTugasHafalan(number: '1'));
}

class DetailTugasHafalan extends StatelessWidget {
  final String number;
  const DetailTugasHafalan({Key? key, required this.number}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Convert string to int
    final int numberAsInt = int.parse(number);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: AssignmentListPage(assignmentNumber: numberAsInt),
    );
  }
}

class AssignmentListPage extends StatelessWidget {
  final int assignmentNumber;
  const AssignmentListPage({Key? key, required this.assignmentNumber})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Exam()),
            );
          },
        ),
        title: Text(
          'Data Tugas Hafalan $assignmentNumber',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: ListView(
        children: [
          AssignmentTile(
            title: 'Tugas Hafalan 1',
            iconColor: Colors.amber,
            iconData: Icons.note_alt_outlined,
            score: 100,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TugasHafalanScreen(number: 1),
                ),
              );
            },
          ),
          const Divider(height: 1),
          AssignmentTile(
            title: 'Tugas Hafalan 2',
            iconColor: Colors.pink,
            iconData: Icons.person,
            score: 100,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TugasHafalanScreen(number: 2),
                ),
              );
            },
          ),
          const Divider(height: 1),
          AssignmentTile(
            title: 'Tugas Hafalan 3',
            iconColor: Colors.red,
            iconData: Icons.people,
            score: 100,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TugasHafalanScreen(number: 3),
                ),
              );
            },
          ),
          const Divider(height: 1),
          AssignmentTile(
            title: 'Tugas Hafalan 4',
            iconColor: Colors.lightBlue,
            iconData: Icons.book,
            score: 100,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TugasHafalanScreen(number: 4),
                ),
              );
            },
          ),
          const Divider(height: 1),
          AssignmentTile(
            title: 'Tugas Hafalan 5',
            iconColor: Colors.purple,
            iconData: Icons.school,
            score: 100,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TugasHafalanScreen(number: 5),
                ),
              );
            },
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}

class AssignmentTile extends StatelessWidget {
  final String title;
  final Color iconColor;
  final IconData iconData;
  final int score;
  final VoidCallback onTap;
  const AssignmentTile({
    Key? key,
    required this.title,
    required this.iconColor,
    required this.iconData,
    required this.score,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          children: [
            // Icon with colored background
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(iconData, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            // Assignment title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Score badge
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '100',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            // Arrow icon
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

// The TugasHafalanScreen class that will be navigated to from the AssignmentTile
class TugasHafalanScreen extends StatefulWidget {
  final int number;
  const TugasHafalanScreen({Key? key, required this.number}) : super(key: key);
  @override
  State<TugasHafalanScreen> createState() => _TugasHafalanScreenState();
}

class _TugasHafalanScreenState extends State<TugasHafalanScreen> {
  final TextEditingController _jawabanController = TextEditingController();

  String getQuestion() {
    // Based on the assignment number, return the appropriate question
    switch (widget.number) {
      case 1:
        return 'Buatlah 20 Ungkapan Untuk Menanyakan Kabar Seseorang!';
      case 2:
        return 'Buatlah 15 Ungkapan Untuk Menawarkan Bantuan Kepada Seseorang!';
      case 3:
        return 'Buatlah 10 Ungkapan Untuk Mengucapkan Terima Kasih!';
      case 4:
        return 'Buatlah 12 Ungkapan Untuk Meminta Maaf!';
      case 5:
        return 'Buatlah 18 Ungkapan Untuk Menyatakan Persetujuan!';
      default:
        return 'Buatlah Ungkapan Sesuai Petunjuk!';
    }
  }

  @override
  void dispose() {
    _jawabanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  BackButton(onPressed: () => Navigator.pop(context)),
                  const SizedBox(width: 8),
                  Text(
                    'Tugas Hafalan ${widget.number}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Petunjuk
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD580), // Light orange
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 14, color: Colors.black),
                            children: [
                              TextSpan(
                                text: 'Petunjuk: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text:
                                    'Jawablah pertanyaan di bawah ini dengan menggunakan ungkapan yang sesuai dari daftar hafalan.',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Pertanyaan card with drop shadow
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Pertanyaan header
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFD580), // Light orange
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Pertanyaan',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Pertanyaan content
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              child: Text(
                                getQuestion(),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Jawaban card with drop shadow
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Jawaban header
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 12,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFD580), // Light orange
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Jawaban',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Jawaban content
                            Container(
                              width: double.infinity,
                              height: 180,
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                              ),
                              child: TextField(
                                controller: _jawabanController,
                                maxLines: null,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Tulis jawaban di sini...',
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // Bottom Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Edit Button
                          SizedBox(
                            width: 100,
                            child: ElevatedButton(
                              onPressed: () {
                                // Edit functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Edit ditekan')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF5CE1E6,
                                ), // Teal
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text('Edit'),
                            ),
                          ),
                          // Tambah Button
                          SizedBox(
                            width: 100,
                            child: ElevatedButton(
                              onPressed: () {
                                // Tambah functionality
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Tambah ditekan'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFFFFD580,
                                ), // Light orange
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text('Tambah'),
                            ),
                          ),
                          // Hapus Button
                          SizedBox(
                            width: 100,
                            child: ElevatedButton(
                              onPressed: () {
                                // Hapus functionality
                                _jawabanController.clear();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Jawaban dihapus'),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFFFFA8A8,
                                ), // Light red
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: const Text('Hapus'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
