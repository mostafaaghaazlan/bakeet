import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bakeet/features/marketplace/cubit/storefront_cubit.dart';
import 'package:bakeet/features/marketplace/cubit/cart_cubit.dart';
import 'package:bakeet/features/marketplace/data/repository/marketplace_repository.dart';
import 'package:bakeet/features/marketplace/data/model/product_model.dart';
import 'package:bakeet/features/marketplace/data/model/vendor_model.dart';
import 'package:bakeet/core/ui/widgets/cached_image.dart';
import 'package:bakeet/core/utils/functions/currency_formatter.dart';
import 'package:bakeet/core/constant/app_colors/app_colors.dart';
import 'package:bakeet/core/di/injection.dart';
import 'package:bakeet/features/marketplace/screen/cart_screen.dart';
import 'package:shimmer/shimmer.dart';
import 'product_detail_screen.dart';

/// A stunning storefront screen showcasing vendor products with beautiful animations
class StorefrontScreen extends StatefulWidget {
  final String vendorId;
  final String vendorName;

  const StorefrontScreen({
    Key? key,
    required this.vendorId,
    required this.vendorName,
  }) : super(key: key);

  @override
  State<StorefrontScreen> createState() => _StorefrontScreenState();
}

class _StorefrontScreenState extends State<StorefrontScreen>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _headerController;
  bool _showAppBarTitle = false;

  final List<String> _categories = ['All', 'Popular', 'New Arrivals', 'Sale'];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scrollController.addListener(() {
      if (_scrollController.offset > 200 && !_showAppBarTitle) {
        setState(() => _showAppBarTitle = true);
      } else if (_scrollController.offset <= 200 && _showAppBarTitle) {
        setState(() => _showAppBarTitle = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _headerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StorefrontCubit(MarketplaceRepository())
        ..loadProductsForVendor(widget.vendorId),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: AppColors.appWhite,
        appBar: _buildAppBar(context),
        body: BlocBuilder<StorefrontCubit, StorefrontState>(
          builder: (context, state) {
            if (state is StorefrontLoading) {
              return _buildLoadingState();
            }

            if (state is StorefrontLoaded) {
              final products = state.products.cast<ProductModel>();
              final repository = MarketplaceRepository();

              return FutureBuilder<VendorModel?>(
                future: _getVendor(repository),
                builder: (context, snapshot) {
                  return CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      if (snapshot.hasData)
                        _buildVendorHeader(snapshot.data!),
                      SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                      _buildCategoryFilters(),
                      SliverToBoxAdapter(child: SizedBox(height: 16.h)),
                      _buildProductsHeader(products.length),
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 8.h,
                        ),
                        sliver: _buildProductsGrid(products),
                      ),
                      SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                    ],
                  );
                },
              );
            }

            if (state is StorefrontError) {
              return _buildErrorState(state.message);
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: _buildCartFAB(),
      ),
    );
  }

  Future<VendorModel?> _getVendor(MarketplaceRepository repository) async {
    final vendors = await repository.getVendors();
    try {
      return vendors.firstWhere((v) => v.id == widget.vendorId) as VendorModel;
    } catch (e) {
      return null;
    }
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: _showAppBarTitle ? 4 : 0,
      backgroundColor:
          _showAppBarTitle ? AppColors.white : Colors.transparent,
      foregroundColor:
          _showAppBarTitle ? AppColors.neutral900 : AppColors.white,
      title: AnimatedOpacity(
        opacity: _showAppBarTitle ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: Text(
          widget.vendorName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () {},
          tooltip: 'Search',
        ),
        IconButton(
          icon: const Icon(Icons.share_rounded),
          onPressed: () {},
          tooltip: 'Share',
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildVendorHeader(VendorModel vendor) {
    return SliverToBoxAdapter(
      child: Stack(
        children: [
          // Banner Image
          Container(
            height: 280.h,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedImage(
                  imageUrl: vendor.bannerUrl,
                  fit: BoxFit.cover,
                ),
                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Vendor Info
          Positioned(
            left: 20.w,
            right: 20.w,
            bottom: 20.h,
            child: Row(
              children: [
                // Logo
                Container(
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 40.r,
                    backgroundImage: NetworkImage(vendor.logoUrl),
                    backgroundColor: AppColors.white,
                  ),
                ),
                SizedBox(width: 16.w),
                // Vendor Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              vendor.name,
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.all(6.r),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.verified_rounded,
                              color: AppColors.white,
                              size: 18.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        vendor.tagline,
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.9),
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          _buildInfoChip(
                            Icons.star_rounded,
                            '4.8',
                            AppColors.yellow,
                          ),
                          SizedBox(width: 12.w),
                          _buildInfoChip(
                            Icons.inventory_2_outlined,
                            '120+ Products',
                            AppColors.primary,
                          ),
                          SizedBox(width: 12.w),
                          _buildInfoChip(
                            Icons.local_shipping_outlined,
                            'Fast',
                            AppColors.success,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16.sp),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              color: AppColors.white,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 45.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          itemCount: _categories.length,
          separatorBuilder: (_, __) => SizedBox(width: 12.w),
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategory == category;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: FilterChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() => _selectedCategory = category);
                },
                backgroundColor: AppColors.white,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.neutral700,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14.sp,
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                elevation: isSelected ? 4 : 1,
                shadowColor: AppColors.primary.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.neutral300,
                    width: isSelected ? 0 : 1,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductsHeader(int count) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Products',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral900,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '$count items available',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: Icon(Icons.tune_rounded, size: 24.sp),
              onPressed: () {},
              tooltip: 'Sort & Filter',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid(List<ProductModel> products) {
    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(40.r),
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 80.sp,
                  color: AppColors.neutral400,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No products available',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral700,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.68,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          return _AnimatedProductCard(
            product: products[index],
            index: index,
            onAddToCart: () => _addToCart(products[index]),
          );
        },
        childCount: products.length,
      ),
    );
  }

  Widget _buildLoadingState() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Shimmer.fromColors(
            baseColor: AppColors.neutral200,
            highlightColor: AppColors.neutral100,
            child: Container(
              height: 280.h,
              color: AppColors.white,
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: 24.h)),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 0.68,
            ),
            delegate: SliverChildBuilderDelegate(
              (_, __) => Shimmer.fromColors(
                baseColor: AppColors.neutral200,
                highlightColor: AppColors.neutral100,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ),
              childCount: 6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80.sp,
              color: AppColors.danger,
            ),
            SizedBox(height: 16.h),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.neutral700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.neutral600,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<StorefrontCubit>()
                    .loadProductsForVendor(widget.vendorId);
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartFAB() {
    return BlocBuilder<CartCubit, CartState>(
      bloc: getIt<CartCubit>(),
      builder: (context, state) {
        final count = state is CartUpdated ? state.items.length : 0;

        return FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          },
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 8,
          icon: Stack(
            children: [
              const Icon(Icons.shopping_cart_rounded),
              if (count > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(minWidth: 16.w, minHeight: 16.h),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          label: Text(count > 0 ? 'View Cart ($count)' : 'Cart'),
        );
      },
    );
  }

  void _addToCart(ProductModel product) {
    final cartCubit = getIt<CartCubit>();
    cartCubit.addItem(CartItem(
      productId: product.id,
      vendorId: product.vendorId,
      qty: 1,
      unitPrice: product.price,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.title} added to cart'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        action: SnackBarAction(
          label: 'View Cart',
          textColor: AppColors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          },
        ),
      ),
    );
  }
}

