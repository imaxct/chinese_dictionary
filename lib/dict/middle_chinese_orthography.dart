import 'package:chinese_dictionary/dict/orthography.dart';

class MiddleChineseOrthography extends Orthography {
  MiddleChineseOrthography._();
  static final MiddleChineseOrthography instance = MiddleChineseOrthography._();

  static late final Map<String, String> _mapInitials;
  static late final Map<String, String> _mapFinals;
  static late final Map<String, String> _mapSjep;
  static late final Map<String, String> _mapTongx;
  static late final Map<String, String> _mapHo;
  static late final Map<String, String> _mapBiengSjyix;
  @override
  String? canonicalize(String input, int system) {
    // eascape ' to avoid sqlite query exception
    return input.replaceAll('\'', '0');
  }

  @override
  String? display(String input, int system) {
    return input.replaceAll('0', '\'');
  }

  @override
  List<String>? getAllTones(String input) {
    if (input.isEmpty) return null;
    var base = input.substring(0, input.length - 1);
    if (base.isEmpty) return null;
    switch (input[input.length - 1]) {
      case 'x':
        return [input, base, base + 'h'];
      case 'h':
        return [input, base, base + 'x'];
      case 'd':
      case 'p':
      case 't':
      case 'k':
        return ['input'];
      default:
        return [input, input + 'x', input + 'h'];
    }
  }

  String? detail(String input) {
    var s = input;
    // tone
    int tone = 0;
    switch (s[s.length - 1]) {
      case 'x':
        tone = 1;
        s = s.substring(0, s.length - 1);
        break;
      case 'h':
        tone = 2;
        s = s.substring(0, s.length - 1);
        break;
      case 'd':
        tone = 2;
        break;
      case 'p':
        tone = 3;
        s = s.substring(0, s.length - 1) + 'm';
        break;
      case 't':
        tone = 3;
        s = s.substring(0, s.length - 1) + 'n';
        break;
      case 'k':
        tone = 3;
        s = s.substring(0, s.length - 1) + 'ng';
        break;
    }

    // initial and final
    String init = '';
    String fin = '';
    bool extraJ = false;
    int pos = s.indexOf('0');
    if (pos < 0) {
      for (int i = 3; i >= 0; --i) {
        if (i <= s.length && _mapInitials.containsKey(s.substring(0, i))) {
          init = s.substring(0, i);
          fin = s.substring(i);
          break;
        }
      }
      if (init.isEmpty) return null;

      if (fin.startsWith('j')) {
        if (fin.length < 2) return null;
        extraJ = true;
        if (fin[1] == 'i' || fin[1] == 'y') {
          fin = fin.substring(1);
        } else {
          fin = 'i' + fin.substring(1);
        }
      }

      if (init.endsWith('r')) {
        if (fin[0] != 'i' && fin[0] != 'y') {
          fin = 'r' + fin;
        }
      } else if (init.endsWith('j')) {
        if (fin[0] != 'i' && fin[0] != 'y') {
          fin = 'i' + fin;
        }
      }
      if (!_mapFinals.containsKey(fin)) return null;
    } else {
      init = s.substring(0, pos);
      fin = s.substring(pos + 1);
      if (init == 'i') init = '';
      if (!_mapInitials.containsKey(init)) return null;
      if (!_mapFinals.containsKey(fin)) return null;
    }

    // 重韵
    if (fin == 'ia') {
      if (["k", "kh", "g", "ng"].contains(init)) {
        fin = 'Ia';
      }
    } else if (fin == 'ieng' || fin == 'yeng') {
      if (!extraJ &&
          [
            "p",
            "ph",
            "b",
            "m",
            "k",
            "kh",
            "g",
            "ng",
            "h",
            "gh",
            "q",
            "",
            "cr",
            "chr",
            "zr",
            "sr",
            "zsr"
          ].contains(init)) {
        fin = fin == 'ieng' ? 'Ieng' : 'Yeng';
      }
    } else if (fin == 'in') {
      if (["cr", "chr", "zr", "sr", "zsr"].contains(init)) {
        fin = 'In';
      }
    } else if (fin == 'yn') {
      if (["p", "ph", "b", "m", "k", "kh", "g", "ng", "h", "gh", "q", ""]
              .contains(init) &&
          !extraJ) {
        fin = 'Yn';
      }
    }

    // 重纽
    var dryungNriux = '';
    if ('支脂祭眞仙宵侵鹽'.contains(_mapFinals[fin]!) &&
        ["p", "ph", "b", "m", "k", "kh", "g", "ng", "h", "gh", "q", "", "j"]
            .contains(init)) {
      dryungNriux = (extraJ || init == 'j') ? 'A' : 'B';
    }

    var mux = _mapInitials[init]!;
    var sjep = _mapSjep[fin]!;
    var yonh = _mapFinals[fin]![fin.endsWith('d') ? 0 : tone];
    var tongx = _mapTongx[fin]!;
    var ho = _mapHo[fin]!;
    var biengSjyix = _mapBiengSjyix[yonh]!;

    return mux + sjep + yonh + dryungNriux + tongx + ho + ' ' + biengSjyix;
  }

  @override
  Future<void> init() async {
    await _initInitials();
    await _initFinals();
    await _initBiengSjyix();
  }

  Future<void> _initInitials() async {
    _mapInitials = {};
    var fields =
        await parseTsvFile('assets/character/orthography_mc_initials.tsv');
    for (var field in fields) {
      if (field[0] == '_') field[0] = '';
      _mapInitials[field[0]] = field[1];
    }
  }

  Future<void> _initFinals() async {
    // 摄
    _mapSjep = {};
    // 等
    _mapTongx = {};
    // 呼
    _mapHo = {};
    _mapFinals = {};
    var fields =
        await parseTsvFile('assets/character/orthography_mc_finals.tsv');
    for (var field in fields) {
      _mapSjep[field[0]] = field[1];
      _mapTongx[field[0]] = field[2];
      _mapHo[field[0]] = field[3];
      _mapFinals[field[0]] = field[4];
    }
  }

  /// 广韵 -> 平水韵
  Future<void> _initBiengSjyix() async {
    _mapBiengSjyix = {};
    var fields =
        await parseTsvFile('assets/character/orthography_mc_bieng_sjyix.tsv');
    for (var field in fields) {
      for (int i = 0; i < field[1].length; ++i) {
        _mapBiengSjyix[field[1][i]] = field[0];
      }
    }
  }
}
