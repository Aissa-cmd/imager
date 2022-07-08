import 'package:shared_preferences/shared_preferences.dart';

class DataSharedPreferences {
  static const isFirstTime = "isFirstTime";
  static const showPersonalizedAds = "showPersonalizedAds";
  static SharedPreferences? _preferences;

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static Future setIsFirstTime(bool value) async {
    await _preferences?.setBool(isFirstTime, value);
  }

  static bool? getIsFirstTime() {
    return _preferences?.getBool(isFirstTime);
  }

  static Future setShowPersonalizedAds(bool value) async {
    await _preferences?.setBool(showPersonalizedAds, value);
  }

  static bool getShowPersonalizedAds() {
    return _preferences?.getBool(showPersonalizedAds) ?? false;
  }
}
