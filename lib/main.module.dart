import 'package:e_trainer_chess/core/utils/module.base.dart';
import 'package:e_trainer_chess/features/features.module.dart';
import 'package:e_trainer_chess/infra/intra-api/intra-api.module.dart';
import 'package:get_it/get_it.dart';

class MainModule extends ModuleBase {
  @override
  List<ModuleBase> get imports => [
    IntraApiModule(),
    FeaturesModule(),
  ];

  @override
  void inject(GetIt sl) {}
}
