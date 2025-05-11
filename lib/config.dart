import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Config {
// singleton
  static final Config _config = Config._internal();
  factory Config() {
    return _config;
  }
  Config._internal();
  static String unit = 'metric';
  static bool hasSeenGuide = false;

  static Future<void> loadConfig() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    unit = prefs.getString('unit') ?? 'metric';
    hasSeenGuide = prefs.getBool('hasSeenGuide') ?? false;
  }

  static void setUnit(String newUnit) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('unit', newUnit);
    unit = newUnit;
  }

  static void setHasSeenGuide(bool seen) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('hasSeenGuide', seen);
    hasSeenGuide = seen;
  }

  static String getUnitAbbreviation() {
    if (unit == 'imperial') {
      return 'lb';
    }

    return 'kg';
  }

  // Add this method for testing purposes
  @visibleForTesting
  static void setUnitForTesting(String newUnit) {
    unit = newUnit;
  }
}
