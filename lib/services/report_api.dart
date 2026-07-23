import 'dart:async';
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
    required String referenceNote,
    String previousComment = '',
    String revisionRequest = '',
  }) async {
    final body = {
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
      'reference_note': referenceNote,
      'previous_comment': previousComment,
      'revision_request': revisionRequest,
    };

    return _postGenerateCommentWithRetry(body);
  }

  Future<String> _postGenerateCommentWithRetry(
    Map<String, dynamic> body,
  ) async {
    Exception? lastError;

    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        return await _postGenerateComment(body);
      } on Exception catch (e) {
        lastError = e;

        if (attempt < 2) {
          await Future.delayed(const Duration(milliseconds: 700));
        }
      }
    }

    throw Exception('AI 코멘트 생성 요청 실패: $lastError');
  }

  Future<String> _postGenerateComment(
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('$baseUrl/generate-comment');

    final response = await http
        .post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        )
        .timeout(
          const Duration(seconds: 60),
        );

    final decodedBody = utf8.decode(response.bodyBytes);

    if (response.statusCode != 200) {
      throw Exception(
        '서버 오류 ${response.statusCode}: $decodedBody',
      );
    }

    final data = jsonDecode(decodedBody);

    if (data['comment'] == null) {
      throw Exception('서버 응답에 comment 값이 없습니다: $decodedBody');
    }

    return data['comment'].toString();
  }
}