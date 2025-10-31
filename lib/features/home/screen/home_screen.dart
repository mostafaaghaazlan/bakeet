import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bakeet/core/ui/widgets/cached_image.dart';
import 'package:bakeet/core/utils/functions/currency_formatter.dart';
import 'package:bakeet/core/constant/app_colors/app_colors.dart';
import 'package:bakeet/features/marketplace/screen/vendors_list_screen.dart';
import 'package:bakeet/features/marketplace/screen/product_detail_screen.dart';
import 'package:bakeet/features/marketplace/screen/storefront_screen.dart';
import 'package:bakeet/features/marketplace/data/repository/marketplace_repository.dart';
import 'package:bakeet/features/marketplace/data/model/vendor_model.dart';
import 'package:bakeet/features/marketplace/data/model/product_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bakeet/features/marketplace/cubit/vendors_cubit.dart';
import 'package:bakeet/features/marketplace/cubit/storefront_cubit.dart';
import 'package:bakeet/features/marketplace/cubit/cart_cubit.dart';
import 'package:bakeet/core/di/injection.dart';
import 'package:shimmer/shimmer.dart';

/// A stunning, modern e-commerce home page with advanced animations and beautiful design
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final MarketplaceRepository _repo;
  late final ScrollController _scrollController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;
  bool _showSearchBar = false;

  final List<String> _categories = [
    'All',
    'Furniture',
    'Home',
    'Clothing',
    'Decor',
    'Crafts',
  ];
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _repo = MarketplaceRepository();
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();

    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && !_showSearchBar) {
        setState(() => _showSearchBar = true);
      } else if (_scrollController.offset <= 100 && _showSearchBar) {
        setState(() => _showSearchBar = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    context.read<VendorsCubit>().loadVendors();
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => VendorsCubit(_repo)..loadVendors()),
        BlocProvider(create: (_) => StorefrontCubit(_repo)),
      ],
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(context),
        body: Stack(
          children: [
            _buildGradientBackground(context),
            RefreshIndicator(
              onRefresh: _onRefresh,
              color: AppColors.primary,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                  _buildWelcomeSection(),
                  SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                  _buildBannerSection(),
                  SliverToBoxAdapter(child: SizedBox(height: 32.h)),
                  _buildCategoryChips(),
                  SliverToBoxAdapter(child: SizedBox(height: 32.h)),
                  _buildFlashDealsSection(),
                  SliverToBoxAdapter(child: SizedBox(height: 32.h)),
                  _buildVendorsSection(),
                  SliverToBoxAdapter(child: SizedBox(height: 32.h)),
                  _buildProductsSection(),
                  SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                ],
              ),
            ),
            if (_showSearchBar) _buildFloatingSearchBar(),
          ],
        ),
        floatingActionButton: _buildFAB(context),
      ),
    );
  }

  Widget _buildGradientBackground(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary25,
            AppColors.appWhite,
            AppColors.primary50.withValues(alpha: 0.3),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
              ),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.storefront_rounded,
              color: AppColors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            'Bakeet',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24.sp,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.notifications_outlined),
          tooltip: 'Notifications',
        ),
        Stack(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.shopping_cart_outlined),
              tooltip: 'Cart',
            ),
            Positioned(
              right: 8,
              top: 8,
              child: BlocBuilder<CartCubit, CartState>(
                bloc: getIt<CartCubit>(),
                builder: (context, state) {
                  final count = state is CartUpdated ? state.items.length : 0;
                  if (count == 0) return const SizedBox.shrink();
                  return Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16.w,
                      minHeight: 16.h,
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        SizedBox(width: 8.w),
      ],
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.black,
    );
  }

  Widget _buildWelcomeSection() {
    return SliverToBoxAdapter(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back!',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral900,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Discover amazing products from local vendors',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.neutral600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerSection() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 200.h,
        child: BlocBuilder<VendorsCubit, VendorsState>(
          builder: (context, state) {
            if (state is VendorsLoaded) {
              final banners = state.vendors
                  .take(3)
                  .map((v) => (v as VendorModel).bannerUrl)
                  .toList();
              if (banners.isEmpty) return const SizedBox.shrink();
              return _AnimatedBannerCarousel(banners: banners);
            }
            return _buildBannerShimmer();
          },
        ),
      ),
    );
  }

  Widget _buildBannerShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Shimmer.fromColors(
        baseColor: AppColors.neutral200,
        highlightColor: AppColors.neutral100,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 50.h,
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
              curve: Curves.easeInOut,
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
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                elevation: isSelected ? 4 : 0,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.neutral300,
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

  Widget _buildFlashDealsSection() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
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
                  child: Row(
                    children: [
                      Icon(Icons.flash_on, color: AppColors.white, size: 20.sp),
                      SizedBox(width: 4.w),
                      Text(
                        'Flash Deals',
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                _FlashDealTimer(),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 180.h,
            child: BlocBuilder<VendorsCubit, VendorsState>(
              builder: (context, state) {
                if (state is VendorsLoaded) {
                  final vendors = state.vendors.cast<VendorModel>();
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: vendors.take(3).length,
                    separatorBuilder: (_, __) => SizedBox(width: 16.w),
                    itemBuilder: (context, index) {
                      return _FlashDealCard(vendor: vendors[index]);
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorsSection() {
    return SliverToBoxAdapter(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Top Vendors',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral900,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Trusted by thousands',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.neutral600,
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const VendorsListScreen(),
                    ),
                  ),
                  icon: const Text('View all'),
                  label: const Icon(Icons.arrow_forward_rounded, size: 20),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 260.h,
            child: BlocBuilder<VendorsCubit, VendorsState>(
              builder: (context, state) {
                if (state is VendorsLoaded) {
                  final vendors = state.vendors.cast<VendorModel>();
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemBuilder: (context, index) {
                      return _ModernVendorCard(
                        vendor: vendors[index],
                        index: index,
                      );
                    },
                    separatorBuilder: (_, __) => SizedBox(width: 16.w),
                    itemCount: vendors.length,
                  );
                }
                if (state is VendorsLoading) {
                  return _buildVendorShimmer();
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorShimmer() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      itemCount: 3,
      separatorBuilder: (_, __) => SizedBox(width: 16.w),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.neutral200,
        highlightColor: AppColors.neutral100,
        child: Container(
          width: 200.w,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
        ),
      ),
    );
  }

  Widget _buildProductsSection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trending Products',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral900,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Handpicked for you',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.neutral600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          BlocBuilder<VendorsCubit, VendorsState>(
            builder: (context, state) {
              if (state is VendorsLoaded) {
                context.read<StorefrontCubit>().loadAllProducts();
              }
              return const SizedBox.shrink();
            },
          ),
          BlocBuilder<StorefrontCubit, StorefrontState>(
            builder: (context, state) {
              if (state is StorefrontLoaded) {
                final products = state.products.cast<ProductModel>();
                final filteredProducts = _selectedCategory == 'All'
                    ? products
                    : products
                          .where((p) => p.category == _selectedCategory)
                          .toList();

                if (filteredProducts.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(40.r),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64.sp,
                            color: AppColors.neutral400,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No products found',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: AppColors.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16.h,
                    crossAxisSpacing: 16.w,
                    childAspectRatio: 0.68,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    return _StaggeredProductCard(
                      product: filteredProducts[index],
                      index: index,
                    );
                  },
                );
              }
              if (state is StorefrontLoading) {
                return _buildProductShimmer();
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProductShimmer() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16.h,
        crossAxisSpacing: 16.w,
        childAspectRatio: 0.68,
      ),
      itemCount: 4,
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: AppColors.neutral200,
        highlightColor: AppColors.neutral100,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20.r),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingSearchBar() {
    return Positioned(
      top: 60.h,
      left: 20.w,
      right: 20.w,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(28.r),
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search products, vendors...',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              suffixIcon: IconButton(
                icon: const Icon(Icons.tune, color: AppColors.primary),
                onPressed: () {},
              ),
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 16.h,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VendorsListScreen()),
      ),
      label: const Text('Explore'),
      icon: const Icon(Icons.explore_outlined),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      elevation: 8,
      extendedPadding: EdgeInsets.symmetric(horizontal: 24.w),
    );
  }
}

// Animated Banner Carousel with Auto-rotation
class _AnimatedBannerCarousel extends StatefulWidget {
  final List<String> banners;

  const _AnimatedBannerCarousel({required this.banners});

  @override
  State<_AnimatedBannerCarousel> createState() =>
      _AnimatedBannerCarouselState();
}

class _AnimatedBannerCarouselState extends State<_AnimatedBannerCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _startAutoRotate();
  }

  void _startAutoRotate() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_currentPage < widget.banners.length - 1) {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.banners.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.3)).clamp(0.0, 1.0);
                  }
                  return Center(
                    child: SizedBox(
                      height: Curves.easeOut.transform(value) * 200.h,
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
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
                          CachedImage(
                            imageUrl: widget.banners[index],
                            fit: BoxFit.cover,
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  AppColors.black.withValues(alpha: 0.4),
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
            },
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.banners.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              width: _currentPage == index ? 32.w : 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                gradient: _currentPage == index
                    ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
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

// Modern Vendor Card with Gradient
class _ModernVendorCard extends StatelessWidget {
  final VendorModel vendor;
  final int index;

  const _ModernVendorCard({required this.vendor, required this.index});

  @override
  Widget build(BuildContext context) {
    final gradients = [
      [AppColors.primary, AppColors.accent],
      [AppColors.cardPurple, AppColors.cardRed],
      [AppColors.cardGreen, AppColors.cardBlue],
    ];
    final gradient = gradients[index % gradients.length];

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              StorefrontScreen(vendorId: vendor.id, vendorName: vendor.name),
        ),
      ),
      child: Container(
        width: 200.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: -20,
              right: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 36.r,
                      backgroundImage: NetworkImage(vendor.logoUrl),
                      backgroundColor: AppColors.white,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    vendor.name,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      vendor.tagline,
                      style: TextStyle(color: AppColors.white, fontSize: 12.sp),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Icon(Icons.star, color: AppColors.yellow, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text(
                        '4.8',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.white,
                        size: 20.sp,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Staggered Product Card with Animation
class _StaggeredProductCard extends StatefulWidget {
  final ProductModel product;
  final int index;

  const _StaggeredProductCard({required this.product, required this.index});

  @override
  State<_StaggeredProductCard> createState() => _StaggeredProductCardState();
}

class _StaggeredProductCardState extends State<_StaggeredProductCard>
    with SingleTickerProviderStateMixin {
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
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

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
                  color: AppColors.neutral300.withValues(alpha: 0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    Positioned(
                      top: 12.h,
                      left: 12.w,
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite_border,
                          color: AppColors.danger,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
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
                        Text(
                          CurrencyFormatter.formatIraqiDinar(
                            widget.product.price,
                          ),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
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

// Flash Deal Card
class _FlashDealCard extends StatelessWidget {
  final VendorModel vendor;

  const _FlashDealCard({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.danger.withValues(alpha: 0.9),
            AppColors.warning.withValues(alpha: 0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.danger.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Icon(
              Icons.flash_on,
              size: 100.sp,
              color: AppColors.white.withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'UP TO 50% OFF',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                CircleAvatar(
                  radius: 24.r,
                  backgroundImage: NetworkImage(vendor.logoUrl),
                  backgroundColor: AppColors.white,
                ),
                SizedBox(height: 8.h),
                Text(
                  vendor.name,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Flash Deal Timer
class _FlashDealTimer extends StatefulWidget {
  @override
  State<_FlashDealTimer> createState() => _FlashDealTimerState();
}

class _FlashDealTimerState extends State<_FlashDealTimer> {
  late Timer _timer;
  Duration _remaining = const Duration(hours: 2, minutes: 34, seconds: 12);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_remaining.inSeconds > 0) {
            _remaining -= const Duration(seconds: 1);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hours = _remaining.inHours.toString().padLeft(2, '0');
    final minutes = (_remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_remaining.inSeconds % 60).toString().padLeft(2, '0');

    return Row(
      children: [
        Icon(Icons.timer_outlined, color: AppColors.neutral600, size: 18.sp),
        SizedBox(width: 4.w),
        Text(
          '$hours:$minutes:$seconds',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.neutral700,
            fontFeatures: [const FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
