import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/report_builder.dart';
import '../services/report_api.dart';

class BookStudyGroup {
  BookStudyGroup({
    required this.bookController,
    required this.unitControllers,
  });

  final TextEditingController bookController;
  final List<TextEditingController> unitControllers;

  void dispose() {
    bookController.dispose();

    for (final controller in unitControllers) {
      controller.dispose();
    }
  }
}

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final ReportApi reportApi = ReportApi(
    baseUrl: 'https://academy-text-generator-api.onrender.com',
  );

  bool isGeneratingComment = false;

  final TextEditingController weekController =
      TextEditingController(text: '4주차');
  final TextEditingController studentNameController =
      TextEditingController(text: '강다영');
  final TextEditingController gradeController =
      TextEditingController(text: '초4');
  final TextEditingController attendanceController =
      TextEditingController(text: '결석(x)');

  final List<BookStudyGroup> bookStudyGroups = [
    BookStudyGroup(
      bookController: TextEditingController(text: '4-1 독해가힘이다.라이트쎈'),
      unitControllers: [
        TextEditingController(text: '4.평면도형의 이동'),
        TextEditingController(text: '5.막대그래프'),
      ],
    ),
  ];

  final TextEditingController homeworkSubmitController =
      TextEditingController(text: '100%');
  final TextEditingController homeworkQualityController =
      TextEditingController(text: '80%');
  final TextEditingController attitudeController =
      TextEditingController(text: '좋음');

  final TextEditingController testUnit1Controller =
      TextEditingController(text: '5단원');
  final TextEditingController testTotal1Controller =
      TextEditingController(text: '20');
  final TextEditingController testCorrect1Controller =
      TextEditingController(text: '18');

  final TextEditingController testUnit2Controller =
      TextEditingController(text: '6단원');
  final TextEditingController testTotal2Controller =
      TextEditingController(text: '20');
  final TextEditingController testCorrect2Controller =
      TextEditingController(text: '19');

  final TextEditingController referenceNoteController = TextEditingController(
    text: '이번 월말평가는 빠른 시간 안에 잘 풀었습니다',
  );

  final TextEditingController weakPointsController = TextEditingController(
    text: '도형의 이동 단원에서 오답과 모르는 문제가 많이 나오고 있음',
  );

  final TextEditingController planController = TextEditingController(
    text: '4단원은 다양한 문제 풀이로 다시 학습할 예정입니다.',
  );

  final TextEditingController commentController = TextEditingController(
    text:
        '이번 월말평가는 빠른 시간 안에 잘 풀었습니다.\n꾸준한 학습으로 응용서 마무리가 되면 실력이 더 향상될 수 있을 거라 생각됩니다.\n응용서도 역시 도형의 이동 단원에서 오답과 모르는 문제들이 많이 나오고 있는 상황입니다.\n4단원은 다양한 문제 풀이로 다시 학습할 예정입니다.\n꾸준한 학습 이어갈 수 있도록 지도하겠습니다.',
  );

  String generatedText = '';

  @override
  void dispose() {
    weekController.dispose();
    studentNameController.dispose();
    gradeController.dispose();
    attendanceController.dispose();

    for (final group in bookStudyGroups) {
      group.dispose();
    }

    homeworkSubmitController.dispose();
    homeworkQualityController.dispose();
    attitudeController.dispose();

    testUnit1Controller.dispose();
    testTotal1Controller.dispose();
    testCorrect1Controller.dispose();
    testUnit2Controller.dispose();
    testTotal2Controller.dispose();
    testCorrect2Controller.dispose();

    referenceNoteController.dispose();
    weakPointsController.dispose();
    planController.dispose();
    commentController.dispose();

    super.dispose();
  }

  int _parseIntOrZero(String value) {
    return int.tryParse(value.trim()) ?? 0;
  }

  String getBooksText() {
    return bookStudyGroups
        .map((group) => group.bookController.text.trim())
        .where((book) => book.isNotEmpty)
        .join(', ');
  }

  List<String> getFlatUnitsText() {
    final List<String> units = [];

    for (final group in bookStudyGroups) {
      for (final unitController in group.unitControllers) {
        final unit = unitController.text.trim();

        if (unit.isNotEmpty) {
          units.add(unit);
        }
      }
    }

    return units;
  }

  List<Map<String, dynamic>> getStudyGroups() {
    return bookStudyGroups.map((group) {
      return {
        'book': group.bookController.text.trim(),
        'units': group.unitControllers
            .map((controller) => controller.text.trim())
            .where((unit) => unit.isNotEmpty)
            .toList(),
      };
    }).toList();
  }

  void addBookGroup() {
    setState(() {
      bookStudyGroups.add(
        BookStudyGroup(
          bookController: TextEditingController(),
          unitControllers: [
            TextEditingController(),
          ],
        ),
      );
    });
  }

  void removeBookGroup(int bookIndex) {
    if (bookStudyGroups.length <= 1) {
      return;
    }

    setState(() {
      final group = bookStudyGroups.removeAt(bookIndex);
      group.dispose();
    });
  }

  void addUnitToBook(int bookIndex) {
    setState(() {
      bookStudyGroups[bookIndex].unitControllers.add(
            TextEditingController(),
          );
    });
  }

  void removeUnitFromBook(int bookIndex, int unitIndex) {
    final units = bookStudyGroups[bookIndex].unitControllers;

    if (units.length <= 1) {
      return;
    }

    setState(() {
      final controller = units.removeAt(unitIndex);
      controller.dispose();
    });
  }

  void generateReport() {
    final report = buildFinalReport(
      week: weekController.text.trim(),
      studentName: studentNameController.text.trim(),
      grade: gradeController.text.trim(),
      attendance: attendanceController.text.trim(),
      studyGroups: getStudyGroups(),
      homeworkSubmit: homeworkSubmitController.text.trim(),
      homeworkQuality: homeworkQualityController.text.trim(),
      attitude: attitudeController.text.trim(),
      testResults: [
        {
          'unit': testUnit1Controller.text.trim(),
          'total': _parseIntOrZero(testTotal1Controller.text),
          'correct': _parseIntOrZero(testCorrect1Controller.text),
        },
        {
          'unit': testUnit2Controller.text.trim(),
          'total': _parseIntOrZero(testTotal2Controller.text),
          'correct': _parseIntOrZero(testCorrect2Controller.text),
        },
      ],
      comment: commentController.text.trim(),
    );

    setState(() {
      generatedText = report;
    });
  }

  Future<void> generateAiComment() async {
    setState(() {
      isGeneratingComment = true;
    });

    try {
      final comment = await reportApi.generateComment(
        studentName: studentNameController.text.trim(),
        grade: gradeController.text.trim(),
        week: weekController.text.trim(),
        attendance: attendanceController.text.trim(),
        books: getBooksText(),
        units: getFlatUnitsText(),
        homeworkSubmit: homeworkSubmitController.text.trim(),
        homeworkQuality: homeworkQualityController.text.trim(),
        attitude: attitudeController.text.trim(),
        testResults: [
          {
            'unit': testUnit1Controller.text.trim(),
            'total': _parseIntOrZero(testTotal1Controller.text),
            'correct': _parseIntOrZero(testCorrect1Controller.text),
          },
          {
            'unit': testUnit2Controller.text.trim(),
            'total': _parseIntOrZero(testTotal2Controller.text),
            'correct': _parseIntOrZero(testCorrect2Controller.text),
          },
        ],
        weakPoints: weakPointsController.text.trim(),
        plan: planController.text.trim(),
        referenceNote: referenceNoteController.text.trim(),
      );

      setState(() {
        commentController.text = comment;
      });

      generateReport();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('AI 코멘트가 생성되었습니다.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI 코멘트 생성 실패: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isGeneratingComment = false;
        });
      }
    }
  }

  Future<void> copyReport() async {
    if (generatedText.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('먼저 문자를 생성해주세요.'),
        ),
      );
      return;
    }

    await Clipboard.setData(
      ClipboardData(text: generatedText),
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('문자가 복사되었습니다.'),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget buildDynamicTextField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onRemove,
    bool canRemove = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: canRemove ? onRemove : null,
            icon: const Icon(Icons.remove_circle_outline),
            tooltip: '삭제',
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget buildBookStudyGroupCard(int bookIndex) {
    final group = bookStudyGroups[bookIndex];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade400,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '교재 ${bookIndex + 1}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: bookStudyGroups.length > 1
                    ? () => removeBookGroup(bookIndex)
                    : null,
                icon: const Icon(Icons.delete_outline),
                tooltip: '교재 삭제',
              ),
            ],
          ),
          buildTextField(
            label: '교재 ${bookIndex + 1}',
            controller: group.bookController,
          ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  '학습 단원',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => addUnitToBook(bookIndex),
                icon: const Icon(Icons.add_circle_outline),
                tooltip: '학습 단원 추가',
              ),
            ],
          ),
          ...List.generate(group.unitControllers.length, (unitIndex) {
            return buildDynamicTextField(
              label: '학습 단원 ${unitIndex + 1}',
              controller: group.unitControllers[unitIndex],
              canRemove: group.unitControllers.length > 1,
              onRemove: () => removeUnitFromBook(bookIndex, unitIndex),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('학습 안내문 생성기'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildSectionTitle('기본 정보'),
            buildTextField(label: '주차', controller: weekController),
            buildTextField(label: '학생 이름', controller: studentNameController),
            buildTextField(label: '학년', controller: gradeController),
            buildTextField(label: '출결상황', controller: attendanceController),

            buildSectionTitle('학습 과정'),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    '교재별 학습 단원',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: addBookGroup,
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: '교재 추가',
                ),
              ],
            ),
            ...List.generate(bookStudyGroups.length, (bookIndex) {
              return buildBookStudyGroupCard(bookIndex);
            }),

            buildSectionTitle('과제 / 태도'),
            buildTextField(
              label: '과제 제출률',
              controller: homeworkSubmitController,
            ),
            buildTextField(
              label: '과제 완성도',
              controller: homeworkQualityController,
            ),
            buildTextField(label: '수업 태도', controller: attitudeController),

            buildSectionTitle('월말평가'),
            buildTextField(label: '평가 단원 1', controller: testUnit1Controller),
            buildTextField(
              label: '전체 문항 수 1',
              controller: testTotal1Controller,
              keyboardType: TextInputType.number,
            ),
            buildTextField(
              label: '정답 개수 1',
              controller: testCorrect1Controller,
              keyboardType: TextInputType.number,
            ),
            buildTextField(label: '평가 단원 2', controller: testUnit2Controller),
            buildTextField(
              label: '전체 문항 수 2',
              controller: testTotal2Controller,
              keyboardType: TextInputType.number,
            ),
            buildTextField(
              label: '정답 개수 2',
              controller: testCorrect2Controller,
              keyboardType: TextInputType.number,
            ),

            buildSectionTitle('AI 코멘트 생성 정보'),
            buildTextField(
              label: 'AI가 참고할 초반 내용',
              controller: referenceNoteController,
              maxLines: 2,
            ),
            buildTextField(
              label: '보완이 필요한 부분',
              controller: weakPointsController,
              maxLines: 2,
            ),
            buildTextField(
              label: '향후 지도 계획',
              controller: planController,
              maxLines: 2,
            ),

            buildSectionTitle('코멘트'),
            buildTextField(
              label: '학부모 전달 코멘트',
              controller: commentController,
              maxLines: 6,
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isGeneratingComment ? null : generateAiComment,
                child: Text(
                  isGeneratingComment ? 'AI 코멘트 생성 중...' : 'AI 코멘트 생성',
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: generateReport,
                    child: const Text('문자 생성'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: copyReport,
                    child: const Text('복사하기'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            if (generatedText.isNotEmpty) ...[
              buildSectionTitle('미리보기'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SelectableText(
                  generatedText,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}