import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:async';
import 'dart:math';

class RecognitionPage extends StatefulWidget {
  static const routeName = '/recognition';

  const RecognitionPage({Key? key}) : super(key: key);

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
  List<List<double>> _sensorData = [];
  List<double> _mean = [0.0, 0.0, 0.0];
  List<double> _stddev = [1.0, 1.0, 1.0]; // Inicialmente padrão, pode ser ajustado conforme necessário
  final List<String> _labels = ['Standing', 'Sitting' ,'Downstairs'];
 

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
      _interpreter =
          await Interpreter.fromAsset('assets/rah_model100Hz.tflite');
      print('Modelo carregado com sucesso!');
    } catch (e) {
      print('Falha ao carregar modelo: $e');
    }
  }

  void _predictActivity(List<List<double>> inputData) {
    var standardizedData = standardizeData(inputData);
    var input = _convertToByteBuffer(standardizedData);
    var output = _createOutputBuffer();

    try {
      _interpreter!.run(input, output);

      var outputList = _extractOutput(output);
      int activityIndex =
          outputList.indexOf(outputList.reduce((curr, next) => curr > next ? curr : next));
      setState(() {
        _predictedActivity = _labels[activityIndex];
      });
    } catch (e) {
      print('Falha ao realizar predição: $e');
    }
  }

  List<List<double>> standardizeData(List<List<double>> data) {
    // Calcular a média de cada dimensão
    for (var i = 0; i < data.length; i++) {
      _mean[0] += data[i][0];
      _mean[1] += data[i][1];
      _mean[2] += data[i][2];
    }
    _mean[0] /= data.length;
    _mean[1] /= data.length;
    _mean[2] /= data.length;

    // Calcular o desvio padrão de cada dimensão
    for (var i = 0; i < data.length; i++) {
      _stddev[0] += (data[i][0] - _mean[0]) * (data[i][0] - _mean[0]);
      _stddev[1] += (data[i][1] - _mean[1]) * (data[i][1] - _mean[1]);
      _stddev[2] += (data[i][2] - _mean[2]) * (data[i][2] - _mean[2]);
    }
    _stddev[0] = sqrt(_stddev[0] / data.length);
    _stddev[1] = sqrt(_stddev[1] / data.length);
    _stddev[2] = sqrt(_stddev[2] / data.length);

    // Aplicar a padronização
    return data.map((d) {
      return [
        (d[0] - _mean[0]) / _stddev[0],
        (d[1] - _mean[1]) / _stddev[1],
        (d[2] - _mean[2]) / _stddev[2],
      ];
    }).toList();
  }

  Uint8List _convertToByteBuffer(List<List<double>> input) {
    var flatList = input.expand((i) => i).toList();
    var floatList = Float32List.fromList(flatList);
    var byteBuffer = floatList.buffer.asUint8List();
    return byteBuffer;
  }

  List<List<double>> _createOutputBuffer() {
    return List.generate(1, (_) => List.filled(3, 0.0));
  }

  List<double> _extractOutput(List<List<double>> buffer) {
    return buffer.expand((e) => e).toList();
  }

  void listenToAccelerometer() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      if (_isListening) {
        setState(() {
          _accelerometerValues = [event.x, event.y, event.z];
        });
        _sensorData.add([event.x, event.y, event.z]);

        if (_sensorData.length >= 80) {
          _predictActivity(_sensorData);
          _sensorData.clear();
        }
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
      _predictedActivity = 'Unknown';
    });
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
              onPressed:
                  _isStartButtonDisabled ? null : startListeningToAccelerometer,
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
          ],
        ),
      ),
    );
  }
}