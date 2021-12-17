import 'package:flutter/services.dart';

class Hanzi {
  Hanzi._();
  static final Hanzi instance = Hanzi._();

  static const int _firstHanzi = 0x4E00;
  static const int _lastHanzi = 0x9FA5;
  static late final Map<int, List<String>> _mapVariants;

  bool isHanzi(String char) {
    return char.isNotEmpty &&
        char.length == 1 &&
        char.codeUnitAt(0) >= _firstHanzi &&
        char.codeUnitAt(0) <= _lastHanzi;
  }

  List<String>? getVariants(String char) {
    if (char.isEmpty) return null;
    if (!_mapVariants.containsKey(char.codeUnitAt(0))) return [char];
    return _mapVariants[char.codeUnitAt(0)];
  }

  Future<void> init() async {
    _mapVariants = {};
    var rawText = await rootBundle
        .loadString('assets/character/orthography_hz_variants.txt');
    var lines = rawText.split('\n');
    for (var line in lines) {
      if (line.isEmpty) continue;
      _mapVariants[line.codeUnitAt(0)] = line.split('');
    }
  }
}
