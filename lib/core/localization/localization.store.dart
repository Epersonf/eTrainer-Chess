import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:mobx/mobx.dart';
import 'package:e_trainer_chess/core/local_storage/shared_prefs_helper.dart';

part 'localization.store.g.dart';

class LocalizationStore = LocalizationStoreBase with _$LocalizationStore;

abstract class LocalizationStoreBase with Store {
  static const _langKey = 'selected_language';

  @observable
  String currentLocale = 'pt';

  @observable
  ObservableMap<String, String> translations = ObservableMap<String, String>();

  final List<Map<String, String>> availableLanguages = [
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
    {'code': 'pt', 'name': 'Português', 'flag': '🇧🇷'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'it', 'name': 'Italiano', 'flag': '🇮🇹'},
    {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
  ];

  @action
  Future<void> init() async {
    final savedLang = SharedPrefsHelper.prefs.getString(_langKey) ?? 'pt';
    await setLocale(savedLang);
  }

  @action
  Future<void> setLocale(String locale) async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/localization/$locale.json',
      );
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      translations = ObservableMap.of(_flattenMap(jsonMap));
      currentLocale = locale;

      await SharedPrefsHelper.prefs.setString(_langKey, locale);
    } catch (e) {
      print("Erro ao carregar idioma $locale: $e");
    }
  }

  // Achata o JSON aninhado para notação de ponto
  Map<String, String> _flattenMap(
    Map<String, dynamic> map, {
    String prefix = '',
  }) {
    Map<String, String> result = {};
    map.forEach((key, value) {
      final newKey = prefix.isEmpty ? key : '$prefix.$key';
      if (value is Map<String, dynamic>) {
        result.addAll(_flattenMap(value, prefix: newKey));
      } else {
        result[newKey] = value.toString();
      }
    });
    return result;
  }

  String t(String key) {
    return translations[key] ?? key;
  }
}
