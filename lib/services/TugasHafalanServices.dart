import 'dart:convert';
import 'package:http/http.dart' as http;

class TugasHafalan {
  final int id;
  final int hafalanId;
  final String kkm;
  final String bodyQuestions;
  final String createdAt;
  final String updatedAt;

  TugasHafalan({
    required this.id,
    required this.hafalanId,
    required this.kkm,
    required this.bodyQuestions,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TugasHafalan.fromJson(Map<String, dynamic> json) {
    return TugasHafalan(
      id: json['id'],
      hafalanId: json['hafalan_id'],
      kkm: json['kkm'],
      bodyQuestions: json['body_questions'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class ApiService {
  static const String baseUrl = 'https://speakeasy-english.web.id/api';

  static var getUserId;

  Future<List<TugasHafalan>> fetchTugasHafalans() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/tugas-hafalans'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'];

        return data.map((json) => TugasHafalan.fromJson(json)).toList();
      } else {
        throw Exception(
          'Failed to load tugas hafalans: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to connect to API: $e');
    }
  }

  Future<Map<String, dynamic>> submitJawaban(
    int hafalanId,
    String jawaban,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tugas-hafalans/$hafalanId/submit'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'jawaban': jawaban}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to submit answer: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to API: $e');
    }
  }

  static Future<Map<String, dynamic>> submitJawabanHafalan({
    required int userId,
    required int tugasHafalanId,
    required String bodyAnswers,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/jawaban-hafalans'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId.toString(),
          'tugas_hafalan_id': tugasHafalanId.toString(),
          'body_answers': bodyAnswers,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Gagal mengirim jawaban: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Gagal terhubung ke API: $e');
    }
  }
}