// Animated Product Card
class _AnimatedProductCard extends StatefulWidget {
  final ProductModel product;
  final int index;
  final VoidCallback onAddToCart;

  const _AnimatedProductCard({
    required this.product,
    required this.index,
    required this.onAddToCart,
  });

  @override
  State<_AnimatedProductCard> createState() => _AnimatedProductCardState();
}

class _AnimatedProductCardState extends State<_AnimatedProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    Future.delayed(Duration(milliseconds: widget.index * 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = widget.product.compareAtPrice != null;
    final discountPercent = hasDiscount
        ? (((widget.product.compareAtPrice! - widget.product.price) /
                    widget.product.compareAtPrice!) *
                100)
            .round()
        : 0;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(productId: widget.product.id),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.neutral300.withOpacity(0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20.r),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: CachedImage(
                          imageUrl: widget.product.images.isNotEmpty
                              ? widget.product.images.first
                              : '',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Discount Badge
                    if (hasDiscount)
                      Positioned(
                        top: 12.h,
                        right: 12.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.danger, AppColors.warning],
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            '-$discountPercent%',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    // Favorite Button
                    Positioned(
                      top: 12.h,
                      left: 12.w,
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _isFavorite = !_isFavorite);
                        },
                        child: Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: AppColors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: _isFavorite ? AppColors.danger : AppColors.neutral600,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Product Info
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(12.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral900,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        if (hasDiscount) ...[
                          Text(
                            CurrencyFormatter.formatIraqiDinar(
                              widget.product.compareAtPrice!,
                            ),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.neutral600,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          SizedBox(height: 4.h),
                        ],
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                CurrencyFormatter.formatIraqiDinar(
                                  widget.product.price,
                                ),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            // Add to Cart Button
                            GestureDetector(
                              onTap: widget.onAddToCart,
                              child: Container(
                                padding: EdgeInsets.all(8.r),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [AppColors.primary, AppColors.accent],
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.add_shopping_cart_rounded,
                                  color: AppColors.white,
                                  size: 18.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
