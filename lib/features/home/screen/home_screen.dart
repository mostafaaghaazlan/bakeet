import 'dart:async';
import 'package:bakeet/core/utils/Navigation/navigation.dart';
import 'package:bakeet/features/marketplace/screen/cart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bakeet/core/ui/widgets/cached_image.dart';
import 'package:bakeet/core/ui/widgets/logo_widget.dart';
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
  bool _showSearchBar = false;
  final TextEditingController _searchController = TextEditingController();
  // selected filter for searches
  String _searchFilter = 'All';

  final List<String> _categories = [
    'All',
    'Furniture',
    'Home',
    'Clothing',
    'Decor',
    'Crafts',
  ];
  String _selectedCategory = 'All';

  String _catLabel(String cat) {
    switch (cat) {
      case 'All':
        return tr('all');
      case 'Furniture':
        return tr('tag_furniture');
      case 'Home':
        return tr('category_home');
      case 'Clothing':
        return tr('tag_clothing');
      case 'Decor':
        return tr('tag_decor');
      case 'Crafts':
        return tr('crafts');
      default:
        return cat;
    }
  }

  @override
  void initState() {
    super.initState();
    _repo = MarketplaceRepository();
    _scrollController = ScrollController();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
    _searchController.dispose();
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
            AppColors.secondary.withValues(alpha: 0.08),
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
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            // Use the app logo widget for a consistent brand mark
            child: SizedBox(
              width: 46.w,
              height: 34.h,
              child: FittedBox(
                fit: BoxFit.contain,
                child: LogoWidget(height: 34.h, width: 46.w),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            tr('app_name_arabic'),
            style: TextStyle(
              color: AppColors.neutral400,
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
          tooltip: tr('notifications'),
        ),
        Stack(
          children: [
            IconButton(
              onPressed: () {
                Navigation.push(CartScreen());
              },
              icon: const Icon(Icons.shopping_bag),
              tooltip: tr('cart_screen'),
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
                label: Text(_catLabel(category)),
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
                        tr('flash_deals'),
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
                      tr('top_vendors'),
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.neutral900,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      tr('trusted_by_thousands'),
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
                  icon: Text(tr('view_all')),
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
              // mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr('trending_products'),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral900,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  tr('handpicked_for_you'),
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
                            tr('no_products_found'),
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
                    childAspectRatio: 0.6,
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
    // compute top offset to place the search bar below the status bar and AppBar
    final double topOffset =
        MediaQuery.of(context).padding.top + kToolbarHeight + 8.h;

    return Positioned(
      top: topOffset,
      left: 20.w,
      right: 20.w,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28.r),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.white.withValues(alpha: 0.95),
                AppColors.white.withValues(alpha: 0.9),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.neutral900,
                fontWeight: FontWeight.w500,
              ),
              onSubmitted: (value) async {
                if (value.trim().isEmpty) return;
                await _performCombinedSearch(
                  value.trim(),
                  initialFilter: _searchFilter,
                );
              },
              onChanged: (value) {
                // Optional: Add debounced search here
              },
              decoration: InputDecoration(
                hintText: tr('search_products'),
                hintStyle: TextStyle(
                  fontSize: 15.sp,
                  color: AppColors.neutral400,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Container(
                  margin: EdgeInsets.all(12.r),
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.search_rounded,
                    color: AppColors.white,
                    size: 20.sp,
                  ),
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColors.neutral400,
                          size: 20.sp,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      ),
                    IconButton(
                      icon: Icon(
                        Icons.tune_rounded,
                        color: AppColors.primary,
                        size: 20.sp,
                      ),
                      onPressed: () async {
                        // show filter picker and apply
                        final chosen = await showModalBottomSheet<String>(
                          context: context,
                          backgroundColor: AppColors.appWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16.r),
                            ),
                          ),
                          builder: (ctx) {
                            return Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 16.h,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    tr('filter_results'),
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: ['All', 'Products', 'Vendors']
                                        .map((f) {
                                          final selected = f == _searchFilter;
                                          return ElevatedButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, f),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: selected
                                                  ? AppColors.primary
                                                  : AppColors.neutral100,
                                              foregroundColor: selected
                                                  ? AppColors.white
                                                  : AppColors.neutral700,
                                              elevation: selected ? 4 : 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                              ),
                                            ),
                                            child: Text(tr(f.toLowerCase())),
                                          );
                                        })
                                        .toList(),
                                  ),
                                  SizedBox(height: 12.h),
                                ],
                              ),
                            );
                          },
                        );

                        if (chosen != null) {
                          setState(() => _searchFilter = chosen);
                          final q = _searchController.text.trim();
                          await _performCombinedSearch(
                            q,
                            initialFilter: chosen,
                          );
                        }
                      },
                    ),
                  ],
                ),
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28.r),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28.r),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28.r),
                  borderSide: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 16.h,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _performCombinedSearch(
    String query, {
    String? initialFilter,
  }) async {
    // Show modern search results modal immediately
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SearchResultsSheet(
        query: query,
        repo: _repo,
        initialFilter: initialFilter,
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    // Use a decorated container to show a purple->teal gradient behind the FAB
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VendorsListScreen()),
        ),
        label: const Text('explore_vendors').tr(),
        icon: const Icon(Icons.explore_outlined),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.white,
        extendedPadding: EdgeInsets.symmetric(horizontal: 24.w),
      ),
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

