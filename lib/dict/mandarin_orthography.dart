import 'package:chinese_dictionary/dict/display_option_enum.dart';
import 'package:chinese_dictionary/dict/orthography.dart';
import 'package:flutter/cupertino.dart';

class MandarinOrthography extends Orthography {
  MandarinOrthography._();
  static final MandarinOrthography instance = MandarinOrthography._();

  /// e.g. a1 -> ā; ǒ -> o3
  static late final Map<String, String> _mapPinyin;

  /// e.g. ㄓ -> zh
  static late final Map<String, String> _mapFromBopomofoPartial;

  /// reverse of mapFromBopomofoPartial
  static late final Map<String, String> _mapToBopomofoPartial;

  /// e.g. e.g. ˊ -> 2
  static late final Map<String, String> _mapFromBopomofoTone;

  /// reverse of mapFromBopomofoTone
  static late final Map<String, String> _mapToBopomofoTone;

  /// e.g. ㄓ -> zhi
  static late final Map<String, String> _mapFromBopomofoWhole;

  /// reverse of mapFromBopomofoWhole
  static late final Map<String, String> _mapToBopomofoWhole;

  final _vowels = ['a', 'o', 'e', 'i', 'u', 'v', 'n', 'm'];

  @override
  String? canonicalize(String input, int system) {
    if (input.isEmpty) return null;

    if (_mapFromBopomofoPartial.containsKey(input[0]) ||
        _mapFromBopomofoTone.containsKey(input[0])) {
      // input is bopomofo

      // the tone can be either first one or last one.
      var tone = '1';
      if (_mapFromBopomofoTone.containsKey(input[0])) {
        tone = _mapFromBopomofoTone[input[0]]!;
        input = input.substring(1);
      } else if (_mapFromBopomofoTone.containsKey(input[input.length - 1])) {
        tone = _mapFromBopomofoTone[input[input.length - 1]]!;
        input = input.substring(0, input.length - 1);
      }
      if (input.isEmpty) return null;
      if (_mapFromBopomofoWhole.containsKey(input)) {
        input = _mapFromBopomofoWhole[input]!;
      } else if (_mapFromBopomofoPartial.containsKey(input[0]) &&
          _mapFromBopomofoPartial.containsKey(input.substring(1))) {
        input = _mapFromBopomofoPartial[input[0]]! +
            _mapFromBopomofoPartial[input.substring(1)]!;
        if (input.startsWith('jv') ||
            input.startsWith('qv') ||
            input.startsWith('xv')) {
          input = input[0] + 'u' + input.substring(2);
        }
      } else {
        return null;
      }
      return input + (tone == '_' ? '' : tone);
    } else {
      // input is pinyin

      var tone = '_';
      var pinyin = '';
      for (int i = 0; i < input.length; ++i) {
        var s = input[i];
        if (_mapPinyin.containsKey(s)) {
          var value = _mapPinyin[s]!;
          assert(value.length == 2);
          var base = value[0];
          var t = value[1];
          if (base != '_') pinyin += base;
          if (t != '_') tone = t;
        } else {
          pinyin += s;
        }
      }
      return pinyin + (tone == '_' ? '' : tone);
    }
  }

  @override
  String? display(String input, int system) {
    var option = MandarinDisplayOption.values[system];
    var tone = input[input.length - 1];
    if (tone.compareTo('1') >= 0 && tone.compareTo('4') <= 0) {
      input = input.substring(0, input.length - 1);
    } else {
      tone = '_';
    }

    switch (option) {
      case MandarinDisplayOption.pinyin:
        // the index on which should the tone lie
        int pos = -1;
        if (input.endsWith('iu')) {
          // in this case, tone should on u
          pos = input.length - 1;
        } else {
          // other cases, tone should on vowels
          for (var v in _vowels) {
            if ((pos = input.indexOf(v)) > 0) break;
          }
        }

        if (pos == -1) return null;
        var result = '';
        for (int i = 0; i < input.length; ++i) {
          var t = (i == pos) ? tone : '_';
          var key = input[i] + t;
          if (_mapPinyin.containsKey(key)) {
            result += _mapPinyin[key]!;
          } else {
            result += input[i];
            if (t != '_') result += _mapPinyin['_$t']!;
          }
        }

        return result;
      case MandarinDisplayOption.bopomofo:
        if (!_mapToBopomofoWhole.containsKey(input)) {
          if (input.startsWith('ju') ||
              input.startsWith('qu') ||
              input.startsWith('xu')) {
            input = input[0] + 'v' + input.substring(2);
          }

          int pos = input.length;
          if (pos > 2) pos = 2;

          while (pos > 0) {
            if (_mapToBopomofoPartial.containsKey(input.substring(0, pos))) {
              break;
            }
            --pos;
          }

          if (pos == 0) return null;
          if (!_mapToBopomofoPartial.containsKey(input.substring(pos))) {
            return null;
          }

          input = _mapToBopomofoPartial[input.substring(0, pos)]! +
              _mapToBopomofoPartial[input.substring(pos)]!;
        } else {
          input = _mapToBopomofoWhole[input]!;
        }

        if ('234'.contains(tone)) {
          return input + _mapToBopomofoTone[tone]!;
        } else if (tone == '_') {
          return _mapToBopomofoTone[tone]! + input;
        }

        return input;
      default:
        return null;
    }
  }

  @override
  List<String>? getAllTones(String input) {
    if (input.isEmpty) return null;
    var tone = input[input.length - 1];
    var base = input;

    if (tone.compareTo('1') >= 0 && tone.compareTo('4') <= 0) {
      base = base.substring(0, base.length - 1);
    } else {
      tone = '_';
    }

    if (base.isEmpty) return null;

    List<String> result = [];
    result.add(input);
    for (int i = 1; i < 4; ++i) {
      if (i.toString() != tone) {
        result.add(base + i.toString());
      }
    }

    if (tone != '_') result.add(base);
    return result;
  }

  @override
  Future<void> init() async {
    await _initPinyin();
    await _initBopomofo();
  }

  Future<void> _initPinyin() async {
    _mapPinyin = {};
    var fields =
        await parseTsvFile('assets/character/orthography_pu_pinyin.tsv');
    for (var field in fields) {
      if (field.length != 3) continue;
      _mapPinyin[field[0]] = field[1] + field[2];
      _mapPinyin[field[1] + field[2]] = field[0];
    }
  }

  Future<void> _initBopomofo() async {
    _mapFromBopomofoPartial = {};
    _mapToBopomofoPartial = {};
    _mapFromBopomofoTone = {};
    _mapToBopomofoTone = {};
    _mapFromBopomofoWhole = {};
    _mapToBopomofoWhole = {};
    var fields =
        await parseTsvFile('assets/character/orthography_pu_bopomofo.tsv');
    for (var field in fields) {
      if (field.isEmpty) continue;
      if (field.length == 1) {
        debugPrint(field[0]);
      }
      if ('234_'.contains(field[1])) {
        // map tones
        _mapFromBopomofoTone[field[0]] = field[1];
        _mapToBopomofoTone[field[1]] = field[0];
      } else {
        _mapFromBopomofoPartial[field[0]] = field[1];
        _mapToBopomofoPartial[field[1]] = field[0];
        if (field.length > 2) {
          _mapFromBopomofoWhole[field[0]] = field[2];
          _mapToBopomofoWhole[field[2]] = field[0];
        }
      }
    }
  }
}
