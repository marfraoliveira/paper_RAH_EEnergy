import 'package:flutter/material.dart';

class RunTrainingPage extends StatelessWidget {
  static const routeName = '/runtraining';

  const RunTrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Executar Treinamento de Atividade'),
      ),
      body: const Center(
        child: Text(
          'Executar Treinamento de Atividade',
          style: TextStyle(fontSize: 30),
        ),
      ),
    );
  }
}
