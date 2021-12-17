class Character {
  /// 汉字Unicode
  String unicode;

  /// 汉语中古音
  List<String>? middleChinese;

  /// 普通话
  List<String>? mandarin;

  /// 粤语(广东话)
  List<String>? cantonese;

  /// 吴语
  List<String>? shanghainese;

  /// 闽南语
  List<String>? minnan;

  /// 朝鲜语
  List<String>? korean;

  /// 越南语
  List<String>? vietnamese;

  /// 日语吴音
  List<String>? japaneseGoOn;

  /// 日语汉音
  List<String>? japaneseKanOn;

  /// 日语唐音
  List<String>? japaneseToOn;

  /// 日语惯用音
  List<String>? japaneseKwan;

  /// 日语其他
  List<String>? japaneseOther;

  Character({
    required this.unicode,
    required this.middleChinese,
    required this.mandarin,
    required this.cantonese,
    required this.shanghainese,
    required this.minnan,
    required this.korean,
    required this.vietnamese,
    required this.japaneseGoOn,
    required this.japaneseKanOn,
    required this.japaneseToOn,
    required this.japaneseKwan,
    required this.japaneseOther,
  });
}
