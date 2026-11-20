import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/app_empty_state.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../controllers/loan_controller.dart';

class LoanListView extends GetView<LoanController> {
  const LoanListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('loan_management'.tr),
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const AppLoadingIndicator();
              }

              if (controller.loans.isEmpty) {
                return AppEmptyState(
                  message: 'কোন ঋণ রেকর্ড নেই',
                  actionText: 'add_loan'.tr,
                  onAction: () => Get.toNamed(AppRoutes.addLoan),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppSizes.p16),
                itemCount: controller.loans.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSizes.p8),
                itemBuilder: (context, index) {
                  final item = controller.loans[index];
                  final isReceivable = item.loan.loanType == 'receivable';

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: (isReceivable
                                ? AppColors.infoBlue
                                : AppColors.warningAmber)
                            .withValues(alpha: 0.15),
                        child: Icon(
                          isReceivable
                              ? Icons.call_received_rounded
                              : Icons.call_made_rounded,
                          color: isReceivable
                              ? AppColors.infoBlue
                              : AppColors.warningAmberDark,
                        ),
                      ),
                      title: Text(item.loan.partyName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      subtitle: Text(
                        'মেয়াদ: ${AppDateUtils.formatTimestamp(item.loan.dueDate)}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondaryLight),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyUtils.format(item.remainingPrincipalMinor),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: isReceivable
                                  ? AppColors.infoBlue
                                  : AppColors.warningAmberDark,
                            ),
                          ),
                          Text(
                            item.loan.status == 'settled'
                                ? 'পরিশোধিত'
                                : 'বকেয়া আসল',
                            style: TextStyle(
                              fontSize: 10,
                              color: item.loan.status == 'settled'
                                  ? AppColors.incomeGreen
                                  : AppColors.textSecondaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        controller.loadLoanPayments(item.loan.id);
                        Get.toNamed(AppRoutes.loanDetails, arguments: item);
                      },
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(AppRoutes.addLoan),
        backgroundColor: AppColors.primaryNavy,
        child: const Icon(AppIcons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Obx(() {
      final current = controller.selectedTypeFilter.value;
      return Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.p16, vertical: AppSizes.p8),
        child: Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: Center(child: Text('loan_receivable'.tr)),
                selected: current == 'receivable',
                selectedColor: AppColors.primaryNavy,
                labelStyle: TextStyle(
                    color: current == 'receivable'
                        ? Colors.white
                        : AppColors.textPrimaryLight),
                onSelected: (_) => controller.setTypeFilter('receivable'),
              ),
            ),
            const SizedBox(width: AppSizes.p8),
            Expanded(
              child: ChoiceChip(
                label: Center(child: Text('loan_payable'.tr)),
                selected: current == 'payable',
                selectedColor: AppColors.primaryNavy,
                labelStyle: TextStyle(
                    color: current == 'payable'
                        ? Colors.white
                        : AppColors.textPrimaryLight),
                onSelected: (_) => controller.setTypeFilter('payable'),
              ),
            ),
          ],
        ),
      );
    });
  }
}
