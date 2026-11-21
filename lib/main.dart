import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'app/app.dart';
import 'core/security/pin_service.dart';
import 'core/services/active_business_service.dart';
import 'core/services/database_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Pre-initialize essential services
  final storageService = await StorageService().init();
  Get.put<StorageService>(storageService, permanent: true);

  final pinService = PinService();
  Get.put<PinService>(pinService, permanent: true);

  final dbService = await DatabaseService().init();
  Get.put<DatabaseService>(dbService, permanent: true);

  final activeBizService = await ActiveBusinessService().init();
  Get.put<ActiveBusinessService>(activeBizService, permanent: true);

  final themeController = AppThemeController();
  Get.put<AppThemeController>(themeController, permanent: true);

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MlbApp(),
    ),
  );
}
