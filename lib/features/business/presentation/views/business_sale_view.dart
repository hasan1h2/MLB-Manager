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
import '../controllers/business_sale_controller.dart';

class BusinessSaleView extends GetView<BusinessSaleController> {
  const BusinessSaleView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    // Check if initial argument is wholesale
    final arg = Get.arguments;
    if (arg == 'wholesale') {
      controller.setSaleType('wholesale');
    }

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              controller.saleType.value == 'wholesale'
                  ? 'পাইকারি বিক্রয় (Wholesale)'
                  : 'খুচরা বিক্রয় (Retail POS)',
              style: const TextStyle(fontWeight: FontWeight.w700),
            )),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'কার্ট পরিষ্কার করুন',
            onPressed: () {
              if (controller.cartItems.isNotEmpty) {
                Get.defaultDialog(
                  title: 'কার্ট পরিষ্কার',
                  middleText: 'আপনি কি কার্টের সব পণ্য মুছে ফেলতে চান?',
                  textConfirm: 'হ্যাঁ, মুছুন',
                  textCancel: 'বাতিল',
                  confirmTextColor: Colors.white,
                  onConfirm: () {
                    controller.clearCart();
                    Get.back();
                  },
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSaleTypeSwitcher(),
          _buildDateTimeBanner(context, isDark),
          _buildCustomerSelector(context, cardBg, borderColor, isDark),
          _buildActionButtons(context),
          Expanded(
            child: _buildCartList(context, cardBg, borderColor, isDark),
          ),
          _buildBottomCheckoutPanel(context, cardBg, borderColor, isDark),
        ],
      ),
    );
  }

  Widget _buildSaleTypeSwitcher() {
    return Obx(() {
      final isWholesale = controller.saleType.value == 'wholesale';
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p8),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.primaryNavy.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppSizes.r12),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.setSaleType('retail'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: !isWholesale ? AppColors.primaryNavy : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'খুচরা বিক্রয় (Retail)',
                    style: TextStyle(
                      color: !isWholesale ? Colors.white : null,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.setSaleType('wholesale'),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isWholesale ? AppColors.warningAmberDark : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppSizes.r8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'পাইকারি বিক্রয় (Wholesale)',
                    style: TextStyle(
                      color: isWholesale ? Colors.white : null,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildDateTimeBanner(BuildContext context, bool isDark) {
    return Obx(() {
      final d = controller.transactionDate.value;
      final t = controller.transactionTime.value;
      final dt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      final formatted = DateFormat('dd MMM yyyy, hh:mm a').format(dt);
      final isCustom = controller.isCustomDateTime.value;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: 4),
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
                  isCustom ? Icons.edit_calendar_rounded : Icons.access_time_rounded,
                  size: 16,
                  color: isCustom ? AppColors.warningAmberDark : AppColors.secondaryElectric,
                ),
                const SizedBox(width: 8),
                Text(
                  formatted,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
                if (!isCustom)
                  const Text(
                    ' (লাইভ সময়)',
                    style: TextStyle(fontSize: 10, color: AppColors.incomeGreen, fontWeight: FontWeight.bold),
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

  Widget _buildCustomerSelector(
      BuildContext context, Color cardBg, Color borderColor, bool isDark) {
    return Obx(() {
      final cust = controller.selectedCustomer.value;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: 4),
        padding: const EdgeInsets.all(AppSizes.p8),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppSizes.r8),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_outline_rounded,
                color: AppColors.secondaryElectric, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cust == null ? 'সাধারণ খরিদ্দার (Walk-in Customer)' : cust.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  if (cust != null && cust.phone != null)
                    Text(
                      cust.phone!,
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
              onPressed: () => _showCustomerPicker(context),
              child: Text(cust == null ? 'নির্বাচন করুন' : 'পরিবর্তন'),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r8)),
              ),
              icon: const Icon(Icons.add_shopping_cart, size: 18),
              label: const Text('পণ্য যোগ করুন', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              onPressed: () => _showProductPicker(context),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r8)),
              ),
              icon: const Icon(Icons.flash_on_rounded, size: 18, color: AppColors.warningAmber),
              label: const Text('কুইক সেল', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              onPressed: () => _showQuickSaleDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartList(
      BuildContext context, Color cardBg, Color borderColor, bool isDark) {
    return Obx(() {
      if (controller.cartItems.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_bag_outlined,
                  size: 56,
                  color: isDark
                      ? AppColors.textSecondaryDark.withValues(alpha: 0.3)
                      : AppColors.textSecondaryLight.withValues(alpha: 0.4)),
              const SizedBox(height: 8),
              const Text('কার্টে কোন পণ্য নেই',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              const Text('উপরে "পণ্য যোগ করুন" বা "কুইক সেল" চাপুন',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: 8),
        itemCount: controller.cartItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = controller.cartItems[index];
          return Card(
            elevation: 0.5,
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p12),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Obx(() => Text(
                              'দর: ${CurrencyUtils.format(item.unitPriceMinor.value)} / ${item.unit}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight),
                            )),
                      ],
                    ),
                  ),
                  // Quantity controls
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 22),
                        color: AppColors.expenseRed,
                        onPressed: () {
                          controller.updateItemQuantity(item, item.quantity.value - 1);
                        },
                      ),
                      Obx(() => Text(
                            '${item.quantity.value % 1 == 0 ? item.quantity.value.toInt() : item.quantity.value}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          )),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, size: 22),
                        color: AppColors.incomeGreen,
                        onPressed: () {
                          controller.updateItemQuantity(item, item.quantity.value + 1);
                        },
                      ),
                    ],
                  ),
                  // Total & Delete
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Obx(() => Text(
                              CurrencyUtils.format(item.totalMinor),
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            )),
                        InkWell(
                          onTap: () => controller.removeItem(item),
                          child: const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Icon(Icons.close, size: 16, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildBottomCheckoutPanel(
      BuildContext context, Color cardBg, Color borderColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.p16),
      decoration: BoxDecoration(
        color: cardBg,
        border: Border(top: BorderSide(color: borderColor)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
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
                      const Text('সাবটোটাল:', style: TextStyle(fontSize: 13)),
                      Text(CurrencyUtils.format(controller.subtotalMinor),
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('মোট প্রদেয় বিল:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      Text(
                        CurrencyUtils.format(controller.totalMinor),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.incomeGreen,
                        ),
                      ),
                    ],
                  ),
                  if (controller.dueMinor > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('বাকি থাকবে:',
                            style: TextStyle(fontSize: 13, color: AppColors.expenseRed, fontWeight: FontWeight.w700)),
                        Text(
                          CurrencyUtils.format(controller.dueMinor),
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.expenseRed),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            }),
            const SizedBox(height: AppSizes.p12),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: 'সংরক্ষণ ও প্রিন্ট',
                    icon: Icons.print_outlined,
                    onPressed: () async {
                      final ok = await controller.processSale(printReceipt: true);
                      if (ok) Get.back();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r8)),
                    ),
                    icon: const Icon(AppIcons.check),
                    label: const Text('শুধু সংরক্ষণ', style: TextStyle(fontWeight: FontWeight.w700)),
                    onPressed: () async {
                      final ok = await controller.processSale(printReceipt: false);
                      if (ok) Get.back();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomerPicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSizes.p16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.r16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('গ্রাহক নির্বাচন করুন',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSizes.p8),
            ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: const Text('সাধারণ খরিদ্দার (Walk-in Customer)'),
              subtitle: const Text('নগদ লেনদেন'),
              onTap: () {
                controller.selectedCustomer.value = null;
                Get.back();
              },
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: controller.availableCustomers.length,
                itemBuilder: (context, index) {
                  final c = controller.availableCustomers[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.secondaryElectric.withValues(alpha: 0.15),
                      child: Text(c.name.isNotEmpty ? c.name[0] : 'C'),
                    ),
                    title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(c.phone ?? c.customerType.toUpperCase()),
                    trailing: Text(
                      c.customerType == 'wholesale' ? 'পাইকারি' : 'খুচরা',
                      style: const TextStyle(fontSize: 11, color: AppColors.infoBlue),
                    ),
                    onTap: () {
                      controller.selectedCustomer.value = c;
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

  void _showProductPicker(BuildContext context) {
    final search = TextEditingController();
    final filtered = controller.availableProducts.toList().obs;

    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(AppSizes.p16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.r16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('পণ্য নির্বাচন করুন',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            TextField(
              controller: search,
              decoration: const InputDecoration(
                hintText: 'পণ্যের নাম বা বারকোড দিয়ে খুঁজুন...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (val) {
                final q = val.trim().toLowerCase();
                if (q.isEmpty) {
                  filtered.value = controller.availableProducts.toList();
                } else {
                  filtered.value = controller.availableProducts.where((p) {
                    return p.name.toLowerCase().contains(q) ||
                        (p.barcode?.toLowerCase().contains(q) ?? false) ||
                        (p.nameEn?.toLowerCase().contains(q) ?? false);
                  }).toList();
                }
              },
            ),
            const SizedBox(height: AppSizes.p12),
            Expanded(
              child: Obx(() {
                if (filtered.isEmpty) {
                  return const Center(child: Text('কোন পণ্য পাওয়া যায়নি'));
                }
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = filtered[index];
                    return ListTile(
                      title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        'খুচরা: ${CurrencyUtils.format(p.sellingPriceMinor)} • পাইকারি: ${CurrencyUtils.format(p.wholesalePriceMinor)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryElectric,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('যোগ করুন'),
                        onPressed: () {
                          controller.addProductToCart(p);
                          Get.back();
                        },
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showQuickSaleDialog(BuildContext context) {
    Get.defaultDialog(
      title: 'কুইক সেল (অ-তালিকাভুক্ত আইটেম)',
      content: SingleChildScrollView(
        child: Column(
          children: [
            AppTextField(
              label: 'পণ্যের নাম / বিবরণ',
              hint: 'যেমন: খুচরা খোলা চিনি ৫০০ গ্রাম',
              controller: controller.quickItemNameController,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    label: 'পরিমাণ',
                    controller: controller.quickItemQtyController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CurrencyInputField(
                    label: 'বিক্রয় মূল্য',
                    controller: controller.quickItemPriceController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            CurrencyInputField(
              label: 'ক্রয় মূল্য / খরচ (COGS হিসেবের জন্য)',
              controller: controller.quickItemCostController,
            ),
          ],
        ),
      ),
      textConfirm: 'কার্টে যোগ করুন',
      textCancel: 'বাতিল',
      confirmTextColor: Colors.white,
      onConfirm: () => controller.addQuickSaleItem(),
    );
  }
}
