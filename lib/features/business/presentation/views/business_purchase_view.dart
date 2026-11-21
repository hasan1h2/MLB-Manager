import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_snackbar.dart';
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
                        if (item.categoryName != null)
                          Text(
                            item.categoryName!,
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.secondaryElectric,
                                fontWeight: FontWeight.w600),
                          ),
                        const SizedBox(height: 2),
                        Obx(() => Text(
                              'ক্রয়দর: ${CurrencyUtils.format(item.unitCostMinor.value)} / ${item.unit}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight),
                            )),
                        if (item.conversionFactor > 1)
                          Text(
                            'প্যাকেজিং: ১ ${item.unit} = ${item.packageQuantity ?? item.conversionFactor} ${item.baseUnit} (স্টক: +${item.baseQuantity} ${item.baseUnit})',
                            style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.incomeGreen,
                                fontWeight: FontWeight.w600),
                          ),
                        if (item.retailPriceMinor > 0)
                          Text(
                            'খুচরা বিক্রয়: ${CurrencyUtils.format(item.retailPriceMinor)}${item.wholesalePriceMinor > 0 ? ' | পাইকারি: ${CurrencyUtils.format(item.wholesalePriceMinor)}' : ''}',
                            style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondaryLight),
                          ),
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
    final isNewProductMode = false.obs;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r16)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
            top: AppSizes.p16,
            left: AppSizes.p16,
            right: AppSizes.p16,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(bottomSheetContext).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              child: Obx(() {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ক্রয়ের পণ্য যোগ (Purchase Item)',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(bottomSheetContext),
                        ),
                      ],
                    ),
                    const Divider(),

                    // Step 1: Category Selector
                    const Text('১. ক্যাটাগরি নির্বাচন করুন (Category)*',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: controller.selectedCategory.value?.id,
                      decoration: InputDecoration(
                        hintText: 'ক্যাটাগরি বাছাই করুন',
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      isExpanded: true,
                      items: controller.availableCategories.map((c) {
                        return DropdownMenuItem(
                          value: c.id,
                          child: Text(c.nameBn,
                              overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        final cat = controller.availableCategories
                            .firstWhereOrNull((c) => c.id == val);
                        controller.onSelectCategory(cat);
                      },
                    ),

                    // Optional Subcategory Selector
                    if (controller.availableSubcategories.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Text('সাবক্যাটাগরি (ঐচ্ছিক)',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: controller.selectedSubcategory.value?.id,
                        decoration: InputDecoration(
                          hintText: 'সাবক্যাটাগরি বাছাই করুন',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        isExpanded: true,
                        items: controller.availableSubcategories.map((sc) {
                          return DropdownMenuItem(
                            value: sc.id,
                            child: Text(sc.nameBn,
                                overflow: TextOverflow.ellipsis),
                          );
                        }).toList(),
                        onChanged: (val) {
                          final sub = controller.availableSubcategories
                              .firstWhereOrNull((s) => s.id == val);
                          controller.onSelectSubcategory(sub);
                        },
                      ),
                    ],

                    // Dynamic Suggestion Chips
                    if (controller.productSuggestions.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      const Text('পণ্য পরামর্শ (দ্রুত বাছাই):',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondaryElectric)),
                      const SizedBox(height: 4),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: controller.productSuggestions.take(8).map((sugg) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ActionChip(
                                label: Text(sugg,
                                    style: const TextStyle(fontSize: 11)),
                                visualDensity: VisualDensity.compact,
                                onPressed: () {
                                  // Look if exists in available products
                                  final match = controller.availableProducts
                                      .firstWhereOrNull((p) =>
                                          p.name.contains(sugg) ||
                                          (p.nameBn ?? '').contains(sugg));
                                  if (match != null) {
                                    controller.onSelectProduct(match);
                                    isNewProductMode.value = false;
                                  } else {
                                    isNewProductMode.value = true;
                                    controller.inlineNameController.text = sugg;
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Toggle: Existing Product vs New Product
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('বিদ্যমান পণ্য')),
                            selected: !isNewProductMode.value,
                            onSelected: (val) {
                              if (val) isNewProductMode.value = false;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: const Center(child: Text('+ নতুন পণ্য তৈরি')),
                            selected: isNewProductMode.value,
                            onSelected: (val) {
                              if (val) isNewProductMode.value = true;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (!isNewProductMode.value) ...[
                      // Select Existing Product
                      const Text('২. পণ্য নির্বাচন করুন (Product)*',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: controller.selectedProductToAdd.value?.id,
                        decoration: InputDecoration(
                          hintText: controller.filteredProductsForAdd.isEmpty
                              ? 'এই ক্যাটাগরিতে পণ্য নেই (+ নতুন পণ্য তৈরি করুন)'
                              : 'পণ্য বাছাই করুন',
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        isExpanded: true,
                        items: controller.filteredProductsForAdd.map((p) {
                          return DropdownMenuItem(
                            value: p.id,
                            child: Text(
                              '${p.nameBn ?? p.name} (${p.unit})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          final prod = controller.availableProducts
                              .firstWhereOrNull((p) => p.id == val);
                          controller.onSelectProduct(prod);
                        },
                      ),
                    ] else ...[
                      // Inline New Product Form
                      const Text('নতুন পণ্যের বিবরণ:',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondaryElectric)),
                      const SizedBox(height: 6),
                      AppTextField(
                        label: 'পণ্যের নাম (Product Name)*',
                        controller: controller.inlineNameController,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: controller.selectedUnit.value,
                              decoration: const InputDecoration(
                                labelText: 'বেস স্টক একক (Base Unit)*',
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'piece', child: Text('পিস (Piece)')),
                                DropdownMenuItem(value: 'packet', child: Text('প্যাকেট (Packet)')),
                                DropdownMenuItem(value: 'kg', child: Text('কেজি (KG)')),
                                DropdownMenuItem(value: 'g', child: Text('গ্রাম (G)')),
                                DropdownMenuItem(value: 'liter', child: Text('লিটার (L)')),
                                DropdownMenuItem(value: 'bottle', child: Text('বোতল (Bottle)')),
                                DropdownMenuItem(value: 'box', child: Text('বক্স (Box)')),
                                DropdownMenuItem(value: 'carton', child: Text('কার্টন (Carton)')),
                              ],
                              onChanged: (val) {
                                if (val != null) controller.selectedUnit.value = val;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: controller.selectedPackageUnit.value.isEmpty
                                  ? null
                                  : controller.selectedPackageUnit.value,
                              decoration: const InputDecoration(
                                labelText: 'প্যাকেজিং একক (ঐচ্ছিক)',
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 8),
                              ),
                              items: const [
                                DropdownMenuItem(value: '', child: Text('কোনটিই নয়')),
                                DropdownMenuItem(value: 'carton', child: Text('কার্টন (Carton)')),
                                DropdownMenuItem(value: 'box', child: Text('বক্স (Box)')),
                                DropdownMenuItem(value: 'bag', child: Text('বস্তা (Bag)')),
                                DropdownMenuItem(value: 'packet', child: Text('প্যাকেট (Packet)')),
                              ],
                              onChanged: (val) {
                                controller.selectedPackageUnit.value = val ?? '';
                              },
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Packaging conversion if carton/box/bag selected
                    Obx(() {
                      final isPack = controller.selectedUnit.value == 'carton' ||
                          controller.selectedUnit.value == 'box' ||
                          controller.selectedUnit.value == 'bag' ||
                          controller.selectedPackageUnit.value.isNotEmpty;
                      if (!isPack) return const SizedBox.shrink();

                      final baseLabel = controller.selectedProductToAdd.value?.unit ??
                          controller.selectedUnit.value;
                      final packLabel = controller.selectedUnit.value == 'carton' ||
                              controller.selectedUnit.value == 'box' ||
                              controller.selectedUnit.value == 'bag'
                          ? controller.selectedUnit.value
                          : controller.selectedPackageUnit.value;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryElectric.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.secondaryElectric.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                '১ $packLabel = কত $baseLabel?',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: AppTextField(
                                label: 'সংখ্যা',
                                controller: controller.packageQuantityController,
                                keyboardType: const TextInputType.numberWithOptions(
                                    decimal: true),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    // Quantity and Purchase Unit
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: AppTextField(
                            label: 'ক্রয় পরিমাণ (Qty)*',
                            controller: controller.qtyController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<String>(
                            value: controller.selectedUnit.value,
                            decoration: const InputDecoration(
                              labelText: 'ক্রয় একক (Unit)*',
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'piece', child: Text('পিস (Piece)')),
                              DropdownMenuItem(value: 'packet', child: Text('প্যাকেট (Packet)')),
                              DropdownMenuItem(value: 'kg', child: Text('কেজি (KG)')),
                              DropdownMenuItem(value: 'g', child: Text('গ্রাম (G)')),
                              DropdownMenuItem(value: 'liter', child: Text('লিটার (L)')),
                              DropdownMenuItem(value: 'bottle', child: Text('বোতল (Bottle)')),
                              DropdownMenuItem(value: 'box', child: Text('বক্স (Box)')),
                              DropdownMenuItem(value: 'carton', child: Text('কার্টন (Carton)')),
                              DropdownMenuItem(value: 'bag', child: Text('বস্তা (Bag)')),
                              DropdownMenuItem(value: 'dozen', child: Text('ডজন (Dozen)')),
                              DropdownMenuItem(value: 'pair', child: Text('জোড়া (Pair)')),
                            ],
                            onChanged: (val) {
                              if (val != null) controller.selectedUnit.value = val;
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Unit Purchase Cost
                    CurrencyInputField(
                      label: 'প্রতি একক ক্রয়মূল্য (Purchase Cost)*',
                      controller: controller.unitCostController,
                    ),

                    const SizedBox(height: 10),

                    // Selling Prices (Retail & Wholesale)
                    Row(
                      children: [
                        Expanded(
                          child: CurrencyInputField(
                            label: 'খুচরা বিক্রয় মূল্য',
                            controller: controller.retailPriceController,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CurrencyInputField(
                            label: 'পাইকারি মূল্য (ঐচ্ছিক)',
                            controller: controller.wholesalePriceController,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.incomeGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text(
                          'তালিকায় যুক্ত করুন (Add Item)',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                        onPressed: () async {
                          if (isNewProductMode.value) {
                            final name = controller.inlineNameController.text.trim();
                            if (name.isEmpty) {
                              AppSnackbar.error('নতুন পণ্যের নাম লিখুন');
                              return;
                            }
                            final packQty = double.tryParse(
                                    controller.packageQuantityController.text) ??
                                1.0;
                            final purchaseCost = CurrencyUtils.takaToMinor(
                                controller.unitCostController.text);
                            final retailPrice = CurrencyUtils.takaToMinor(
                                controller.retailPriceController.text);
                            final wholesalePrice = CurrencyUtils.takaToMinor(
                                controller.wholesalePriceController.text);

                            final created = await controller.createProductInline(
                              name: name,
                              baseUnit: controller.selectedUnit.value,
                              packageUnit: controller.selectedPackageUnit.value.isNotEmpty
                                  ? controller.selectedPackageUnit.value
                                  : null,
                              packageQuantity: packQty,
                              purchaseCostMinor: purchaseCost,
                              retailPriceMinor: retailPrice,
                              wholesalePriceMinor: wholesalePrice,
                            );

                            if (created != null) {
                              controller.addItem();
                              if (bottomSheetContext.mounted) {
                                Navigator.pop(bottomSheetContext);
                              }
                            }
                          } else {
                            controller.addItem();
                            if (bottomSheetContext.mounted) {
                              Navigator.pop(bottomSheetContext);
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
