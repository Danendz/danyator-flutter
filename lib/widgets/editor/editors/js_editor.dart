import 'package:highlight/languages/javascript.dart';
import 'package:danyator/widgets/editor/editor_base.dart';

class JSEditor extends EditorBase {
  const JSEditor({
    super.key,
    required super.initialCode,
    required super.onCodeChanged,
  });

  @override
  dynamic get language => javascript;
}
