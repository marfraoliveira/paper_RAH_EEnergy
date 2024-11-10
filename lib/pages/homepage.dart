import 'package:flutter/material.dart';
import 'package:rah/pages/recognitionpageCACC.dart';
// import 'package:rah/pages/trainingpage.dart';

class HomePage extends StatefulWidget {
  static const routeName = '/';

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          'UFF - Reconhecimento de Atividades Humanas',
          style: TextStyle(fontSize: 15),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.pushNamed(context, TrainingPage.routeName);
            //   },
            //   child: const Text('Treinar Atividades'),
            // ),
            // const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, RecognitionPage.routeName);
              },
              child: const Text('Reconhecimento de Atividades'),
            ),
          ],
        ),
      ),
    );
  }
}
