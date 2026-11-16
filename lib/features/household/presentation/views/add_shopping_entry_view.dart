import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_image.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/currency_input_field.dart';
import '../controllers/household_controller.dart';

class AddShoppingEntryView extends GetView<HouseholdController> {
  const AddShoppingEntryView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('add_shopping_entry'.tr),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth >= 768;

          if (isWideScreen) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column: Cart Items & Add Product (flex: 6)
                Expanded(
                  flex: 6,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSizes.p16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCartHeader(context, isDark),
                        const SizedBox(height: AppSizes.p12),
                        _buildCartItemsList(context, isDark),
                        const SizedBox(height: AppSizes.p16),
                        _buildAddProductButton(context),
                      ],
                    ),
                  ),
                ),
                // Divider
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
                // Right Column: Store info, Date, Bill Summary, Account & Save (flex: 5)
                Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSizes.p16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStoreAndDateCard(context, isDark),
                        const SizedBox(height: AppSizes.p16),
                        _buildBillSummaryCard(context, isDark),
                        const SizedBox(height: AppSizes.p24),
                        _buildSaveButton(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          // Mobile Layout (< 768px): Single Scrollable Column
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStoreAndDateCard(context, isDark),
                const SizedBox(height: AppSizes.p16),
                _buildCartHeader(context, isDark),
                const SizedBox(height: AppSizes.p12),
                _buildCartItemsList(context, isDark),
                const SizedBox(height: AppSizes.p12),
                _buildAddProductButton(context),
                const SizedBox(height: AppSizes.p20),
                _buildBillSummaryCard(context, isDark),
                const SizedBox(height: AppSizes.p24),
                _buildSaveButton(),
                const SizedBox(height: AppSizes.p32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoreAndDateCard(BuildContext context, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'দোকান ও তারিখের বিবরণ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: AppSizes.p12),
            AppTextField(
              label: 'store_name'.tr,
              hint: 'যেমন: কারওয়ান বাজার, স্থানীয় মুদি দোকান',
              controller: controller.storeNameController,
              prefixIcon: Icons.storefront_outlined,
            ),
            const SizedBox(height: AppSizes.p12),
            _buildDatePicker(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, bool isDark) {
    return Obx(() {
      return InkWell(
        borderRadius: BorderRadius.circular(AppSizes.r8),
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: controller.shoppingDate.value,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            controller.shoppingDate.value = picked;
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.p12, vertical: AppSizes.p10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.r8),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            color: isDark ? AppColors.surfaceDark : Colors.white,
          ),
          child: Row(
            children: [
              const Icon(AppIcons.calendar, color: AppColors.secondaryElectric, size: 20),
              const SizedBox(width: AppSizes.p12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'date'.tr,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    Text(
                      AppDateUtils.standardDateFormat.format(controller.shoppingDate.value),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCartHeader(BuildContext context, bool isDark) {
    return Obx(() {
      final count = controller.cartItems.length;
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(AppIcons.shopping, color: AppColors.secondaryElectric, size: 20),
              const SizedBox(width: AppSizes.p8),
              Text(
                'বাজারের কার্ট',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: AppSizes.p8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryElectric.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSizes.rFull),
                  ),
                  child: Text(
                    '$count টি পণ্য',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryElectric,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (count > 0)
            TextButton.icon(
              icon: const Icon(Icons.delete_sweep_outlined, size: 16, color: AppColors.expenseRed),
              label: const Text('সব মুছুন', style: TextStyle(color: AppColors.expenseRed, fontSize: 13)),
              onPressed: () => controller.clearCart(),
            ),
        ],
      );
    });
  }

  Widget _buildCartItemsList(BuildContext context, bool isDark) {
    return Obx(() {
      final items = controller.cartItems;

      if (items.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppSizes.p32, horizontal: AppSizes.p16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(AppSizes.r12),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.secondaryElectric : AppColors.primaryNavy).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shopping_cart_outlined, size: 32, color: AppColors.secondaryElectric),
              ),
              const SizedBox(height: AppSizes.p12),
              Text(
                'আপনার শপিং কার্ট খালি',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: AppSizes.p4),
              Text(
                'পণ্য যোগ করতে নিচের "পণ্য যোগ করুন" বাটনে চাপ দিন',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSizes.p8),
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildCartItemCard(context, item, index, isDark);
        },
      );
    });
  }

  Widget _buildCartItemCard(BuildContext context, CartItem item, int index, bool isDark) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r12),
        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Product Image / Thumbnail
            _buildProductThumbnail(item, isDark),
            const SizedBox(width: AppSizes.p12),

            // Product Name & Unit Price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Obx(() {
                    return Text(
                      'দর: ${CurrencyUtils.format(item.unitPriceMinor.value)} / ${_formatUnit(item.unit)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  // Quantity Stepper: [-] [qty unit] [+]
                  _buildQuantityStepper(item, index, isDark),
                ],
              ),
            ),

            const SizedBox(width: AppSizes.p12),

            // Subtotal & Delete Button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.expenseRed, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'মুছুন',
                  onPressed: () => controller.removeCartItem(index),
                ),
                const SizedBox(height: 12),
                Text(
                  'মোট',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
                Obx(() {
                  return Text(
                    CurrencyUtils.format(item.subtotalMinor),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.incomeGreen,
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductThumbnail(CartItem item, bool isDark) {
    return Obx(() {
      return AppImage(
        imagePath: item.imagePath.value,
        width: 54,
        height: 54,
        fallbackIcon: Icons.fastfood_outlined,
        fallbackColor: AppColors.secondaryElectric,
        borderRadius: AppSizes.r8,
      );
    });
  }

  Widget _buildQuantityStepper(CartItem item, int index, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Decrement button
        InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => controller.decrementQuantity(index),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              borderRadius: BorderRadius.circular(4),
              color: isDark ? AppColors.surfaceDark : Colors.white,
            ),
            child: Icon(
              Icons.remove,
              size: 16,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Obx(() {
            final qty = item.quantity.value;
            final qtyStr = qty == qty.roundToDouble() ? qty.toInt().toString() : qty.toString();
            return Text(
              '$qtyStr ${_formatUnit(item.unit)}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            );
          }),
        ),
        // Increment button
        InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () => controller.incrementQuantity(index),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              borderRadius: BorderRadius.circular(4),
              color: isDark ? AppColors.surfaceDark : Colors.white,
            ),
            child: Icon(
              Icons.add,
              size: 16,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddProductButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.add_shopping_cart_rounded, size: 18),
        label: const Text('পণ্য যোগ করুন (Add Product)', style: TextStyle(fontWeight: FontWeight.w600)),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: const BorderSide(color: AppColors.secondaryElectric, width: 1.5),
          foregroundColor: AppColors.secondaryElectric,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r8)),
        ),
        onPressed: () => _showAddProductDialog(context),
      ),
    );
  }

  Widget _buildBillSummaryCard(BuildContext context, bool isDark) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.r12),
        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: AppColors.secondaryElectric, size: 20),
                const SizedBox(width: AppSizes.p8),
                Text(
                  'বিলের বিবরণ (Bill Summary)',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.p16),

            // Subtotal Row
            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'সাবটোটাল (Subtotal)',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  Text(
                    CurrencyUtils.format(controller.subtotalMinor),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: AppSizes.p12),

            // Discount Input
            CurrencyInputField(
              label: 'discount'.tr,
              controller: controller.discountController,
              onChanged: (_) {
                controller.cartItems.refresh();
              },
            ),
            const SizedBox(height: AppSizes.p12),

            const Divider(),
            const SizedBox(height: AppSizes.p8),

            // Net Payable / Total Bill Row
            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'মোট প্রদেয় (Net Payable)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    CurrencyUtils.format(controller.totalBillMinor),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.expenseRed,
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: AppSizes.p16),

            // Paid Amount Input
            CurrencyInputField(
              label: 'paid_amount'.tr,
              controller: controller.paidController,
              onChanged: (_) {
                controller.cartItems.refresh();
              },
            ),
            const SizedBox(height: AppSizes.p12),

            // Due Amount Row
            Obx(() {
              final due = controller.cartDueMinor;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'বকেয়া (Due)',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  Text(
                    CurrencyUtils.format(due),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: due > 0 ? AppColors.warningAmberDark : AppColors.incomeGreen,
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: AppSizes.p16),

            // Account Selection Dropdown
            _buildAccountDropdown(context, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountDropdown(BuildContext context, bool isDark) {
    return Obx(() {
      final selectedId = controller.selectedAccountId.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'পরিশোধের মাধ্যম / অ্যাকাউন্ট',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSizes.r8),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              color: isDark ? AppColors.surfaceDark : Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedId,
                isExpanded: true,
                dropdownColor: isDark ? AppColors.cardDark : Colors.white,
                hint: Text('অ্যাকাউন্ট নির্বাচন করুন', style: TextStyle(color: isDark ? Colors.white70 : Colors.black54)),
                items: const [
                  DropdownMenuItem(value: 'acc_cash_01', child: Text('নগদ ক্যাশ (Cash)')),
                  DropdownMenuItem(value: 'acc_bkash_01', child: Text('বিকাশ (bKash)')),
                  DropdownMenuItem(value: 'acc_bank_01', child: Text('ব্যাংক অ্যাকাউন্ট')),
                ],
                onChanged: (val) {
                  if (val != null) controller.selectedAccountId.value = val;
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSaveButton() {
    return AppButton(
      text: 'হিসাব সংরক্ষণ করুন (Save Bill)',
      icon: AppIcons.check,
      onPressed: () async {
        final success = await controller.saveShoppingBill();
        if (success) {
          Get.back();
        }
      },
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final priceCtrl = TextEditingController();
    final RxString unit = 'kg'.obs;
    final Rx<String?> imagePath = Rx<String?>(null);

    final suggestions = ['চাল', 'ডাল', 'তেল', 'আলু', 'পেঁয়াজ', 'ডিম', 'মাছ', 'মাংস', 'সবজি', 'দুধ', 'চিনি', 'লবণ'];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r16)),
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.p20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.add_shopping_cart_rounded, color: AppColors.secondaryElectric),
                      const SizedBox(width: AppSizes.p8),
                      Text(
                        'পণ্য যোগ করুন',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p12),

              // Suggestions chips
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: suggestions.map((s) {
                  return InkWell(
                    borderRadius: BorderRadius.circular(AppSizes.rFull),
                    onTap: () {
                      nameCtrl.text = s;
                      if (s == 'তেল' || s == 'দুধ') {
                        unit.value = 'liter';
                      } else if (s == 'ডিম') {
                        unit.value = 'piece';
                      } else {
                        unit.value = 'kg';
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.surfaceDark : Colors.grey.shade100),
                        borderRadius: BorderRadius.circular(AppSizes.rFull),
                        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.p16),

              // Product Name Field
              AppTextField(
                label: 'product_name'.tr,
                controller: nameCtrl,
                hint: 'যেমন: বাসমতি চাল, সয়াবিন তেল...',
                prefixIcon: Icons.shopping_basket_outlined,
              ),
              const SizedBox(height: AppSizes.p12),

              // Quantity & Unit
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: AppTextField(
                      label: 'quantity'.tr,
                      controller: qtyCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      prefixIcon: Icons.scale_outlined,
                    ),
                  ),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(
                    flex: 2,
                    child: Obx(() {
                      return DropdownButtonFormField<String>(
                        value: unit.value,
                        dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                        decoration: const InputDecoration(labelText: 'একক'),
                        items: const [
                          DropdownMenuItem(value: 'kg', child: Text('কেজি')),
                          DropdownMenuItem(value: 'liter', child: Text('লিটার')),
                          DropdownMenuItem(value: 'piece', child: Text('পিস')),
                          DropdownMenuItem(value: 'packet', child: Text('প্যাকেট')),
                          DropdownMenuItem(value: 'g', child: Text('গ্রাম')),
                        ],
                        onChanged: (v) {
                          if (v != null) unit.value = v;
                        },
                      );
                    }),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p12),

              // Unit Price
              AppTextField(
                label: 'প্রতি একক দর (Unit Price)',
                controller: priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                hint: '0.00',
                prefixIcon: Icons.currency_exchange_rounded,
              ),
              const SizedBox(height: AppSizes.p16),

              // Optional Product Image Picker
              Obx(() {
                final path = imagePath.value;
                return Row(
                  children: [
                    AppImage(
                      imagePath: path,
                      width: 44,
                      height: 44,
                      borderRadius: AppSizes.r8,
                      fallbackIcon: Icons.image_outlined,
                    ),
                    const SizedBox(width: AppSizes.p12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.add_a_photo_outlined, size: 16),
                        label: Text(
                          path != null ? 'ছবি পরিবর্তন করুন' : 'পণ্যের ছবি যুক্ত করুন',
                          style: const TextStyle(fontSize: 12),
                        ),
                        onPressed: () async {
                          final picker = ImagePicker();
                          final image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                          if (image != null) {
                            imagePath.value = image.path;
                          }
                        },
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: AppSizes.p24),

              // Add to Cart Button
              AppButton(
                text: 'কার্টে যোগ করুন (Add to Cart)',
                icon: Icons.check_rounded,
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  if (name.isEmpty) {
                    return;
                  }
                  final qty = double.tryParse(qtyCtrl.text.trim()) ?? 1.0;
                  final priceMinor = CurrencyUtils.takaToMinor(priceCtrl.text.trim());

                  controller.addToCart(
                    name: name,
                    quantity: qty,
                    unit: unit.value,
                    unitPriceMinor: priceMinor,
                    imagePath: imagePath.value,
                  );

                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatUnit(String unit) {
    switch (unit) {
      case 'kg':
        return 'কেজি';
      case 'liter':
        return 'লিটার';
      case 'piece':
        return 'পিস';
      case 'packet':
        return 'প্যাকেট';
      case 'g':
        return 'গ্রাম';
      default:
        return unit;
    }
  }
}
