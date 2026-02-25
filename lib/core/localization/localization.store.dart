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
  ObservableMap<String, dynamic> translations = ObservableMap<String, dynamic>();

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
      final jsonString = await rootBundle.loadString('assets/localization/$locale.json');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonString);

      translations = ObservableMap.of(jsonMap);
      currentLocale = locale;

      await SharedPrefsHelper.prefs.setString(_langKey, locale);
    } catch (e) {
      // Fallback em caso de erro no JSON
      print("Erro ao carregar idioma: $e");
    }
  }

  String t(String key) {
    return translations[key] ?? key;
  }
}
