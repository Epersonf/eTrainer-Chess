// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i4;
import 'package:e_trainer_chess/features/analysis/screens/analysis.screen.dart'
    as _i1;
import 'package:e_trainer_chess/features/lines_tool/opening_editor/screens/opening_editor.screen.dart'
    as _i2;
import 'package:e_trainer_chess/features/lines_tool/opening_trainer/screens/opening_trainer.screen.dart'
    as _i3;

/// generated route for
/// [_i1.AnalysisScreen]
class AnalysisRoute extends _i4.PageRouteInfo<void> {
  const AnalysisRoute({List<_i4.PageRouteInfo>? children})
    : super(AnalysisRoute.name, initialChildren: children);

  static const String name = 'AnalysisRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i1.AnalysisScreen();
    },
  );
}

/// generated route for
/// [_i2.OpeningEditorScreen]
class OpeningEditorRoute extends _i4.PageRouteInfo<void> {
  const OpeningEditorRoute({List<_i4.PageRouteInfo>? children})
    : super(OpeningEditorRoute.name, initialChildren: children);

  static const String name = 'OpeningEditorRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i2.OpeningEditorScreen();
    },
  );
}

/// generated route for
/// [_i3.OpeningTrainerScreen]
class OpeningTrainerRoute extends _i4.PageRouteInfo<void> {
  const OpeningTrainerRoute({List<_i4.PageRouteInfo>? children})
    : super(OpeningTrainerRoute.name, initialChildren: children);

  static const String name = 'OpeningTrainerRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i3.OpeningTrainerScreen();
    },
  );
}
