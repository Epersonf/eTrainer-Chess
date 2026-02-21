import 'package:auto_route/auto_route.dart';
import 'package:e_trainer_chess/core/router/router.gr.dart';
import 'package:e_trainer_chess/core/utils/module.base.dart';
import 'package:e_trainer_chess/features/opening_editor/services/stores/opening_editor.store.dart';
import 'package:get_it/get_it.dart';

class OpeningEditorModule extends ModuleBase {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: OpeningEditorRoute.page,
      path: "/opening-editor",
    ),
  ];

  @override
  void inject(GetIt sl) {
    if (!sl.isRegistered<OpeningEditorStore>()) {
      sl.registerFactory<OpeningEditorStore>(() => OpeningEditorStore());
    }
  }
}
