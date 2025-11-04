import 'package:bakeet/core/constant/app_size/app_size.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bakeet/features/marketplace/cubit/cart_cubit.dart';
import 'package:bakeet/features/marketplace/data/repository/marketplace_repository.dart';
import 'package:bakeet/features/marketplace/data/model/product_model.dart';
import 'package:bakeet/core/di/injection.dart';
import 'package:bakeet/core/utils/functions/currency_formatter.dart';
import 'package:bakeet/core/constant/app_colors/app_colors.dart';
import 'package:bakeet/core/ui/widgets/cached_image.dart';
import 'checkout_screen.dart';

/// A stunning cart screen with beautiful item cards and modern design
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  final MarketplaceRepository _repository = MarketplaceRepository();
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cubit = getIt<CartCubit>();

    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: _buildAppBar(context, cubit),
      body: BlocBuilder<CartCubit, CartState>(
        bloc: cubit,
        builder: (context, state) {
          final items = cubit.items;

          if (items.isEmpty) {
            return _buildEmptyCart(context);
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(20.r),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    return _CartItemCard(
                      item: items[index],
                      index: index,
                      repository: _repository,
                      onQuantityChanged: (qty) {
                        cubit.updateQuantity(items[index].productId, qty);
                      },
                      onRemove: () {
                        _showRemoveDialog(context, cubit, items[index]);
                      },
                    );
                  },
                ),
              ),
              _buildPriceSummary(cubit),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, CartCubit cubit) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.appWhite,
      foregroundColor: AppColors.neutral900,
      title: BlocBuilder<CartCubit, CartState>(
        bloc: cubit,
        builder: (context, state) {
          final count = cubit.items.length;
          return Text(
            count > 0
                ? tr('shopping_cart_count', args: ['$count'])
                : tr('shopping_cart'),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.sp),
          );
        },
      ),
      actions: [
        BlocBuilder<CartCubit, CartState>(
          bloc: cubit,
          builder: (context, state) {
            if (cubit.items.isEmpty) return const SizedBox.shrink();
            return TextButton.icon(
              onPressed: () => _showClearDialog(context, cubit),
              icon: const Icon(Icons.delete_outline_rounded),
              label: Text(tr('clear')),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            );
          },
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32.r),
              decoration: BoxDecoration(
                color: AppColors.primary25,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.shopping_cart_outlined,
                size: 80.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              tr('your_cart_is_empty'),
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.neutral900,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              tr('add_items_to_start'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.sp, color: AppColors.neutral600),
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: Text(tr('start_shopping')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceSummary(CartCubit cubit) {
    final subtotal = cubit.subtotal;
    final shipping = 5000.0; // Fixed shipping cost
    final discount = 0.0; // No discount for now
    final total = subtotal + shipping - discount;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral300.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Price Breakdown
              _buildPriceRow(tr('subtotal_label'), subtotal, false),
              SizedBox(height: 12.h),
              _buildPriceRow(tr('shipping_label'), shipping, false),
              if (discount > 0) ...[
                SizedBox(height: 12.h),
                _buildPriceRow(
                  tr('discount_label'),
                  -discount,
                  false,
                  color: AppColors.success,
                ),
              ],
              Padding(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                child: Divider(color: AppColors.neutral200, height: 1),
              ),
              _buildPriceRow(tr('total_label'), total, true),
              SizedBox(height: 20.h),
              // Checkout Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(vertical: 18.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tr('proceed_to_checkout'),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.arrow_forward_rounded, size: 20.sp),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount,
    bool isTotal, {
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 18.sp : 16.sp,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color:
                color ??
                (isTotal ? AppColors.neutral900 : AppColors.neutral600),
          ),
        ),
        Text(
          CurrencyFormatter.formatIraqiDinar(amount.abs()),
          style: TextStyle(
            fontSize: isTotal ? 22.sp : 16.sp,
            fontWeight: FontWeight.bold,
            color:
                color ?? (isTotal ? AppColors.primary : AppColors.neutral900),
          ),
        ),
      ],
    );
  }

  void _showRemoveDialog(BuildContext context, CartCubit cubit, CartItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(tr('remove_item')),
        content: Text(tr('remove_item_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              cubit.removeItem(item.productId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tr('item_removed')),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.white,
            ),
            child: Text(tr('remove')),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, CartCubit cubit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(tr('clear_cart')),
        content: Text(tr('clear_cart_confirm')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              cubit.clear();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(tr('cart_cleared')),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: AppColors.white,
            ),
            child: Text(tr('clear_all')),
          ),
        ],
      ),
    );
  }
}

// Cart Item Card
class _CartItemCard extends StatefulWidget {
  final CartItem item;
  final int index;
  final MarketplaceRepository repository;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.index,
    required this.repository,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  State<_CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<_CartItemCard>
    with SingleTickerProviderStateMixin {
  ProductModel? _product;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _loadProduct();

    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
  }

  Future<void> _loadProduct() async {
    final product = await widget.repository.getProductById(
      widget.item.productId,
    );
    if (mounted) {
      setState(() => _product = product);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutral300.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _product == null ? _buildLoadingState() : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          Container(
            width: 100.w,
            height: 100.h,
            decoration: BoxDecoration(
              color: AppColors.neutral200,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: AppColors.neutral200,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: 100.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: AppColors.neutral200,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final totalPrice = widget.item.unitPrice * widget.item.qty;

    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: SizedBox(
              width: 100.w,
              height: 100.h,
              child: CachedImage(
                imageUrl: _product!.images.isNotEmpty
                    ? _product!.images.first
                    : '',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _product!.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral900,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onRemove,
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.neutral600,
                        size: 20.sp,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                // Price
                Row(
                  children: [
                    Text(
                      CurrencyFormatter.formatIraqiDinar(widget.item.unitPrice),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.neutral600,
                      ),
                    ),
                    Text(
                      ' × ${widget.item.qty}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // Quantity Selector and Total
                Column(
                  spacing: AppSize.size_10,
                  children: [
                    // Quantity Controls
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.neutral50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.neutral300,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildQuantityButton(Icons.remove_rounded, () {
                            if (widget.item.qty > 1) {
                              widget.onQuantityChanged(widget.item.qty - 1);
                            }
                          }),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Text(
                              '${widget.item.qty}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.neutral900,
                              ),
                            ),
                          ),
                          _buildQuantityButton(Icons.add_rounded, () {
                            widget.onQuantityChanged(widget.item.qty + 1);
                          }),
                        ],
                      ),
                    ),
                    // Total Price (avoid Flexible inside unbounded Column)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        CurrencyFormatter.formatIraqiDinar(totalPrice),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(8.r),
        child: Icon(icon, color: AppColors.primary, size: 18.sp),
      ),
    );
  }
}
