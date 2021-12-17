import 'package:chinese_dictionary/dict/display_option_enum.dart';
import 'package:chinese_dictionary/dict/orthography.dart';

class CantoneseOrthography extends Orthography {
  CantoneseOrthography._();
  static final CantoneseOrthography instance = CantoneseOrthography._();

  /// Map jyutping initials to cantonese pinyin ones
  static late final Map<String, String> _mapInitialsJ2C;
  static late final Map<String, String> _mapInitialsJ2Y;
  static late final Map<String, String> _mapInitialsJ2L;
  static late final Map<String, String> _mapInitialsC2J;
  static late final Map<String, String> _mapInitialsY2J;
  static late final Map<String, String> _mapInitialsL2J;
  static late final Map<String, String> _mapFinalsJ2C;
  static late final Map<String, String> _mapFinalsJ2Y;
  static late final Map<String, String> _mapFinalsJ2L;
  static late final Map<String, String> _mapFinalsC2J;
  static late final Map<String, String> _mapFinalsY2J;
  static late final Map<String, String> _mapFinalsL2J;

  /// convert to Jyutping
  @override
  String? canonicalize(String input, int system) {
    if (input.isEmpty) return null;
    CantoneseDisplayOption option = CantoneseDisplayOption.values[system];
    Map<String, String> mapInitals;
    Map<String, String> mapFinals;
    switch (option) {
      case CantoneseDisplayOption.jyutping:
        return input;
      case CantoneseDisplayOption.cantonesePinyin:
        mapInitals = _mapInitialsC2J;
        mapFinals = _mapFinalsC2J;
        break;
      case CantoneseDisplayOption.yale:
        mapInitals = _mapInitialsY2J;
        mapFinals = _mapFinalsY2J;
        break;
      case CantoneseDisplayOption.sidneyLau:
        mapInitals = _mapInitialsL2J;
        mapFinals = _mapFinalsL2J;
        break;
      default:
        return null;
    }

    // tone
    var tone = input[input.length - 1];
    var s = input;
    if (tone.compareTo('1') >= 0 && tone.compareTo('9') <= 0) {
      s = s.substring(0, s.length - 1);
    } else {
      tone = '_';
    }

    // final
    int pos = 0;
    while (pos < s.length && !mapFinals.containsKey(s.substring(pos))) {
      ++pos;
    }
    if (pos == s.length) return null;
    var fin = mapFinals[s.substring(pos)]!;

    // inital
    var init = s.substring(0, pos);
    if (pos > 0) {
      if (!mapInitals.containsKey(init)) return null;
      init = mapInitals[init]!;
    }

    // cantonese pinyin tone to jyutping
    switch (tone) {
      case '7':
        tone = '1';
        break;
      case '8':
        tone = '3';
        break;
      case '9':
        tone = '6';
        break;
    }

    // In Yale, initial "y" is omitted if final begins with "yu"
    // If that happens, we need to put the initial "j" back in Jyutping
    if (option == CantoneseDisplayOption.yale &&
        init.isEmpty &&
        fin.startsWith('yu')) {
      init = 'j';
    }

    return init + fin + (tone == '_' ? '' : tone);
  }

