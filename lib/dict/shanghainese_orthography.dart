import 'package:chinese_dictionary/dict/orthography.dart';

class ShanghaineseOrthography extends Orthography {
  ShanghaineseOrthography._();
  static final ShanghaineseOrthography instance = ShanghaineseOrthography._();

  @override
  String? canonicalize(String input, int system) {
    return input;
  }

  @override
  String? display(String input, int system) {
    return input;
  }

  @override
  List<String>? getAllTones(String input) {
    if (input.isEmpty) return null;
    var tone = input[input.length - 1];
    var base = input;
    if ('15678'.contains(tone)) {
      base = input.substring(0, input.length - 1);
    } else {
      tone = '_';
    }

    if (base.isEmpty) return null;

    bool isEnteringTone = base.endsWith('h');
    List<String> result = [];
    result.add(input);
    if (isEnteringTone) {
      if (tone != '7') result.add(base + '7');
      if (tone != '8') result.add(base + '8');
    } else {
      if (tone != '1') result.add(base + '1');
      if (tone != '5') result.add(base + '5');
      if (tone != '6') result.add(base + '6');
    }
    return result;
  }

  @override
  Future<void> init() async {
    // does not need init
  }
}
