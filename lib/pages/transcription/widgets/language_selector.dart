import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:inference/pages/transcription/providers/speech_inference_provider.dart';
import 'package:inference/widgets/controls/no_outline_button.dart';
import 'package:provider/provider.dart';

class Language {
  final String iso639Set1Code;
  final String name;

  const Language(this.iso639Set1Code, this.name);


  static Future<List<Language>> loadFromAssets() async {
    final contents = await rootBundle.loadString("assets/whisper-languages.json");
    final jsonData = jsonDecode(contents);
    return List<Language>.from(jsonData.entries.map((entry) => Language(entry.key, entry.value)));
  }
}

Future<Map<String, String>> loadLanguageList() async {
    final contents = await rootBundle.loadString("assets/whisper-languages.json");
    return Map<String, String>.from(jsonDecode(contents));
}

class LanguageSelector extends StatefulWidget {
  const LanguageSelector({super.key});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  FutureOr<Map<String, String>>? languages;

  @override
  void initState() {
    super.initState();
    languages = loadLanguageList()..then((output) {
        setState(() {
           languages = output;
        });
    });
  }
  @override
  Widget build(BuildContext context) {
    if (languages is Map<String, String>) {
      return Consumer<SpeechInferenceProvider>(builder: (context, provider, child) {
          final languagesMap = languages as Map<String, String>;
          final language = languagesMap[provider.language];

          return DropDownButton(
            buttonBuilder: (context, callback) {
              return NoOutlineButton(
                onPressed: callback,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text("Language: $language"),
                      const Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Icon(FluentIcons.chevron_down, size: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
            items: [
              for (final language in languagesMap.entries)
                MenuFlyoutItem(text: Text(language.value), onPressed: () => provider.language = language.key)
            ]
          );
        }
      );
    } else {
      return Container();
    }
  }
}
