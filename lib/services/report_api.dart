import 'dart:convert';
import 'package:http/http.dart' as http;

class ReportApi {
  final String baseUrl;

  ReportApi({required this.baseUrl});

  Future<String> generateComment({
    required String studentName,
    required String grade,
    required String week,
    required String attendance,
    required String books,
    required List<String> units,
    required String homeworkSubmit,
    required String homeworkQuality,
    required String attitude,
    required List<Map<String, dynamic>> testResults,
    required String weakPoints,
    required String plan,
  }) async {
    final url = Uri.parse('$baseUrl/generate-comment');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'student_name': studentName,
        'grade': grade,
        'week': week,
        'attendance': attendance,
        'books': books,
        'units': units,
        'homework_submit': homeworkSubmit,
        'homework_quality': homeworkQuality,
        'attitude': attitude,
        'test_results': testResults,
        'weak_points': weakPoints,
        'plan': plan,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('AI 코멘트 생성 실패: ${response.body}');
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    return data['comment'];
  }
}