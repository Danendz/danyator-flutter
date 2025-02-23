import 'package:highlight/languages/vbscript-html.dart';
import 'package:danyator/widgets/editor/editor_base.dart';

class HTMLEditor extends EditorBase {
  const HTMLEditor({
    super.key,
    required super.initialCode,
    required super.onCodeChanged,
  });

  @override
  dynamic get language => vbscriptHtml;
}