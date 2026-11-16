import 'package:flutter/material.dart';

class AppLocales {
  static const Locale bengali = Locale('bn', 'BD');
  static const Locale english = Locale('en', 'US');

  static const List<Locale> supportedLocales = [
    bengali,
    english,
  ];

  static const Locale fallbackLocale = bengali;
}
