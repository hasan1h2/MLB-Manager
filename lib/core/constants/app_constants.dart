class AppConstants {
  static const String appName = 'My Life & Business Manager';
  static const String appShortName = 'MLB Manager';
  static const String appVersion = '1.0.0';

  // Assets
  static const String appIconAsset = 'assets/icons/app_icon.png';
  static const String appLogoAsset = 'assets/images/app_logo.png';

  // Currency & Monetary
  static const String defaultCurrencyCode = 'BDT';
  static const String defaultCurrencySymbol = '৳';
  static const int minorUnitMultiplier = 100; // 1 Taka = 100 Poisha

  // Database
  static const String databaseName = 'mlb_manager.sqlite';
  static const int databaseVersion = 4;

  // Pagination
  static const int defaultPageSize = 25;

  // Security & Storage Keys
  static const String keyAppPin = 'mlb_app_pin_hash';
  static const String keyBiometricEnabled = 'mlb_biometric_enabled';
  static const String keyAutoLockDuration = 'mlb_auto_lock_duration';
  static const String keyLanguage = 'mlb_app_language';
  static const String keyThemeMode = 'mlb_app_theme_mode';
  static const String keyDefaultAccount = 'mlb_default_account_id';
  static const String keyDefaultBusiness = 'mlb_default_business_id';
  static const String keyActiveMember = 'mlb_active_member_id';
  static const String keyIsFirstRun = 'mlb_is_first_run';

  // Units
  static const List<String> supportedUnits = [
    'kg',
    'g',
    'liter',
    'ml',
    'piece',
    'packet',
    'box',
    'carton',
    'dozen',
    'bottle',
    'pair',
    'bag',
    'meter',
    'yard',
    'sqft',
  ];
}
