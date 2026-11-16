import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';

import '../core/constants/app_constants.dart';
import '../core/localization/app_locales.dart';
import '../core/localization/app_translations.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/app_theme_controller.dart';
import 'bindings/initial_binding.dart';
import 'routes/app_pages.dart';

class MlbApp extends StatelessWidget {
  const MlbApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<AppThemeController>();

    return Obx(() {
      return GetMaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        useInheritedMediaQuery: true,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.themeMode,
        translations: AppTranslations(),
        locale: DevicePreview.locale(context) ?? AppLocales.bengali,
        fallbackLocale: AppLocales.fallbackLocale,
        initialBinding: InitialBinding(),
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
        builder: (context, child) {
          final previewChild = DevicePreview.appBuilder(context, child);
          return ResponsiveBreakpoints.builder(
            child: previewChild,
            breakpoints: [
              const Breakpoint(start: 0, end: 450, name: MOBILE),
              const Breakpoint(start: 451, end: 800, name: TABLET),
              const Breakpoint(start: 801, end: 1920, name: DESKTOP),
            ],
          );
        },
      );
    });
  }
}
