import 'package:chinese_dictionary/dict/orthography.dart';

class MinnanOrthography extends Orthography {
  MinnanOrthography._();
  static final MinnanOrthography instance = MinnanOrthography._();

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
    if ('1234578'.contains(tone)) {
      base = input.substring(0, input.length - 1);
    } else {
      tone = '_';
    }

    if (base.isEmpty) return null;

    bool isEnteringTone = 'ptkh'.contains(base[base.length - 1]);
    List<String> result = [];
    result.add(input);
    if (isEnteringTone) {
      if (tone != '4') result.add(base + '4');
      if (tone != '8') result.add(base + '8');
    } else {
      if (tone != '1') result.add(base + '1');
      if (tone != '2') result.add(base + '2');
      if (tone != '3') result.add(base + '3');
      if (tone != '5') result.add(base + '5');
      if (tone != '7') result.add(base + '7');
    }
    return result;
  }

  @override
  Future<void> init() async {
    // no extra resource to load
  }
}
