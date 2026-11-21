import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/currency_input_field.dart';
import '../controllers/business_purchase_controller.dart';

class BusinessPurchaseView extends GetView<BusinessPurchaseController> {
  const BusinessPurchaseView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('পণ্য ক্রয় এন্ট্রি (Purchase)',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          _buildDateTimeBanner(context),
          _buildSupplierSelector(context, cardBg, borderColor, isDark),
          _buildInvoiceRow(),
          _buildAddItemButton(context),
          Expanded(
            child: _buildItemsList(context, cardBg, borderColor, isDark),
          ),
          _buildBottomSummary(context, cardBg, borderColor, isDark),
        ],
      ),
    );
  }

  Widget _buildDateTimeBanner(BuildContext context) {
    return Obx(() {
      final d = controller.transactionDate.value;
      final t = controller.transactionTime.value;
      final dt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      final formatted = DateFormat('dd MMM yyyy, hh:mm a').format(dt);
      final isCustom = controller.isCustomDateTime.value;

      return Container(
        margin: const EdgeInsets.symmetric(
            horizontal: AppSizes.p16, vertical: AppSizes.p8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isCustom
              ? AppColors.warningAmber.withValues(alpha: 0.15)
              : AppColors.secondaryElectric.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.r8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  isCustom
                      ? Icons.edit_calendar_rounded
                      : Icons.access_time_rounded,
                  size: 16,
                  color: isCustom
                      ? AppColors.warningAmberDark
                      : AppColors.secondaryElectric,
                ),
                const SizedBox(width: 8),
                Text(
                  formatted,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 12),
                ),
                if (!isCustom)
                  const Text(
                    ' (লাইভ সময়)',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.incomeGreen,
                        fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            InkWell(
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: d,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (pickedDate != null && context.mounted) {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: t,
                  );
                  if (pickedTime != null) {
                    controller.setCustomDateTime(pickedDate, pickedTime);
                  }
                }
              },
              child: Text(
                isCustom ? 'সময় পরিবর্তন' : 'কাস্টম সময়',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryElectric,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSupplierSelector(
      BuildContext context, Color cardBg, Color borderColor, bool isDark) {
    return Obx(() {
      final supp = controller.selectedSupplier.value;
      return Container(
        margin:
            const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: 4),
        padding: const EdgeInsets.all(AppSizes.p8),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppSizes.r8),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            const Icon(AppIcons.suppliers,
                color: AppColors.warningAmber, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supp == null
                        ? 'সাপ্লায়ার / মহাজন নির্বাচন করুন'
                        : supp.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  if (supp != null && supp.phone != null)
                    Text(
                      supp.phone!,
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight),
                    ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _showSupplierPicker(context),
              child: Text(supp == null ? 'নির্বাচন' : 'পরিবর্তন'),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildInvoiceRow() {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: 4),
      child: AppTextField(
        label: 'চালান / মেমো নম্বর (Invoice / Memo No)',
        controller: controller.invoiceController,
        prefixIcon: Icons.receipt_outlined,
      ),
    );
  }

  Widget _buildAddItemButton(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: 6),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryNavy,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.r8)),
          ),
          icon: const Icon(Icons.add_circle_outline, size: 18),
          label: const Text('ক্রয়ের পণ্য যোগ করুন',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          onPressed: () => _showAddItemDialog(context),
        ),
      ),
    );
  }

  Widget _buildItemsList(
      BuildContext context, Color cardBg, Color borderColor, bool isDark) {
    return Obx(() {
      if (controller.items.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_cart_outlined,
                  size: 56,
                  color: isDark
                      ? AppColors.textSecondaryDark.withValues(alpha: 0.3)
                      : AppColors.textSecondaryLight.withValues(alpha: 0.4)),
              const SizedBox(height: 8),
              const Text('কোন পণ্য যোগ করা হয়নি',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        );
      }

      return ListView.separated(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: 8),
        itemCount: controller.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = controller.items[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p12),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.productName,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        const SizedBox(height: 2),
                        Obx(() => Text(
                              'ক্রয়দর: ${CurrencyUtils.format(item.unitCostMinor.value)} / ${item.unit}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight),
                            )),
                      ],
                    ),
                  ),
                  Text(
                    '${item.quantity.value} ${item.unit}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Obx(() => Text(
                            CurrencyUtils.format(item.totalMinor),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14),
                          )),
                      InkWell(
                        onTap: () => controller.removeItem(item),
                        child: const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child:
                              Icon(Icons.close, size: 16, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildBottomSummary(
      BuildContext context, Color cardBg, Color borderColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('মোট বিল:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      Text(
                        CurrencyUtils.format(controller.totalMinor),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.secondaryElectric),
                      ),
                    ],
                  ),
                  if (controller.dueMinor > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('মহাজনের বকেয়া থাকবে:',
                            style: TextStyle(
                                fontSize: 13,
                                color: AppColors.warningAmberDark,
                                fontWeight: FontWeight.w700)),
                        Text(
                          CurrencyUtils.format(controller.dueMinor),
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.warningAmberDark),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            }),
            const SizedBox(height: AppSizes.p12),
            AppButton(
              text: 'ক্রয় সম্পন্ন ও সংরক্ষণ করুন',
              icon: AppIcons.check,
              onPressed: () async {
                final ok = await controller.savePurchase();
                if (ok) Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSupplierPicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSizes.p16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppSizes.r16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('সাপ্লায়ার নির্বাচন করুন',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSizes.p8),
            Expanded(
              child: ListView.builder(
                itemCount: controller.availableSuppliers.length,
                itemBuilder: (context, index) {
                  final s = controller.availableSuppliers[index];
                  return ListTile(
                    leading: const CircleAvatar(child: Icon(AppIcons.suppliers)),
                    title: Text(s.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(s.phone ?? ''),
                    onTap: () {
                      controller.selectedSupplier.value = s;
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    Get.defaultDialog(
      title: 'ক্রয়ের পণ্য যোগ',
      content: Obx(() {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: controller.selectedProductToAdd.value?.id,
                hint: const Text('পণ্য বাছাই করুন'),
                items: controller.availableProducts.map((p) {
                  return DropdownMenuItem(
                    value: p.id,
                    child: Text(p.name, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  final prod = controller.availableProducts
                      .firstWhereOrNull((p) => p.id == val);
                  if (prod != null) {
                    controller.selectedProductToAdd.value = prod;
                    controller.unitCostController.text =
                        CurrencyUtils.minorToTaka(prod.purchasePriceMinor)
                            .toString();
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'পরিমাণ',
                      controller: controller.qtyController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CurrencyInputField(
                      label: 'একক ক্রয় মূল্য',
                      controller: controller.unitCostController,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
      textConfirm: 'যোগ করুন',
      textCancel: 'বাতিল',
      confirmTextColor: Colors.white,
      onConfirm: () => controller.addItem(),
    );
  }
}
