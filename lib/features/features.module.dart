import 'package:e_trainer_chess/core/utils/module.base.dart';
import 'package:e_trainer_chess/features/opening_trainer/opening_trainer.module.dart';
import 'package:get_it/get_it.dart';

class FeaturesModule extends ModuleBase {
  @override
  List<ModuleBase> get imports => [
    OpeningTrainerModule(),
  ];

  @override
  void inject(GetIt sl) {}
}
