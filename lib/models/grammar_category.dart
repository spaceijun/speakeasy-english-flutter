class GrammarCategory {
  final String title;
  final String imagePath;

  GrammarCategory({required this.title, required this.imagePath});

  factory GrammarCategory.fromJson(Map<String, dynamic> json) {
    return GrammarCategory(title: json['title'], imagePath: json['image_path']);
  }
}
