// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'localization.store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$LocalizationStore on LocalizationStoreBase, Store {
  late final _$currentLocaleAtom = Atom(
    name: 'LocalizationStoreBase.currentLocale',
    context: context,
  );

  @override
  String get currentLocale {
    _$currentLocaleAtom.reportRead();
    return super.currentLocale;
  }

  @override
  set currentLocale(String value) {
    _$currentLocaleAtom.reportWrite(value, super.currentLocale, () {
      super.currentLocale = value;
    });
  }

  late final _$translationsAtom = Atom(
    name: 'LocalizationStoreBase.translations',
    context: context,
  );

  @override
  ObservableMap<String, dynamic> get translations {
    _$translationsAtom.reportRead();
    return super.translations;
  }

  @override
  set translations(ObservableMap<String, dynamic> value) {
    _$translationsAtom.reportWrite(value, super.translations, () {
      super.translations = value;
    });
  }

  late final _$initAsyncAction = AsyncAction(
    'LocalizationStoreBase.init',
    context: context,
  );

  @override
  Future<void> init() {
    return _$initAsyncAction.run(() => super.init());
  }

  late final _$setLocaleAsyncAction = AsyncAction(
    'LocalizationStoreBase.setLocale',
    context: context,
  );

  @override
  Future<void> setLocale(String locale) {
    return _$setLocaleAsyncAction.run(() => super.setLocale(locale));
  }

  @override
  String toString() {
    return '''
currentLocale: ${currentLocale},
translations: ${translations}
    ''';
  }
}
