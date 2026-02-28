import 'engine_arrow.dart';

class EngineEvaluation {
  final String evalString; // Ex: "+0.34", "-4.48" ou "M3"
  final String moveSan; // Ex: "1. e4 e5 2. Nf3 Nc6..."
  final EngineArrow arrow; // A seta individual deste lance

  EngineEvaluation(this.evalString, this.moveSan, this.arrow);
}
