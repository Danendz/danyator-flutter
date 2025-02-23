import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/dark.dart';

class CodeThemeNotifier extends ChangeNotifier {
  CodeThemeData _codeTheme = CodeThemeData(styles: monokaiSublimeTheme);

  CodeThemeData get codeTheme => _codeTheme;

  void setTheme(CodeThemeData newTheme) {
    _codeTheme = newTheme;
    notifyListeners();
  }
}