import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';

abstract class ModuleBase {
  List<AutoRoute> get routes => [];
  List<ModuleBase> get imports => [];

  List<AutoRoute> collectRoutes() {
    final all = <AutoRoute>[...routes];
    for (final m in imports) {
      all.addAll(m.collectRoutes());
    }
    return all;
  }

  void registerStores(GetIt sl) {
    for (final m in imports) {
      m.registerStores(sl);
    }
    inject(sl);
  }

  void inject(GetIt sl);
}