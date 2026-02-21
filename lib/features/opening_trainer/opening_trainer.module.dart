import 'package:auto_route/auto_route.dart';
import 'package:e_trainer_chess/core/router/router.gr.dart';
import 'package:e_trainer_chess/core/utils/module.base.dart';
import 'package:e_trainer_chess/features/opening_trainer/services/stores/opening_trainer.store.dart';
import 'package:get_it/get_it.dart';

class OpeningTrainerModule extends ModuleBase {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          initial: true,
          path: '/opening-trainer',
          page: OpeningTrainerRoute.page,
        ),
      ];

  @override
  void inject(GetIt sl) {
    if (!sl.isRegistered<OpeningTrainerStore>()) {
      sl.registerFactory<OpeningTrainerStore>(() => OpeningTrainerStore());
    }
  }
}
