import 'package:danyator/enums/available_languages.dart';

class LanguagesCodeContent {
  final Map<AvailableLanguages, String> languagesContent = <AvailableLanguages, String>{
    AvailableLanguages.html: "<div>hello adeline</div>",
    AvailableLanguages.css: "",
    AvailableLanguages.js: ""
  };

  void setContent({required AvailableLanguages language, required String input}) {
    languagesContent[language] = input;
  }

  String getLangContent(AvailableLanguages language) {
    if (!languagesContent.containsKey(language)) {
      throw Exception('Language $language is not pre-populated in the map');
    }

    return languagesContent[language]!;
  }
}
