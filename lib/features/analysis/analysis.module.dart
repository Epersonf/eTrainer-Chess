import 'package:auto_route/auto_route.dart';
import 'package:e_trainer_chess/core/router/router.gr.dart';
import 'package:e_trainer_chess/core/utils/module.base.dart';
import 'package:e_trainer_chess/features/analysis/services/stores/analysis.store.dart';
import 'package:get_it/get_it.dart';

class AnalysisModule extends ModuleBase {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: AnalysisRoute.page,
          path: "/analysis",
        ),
      ];

  @override
  void inject(GetIt sl) {
    if (!sl.isRegistered<AnalysisStore>()) {
      // Registrando como Factory para que o estado seja zerado 
      // toda vez que o usuário entrar na tela.
      sl.registerFactory<AnalysisStore>(() => AnalysisStore());
    }
  }
}