import 'package:flutter/material.dart';
import 'package:rah/pages/runtrainingpage.dart';
import 'package:rah/pages/homepage.dart';
import 'package:rah/pages/recognitionpage.dart';
import 'package:rah/pages/trainingpage.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UFF - RAH',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF002147)),
        useMaterial3: true,
      ),
      initialRoute: HomePage.routeName,
      routes: <String, WidgetBuilder>{
        HomePage.routeName: (context) => const HomePage(),
        TrainingPage.routeName: (context) => const TrainingPage(),
        RecognitionPage.routeName: (context) => const RecognitionPage(),
        RunTrainingPage.routeName: (context) => const RunTrainingPage(),
      },
    );
  }
}
