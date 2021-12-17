enum QueryMode {
  hanzi,
  middleChinese,
  mandarin,
  cantonese,
  shanghainese,
  minnan,
  kerean,
  vietnamese,
  japaneseGoOn,
  japaneseKanOn,
  japaneseAny,
}

/// query mode projection to db column
const queryModeToColumnName = [
  "unicode",
  "mc",
  "pu",
  "ct",
  "sh",
  "mn",
  "kr",
  "vn",
  "jp_go",
  "jp_kan",
  null
];
