class Config {
// singleton
  static final Config _config = Config._internal();
  factory Config() {
    return _config;
  }
  Config._internal();

  static String unit = 'metric';

  static String getUnitAbbreviation() {
    if (unit == 'imperial') {
      return 'lb';
    }

    return 'kg';
  }
}
