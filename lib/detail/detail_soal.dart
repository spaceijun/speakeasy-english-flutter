import 'package:flutter/material.dart';

void main() {
  runApp(const DetailSoal());
}

class DetailSoal extends StatelessWidget {
  const DetailSoal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tugas Hafalan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const TugasHafalanScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TugasHafalanScreen extends StatefulWidget {
  const TugasHafalanScreen({Key? key}) : super(key: key);

  @override
  State<TugasHafalanScreen> createState() => _TugasHafalanScreenState();
}

class _TugasHafalanScreenState extends State<TugasHafalanScreen> {
  final TextEditingController _jawabanController = TextEditingController();

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
                  const BackButton(),
                  const SizedBox(width: 8),
                  const Text(
                    'Tugas Hafalan 1',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                        ),
                        child: const Text(
                          'Petunjuk: Jawablah pertanyaan di bawah ini dengan menggunakan ungkapan yang sesuai dari daftar hafalan.',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Pertanyaan
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD580), // Light orange
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Pertanyaan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Buatlah 20 Ungkapan Untuk Menanyakan Kabar Seseorang!',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Jawaban
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD580), // Light orange
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Jawaban',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Container(
                        width: double.infinity,
                        height: 180,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.3),
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

                      const SizedBox(height: 30),

                      // Bottom Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Edit Button
                          SizedBox(
                            width: 100,
                            child: ElevatedButton(
                              onPressed: () {},
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
                              onPressed: () {},
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
                              onPressed: () {},
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
