/// 普通话
enum MandarinDisplayOption {
  /// 拼音 db
  pinyin,

  /// 注音
  bopomofo,
}

/// 粤语
enum CantoneseDisplayOption {
  /// 粤拼(香港语言学学会式) db
  jyutping,

  /// 教院式
  cantonesePinyin,

  /// 耶鲁式
  yale,

  /// 刘锡祥式
  sidneyLau,
}

/// 吴语
enum ShanghaineseDisplayOption {
  normal,
}

/// 闽南语
enum MinnanDisplayOption {
  normal,
}

/// 朝鲜语展示方式
enum KoreanDisplayOption {
  /// 谚文
  hangul,

  /// 文观部2000年式罗马文 db
  romanization,
}

/// 越南语
enum VietnameseDisplayOption {
  oldStyle,
  newStyle,
}

/// 日语
enum JapaneseDisplayOption {
  /// 平假名
  hiragana,

  /// 片假名
  katakana,

  /// 日本式罗马字 db
  nippon,

  /// 黑本式罗马字
  hepburn,
}
