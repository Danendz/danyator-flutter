import 'package:danyator/widgets/editor/notifiers/code_theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:provider/provider.dart';

abstract class EditorBase extends StatefulWidget {
  final String initialCode;
  final void Function(String code) onCodeChanged;

  const EditorBase({
    super.key,
    required this.initialCode,
    required this.onCodeChanged,
  });

  dynamic get language;

  @override
  State<EditorBase> createState() => _EditorBaseState();
}

class _EditorBaseState extends State<EditorBase> {
  late CodeController _codeController;

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: widget.initialCode,
      language: widget.language,
    );

    _codeController.addListener(() {
      widget.onCodeChanged(_codeController.text);
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<CodeThemeNotifier>(context).codeTheme;

    return CodeTheme(
      data: currentTheme,
      child: SingleChildScrollView(
        child: CodeField(controller: _codeController),
      ),
    );
  }
}