  @override
  String? display(String input, int system) {
    // convert from Jyutping to given system
    if (input.isEmpty) return null;
    CantoneseDisplayOption option = CantoneseDisplayOption.values[system];
    Map<String, String> mapInitals;
    Map<String, String> mapFinals;
    switch (option) {
      case CantoneseDisplayOption.jyutping:
        return input;
      case CantoneseDisplayOption.cantonesePinyin:
        mapInitals = _mapInitialsJ2C;
        mapFinals = _mapFinalsJ2C;
        break;
      case CantoneseDisplayOption.yale:
        mapInitals = _mapInitialsJ2Y;
        mapFinals = _mapFinalsJ2Y;
        break;
      case CantoneseDisplayOption.sidneyLau:
        mapInitals = _mapInitialsJ2L;
        mapFinals = _mapFinalsJ2L;
        break;
      default:
        return null;
    }

    // tone
    var s = input;
    var tone = s[s.length - 1];
    if (tone.compareTo('1') >= 0 && tone.compareTo('6') <= 0) {
      s = s.substring(0, s.length - 1);
    } else {
      tone = '_';
    }

    // final
    int pos = 0;
    while (pos < s.length && !mapFinals.containsKey(s.substring(pos))) {
      ++pos;
    }
    if (pos == s.length) return null;
    var fin = mapFinals[s.substring(pos)]!;

    // initial
    var init = s.substring(0, pos);
    if (pos > 0) {
      if (!mapInitals.containsKey(init)) return null;
      init = mapInitals[init]!;
    }

    // handle entering tone of cantonese pinyin
    if (option == CantoneseDisplayOption.cantonesePinyin &&
        'ptk'.contains(fin[fin.length - 1])) {
      switch (tone) {
        case '1':
          tone = '7';
          break;
        case '3':
          tone = '8';
          break;
        case '6':
          tone = '9';
          break;
      }
    }

    // In Yale, initial "y" is omitted if final begins with "yu"
    if (option == CantoneseDisplayOption.yale &&
        init == 'y' &&
        fin.startsWith('yu')) {
      init = '';
    }

    return init + fin + (tone == '_' ? '' : tone);
  }

  @override
  List<String>? getAllTones(String input) {
    if (input.isEmpty) return null;
    var tone = input[input.length - 1];
    var base = input;
    if (tone.compareTo('1') >= 0 && tone.compareTo('6') <= 0) {
      base = input.substring(0, input.length - 1);
    } else {
      tone = '_';
    }

    if (base.isEmpty) return null;

    bool isEnteringTone = 'ptk'.contains(base[base.length - 1]);
    List<String> result = [];
    result.add(input);
    if (tone != '1') result.add(base + '1');
    if (tone != '2' && !isEnteringTone) result.add(base + '2');
    if (tone != '3') result.add(base + '3');
    if (tone != '4' && !isEnteringTone) result.add(base + '4');
    if (tone != '5' && !isEnteringTone) result.add(base + '5');
    if (tone != '6') result.add(base + '6');

    return result;
  }

  @override
  Future<void> init() async {
    await _initInitials();
    await _initFinals();
  }

  Future<void> _initInitials() async {
    _mapInitialsJ2C = {};
    _mapInitialsJ2Y = {};
    _mapInitialsJ2L = {};
    _mapInitialsC2J = {};
    _mapInitialsY2J = {};
    _mapInitialsL2J = {};
    var fields =
        await parseTsvFile('assets/character/orthography_ct_initials.tsv');
    for (var field in fields) {
      _mapInitialsJ2C[field[0]] = field[1];
      _mapInitialsJ2Y[field[0]] = field[2];
      _mapInitialsJ2L[field[0]] = field[3];
      _mapInitialsC2J[field[1]] = field[0];
      _mapInitialsY2J[field[2]] = field[0];
      _mapInitialsL2J[field[3]] = field[0];
    }
  }

  Future<void> _initFinals() async {
    _mapFinalsJ2C = {};
    _mapFinalsJ2Y = {};
    _mapFinalsJ2L = {};
    _mapFinalsC2J = {};
    _mapFinalsY2J = {};
    _mapFinalsL2J = {};
    var fields =
        await parseTsvFile('assets/character/orthography_ct_finals.tsv');
    for (var field in fields) {
      _mapFinalsJ2C[field[0]] = field[1];
      _mapFinalsJ2Y[field[0]] = field[2];
      _mapFinalsJ2L[field[0]] = field[3];
      _mapFinalsC2J[field[1]] = field[0];
      _mapFinalsY2J[field[2]] = field[0];
      _mapFinalsL2J[field[3]] = field[0];
    }
  }
}
