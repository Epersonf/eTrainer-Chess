import 'package:auto_route/auto_route.dart';
import 'package:e_trainer_chess/main.module.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter();

  static final MainModule _mainModule = MainModule();

  @override
  List<AutoRoute> get routes => [..._mainModule.collectRoutes()];
}
