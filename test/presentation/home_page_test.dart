import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mlb_manager/app/routes/app_pages.dart';
import 'package:mlb_manager/core/database/app_database.dart';
import 'package:mlb_manager/core/security/pin_service.dart';
import 'package:mlb_manager/core/services/active_business_service.dart';
import 'package:mlb_manager/core/services/database_service.dart';
import 'package:mlb_manager/core/services/storage_service.dart';
import 'package:mlb_manager/core/theme/app_theme_controller.dart';
import 'package:mlb_manager/features/dashboard/presentation/views/dashboard_view.dart';
import 'package:mlb_manager/features/dashboard/presentation/views/main_nav_view.dart';
import 'package:mlb_manager/core/constants/app_icons.dart';
import 'package:mlb_manager/core/localization/app_translations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  late AppDatabase db;
  late DatabaseService dbService;

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService().init();
    Get.put<StorageService>(storageService, permanent: true);

    final pinService = PinService();
    Get.put<PinService>(pinService, permanent: true);

    db = AppDatabase.forTesting(NativeDatabase.memory());
    dbService = await DatabaseService().init(customDb: db);
    Get.put<DatabaseService>(dbService, permanent: true);

    final activeBizService = await ActiveBusinessService().init();
    Get.put<ActiveBusinessService>(activeBizService, permanent: true);

    Get.put<AppThemeController>(AppThemeController(), permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('MainNavView and DashboardView load properly on AppPages.initial',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('bn', 'BD'),
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
      ),
    );

    // Initial frame pump
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify MainNavView & DashboardView are displayed
    expect(find.byType(MainNavView), findsOneWidget);
    expect(find.byType(DashboardView), findsOneWidget);

    // Verify Bottom Navigation is present
    expect(find.byType(BottomNavigationBar), findsOneWidget);

    // Verify FloatingActionButton (+ transaction) is present on Home tab
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Clean up active widget tree
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });

  testWidgets('Bottom navigation switches tabs cleanly without error',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('bn', 'BD'),
        initialRoute: AppPages.initial,
        getPages: AppPages.routes,
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Tap on Transactions tab (index 1)
    await tester.tap(find.byIcon(AppIcons.transactions));
    await tester.pump(const Duration(milliseconds: 300));

    // Tap on Business tab (index 2)
    await tester.tap(find.byIcon(AppIcons.business));
    await tester.pump(const Duration(milliseconds: 300));

    // Tap on Reports tab (index 3)
    await tester.tap(find.byIcon(AppIcons.reports));
    await tester.pump(const Duration(milliseconds: 300));

    // Tap on More tab (index 4)
    await tester.tap(find.byIcon(AppIcons.more));
    await tester.pump(const Duration(milliseconds: 300));

    // Tap back to Home tab (index 0)
    await tester.tap(find.byIcon(AppIcons.home));
    await tester.pump(const Duration(milliseconds: 300));

    // Confirm DashboardView is visible again
    expect(find.byType(DashboardView), findsOneWidget);

    // Clean up active widget tree
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
