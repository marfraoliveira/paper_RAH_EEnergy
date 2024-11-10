import 'package:rah/enums/modeenum.dart';
import 'package:rah/pages/trainingpage.dart';

class TrainingModel {
  final String id;
  final ModeEnum mode;
  final PositionChoice position;

  TrainingModel(this.id, this.mode, this.position);
}
