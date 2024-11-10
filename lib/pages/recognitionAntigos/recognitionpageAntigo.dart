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
  String _predictedActivity = "Unknown";
  bool _isModelLoaded = false;
  int _timestamp = 0;
  bool _isListening = false;
  bool _isStartButtonDisabled = false;
  Interpreter? _interpreter;
  List<double> _accelerometerValues = [0.0, 0.0, 0.0];
  final List<String> _labels = [
    'Downstairs',
    'Jogging',
    'Sitting',
    'Standing',
    'Upstairs',
    'Walking'
  ];

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {
        _isModelLoaded = true;
      });
    });
    listenToAccelerometer();
  }

  // Load TensorFlow Lite model
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/rah_modelNovo.tflite');

      print('Modelo carregado com sucesso!');
    } catch (e) {
      print('Falha ao carregar modelo: $e');
    }
  }

  void _predictActivity(double x, double y, double z, int timestamp) {
    var input = [x, y, z, timestamp.toDouble()].reshape([1, 4]);
    var output = List.filled(6, 0.0).reshape([1, 6]);
    try {
      _interpreter!.run(input, output);

      int activityIndex = output[0]
          .indexOf(output[0].reduce((curr, next) => curr > next ? curr : next));
      setState(() {
        _predictedActivity = _labels[activityIndex];
      });
    } catch (e) {
      print('Falha ao realizar predição: $e');
    }
  }

  Uint8List _convertToByteBuffer(List<List<double>> input) {
    var flatList = input.expand((i) => i).toList();
    var floatList = Float32List.fromList(flatList);
    var byteBuffer = floatList.buffer.asUint8List();
    return byteBuffer;
  }

  List<List<double>> _createOutputBuffer() {
    // Adjust to match the output shape [1, 6]
    return List.generate(1, (_) => List.filled(6, 0.0));
  }

  List<double> _extractOutput(List<List<double>> buffer) {
    return buffer.expand((e) => e).toList();
  }

  String _mapIndexToActivity(int index) {
    List<String> activities = [
      'Downstairs',
      'Jogging',
      'Sitting',
      'Standing',
      'Upstairs',
      'Walking'
    ];
    return activities[index];
  }

  Future<void> predict() async {
    if (_interpreter == null) {
      print('Interpreter is not initialized');
      return;
    }

    var input = List.generate(80, (index) => [1.0, 2.0, 3.0]);
    var inputBuffer = _convertToByteBuffer(input);

    // Create an output buffer
    var outputBuffer = _createOutputBuffer();

    // Run inference
    _interpreter!.run(inputBuffer, outputBuffer);

    // Extract the output
    var output = _extractOutput(outputBuffer);
    print("Model output: $output");

    // Find the predicted class with the highest probability
    int predictedIndex = output
        .indexOf(output.reduce((curr, next) => curr > next ? curr : next));

    setState(() {
      _predictedActivity = _mapIndexToActivity(predictedIndex);
      print("Output data: $_predictedActivity");
    });
  }

  // Listen to accelerometer
  void listenToAccelerometer() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        _accelerometerValues = [event.x, event.y, event.z];
      });
      if (_isListening) {
        _accelerometerValues = [event.x, event.y, event.z];
        _timestamp = DateTime.now().millisecondsSinceEpoch;
        _predictActivity(event.x, event.y, event.z, _timestamp);
      }
    });
  }

  void startListeningToAccelerometer() {
    _isListening = true;
    setState(() {
      _isStartButtonDisabled = true;
    });
  }

  void stopListeningToAccelerometer() {
    _isListening = false;
    setState(() {
      _isStartButtonDisabled = false;
    });
  }

  void testModelWithExampleInput() {
    //_predictActivity(0.1, 0.2, 0.3, DateTime.now().millisecondsSinceEpoch);
    predict();
  }

  @override
  void dispose() {
    if (_interpreter != null) {
      _interpreter!.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Reconhecimento das atividades'),
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
                onPressed: _isStartButtonDisabled
                    ? null
                    : () {
                        startListeningToAccelerometer();
                      },
                child: const Text('Iniciar Reconhecimento'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  stopListeningToAccelerometer();
                  setState(() {
                    _predictedActivity = '';
                  });
                },
                child: const Text('Parar Reconhecimento'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: testModelWithExampleInput,
                child: const Text('Teste do modelo com valores fixos'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Ação reconhecida:',
              ),
              const SizedBox(height: 10),
              Text(
                _predictedActivity.isEmpty ? 'N/A' : _predictedActivity,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
