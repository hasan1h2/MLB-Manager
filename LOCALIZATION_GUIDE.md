# MLB Manager — Localization Guide

## Architecture
Localization is driven by GetX's `Translations` engine.
- Default Language: **Bengali (`bn_BD`)**
- Secondary Language: **English (`en_US`)**
- Location:
  - `lib/core/localization/app_translations.dart`
  - `lib/core/localization/bn_bd.dart`
  - `lib/core/localization/en_us.dart`
  - `lib/core/localization/app_locales.dart`

## Key Rules
1. **Zero Hardcoded Strings**: No UI widget, form, snackbar, dialog, or button may contain raw string literals. All text must use translation keys (e.g., `'app_title'.tr` or `AppStrings.appTitle.tr`).
2. **Key Synchronization**: Every single key added to `bn_bd.dart` must also exist in `en_us.dart`.
3. **Bengali Unicode Compatibility**: Ensure valid UTF-8 encoding without corrupt character sequences. Numbers can be formatted with Bengali numerals when configured.
4. **Dynamic Switching**: Users can toggle between Bengali and English anytime from Settings without restarting the application (`Get.updateLocale(newLocale)`).
