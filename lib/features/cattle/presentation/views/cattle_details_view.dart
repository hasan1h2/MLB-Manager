import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/currency_input_field.dart';
import '../controllers/cattle_controller.dart';

class CattleDetailsView extends GetView<CattleController> {
  const CattleDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.selectedCattle.value?.tagNumber ?? 'cattle_details'.tr)),
      ),
      body: Obx(() {
        final c = controller.selectedCattle.value;
        final p = controller.selectedProfit.value;

        if (c == null || p == null) {
          return const AppLoadingIndicator();
        }

        final isSold = c.status == 'sold';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.p16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCattleHeader(c, isSold),
              const SizedBox(height: AppSizes.p16),
              _buildProfitabilityCard(p, isSold),
              const SizedBox(height: AppSizes.p20),
              if (!isSold) ...[
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'খরচ যোগ করুন',
                        icon: AppIcons.add,
                        backgroundColor: AppColors.secondaryElectric,
                        height: 42,
                        onPressed: () => _showAddExpenseDialog(context, c.id),
                      ),
                    ),
                    const SizedBox(width: AppSizes.p12),
                    Expanded(
                      child: AppButton(
                        text: 'গরু বিক্রয়',
                        icon: Icons.sell_outlined,
                        backgroundColor: AppColors.incomeGreen,
                        height: 42,
                        onPressed: () => _showRecordSaleDialog(context, c.id),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p20),
              ],
              Text(
                'লালন-পালন ও চিকিৎসার খরচসমূহ',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSizes.p8),
              _buildExpensesList(),
              const SizedBox(height: AppSizes.p32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCattleHeader(dynamic c, bool isSold) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppSizes.r12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppImage(
            imagePath: c.photoPath,
            width: 72,
            height: 72,
            borderRadius: AppSizes.r8,
            fallbackIcon: AppIcons.cattle,
            fallbackColor: AppColors.secondaryElectric,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
          ),
          const SizedBox(width: AppSizes.p12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ট্যাগ: ${c.tagNumber}',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSold ? AppColors.incomeGreen : AppColors.secondaryElectric,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isSold ? 'বিক্রিত' : 'সক্রিয়',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                if (c.name?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text('নাম: ${c.name}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                ],
                const SizedBox(height: 4),
                Text(
                  'জাত: ${c.breed ?? 'N/A'} • লিঙ্গ: ${c.gender?.toUpperCase()} • বর্তমান ওজন: ${c.weightKg ?? 0} কেজি',
                  style: const TextStyle(color: AppColors.secondaryElectricLight, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitabilityCard(dynamic p, bool isSold) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ক্রয় মূল্য', style: TextStyle(color: AppColors.textSecondaryLight)),
                Text(CurrencyUtils.format(p.purchasePriceMinor), style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('মোট খাদ্য ও চিকিৎসা খরচ', style: TextStyle(color: AppColors.textSecondaryLight)),
                Text(CurrencyUtils.format(p.totalExpensesMinor), style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.expenseRed)),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('সর্বমোট বিনিয়োগ খরচ (Total Cost)', style: TextStyle(fontWeight: FontWeight.w700)),
                Text(CurrencyUtils.format(p.totalCostMinor), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              ],
            ),
            if (isSold) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('বিক্রয় মূল্য', style: TextStyle(color: AppColors.incomeGreenDark, fontWeight: FontWeight.w600)),
                  Text(CurrencyUtils.format(p.salePriceMinor), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.incomeGreen)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('নিট লাভ / ক্ষতি', style: TextStyle(fontWeight: FontWeight.w700)),
                  Text(
                    CurrencyUtils.format(p.netProfitMinor),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: p.netProfitMinor >= 0 ? AppColors.incomeGreen : AppColors.expenseRed,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesList() {
    return Obx(() {
      final list = controller.selectedCattleExpenses;
      if (list.isEmpty) {
        return const Card(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.p16),
            child: Center(child: Text('কোন অতিরিক্ত খরচ নথিভুক্ত নেই', style: TextStyle(color: AppColors.textSecondaryLight))),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (context, index) {
          final exp = list[index];
          return Card(
            child: ListTile(
              title: Text(exp.description?.isNotEmpty == true ? exp.description! : exp.expenseType.toUpperCase()),
              subtitle: Text(AppDateUtils.formatTimestamp(exp.expenseDate)),
              trailing: Text(
                CurrencyUtils.format(exp.amountMinor),
                style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.expenseRed),
              ),
            ),
          );
        },
      );
    });
  }

  void _showAddExpenseDialog(BuildContext context, String cattleId) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r12)),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('গরুর খরচ যোগ করুন', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSizes.p16),
              Obx(() => DropdownButtonFormField<String>(
                    value: controller.selectedExpenseType.value,
                    decoration: const InputDecoration(labelText: 'খরচের ধরণ'),
                    items: const [
                      DropdownMenuItem(value: 'feed', child: Text('খাদ্য খরচ (Feed)')),
                      DropdownMenuItem(value: 'medical', child: Text('ওষুধ ও চিকিৎসা (Medical)')),
                      DropdownMenuItem(value: 'vaccination', child: Text('টিকা (Vaccination)')),
                      DropdownMenuItem(value: 'vet', child: Text('ডাক্তার ফি (Vet Fee)')),
                      DropdownMenuItem(value: 'labor', child: Text('শ্রমিক খরচ (Labor)')),
                      DropdownMenuItem(value: 'transport', child: Text('পরিবহন (Transport)')),
                      DropdownMenuItem(value: 'other', child: Text('অন্যান্য (Other)')),
                    ],
                    onChanged: (v) => controller.selectedExpenseType.value = v!,
                  )),
              const SizedBox(height: AppSizes.p12),
              CurrencyInputField(label: 'টাকার পরিমাণ', controller: controller.expenseAmountController),
              const SizedBox(height: AppSizes.p12),
              AppTextField(label: 'বিবরণ', controller: controller.expenseDescController),
              const SizedBox(height: AppSizes.p24),
              AppButton(
                text: 'save'.tr,
                onPressed: () {
                  controller.addExpense(cattleId);
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecordSaleDialog(BuildContext context, String cattleId) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r12)),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('গরু বিক্রয় নিশ্চিতকরণ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSizes.p16),
              AppTextField(label: 'ক্রেতার নাম', controller: controller.buyerNameController),
              const SizedBox(height: AppSizes.p12),
              CurrencyInputField(label: 'বিক্রয় মূল্য', controller: controller.salePriceController),
              const SizedBox(height: AppSizes.p12),
              CurrencyInputField(label: 'নগদ গ্রহণ (পরিশোধিত)', controller: controller.salePaidController),
              const SizedBox(height: AppSizes.p24),
              AppButton(
                text: 'বিক্রয় সম্পন্ন করুন',
                backgroundColor: AppColors.incomeGreen,
                onPressed: () async {
                  final ok = await controller.recordSale(cattleId);
                  if (ok) {
                    Get.back();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
