import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:async';

class RecognitionPage extends StatefulWidget {
  static const routeName = '/recognition';

  const RecognitionPage({super.key});

  @override
  State<RecognitionPage> createState() => _RecognitionPageState();
}

class _RecognitionPageState extends State<RecognitionPage> {
  String _predictedActivity = "Predição não definida";
  bool _isModelLoaded = false;
  bool _isListening = false;
  bool _isStartButtonDisabled = false;
  Interpreter? _interpreter;
  List<double> _accelerometerValues = [0.0, 0.0, 0.0];
  List<Map<String, dynamic>> _accelerometerDataList = [];
  StreamSubscription<AccelerometerEvent>? _subscription;
  int _countdown = 10;
  int _targetFrequency = 50; // Frequência do acelerômetro (Hz)
  int _sampleIntervalMs = 1000 ~/ 50; // Intervalo de amostragem
  int _batchSize = 80; // Tamanho fixo do vetor que o modelo espera
  final List<String> _labels = ['Downstairs', 'Sitting', 'Standing', 'Inclined'];

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {
        _isModelLoaded = true;
      });
    });
  }

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('./rah_modelCNN.tflite');
      print('Modelo carregado com sucesso!');
    } catch (e) {
      print('Falha ao carregar modelo: $e');
    }
  }

  void _predictActivity(List<List<double>> inputData) {
    var input = _convertToByteBuffer(inputData);
    var output = _createOutputBuffer();

    try {
      _interpreter!.run(input, output);
      var outputList = _extractOutput(output);
      int activityIndex = outputList.indexOf(outputList.reduce((curr, next) => curr > next ? curr : next));
      setState(() {
        _predictedActivity = _labels[activityIndex];
      });
    } catch (e) {
      print('Falha ao realizar predição: $e');
    }
  }

  // Converte os dados de entrada para o formato esperado pelo modelo
  Uint8List _convertToByteBuffer(List<List<double>> input) {
    var flatList = input.expand((i) => i).toList();
    var floatList = Float32List.fromList(flatList);
    var byteBuffer = floatList.buffer.asUint8List();
    return byteBuffer;
  }

  // Cria o buffer de saída
  List<List<double>> _createOutputBuffer() {
    return List.generate(1, (_) => List.filled(4, 0.0));
  }

  // Extrai o resultado da predição
  List<double> _extractOutput(List<List<double>> buffer) {
    return buffer.expand((e) => e).toList();
  }

  // Função para coletar dados do acelerômetro e realizar a predição
  void startAccelerometerDataCollection() {
    _accelerometerDataList = [];
    _subscription = accelerometerEvents.listen((AccelerometerEvent event) {
      if (_isListening && _countdown > 0) {
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        final elapsedTime = currentTime - (_accelerometerDataList.isNotEmpty ? _accelerometerDataList.last['timestamp'] as int : 0);

        if (elapsedTime >= _sampleIntervalMs) {
          setState(() {
            _accelerometerDataList.add({
              "x": event.x,
              "y": event.y,
              "z": event.z,
              "timestamp": currentTime,
            });
            _accelerometerValues = [event.x, event.y, event.z];

            if (_accelerometerDataList.length == _batchSize) {
              List<List<double>> batchData = _accelerometerDataList.map((data) => [data['x'] as double, data['y'] as double, data['z'] as double]).toList();
              _predictActivity(batchData);
              _accelerometerDataList.clear();
            }
          });
        }
      }
    });
  }

  // Inicia a coleta de dados do acelerômetro
  void startListeningToAccelerometer() {
    _isListening = true;
    startAccelerometerDataCollection();
    setState(() {
      _isStartButtonDisabled = true;
    });
  }

  // Para a coleta de dados do acelerômetro
  void stopListeningToAccelerometer() {
    _isListening = false;
    _subscription?.cancel();
    setState(() {
      _isStartButtonDisabled = false;
      _predictedActivity = 'Unknown';
    });
  }

  // Atualiza a frequência e o intervalo de amostragem
  void _updateFrequency(int frequency) {
  setState(() {
    _targetFrequency = frequency;
    _sampleIntervalMs = 1000 ~/ _targetFrequency;  // Calcula o intervalo de amostragem (ms)
    _batchSize = 80;  // Tamanho fixo do vetor de entrada (80 posições)
  });

  if (_isListening) {
    stopListeningToAccelerometer();
    startListeningToAccelerometer();
  }
}


  @override
  void dispose() {
    _subscription?.cancel();
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconhecimento das Atividades'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Valores do Acelerômetro:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'X: ${_accelerometerValues[0].toStringAsFixed(2)}, Y: ${_accelerometerValues[1].toStringAsFixed(2)}, Z: ${_accelerometerValues[2].toStringAsFixed(2)}',
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isStartButtonDisabled ? null : startListeningToAccelerometer,
              child: const Text('Iniciar Reconhecimento'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isListening ? stopListeningToAccelerometer : null,
              child: const Text('Parar Reconhecimento'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ação Reconhecida:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _predictedActivity.isEmpty ? 'N/A' : _predictedActivity,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Frequência de Coleta (Hz):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _targetFrequency.toDouble(),
              min: 1,
              max: 100,
              divisions: 99,
              label: _targetFrequency.toString(),
              onChanged: (value) {
                _updateFrequency(value.toInt());
              },
            ),
          ],
        ),
      ),
    );
  }
}
