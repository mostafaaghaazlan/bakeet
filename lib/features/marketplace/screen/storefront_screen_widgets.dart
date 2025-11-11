import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bakeet/features/marketplace/data/model/product_model.dart';
import 'package:bakeet/features/marketplace/data/model/vendor_theme.dart';
import 'package:bakeet/features/marketplace/cubit/cart_cubit.dart';
import 'package:bakeet/core/ui/widgets/cached_image.dart';
import 'package:bakeet/core/utils/functions/currency_formatter.dart';
import 'package:bakeet/core/constant/app_colors/app_colors.dart';
import 'package:bakeet/core/di/injection.dart';
import 'package:bakeet/features/marketplace/screen/product_detail_screen.dart';

// Product Grid with Banners inserted every 5 rows (for Storefront)
class ProductGridWithBannersStorefront extends StatelessWidget {
  final List<ProductModel> products;
  final VendorTheme? theme;
  final Function(ProductModel) onAddToCart;
  final Widget Function(ProductModel, int, VoidCallback, VendorTheme?) cardBuilder;

  const ProductGridWithBannersStorefront({
    super.key,
    required this.products,
    required this.theme,
    required this.onAddToCart,
    required this.cardBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];
    const int productsPerRow = 2;
    const int rowsBeforeBanner = 5;
    const int productsBeforeBanner = productsPerRow * rowsBeforeBanner; // 10 products

    for (int i = 0; i < products.length; i += productsBeforeBanner) {
      // Add a grid section with up to 10 products
      final sectionProducts = products.skip(i).take(productsBeforeBanner).toList();

      children.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: productsPerRow,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 0.68,
            ),
            itemCount: sectionProducts.length,
            itemBuilder: (context, index) {
              final product = sectionProducts[index];
              return cardBuilder(
                product,
                i + index,
                () => onAddToCart(product),
                theme,
              );
            },
          ),
        ),
      );

      // Add banner after this section if there are more products
      if (i + productsBeforeBanner < products.length) {
        children.add(SizedBox(height: 32.h));

        // Get featured products for the banner (prioritize discounted items)
        final featuredProducts = products
            .where((p) => p.compareAtPrice != null)
            .take(5)
            .toList();
        final bannerProducts = featuredProducts.isNotEmpty
            ? featuredProducts
            : products.take(5).toList();

        children.add(
          SizedBox(
            height: 240.h,
            child: ProductBannerCarouselStorefront(products: bannerProducts),
          ),
        );
        children.add(SizedBox(height: 32.h));
      }
    }

    return Column(
      children: children,
    );
  }
}

// Product Banner Carousel for Storefront
class ProductBannerCarouselStorefront extends StatefulWidget {
  final List<ProductModel> products;

  const ProductBannerCarouselStorefront({super.key, required this.products});

  @override
  State<ProductBannerCarouselStorefront> createState() =>
      _ProductBannerCarouselStorefrontState();
}

class _ProductBannerCarouselStorefrontState
    extends State<ProductBannerCarouselStorefront>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.92);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _startAutoRotate();
  }

  void _startAutoRotate() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < widget.products.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.products.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.2)).clamp(0.0, 1.0);
                  }
                  return Transform.scale(
                    scale: Curves.easeOut.transform(value),
                    child: child,
                  );
                },
                child: _ProductBannerCardStorefront(
                  product: widget.products[index],
                  pulseAnimation: _pulseController,
                ),
              );
            },
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.products.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              width: _currentPage == index ? 32.w : 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                gradient: _currentPage == index
                    ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      )
                    : null,
                color: _currentPage == index ? null : AppColors.neutral300,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Individual Product Banner Card for Storefront
class _ProductBannerCardStorefront extends StatelessWidget {
  final ProductModel product;
  final AnimationController pulseAnimation;

  const _ProductBannerCardStorefront({
    required this.product,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.compareAtPrice != null;
    final discountPercent = hasDiscount
        ? (((product.compareAtPrice! - product.price) /
                      product.compareAtPrice!) *
                  100)
              .round()
        : 0;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productId: product.id),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Product Image Background
                CachedImage(
                  imageUrl: product.images.isNotEmpty ? product.images.first : '',
                  fit: BoxFit.cover,
                ),

                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        AppColors.black.withValues(alpha: 0.1),
                        AppColors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),

                // Content Overlay
                Positioned(
                  top: 16.h,
                  left: 16.w,
                  right: 16.w,
                  bottom: 16.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Discount Badge (Top Left)
                      if (hasDiscount)
                        AnimatedBuilder(
                          animation: pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (pulseAnimation.value * 0.1),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFF4757), Color(0xFFFF6B81)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFF4757).withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '$discountPercent%',
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      tr('discount'),
                                      style: TextStyle(
                                        color: AppColors.white,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                      const Spacer(),

                      // Product Info (Bottom)
                      // Product Title
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          product.title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neutral900,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // Price Section & Add to Cart Button
                      Row(
                        children: [
                          // Price Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (hasDiscount) ...[
                                  // Original Price (Strikethrough)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.white.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      CurrencyFormatter.formatIraqiDinar(
                                        product.compareAtPrice!,
                                      ),
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: AppColors.white.withValues(alpha: 0.8),
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: AppColors.white,
                                        decorationThickness: 2,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                ],
                                // Current Price
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [AppColors.primary, AppColors.secondary],
                                    ),
                                    borderRadius: BorderRadius.circular(12.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    CurrencyFormatter.formatIraqiDinar(product.price),
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: 12.w),

                          // Add to Cart Button
                          AnimatedBuilder(
                            animation: pulseAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: 1.0 + (pulseAnimation.value * 0.05),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFFA500), Color(0xFFFFB84D)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFFA500).withValues(alpha: 0.5),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        getIt<CartCubit>().addItem(
                                          CartItem(
                                            productId: product.id,
                                            vendorId: product.vendorId,
                                            qty: 1,
                                            unitPrice: product.price,
                                          ),
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(tr('added_to_cart')),
                                            duration: const Duration(seconds: 2),
                                            behavior: SnackBarBehavior.floating,
                                          ),
                                        );
                                      },
                                      borderRadius: BorderRadius.circular(16.r),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 20.w,
                                          vertical: 14.h,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.shopping_cart_rounded,
                                              color: AppColors.white,
                                              size: 20.sp,
                                            ),
                                            SizedBox(width: 8.w),
                                            Text(
                                              tr('add_to_cart'),
                                              style: TextStyle(
                                                color: AppColors.white,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
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
