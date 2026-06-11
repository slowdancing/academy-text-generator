import 'package:flutter/material.dart';
import 'screens/report_screen.dart';

void main() {
  runApp(const AcademyTextGeneratorApp());
}

class AcademyTextGeneratorApp extends StatelessWidget {
  const AcademyTextGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '학습 안내문 생성기',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const ReportScreen(),
    );
  }
}