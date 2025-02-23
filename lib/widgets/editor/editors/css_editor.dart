import 'package:highlight/languages/css.dart';
import 'package:danyator/widgets/editor/editor_base.dart';

class CSSEditor extends EditorBase {
  const CSSEditor({
    super.key,
    required super.initialCode,
    required super.onCodeChanged,
  });

  @override
  dynamic get language => css;
}
