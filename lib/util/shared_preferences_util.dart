import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtil {
  /// 仅查询广韵
  static const queryKuangxYonhOnly = 'query_kuangx_yonh_only';

  /// 简繁、异体转换
  static const queryAllowVariants = 'query_allow_variants';

  /// 音调不敏感
  static const queryToneInsensitive = 'query_tone_insensitive';

  /// for both query and display
  static const cantoneseSystem = 'cantonese_system';

  static late final SharedPreferences _instance;
  static Future init() async {
    _instance = await SharedPreferences.getInstance();
  }

  static SharedPreferences get instance {
    return _instance;
  }
}
