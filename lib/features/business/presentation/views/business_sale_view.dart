import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/services/active_business_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/unit_conversion_utils.dart';
import '../../../../shared/widgets/app_loading_indicator.dart';
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

    return Obx(() {
      final activeBiz = controller.currentBusiness.value;
      return DefaultTabController(
        length: 2,
        initialIndex: controller.activeTabIndex.value,
        child: Builder(
          builder: (tabContext) {
            // Listen to tab controller changes
            final tabController = DefaultTabController.of(tabContext);
            if (tabController.index != controller.activeTabIndex.value) {
              tabController.animateTo(controller.activeTabIndex.value);
            }
            tabController.addListener(() {
              if (!tabController.indexIsChanging) {
                controller.activeTabIndex.value = tabController.index;
              }
            });

            return Scaffold(
              appBar: AppBar(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.saleType.value == 'wholesale'
                          ? 'পাইকারি বিক্রয় (Wholesale)'
                          : 'খুচরা বিক্রয় (Retail POS)',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    if (activeBiz != null)
                      Text(
                        activeBiz.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.secondaryElectricLight,
                        ),
                      ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.swap_horiz_rounded),
                    tooltip: 'ব্যবসা পরিবর্তন',
                    onPressed: () => _showBusinessSwitcher(context),
                  ),
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
                bottom: TabBar(
                  onTap: (idx) => controller.activeTabIndex.value = idx,
                  indicatorColor: AppColors.secondaryElectricLight,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 18),
                          const SizedBox(width: 6),
                          const Text('পণ্য ক্যাটালগ', style: TextStyle(fontWeight: FontWeight.w700)),
                          if (controller.availableProducts.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${controller.availableProducts.length}',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_cart_outlined, size: 18),
                          const SizedBox(width: 6),
                          const Text('কার্ট ও বিলিং', style: TextStyle(fontWeight: FontWeight.w700)),
                          if (controller.cartItems.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.incomeGreen,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${controller.cartItemCount}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  _buildProductCatalogTab(context, cardBg, borderColor, isDark),
                  _buildCartAndBillingTab(context, cardBg, borderColor, isDark),
                ],
              ),
              bottomNavigationBar: controller.activeTabIndex.value == 0 &&
                      controller.cartItems.isNotEmpty
                  ? _buildCatalogStickyCartBar(context)
                  : null,
            );
          },
        ),
      );
    });
  }

  // ==========================================
  // TAB 1: PRODUCT CATALOG
  // ==========================================
  Widget _buildProductCatalogTab(
      BuildContext context, Color cardBg, Color borderColor, bool isDark) {
    return Column(
      children: [
        _buildSaleTypeSwitcher(),
        _buildSearchBarAndQuickSale(context, cardBg, borderColor, isDark),
        _buildCategoryChips(),
        Expanded(
          child: Obx(() {
            if (controller.isLoadingProducts.value) {
              return const AppLoadingIndicator();
            }

            if (controller.availableProducts.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSizes.p24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 64,
                          color: isDark
                              ? AppColors.textSecondaryDark.withValues(alpha: 0.4)
                              : AppColors.textSecondaryLight.withValues(alpha: 0.4)),
                      const SizedBox(height: AppSizes.p16),
                      Text(
                        'এই ব্যবসায় এখনো কোনো পণ্য যোগ করা হয়নি।',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(height: AppSizes.p8),
                      Text(
                        'বিক্রয় শুরু করতে প্রথমে পণ্যের তালিকা যুক্ত করুন।',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(height: AppSizes.p20),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondaryElectric,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r8)),
                        ),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('নতুন পণ্য যোগ করুন', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          await Get.toNamed(AppRoutes.addProduct);
                          if (controller.currentBusiness.value != null) {
                            controller.loadProductsAndCustomers(controller.currentBusiness.value!.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            final prods = controller.filteredProducts;
            if (prods.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off_rounded, size: 48, color: Colors.grey),
                    const SizedBox(height: 8),
                    const Text('কোন পণ্য খুঁজে পাওয়া যায়নি',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    TextButton(
                      onPressed: () {
                        controller.searchController.clear();
                        controller.searchQuery.value = '';
                        controller.selectedCategoryId.value = null;
                      },
                      child: const Text('ফিল্টার রিসেট করুন'),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSizes.p12),
              itemCount: prods.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final product = prods[index];
                return _buildProductItemCard(context, product, cardBg, borderColor, isDark);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildProductItemCard(
      BuildContext context, Product product, Color cardBg, Color borderColor, bool isDark) {
    return Obx(() {
      final stock = controller.getProductStock(product.id);
      final isWholesale = controller.saleType.value == 'wholesale';
      final priceMinor = (isWholesale && product.wholesalePriceMinor > 0)
          ? product.wholesalePriceMinor
          : product.sellingPriceMinor;
      final cartItem = controller.getCartItemForProduct(product.id);

      Color stockBadgeColor;
      String stockText;
      if (stock <= 0) {
        stockBadgeColor = AppColors.expenseRed;
        stockText = 'স্টক নেই (০ ${product.unit})';
      } else if (stock <= product.minimumStock) {
        stockBadgeColor = AppColors.warningAmberDark;
        stockText = 'কম স্টক (${stock % 1 == 0 ? stock.toInt() : stock} ${product.unit})';
      } else {
        stockBadgeColor = AppColors.incomeGreen;
        stockText = 'স্টক: ${stock % 1 == 0 ? stock.toInt() : stock} ${product.unit}';
      }

      return Container(
        padding: const EdgeInsets.all(AppSizes.p12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppSizes.r12),
          border: Border.all(
            color: cartItem != null ? AppColors.secondaryElectric : borderColor,
            width: cartItem != null ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.secondaryElectric.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSizes.r8),
              ),
              child: const Icon(Icons.inventory_2_outlined, color: AppColors.secondaryElectric, size: 24),
            ),
            const SizedBox(width: AppSizes.p12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nameBn ?? product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  if (product.nameBn != null && product.name != product.nameBn)
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: stockBadgeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          stockText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: stockBadgeColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${CurrencyUtils.format(priceMinor)} / ${product.unit}',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: isWholesale ? AppColors.warningAmberDark : AppColors.incomeGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSizes.p8),
            // Cart Stepper or Add button
            if (cartItem == null)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryElectric,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r8)),
                  elevation: 0,
                ),
                onPressed: () => controller.addProductToCart(product),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_shopping_cart, size: 16),
                    SizedBox(width: 4),
                    Text('যোগ', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: AppColors.secondaryElectric.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                  border: Border.all(color: AppColors.secondaryElectric),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 18),
                      color: AppColors.expenseRed,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        controller.updateItemQuantity(cartItem, cartItem.quantity.value - 1);
                      },
                    ),
                    InkWell(
                      onTap: () => _showQuantityDialog(context, cartItem),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '${cartItem.quantity.value % 1 == 0 ? cartItem.quantity.value.toInt() : cartItem.quantity.value}',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 18),
                      color: AppColors.incomeGreen,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        controller.updateItemQuantity(cartItem, cartItem.quantity.value + 1);
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildSaleTypeSwitcher() {
    return Obx(() {
      final isWholesale = controller.saleType.value == 'wholesale';
      return Container(
        margin: const EdgeInsets.fromLTRB(AppSizes.p16, AppSizes.p8, AppSizes.p16, 4),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.primaryNavy.withValues(alpha: 0.08),
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

  Widget _buildSearchBarAndQuickSale(
      BuildContext context, Color cardBg, Color borderColor, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.searchController,
              onChanged: (val) => controller.searchQuery.value = val,
              decoration: InputDecoration(
                hintText: 'পণ্য খুঁজুন (নাম, কোড বা বারকোড)...',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: Obx(() {
                  if (controller.searchQuery.value.isNotEmpty) {
                    return IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        controller.searchController.clear();
                        controller.searchQuery.value = '';
                      },
                    );
                  }
                  return IconButton(
                    icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
                    tooltip: 'বারকোড স্ক্যান',
                    onPressed: () => _showBarcodeScanDialog(context),
                  );
                }),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: cardBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSizes.r8),
                  borderSide: BorderSide(color: borderColor),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r8)),
              side: BorderSide(color: borderColor),
            ),
            icon: const Icon(Icons.flash_on_rounded, size: 18, color: AppColors.warningAmber),
            label: const Text('কুইক সেল', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
            onPressed: () => _showQuickSaleDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Obx(() {
      final cats = controller.availableCategories;
      if (cats.isEmpty) return const SizedBox.shrink();

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: 4),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ChoiceChip(
                label: const Text('সব পণ্য'),
                selected: controller.selectedCategoryId.value == null,
                selectedColor: AppColors.secondaryElectric,
                labelStyle: TextStyle(
                  color: controller.selectedCategoryId.value == null ? Colors.white : null,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                onSelected: (selected) {
                  if (selected) controller.selectedCategoryId.value = null;
                },
              ),
            ),
            ...cats.map((c) {
              final isSel = controller.selectedCategoryId.value == c.id;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(c.nameBn.isNotEmpty ? c.nameBn : c.nameEn),
                  selected: isSel,
                  selectedColor: AppColors.secondaryElectric,
                  labelStyle: TextStyle(
                    color: isSel ? Colors.white : null,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  onSelected: (selected) {
                    controller.selectedCategoryId.value = selected ? c.id : null;
                  },
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  Widget _buildCatalogStickyCartBar(BuildContext context) {
    return Obx(() {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryNavy,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${controller.cartItemCount} টি পণ্য (${controller.cartTotalQuantity % 1 == 0 ? controller.cartTotalQuantity.toInt() : controller.cartTotalQuantity})',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    CurrencyUtils.format(controller.totalMinor),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.incomeGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r8)),
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('বিলিংয়ে যান (Checkout)', style: TextStyle(fontWeight: FontWeight.w700)),
                onPressed: () => controller.activeTabIndex.value = 1,
              ),
            ],
          ),
        ),
      );
    });
  }

  // ==========================================
  // TAB 2: CART & BILLING
  // ==========================================
  Widget _buildCartAndBillingTab(
      BuildContext context, Color cardBg, Color borderColor, bool isDark) {
    return Column(
      children: [
        _buildDateTimeBanner(context, isDark),
        _buildCustomerSelector(context, cardBg, borderColor, isDark),
        Expanded(
          child: _buildCartList(context, cardBg, borderColor, isDark),
        ),
        _buildBottomCheckoutPanel(context, cardBg, borderColor, isDark),
      ],
    );
  }

  Widget _buildDateTimeBanner(BuildContext context, bool isDark) {
    return Obx(() {
      final d = controller.transactionDate.value;
      final t = controller.transactionTime.value;
      final dt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
      final formatted = DateFormat('dd MMM yyyy, hh:mm a').format(dt);
      final isCustom = controller.isCustomDateTime.value;

      return Container(
        margin: const EdgeInsets.fromLTRB(AppSizes.p16, 6, AppSizes.p16, 4),
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
                    style: TextStyle(
                        fontSize: 10, color: AppColors.incomeGreen, fontWeight: FontWeight.bold),
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
              const SizedBox(height: 6),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryElectric,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.inventory_2_outlined, size: 18),
                label: const Text('পণ্য ক্যাটালগে যান'),
                onPressed: () => controller.activeTabIndex.value = 0,
              ),
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
                              'দর: ${CurrencyUtils.format(item.unitPriceMinor.value)} / ${UnitConversionUtils.getShortUnitLabel(item.unit.value)}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight),
                            )),
                        Obx(() {
                          if (item.conversionFactor.value != 1.0) {
                            return Text(
                              'মোট বেস স্টক: ${item.baseQuantity % 1 == 0 ? item.baseQuantity.toInt() : item.baseQuantity} ${UnitConversionUtils.getShortUnitLabel(item.baseUnit)}',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.incomeGreen,
                                  fontWeight: FontWeight.w600),
                            );
                          }
                          return const SizedBox.shrink();
                        }),
                      ],
                    ),
                  ),
                  // Quantity controls with decimal input support
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 22),
                        color: AppColors.expenseRed,
                        onPressed: () {
                          controller.updateItemQuantity(item, item.quantity.value - 1);
                        },
                      ),
                      InkWell(
                        onTap: () => _showQuantityDialog(context, item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: borderColor),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Obx(() => Text(
                                '${item.quantity.value % 1 == 0 ? item.quantity.value.toInt() : item.quantity.value}',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              )),
                        ),
                      ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.r16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subtotal & Discount row
            Row(
              children: [
                Expanded(
                  child: Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('উপ-মোট (Subtotal)',
                              style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text(
                            CurrencyUtils.format(controller.subtotalMinor),
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                        ],
                      )),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ছাড় (Discount ৳)',
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                      SizedBox(
                        height: 38,
                        child: TextField(
                          controller: controller.discountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSizes.r8)),
                          ),
                          onChanged: (_) => controller.cartItems.refresh(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 16),
            // Total & Paid row
            Row(
              children: [
                Expanded(
                  child: Obx(() => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('সর্বমোট (Total)',
                              style: TextStyle(fontSize: 11, color: Colors.grey)),
                          Text(
                            CurrencyUtils.format(controller.totalMinor),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                              color: AppColors.incomeGreen,
                            ),
                          ),
                        ],
                      )),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('পরিশোধিত (Paid ৳)',
                          style: TextStyle(fontSize: 11, color: Colors.grey)),
                      SizedBox(
                        height: 38,
                        child: TextField(
                          controller: controller.paidController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppSizes.r8)),
                          ),
                          onChanged: (_) => controller.cartItems.refresh(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Due & Account Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() {
                  final due = controller.dueMinor;
                  if (due <= 0) return const SizedBox.shrink();
                  return Text(
                    'বাকি: ${CurrencyUtils.format(due)}',
                    style: const TextStyle(
                      color: AppColors.expenseRed,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  );
                }),
                _buildAccountSelector(),
              ],
            ),
            const SizedBox(height: 12),
            // Save & Print / Complete Sale Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r8)),
                    ),
                    icon: const Icon(Icons.print_outlined, size: 18),
                    label: const Text('সংরক্ষণ ও প্রিন্ট', style: TextStyle(fontWeight: FontWeight.w700)),
                    onPressed: () => controller.processSale(printReceipt: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.incomeGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.r8)),
                    ),
                    icon: const Icon(Icons.check_circle_outline, size: 20),
                    label: const Text('বিক্রয় সম্পন্ন করুন',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                    onPressed: () => controller.processSale(printReceipt: false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSelector() {
    return Obx(() {
      final accounts = controller.availableAccounts;
      if (accounts.isEmpty) return const SizedBox.shrink();

      return DropdownButton<Account>(
        value: controller.selectedAccount.value,
        underline: const SizedBox.shrink(),
        items: accounts.map((acc) {
          return DropdownMenuItem(
            value: acc,
            child: Text(acc.name, style: const TextStyle(fontSize: 12)),
          );
        }).toList(),
        onChanged: (val) => controller.selectedAccount.value = val,
      );
    });
  }

  void _showQuantityDialog(BuildContext context, SaleCartItem item) {
    final qtyController = TextEditingController(text: '${item.quantity.value}');
    final availableUnits = UnitConversionUtils.getAvailableUnitsForProduct(
      baseUnit: item.baseUnit,
      packageUnit: item.packageUnit,
    );
    final selectedUnit = item.unit.value.obs;

    Get.defaultDialog(
      title: 'পরিমাণ ও একক (${item.productName})',
      content: Padding(
        padding: const EdgeInsets.all(AppSizes.p8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: qtyController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'পরিমাণ (Quantity)',
                hintText: 'যেমন: 0.5 বা 2',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Text('একক নির্বাচন (Select Unit):',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Obx(() => DropdownButtonFormField<String>(
                  value: availableUnits.contains(selectedUnit.value)
                      ? selectedUnit.value
                      : availableUnits.first,
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                  items: availableUnits.map((u) {
                    return DropdownMenuItem(
                      value: u,
                      child: Text(UnitConversionUtils.getUnitLabel(u)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) selectedUnit.value = val;
                  },
                )),
          ],
        ),
      ),
      textConfirm: 'নিশ্চিত করুন',
      textCancel: 'বাতিল',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        final val = double.tryParse(qtyController.text);
        if (selectedUnit.value != item.unit.value) {
          await controller.changeCartItemUnit(item, selectedUnit.value);
        }
        if (val != null && val > 0) {
          await controller.updateItemQuantity(item, val);
        }
        Get.back();
      },
    );
  }

  void _showCustomerPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSizes.p16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.r16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('গ্রাহক নির্বাচন করুন',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('নতুন গ্রাহক'),
                  onPressed: () {
                    Get.back();
                    Get.toNamed(AppRoutes.addCustomer);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.secondaryElectric,
                child: Icon(Icons.person_outline, color: Colors.white),
              ),
              title: const Text('সাধারণ খরিদ্দার (Walk-in Customer)',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              onTap: () {
                controller.selectedCustomer.value = null;
                Get.back();
              },
            ),
            const Divider(),
            Expanded(
              child: Obx(() {
                final custs = controller.availableCustomers;
                if (custs.isEmpty) {
                  return const Center(child: Text('কোন গ্রাহক যোগ করা হয়নি'));
                }
                return ListView.separated(
                  itemCount: custs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final c = custs[idx];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(c.name.isNotEmpty ? c.name[0].toUpperCase() : 'C'),
                      ),
                      title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text(c.phone ?? 'মোবাইল নম্বর নেই'),
                      trailing: c.creditLimitMinor > 0
                          ? Text(
                              'বাকি সীমা: ${CurrencyUtils.format(c.creditLimitMinor)}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            )
                          : null,
                      onTap: () {
                        controller.selectedCustomer.value = c;
                        Get.back();
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickSaleDialog(BuildContext context) {
    controller.clearQuickSaleForm();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppColors.cardDark : AppColors.cardLight;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.r16)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + AppSizes.p16,
            left: AppSizes.p16,
            right: AppSizes.p16,
            top: AppSizes.p16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.flash_on_rounded, color: AppColors.secondaryElectric),
                        SizedBox(width: 8),
                        Text(
                          'কুইক সেল (Quick Sale)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        controller.clearQuickSaleForm();
                        Navigator.pop(sheetContext);
                      },
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                // Selected Product Badge if one is selected
                Obx(() {
                  final p = controller.selectedQuickProduct.value;
                  if (p == null) return const SizedBox.shrink();
                  final stock = controller.getProductStock(p.id);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.incomeGreen.withValues(alpha: isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.incomeGreen),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: AppColors.incomeGreen, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.nameBn ?? p.name,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                              Text(
                                'সংরক্ষিত ইনভেন্টরি পণ্য • বর্তমান মজুদ: ${stock % 1 == 0 ? stock.toInt() : stock} ${p.unit}',
                                style: const TextStyle(fontSize: 11, color: AppColors.incomeGreen),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          tooltip: 'বাছাই বাতিল করুন',
                          onPressed: () {
                            controller.selectedQuickProduct.value = null;
                            controller.quickItemNameController.clear();
                          },
                        ),
                      ],
                    ),
                  );
                }),

                // Search / Enter Product Name
                TextField(
                  controller: controller.quickItemNameController,
                  onChanged: (val) => controller.onQuickItemNameChanged(val),
                  decoration: InputDecoration(
                    labelText: 'পণ্যের নাম, কোড বা বারকোড *',
                    hintText: 'যেমন: মিনিকেট চাল, ডিম, লাক্স সাবান',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: Obx(() {
                      if (controller.quickItemNameController.text.isNotEmpty) {
                        return IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            controller.quickItemNameController.clear();
                            controller.onQuickItemNameChanged('');
                            controller.selectedQuickProduct.value = null;
                          },
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),

                // Suggestions List
                Obx(() {
                  final suggestions = controller.quickProductSuggestions;
                  if (suggestions.isEmpty) return const SizedBox.shrink();
                  return Container(
                    constraints: const BoxConstraints(maxHeight: 180),
                    margin: const EdgeInsets.only(top: 4, bottom: 8),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: borderColor),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: suggestions.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, idx) {
                        final p = suggestions[idx];
                        final stock = controller.getProductStock(p.id);
                        final price = controller.saleType.value == 'wholesale' && p.wholesalePriceMinor > 0
                            ? p.wholesalePriceMinor
                            : p.sellingPriceMinor;
                        return ListTile(
                          dense: true,
                          leading: const CircleAvatar(
                            radius: 14,
                            child: Icon(Icons.inventory_2, size: 16),
                          ),
                          title: Text(
                            p.nameBn ?? p.name,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                          subtitle: Text(
                            'স্টক: ${stock % 1 == 0 ? stock.toInt() : stock} ${p.unit} • ${CurrencyUtils.format(price)}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 12),
                          onTap: () => controller.selectQuickProduct(p),
                        );
                      },
                    ),
                  );
                }),

                const SizedBox(height: 12),

                // Quantity and Unit Row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: controller.quickItemQtyController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'পরিমাণ (Qty) *',
                          hintText: '1',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 4,
                      child: Obx(() {
                        final units = controller.quickAvailableUnits;
                        return DropdownButtonFormField<String>(
                          value: units.contains(controller.quickItemUnit.value)
                              ? controller.quickItemUnit.value
                              : (units.isNotEmpty ? units.first : 'piece'),
                          decoration: InputDecoration(
                            labelText: 'একক (Unit) *',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          items: units.map((u) {
                            return DropdownMenuItem<String>(
                              value: u,
                              child: Text(
                                UnitConversionUtils.getUnitLabel(u),
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) controller.quickItemUnit.value = val;
                          },
                        );
                      }),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Selling Price and Purchase Cost Row
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller.quickItemPriceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'বিক্রয় মূল্য (৳) *',
                          hintText: '0.00',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: controller.quickItemCostController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(
                          labelText: 'ক্রয় মূল্য (৳)',
                          hintText: '0.00',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Notice if not existing product
                Obx(() {
                  if (controller.selectedQuickProduct.value == null &&
                      controller.quickItemNameController.text.trim().isNotEmpty) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryElectric.withValues(alpha: isDark ? 0.2 : 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: AppColors.secondaryElectric),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'নতুন পণ্য হলে এটি তালিকায় যুক্ত হয়ে ইনভেন্টরিতে সংরক্ষিত হবে।',
                              style: TextStyle(fontSize: 11, color: AppColors.secondaryElectric),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Add to Cart Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.incomeGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text(
                      'কার্টে যোগ করুন (Add to Cart)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    onPressed: () async {
                      await controller.addQuickSaleItem();
                      if (sheetContext.mounted) {
                        Navigator.pop(sheetContext);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBarcodeScanDialog(BuildContext context) {
    final barcodeCtrl = TextEditingController();
    Get.defaultDialog(
      title: 'বারকোড দিয়ে খুঁজুন',
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: barcodeCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'বারকোড বা SKU কোড',
            prefixIcon: Icon(Icons.qr_code),
            border: OutlineInputBorder(),
          ),
          onSubmitted: (code) {
            Get.back();
            controller.onScanBarcode(code);
          },
        ),
      ),
      textConfirm: 'যোগ করুন',
      textCancel: 'বাতিল',
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        controller.onScanBarcode(barcodeCtrl.text);
      },
    );
  }

  void _showBusinessSwitcher(BuildContext context) {
    final activeBizService = Get.find<ActiveBusinessService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(AppSizes.p16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.r16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('ব্যবসা নির্বাচন করুন',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('নতুন ব্যবসা'),
                  onPressed: () {
                    Get.back();
                    Get.toNamed(AppRoutes.addBusiness);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Obx(() {
              final bizList = activeBizService.allBusinesses;
              final currentId = activeBizService.activeBusinessId;

              return ListView.separated(
                shrinkWrap: true,
                itemCount: bizList.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, idx) {
                  final b = bizList[idx];
                  final isSelected = b.id == currentId;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected
                          ? AppColors.secondaryElectric
                          : AppColors.secondaryElectric.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.store_mall_directory_outlined,
                        color: isSelected ? Colors.white : AppColors.secondaryElectric,
                      ),
                    ),
                    title: Text(b.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('${b.businessType.toUpperCase()} • ${b.location ?? ''}'),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.incomeGreen)
                        : null,
                    onTap: () {
                      activeBizService.switchBusiness(b);
                      Get.back();
                    },
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
