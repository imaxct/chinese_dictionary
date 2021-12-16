import 'package:flutter/services.dart';

abstract class Orthography {
  /// load assets and init static properties.
  Future<void> init();

  /// 标准化查询读音, 读音 -> DB中存储的字段
  String? canonicalize(String input, int system);

  /// 展示读音
  String? display(String input, int system);

  /// 获取读音的所有音调
  List<String>? getAllTones(String input);
}

/// Parse tsv file to two-dim list.
Future<List<List<String>>> parseTsvFile(String asset) async {
  List<List<String>> result = [];
  var rawText = await rootBundle.loadString(asset);
  var lines = rawText.split('\n');
  for (var line in lines) {
    if (line.isEmpty || line.startsWith('#')) continue;
    result.add(line.split(RegExp(r'\s+')));
  }
  return result;
}