// Modern Vendor Card with Gradient
class _ModernVendorCard extends StatelessWidget {
  final VendorModel vendor;
  final int index;

  const _ModernVendorCard({required this.vendor, required this.index});

  @override
  Widget build(BuildContext context) {
    final gradients = [
      [AppColors.primary, AppColors.secondary],
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
                Flexible(
                  fit: FlexFit.loose,
                  child: Padding(
                    padding: EdgeInsets.all(12.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.product.title,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.neutral900,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),
                        if (hasDiscount) ...[
                          Text(
                            CurrencyFormatter.formatIraqiDinar(
                              widget.product.compareAtPrice!,
                            ),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.neutral600,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          SizedBox(height: 2.h),
                        ],
                        Text(
                          CurrencyFormatter.formatIraqiDinar(
                            widget.product.price,
                          ),
                          style: TextStyle(
                            fontSize: 14.sp,
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
                    tr('up_to_50_off'),
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

// Modern Search Results Sheet

class _SearchResultsSheet extends StatefulWidget {
  final String query;
  final MarketplaceRepository repo;
  final String? initialFilter;

  const _SearchResultsSheet({
    required this.query,
    required this.repo,
    this.initialFilter,
  });

  @override
  State<_SearchResultsSheet> createState() => _SearchResultsSheetState();
}

class _SearchResultsSheetState extends State<_SearchResultsSheet>
    with SingleTickerProviderStateMixin {
  List<ProductModel> _matchedProducts = [];
  List<VendorModel> _matchedVendors = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    // apply any initial filter from caller
    if (widget.initialFilter != null) {
      _selectedFilter = widget.initialFilter!;
    }
    _performSearch();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    setState(() => _isLoading = true);

    final q = widget.query.toLowerCase();
    final products = await widget.repo.getAllProducts();
    final vendors = await widget.repo.getVendors();

    final matchedProducts = products.where((p) {
      final title = p.title.toLowerCase();
      final desc = p.shortDescription.toLowerCase();
      final tags = p.tags.map((t) => t.toLowerCase()).toList();
      return title.contains(q) ||
          desc.contains(q) ||
          tags.any((t) => t.contains(q));
    }).toList();

    final matchedVendors = vendors.where((v) {
      return v.name.toLowerCase().contains(q) ||
          v.tagline.toLowerCase().contains(q);
    }).toList();

    if (mounted) {
      setState(() {
        _matchedProducts = matchedProducts.cast<ProductModel>();
        _matchedVendors = matchedVendors.cast<VendorModel>();
        _isLoading = false;
      });
      _animationController.forward();
    }
  }

  List<dynamic> get _filteredResults {
    switch (_selectedFilter) {
      case 'Products':
        return _matchedProducts;
      case 'Vendors':
        return _matchedVendors;
      default:
        return [..._matchedProducts, ..._matchedVendors];
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.neutral25,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHandle(),
              _buildHeader(),
              _buildFilterChips(),
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _filteredResults.isEmpty
                    ? _buildEmptyState()
                    : _buildResultsList(scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
      width: 40.w,
      height: 4.h,
      decoration: BoxDecoration(
        color: AppColors.neutral300,
        borderRadius: BorderRadius.circular(2.r),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 16.w, 16.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('search_results'),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral900,
                  ),
                ),
                SizedBox(height: 4.h),
                if (!_isLoading)
                  Text(
                    tr(
                      'results_for_query',
                      args: [
                        '${_matchedProducts.length + _matchedVendors.length}',
                        widget.query,
                      ],
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.neutral600,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.neutral200,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.close_rounded, color: AppColors.neutral700),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Products', 'Vendors'];
    return Container(
      height: 50.h,
      margin: EdgeInsets.only(bottom: 16.h),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        itemCount: filters.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = _selectedFilter == filter;
          int count = 0;
          if (filter == 'Products') {
            count = _matchedProducts.length;
          } else if (filter == 'Vendors') {
            count = _matchedVendors.length;
          } else {
            count = _matchedProducts.length + _matchedVendors.length;
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(filter),
                  if (count > 0) ...[
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.white.withValues(alpha: 0.3)
                            : AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.white
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() => _selectedFilter = filter);
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
              shadowColor: AppColors.primary.withValues(alpha: 0.3),
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
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Searching...',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.neutral700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            tr('please_wait_search'),
            style: TextStyle(fontSize: 14.sp, color: AppColors.neutral600),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32.r),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 64.sp,
                color: AppColors.neutral400,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              tr('no_results_found'),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.neutral900,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'We couldn\'t find anything matching "${widget.query}"',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.neutral600),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.refresh_rounded),
              label: Text(tr('try_another_search')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(ScrollController controller) {
    return FadeTransition(
      opacity: _animationController,
      child: ListView.separated(
        controller: controller,
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
        itemCount: _filteredResults.length,
        separatorBuilder: (_, __) => SizedBox(height: 16.h),
        itemBuilder: (context, index) {
          final item = _filteredResults[index];
          if (item is ProductModel) {
            return _buildProductCard(item, index);
          } else if (item is VendorModel) {
            return _buildVendorCard(item, index);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProductCard(ProductModel product, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 50)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value.clamp(0.0, 1.0)),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        elevation: 2,
        shadowColor: AppColors.neutral300.withValues(alpha: 0.5),
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ProductDetailScreen(productId: product.id),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            padding: EdgeInsets.all(12.r),
            child: Row(
              children: [
                Hero(
                  tag: 'product-${product.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      width: 100.w,
                      height: 100.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.1),
                            AppColors.accent.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                      child: product.images.isNotEmpty
                          ? CachedImage(
                              imageUrl: product.images.first,
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.image_outlined,
                              size: 40.sp,
                              color: AppColors.neutral400,
                            ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neutral900,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        product.shortDescription,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.neutral600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withValues(alpha: 0.15),
                                  AppColors.accent.withValues(alpha: 0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              CurrencyFormatter.formatIraqiDinar(product.price),
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16.sp,
                            color: AppColors.neutral400,
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

  Widget _buildVendorCard(VendorModel vendor, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 50)),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value.clamp(0.0, 1.0)),
          child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => StorefrontScreen(
                  vendorId: vendor.id,
                  vendorName: vendor.name,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  vendor.primaryColor.withValues(alpha: 0.9),
                  vendor.secondaryColor.withValues(alpha: 0.9),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: vendor.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Hero(
                  tag: 'vendor-${vendor.id}',
                  child: Container(
                    padding: EdgeInsets.all(3.r),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 30.r,
                      backgroundImage: NetworkImage(vendor.logoUrl),
                      backgroundColor: AppColors.white,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor.name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: vendor.textColor ?? AppColors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        vendor.tagline,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: (vendor.textColor ?? AppColors.white)
                              .withValues(alpha: 0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: vendor.textColor ?? AppColors.white,
                  size: 24.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
