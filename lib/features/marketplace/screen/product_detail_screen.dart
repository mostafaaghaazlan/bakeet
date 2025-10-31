import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bakeet/features/marketplace/data/repository/marketplace_repository.dart';
import 'package:bakeet/features/marketplace/data/model/product_model.dart';
import 'package:bakeet/features/marketplace/cubit/cart_cubit.dart';
import 'package:bakeet/core/ui/widgets/cached_image.dart';
import 'package:bakeet/core/di/injection.dart';
import 'package:bakeet/core/utils/functions/currency_formatter.dart';
import 'package:bakeet/core/constant/app_colors/app_colors.dart';
import 'package:bakeet/features/marketplace/screen/cart_screen.dart';
import 'package:shimmer/shimmer.dart';

/// A stunning product detail screen with image gallery and modern design
class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({Key? key, required this.productId})
      : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  final MarketplaceRepository _repository = MarketplaceRepository();
  ProductModel? _product;
  bool _loading = true;
  bool _isFavorite = false;
  int _quantity = 1;
  int _currentImageIndex = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _loadProduct();
  }

  Future<void> _loadProduct() async {
    final product = await _repository.getProductById(widget.productId);
    setState(() {
      _product = product as ProductModel?;
      _loading = false;
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.appWhite,
      appBar: _buildAppBar(),
      body: _loading ? _buildLoadingState() : _buildProductDetail(),
      bottomNavigationBar: _product != null ? _buildBottomBar() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.neutral900,
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: _isFavorite ? AppColors.danger : AppColors.neutral900,
          ),
          onPressed: () {
            setState(() => _isFavorite = !_isFavorite);
          },
          tooltip: 'Add to Favorites',
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

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: AppColors.neutral200,
            highlightColor: AppColors.neutral100,
            child: Container(
              height: 400.h,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 20.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: List.generate(
                5,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Shimmer.fromColors(
                    baseColor: AppColors.neutral200,
                    highlightColor: AppColors.neutral100,
                    child: Container(
                      height: 20.h,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetail() {
    if (_product == null) {
      return Center(
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
              'Product not found',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.neutral700,
              ),
            ),
          ],
        ),
      );
    }

    final hasDiscount = _product!.compareAtPrice != null;
    final discountPercent = hasDiscount
        ? (((_product!.compareAtPrice! - _product!.price) /
                    _product!.compareAtPrice!) *
                100)
            .round()
        : 0;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageGallery(),
              SizedBox(height: 24.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Title & Tags
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _product!.title,
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.neutral900,
                              height: 1.3,
                            ),
                          ),
                        ),
                        if (hasDiscount)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.danger, AppColors.warning],
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              '-$discountPercent%',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    // Category Tags
                    Wrap(
                      spacing: 8.w,
                      children: _product!.tags.map((tag) {
                        return Chip(
                          label: Text(tag),
                          backgroundColor: AppColors.primary25,
                          labelStyle: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20.h),
                    // Price Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (hasDiscount) ...[
                              Text(
                                CurrencyFormatter.formatIraqiDinar(
                                  _product!.compareAtPrice!,
                                ),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColors.neutral600,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              SizedBox(height: 4.h),
                            ],
                            Text(
                              CurrencyFormatter.formatIraqiDinar(_product!.price),
                              style: TextStyle(
                                fontSize: 32.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Rating
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.warning50,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: AppColors.yellow,
                                size: 20.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '4.8',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.neutral900,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '(127)',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.neutral600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    // Description
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral900,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      _product!.shortDescription,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: AppColors.neutral700,
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    // Features
                    _buildFeaturesList(),
                    SizedBox(height: 24.h),
                    // Quantity Selector
                    _buildQuantitySelector(),
                    SizedBox(height: 120.h), // Space for bottom bar
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    final images = _product!.images.isNotEmpty
        ? _product!.images
        : ['https://via.placeholder.com/400'];

    return Column(
      children: [
        SizedBox(
          height: 400.h,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (index) {
              setState(() => _currentImageIndex = index);
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  // TODO: Open full-screen image viewer
                },
                child: CachedImage(
                  imageUrl: images[index],
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        ),
        if (images.length > 1) ...[
          SizedBox(height: 16.h),
          // Image Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: _currentImageIndex == index ? 32.w : 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  gradient: _currentImageIndex == index
                      ? const LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                        )
                      : null,
                  color: _currentImageIndex == index
                      ? null
                      : AppColors.neutral300,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {'icon': Icons.verified_user_rounded, 'text': 'Authentic Product'},
      {'icon': Icons.local_shipping_outlined, 'text': 'Fast Delivery'},
      {'icon': Icons.replay_rounded, 'text': '7 Days Return'},
      {'icon': Icons.payment_rounded, 'text': 'Secure Payment'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why Buy From Us',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.neutral900,
          ),
        ),
        SizedBox(height: 12.h),
        ...features.map((feature) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: AppColors.primary25,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    feature['icon'] as IconData,
                    color: AppColors.primary,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  feature['text'] as String,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: AppColors.neutral700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.neutral50,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.neutral200, width: 1),
      ),
      child: Row(
        children: [
          Text(
            'Quantity',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral900,
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.neutral300, width: 1),
            ),
            child: Row(
              children: [
                _buildQuantityButton(
                  Icons.remove_rounded,
                  () {
                    if (_quantity > 1) {
                      setState(() => _quantity--);
                    }
                  },
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    '$_quantity',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral900,
                    ),
                  ),
                ),
                _buildQuantityButton(
                  Icons.add_rounded,
                  () {
                    setState(() => _quantity++);
                  },
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
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(12.r),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 20.sp,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final totalPrice = _product!.price * _quantity;

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.neutral300.withOpacity(0.5),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Total Price
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Price',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.neutral600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  CurrencyFormatter.formatIraqiDinar(totalPrice),
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(width: 20.w),
            // Add to Cart Button
            Expanded(
              child: ElevatedButton(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_rounded, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Add to Cart',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart() {
    final cartCubit = getIt<CartCubit>();
    cartCubit.addItem(CartItem(
      productId: _product!.id,
      vendorId: _product!.vendorId,
      qty: _quantity,
      unitPrice: _product!.price,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_product!.title} added to cart ($_quantity items)'),
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
