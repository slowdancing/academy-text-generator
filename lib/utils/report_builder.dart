String buildFinalReport({
  required String week,
  required String studentName,
  required String grade,
  required String attendance,
  required List<Map<String, dynamic>> studyGroups,
  required String homeworkSubmit,
  required String homeworkQuality,
  required String attitude,
  required List<Map<String, dynamic>> testResults,
  required String comment,
}) {
  final studyText = studyGroups
      .where((group) {
        final book = group['book'].toString().trim();
        final units = group['units'] as List<String>;

        return book.isNotEmpty || units.any((unit) => unit.trim().isNotEmpty);
      })
      .map((group) {
        final book = group['book'].toString().trim();
        final units = group['units'] as List<String>;

        final unitText = units
            .where((unit) => unit.trim().isNotEmpty)
            .map((unit) => '        ${unit.trim()}')
            .join('\n');

        if (book.isEmpty) {
          return unitText;
        }

        if (unitText.isEmpty) {
          return '  -$book';
        }

        return '  -$book\n$unitText';
      })
      .join('\n');

  final filteredTestResults = testResults
      .where((result) => result['unit'].toString().trim().isNotEmpty)
      .toList();

  final testText = filteredTestResults.isEmpty
      ? '  -이번 주 월말평가는 진행하지 않았습니다.'
      : filteredTestResults.map((result) {
          return '  -${result['unit']} : ${result['total']}문항중 ${result['correct']}개';
        }).join('\n');

  return '''
※체인지수학 $week학습안내※

           ♡$studentName($grade)♡
*출결상황
  -$attendance
*학습과정
$studyText
*과제
  -제출$homeworkSubmit  완성도 $homeworkQuality
*수업태도 - $attitude
*월말평가정답
$testText

-$comment
''';
}