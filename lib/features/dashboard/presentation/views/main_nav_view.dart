import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../business/presentation/views/business_list_view.dart';
import '../../../reports/presentation/views/reports_view.dart';
import '../../../transactions/presentation/views/transaction_list_view.dart';
import '../controllers/main_nav_controller.dart';
import 'dashboard_view.dart';
import 'more_menu_view.dart';

class MainNavView extends GetView<MainNavController> {
  const MainNavView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const DashboardView(),
      const TransactionListView(),
      const BusinessListView(),
      const ReportsView(),
      const MoreMenuView(),
    ];

    return Obx(() {
      final index = controller.currentIndex.value;
      return Scaffold(
        body: IndexedStack(
          index: index,
          children: pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: index,
          onTap: controller.changeTab,
          selectedItemColor: AppColors.secondaryElectric,
          unselectedItemColor: AppColors.textMutedLight,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(AppIcons.home),
              label: 'nav_home'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(AppIcons.transactions),
              label: 'nav_transactions'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(AppIcons.business),
              label: 'nav_business'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(AppIcons.reports),
              label: 'nav_reports'.tr,
            ),
            BottomNavigationBarItem(
              icon: const Icon(AppIcons.more),
              label: 'nav_more'.tr,
            ),
          ],
        ),
        floatingActionButton: index == 0
            ? FloatingActionButton(
                onPressed: () => Get.toNamed(AppRoutes.addExpense),
                backgroundColor: AppColors.primaryNavy,
                child: const Icon(AppIcons.add, color: Colors.white),
              )
            : null,
      );
    });
  }
}
