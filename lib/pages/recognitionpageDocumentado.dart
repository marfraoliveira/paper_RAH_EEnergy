import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:async';

/// Classe principal do widget que representa a página de reconhecimento.
class RecognitionPage extends StatefulWidget {
  static const routeName = '/recognition';

  const RecognitionPage({super.key});

  @override
  State<RecognitionPage> createState() => _RecognitionPageState();
}

/// Estado da página de reconhecimento, gerenciando a lógica de coleta de dados,
/// predição de atividade e interação com o usuário.
class _RecognitionPageState extends State<RecognitionPage> {
  String _predictedActivity = "Predição não definida"; // Texto exibido para a atividade predita
  bool _isModelLoaded = false; // Indica se o modelo está carregado
  bool _isListening = false; // Indica se o acelerômetro está sendo ouvido
  bool _isStartButtonDisabled = false; // Desativa o botão de início após pressionado
  Interpreter? _interpreter; // Interpretador TFLite para executar o modelo
  List<double> _accelerometerValues = [0.0, 0.0, 0.0]; // Valores atuais do acelerômetro
  List<Map<String, dynamic>> _accelerometerDataList = []; // Lista de dados coletados do acelerômetro
  StreamSubscription<AccelerometerEvent>? _subscription; // Assinatura do stream de dados do acelerômetro
  int _targetFrequency = 50; // Frequência de amostragem do acelerômetro (Hz)
  int _sampleIntervalMs = 1000 ~/ 50; // Intervalo entre amostras (ms)
  int _batchSize = 80; // Tamanho do lote de amostras que o modelo espera
  final List<String> _labels = ['Downstairs', 'Sitting', 'Standing', 'Inclined']; // Rótulos de atividades
  List<String> _predictionLogs = []; // Registro de logs das predições com timestamp

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {
        _isModelLoaded = true; // Define o status do modelo como carregado
      });
    });
  }

  /// Carrega o modelo TFLite a partir dos ativos do aplicativo.
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('./rah_modelCNN.tflite');
      print('Modelo carregado com sucesso!');
    } catch (e) {
      print('Falha ao carregar modelo: $e');
    }
  }

  /// Realiza a predição de atividade com base nos dados do acelerômetro.
  void _predictActivity(List<List<double>> inputData) {
    var input = _convertToByteBuffer(inputData);
    var output = _createOutputBuffer();

    try {
      _interpreter!.run(input, output);
      var outputList = _extractOutput(output);
      int activityIndex = outputList.indexOf(outputList.reduce((curr, next) => curr > next ? curr : next));
      
      // Adiciona a predição ao log com timestamp
      final predictionTime = DateTime.now().toIso8601String();
      _predictionLogs.add("[$predictionTime] Predição: ${_labels[activityIndex]}");
      
      setState(() {
        _predictedActivity = _labels[activityIndex]; // Atualiza a atividade predita
      });
    } catch (e) {
      print('Falha ao realizar predição: $e');
    }
  }

  /// Converte dados de entrada para o formato esperado pelo modelo TFLite.
  Uint8List _convertToByteBuffer(List<List<double>> input) {
    var flatList = input.expand((i) => i).toList();
    var floatList = Float32List.fromList(flatList);
    var byteBuffer = floatList.buffer.asUint8List();
    return byteBuffer;
  }

  /// Cria o buffer de saída para armazenar os resultados do modelo.
  List<List<double>> _createOutputBuffer() {
    return List.generate(1, (_) => List.filled(4, 0.0));
  }

  /// Extrai os resultados do buffer de saída do modelo.
  List<double> _extractOutput(List<List<double>> buffer) {
    return buffer.expand((e) => e).toList();
  }

  /// Inicia a coleta de dados do acelerômetro e chama o modelo periodicamente para predição.
  void startAccelerometerDataCollection() {
    _accelerometerDataList = [];
    _subscription = accelerometerEvents.listen((AccelerometerEvent event) {
      if (_isListening) {
        final currentTime = DateTime.now().millisecondsSinceEpoch;
        final elapsedTime = currentTime - (_accelerometerDataList.isNotEmpty ? _accelerometerDataList.last['timestamp'] as int : 0);

        // Verifica se o tempo decorrido é suficiente para coletar uma nova amostra
        if (elapsedTime >= _sampleIntervalMs) {
          setState(() {
            _accelerometerDataList.add({
              "x": event.x,
              "y": event.y,
              "z": event.z,
              "timestamp": currentTime,
            });
            _accelerometerValues = [event.x, event.y, event.z];

            // Executa a predição quando o tamanho do lote é alcançado
            if (_accelerometerDataList.length >= _batchSize) {
              List<List<double>> batchData = _accelerometerDataList
                  .sublist(0, _batchSize)
                  .map((data) => [data['x'] as double, data['y'] as double, data['z'] as double])
                  .toList();
              _predictActivity(batchData);

              // Mantém os últimos 40 registros e remove os mais antigos
              _accelerometerDataList = _accelerometerDataList.sublist(40);
            }
          });
        }
      }
    });
  }

  /// Inicia a escuta dos eventos do acelerômetro.
  void startListeningToAccelerometer() {
    _isListening = true;
    startAccelerometerDataCollection();
    setState(() {
      _isStartButtonDisabled = true;
    });
  }

  /// Para a escuta dos eventos do acelerômetro.
  void stopListeningToAccelerometer() {
    _isListening = false;
    _subscription?.cancel();
    setState(() {
      _isStartButtonDisabled = false;
      _predictedActivity = 'Unknown';
    });
  }

  /// Atualiza a frequência de coleta de dados e reinicia a escuta se estiver ativa.
  void _updateFrequency(int frequency) {
    setState(() {
      _targetFrequency = frequency;
      _sampleIntervalMs = 1000 ~/ _targetFrequency;
      _batchSize = 80;
    });

    if (_isListening) {
      stopListeningToAccelerometer();
      startListeningToAccelerometer();
    }
  }

  /// Fecha o modelo e a assinatura do acelerômetro ao sair da página.
  @override
  void dispose() {
    _subscription?.cancel();
    _interpreter?.close();
    super.dispose();
  }

  /// Constrói a interface da página de reconhecimento de atividades.
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
            const SizedBox(height: 20),
            const Text(
              'Log de Predições:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _predictionLogs.length,
                itemBuilder: (context, index) {
                  return Text(_predictionLogs[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

