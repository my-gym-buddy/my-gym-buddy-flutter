import 'package:shared_preferences/shared_preferences.dart';

class Config {
// singleton
  static final Config _config = Config._internal();
  factory Config() {
    return _config;
  }
  Config._internal();

  static String unit = 'metric';

  static void loadConfig() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    unit = prefs.getString('unit') ?? 'metric';
  }

  static void setUnit(String newUnit) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('unit', newUnit);
    unit = newUnit;
  }

  static String getUnitAbbreviation() {
    if (unit == 'imperial') {
      return 'lb';
    }

    return 'kg';
  }
}
