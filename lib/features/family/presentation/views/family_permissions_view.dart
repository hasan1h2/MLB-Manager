import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';

class FamilyPermissionsView extends StatelessWidget {
  const FamilyPermissionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final permissions = [
      {
        'feature': 'View Dashboard',
        'owner': 'Yes',
        'admin': 'Yes',
        'member': 'Limited',
        'viewer': 'Yes'
      },
      {
        'feature': 'Add Transaction',
        'owner': 'Yes',
        'admin': 'Yes',
        'member': 'Configurable',
        'viewer': 'No'
      },
      {
        'feature': 'Edit Transaction',
        'owner': 'Yes',
        'admin': 'Yes',
        'member': 'Own records',
        'viewer': 'No'
      },
      {
        'feature': 'Delete Transaction',
        'owner': 'Yes',
        'admin': 'Restricted',
        'member': 'No',
        'viewer': 'No'
      },
      {
        'feature': 'Manage Family',
        'owner': 'Yes',
        'admin': 'Yes',
        'member': 'No',
        'viewer': 'No'
      },
      {
        'feature': 'Manage Business',
        'owner': 'Yes',
        'admin': 'Configurable',
        'member': 'Configurable',
        'viewer': 'No'
      },
      {
        'feature': 'View Reports',
        'owner': 'Yes',
        'admin': 'Yes',
        'member': 'Limited',
        'viewer': 'Yes'
      },
      {
        'feature': 'Manage Backup',
        'owner': 'Yes',
        'admin': 'No',
        'member': 'No',
        'viewer': 'No'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('permissions'.tr),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ডিভাইস-লেভেল পারিবারিক অনুমতি ম্যাট্রিক্স',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: AppSizes.p4),
                const Text(
                  'অ্যাপ্লিকেশনের বিভিন্ন ফিচারে সদস্য ও অ্যাডমিনদের অধিকার নির্দেশিকা',
                  style: TextStyle(
                      fontSize: 12, color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: AppSizes.p16),
                Table(
                  border: TableBorder.all(color: AppColors.borderLight),
                  columnWidths: const {
                    0: FlexColumnWidth(2.5),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1.2),
                    3: FlexColumnWidth(1.5),
                    4: FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(
                      decoration:
                          const BoxDecoration(color: AppColors.dividerLight),
                      children: const [
                        Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('ফিচার',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12))),
                        Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('Owner',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12))),
                        Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('Admin',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12))),
                        Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('Member',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12))),
                        Padding(
                            padding: EdgeInsets.all(8),
                            child: Text('Viewer',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12))),
                      ],
                    ),
                    for (var p in permissions)
                      TableRow(
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(p['feature']!,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500))),
                          Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(p['owner']!,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.incomeGreen))),
                          Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(p['admin']!,
                                  style: const TextStyle(fontSize: 11))),
                          Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(p['member']!,
                                  style: const TextStyle(fontSize: 11))),
                          Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(p['viewer']!,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textMutedLight))),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
