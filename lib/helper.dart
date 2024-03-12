import 'package:gym_buddy_app/config.dart';

class Helper {
  static final Helper _helper = Helper._internal();
  factory Helper() {
    return _helper;
  }
  Helper._internal();

  static double getWeightInCorrectUnit(double weight) {
    if (Config.unit == 'imperial') {
      // only 2 decimal places
      return (weight * 2.20462);
    }

    return weight;
  }

  static double convertToKg(double weight) {
    if (Config.unit == 'imperial') {
      return weight / 2.20462;
    }

    return weight;
  }
}
