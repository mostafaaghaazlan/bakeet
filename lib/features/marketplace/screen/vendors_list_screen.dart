import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bakeet/core/ui/widgets/cached_image.dart';
import 'package:bakeet/core/constant/app_colors/app_colors.dart';
import 'package:bakeet/features/marketplace/cubit/vendors_cubit.dart';
import 'package:bakeet/features/marketplace/data/repository/marketplace_repository.dart';
import 'package:bakeet/features/marketplace/data/model/vendor_model.dart';
import 'package:bakeet/features/marketplace/screen/storefront_screen.dart';
import 'package:shimmer/shimmer.dart';

/// A stunning, modern vendors list screen with search, filters, and beautiful animations
class VendorsListScreen extends StatefulWidget {
  const VendorsListScreen({super.key});

  @override
  State<VendorsListScreen> createState() => _VendorsListScreenState();
}

class _VendorsListScreenState extends State<VendorsListScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  bool _isGridView = true;

  final List<String> _filters = ['All', 'Popular', 'New', 'Top Rated'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<VendorModel> _filterVendors(List<VendorModel> vendors) {
    var filtered = vendors;

    // Search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (v) =>
                v.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                v.tagline.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Category filter (simplified - in real app would filter by actual data)
    // For now, just return all as we don't have category data

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VendorsCubit(MarketplaceRepository())..loadVendors(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: _buildAppBar(context),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.primary25, AppColors.appWhite],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildSearchBar(),
                SizedBox(height: 16.h),
                _buildFilterChips(),
                SizedBox(height: 16.h),
                Expanded(
                  child: BlocBuilder<VendorsCubit, VendorsState>(
                    builder: (context, state) {
                      if (state is VendorsLoading) {
                        return _buildShimmerLoading();
                      }

                      if (state is VendorsLoaded) {
                        final vendors = state.vendors.cast<VendorModel>();
                        final filteredVendors = _filterVendors(vendors);

                        if (filteredVendors.isEmpty) {
                          return _buildEmptyState();
                        }

                        return _isGridView
                            ? _buildGridView(filteredVendors)
                            : _buildListView(filteredVendors);
                      }

                      if (state is VendorsError) {
                        return _buildErrorState(state.message);
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.neutral900,
      title: Text(
        'Explore Vendors',
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24.sp),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
            size: 24.sp,
          ),
          onPressed: () {
            setState(() => _isGridView = !_isGridView);
          },
          tooltip: _isGridView ? 'List View' : 'Grid View',
        ),
        IconButton(
          icon: Icon(Icons.filter_list_rounded, size: 24.sp),
          onPressed: () => _showFilterBottomSheet(context),
          tooltip: 'Filters',
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(28.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
          decoration: InputDecoration(
            hintText: 'Search vendors...',
            hintStyle: TextStyle(color: AppColors.neutral400, fontSize: 16.sp),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.primary,
              size: 24.sp,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: AppColors.neutral600,
                      size: 20.sp,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 16.h,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 45.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: ChoiceChip(
              label: Text(filter),
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
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              elevation: isSelected ? 4 : 0,
              shadowColor: AppColors.primary.withValues(alpha: 0.4),
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

  Widget _buildGridView(List<VendorModel> vendors) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.75,
      ),
      itemCount: vendors.length,
      itemBuilder: (context, index) {
        return _AnimatedVendorCard(vendor: vendors[index], index: index);
      },
    );
  }

  Widget _buildListView(List<VendorModel> vendors) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      physics: const BouncingScrollPhysics(),
      itemCount: vendors.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        return _AnimatedVendorListCard(vendor: vendors[index], index: index);
      },
    );
  }

  Widget _buildShimmerLoading() {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.75,
      ),
      itemCount: 6,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.store_outlined, size: 80.sp, color: AppColors.neutral400),
          SizedBox(height: 16.h),
          Text(
            'No vendors found',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(fontSize: 14.sp, color: AppColors.neutral600),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
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
            'Oops! Something went wrong',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.neutral700,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppColors.neutral600),
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () {
              context.read<VendorsCubit>().loadVendors();
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
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.neutral900,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'Sort By',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.neutral700,
              ),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return FilterChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedFilter = filter);
                    Navigator.pop(context);
                  },
                  backgroundColor: AppColors.white,
                  selectedColor: AppColors.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.white : AppColors.neutral700,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

// Animated Vendor Card for Grid View
class _AnimatedVendorCard extends StatefulWidget {
  final VendorModel vendor;
  final int index;

  const _AnimatedVendorCard({required this.vendor, required this.index});

  @override
  State<_AnimatedVendorCard> createState() => _AnimatedVendorCardState();
}

class _AnimatedVendorCardState extends State<_AnimatedVendorCard>
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
    final gradients = [
      [AppColors.primary, AppColors.accent],
      [AppColors.cardPurple, AppColors.cardRed],
      [AppColors.cardGreen, AppColors.cardBlue],
      [AppColors.cardOrange, AppColors.warning],
    ];
    final gradient = gradients[widget.index % gradients.length];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StorefrontScreen(
                vendorId: widget.vendor.id,
                vendorName: widget.vendor.name,
              ),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Stack(
                children: [
                  // Banner Image
                  Positioned.fill(
                    child: CachedImage(
                      imageUrl: widget.vendor.bannerUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Gradient Overlay
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Logo
                  Positioned(
                    top: 16.h,
                    left: 16.w,
                    child: Container(
                      padding: EdgeInsets.all(4.r),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 28.r,
                        backgroundImage: NetworkImage(widget.vendor.logoUrl),
                        backgroundColor: AppColors.white,
                      ),
                    ),
                  ),
                  // Verified Badge
                  Positioned(
                    top: 16.h,
                    right: 16.w,
                    child: Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.verified_rounded,
                        color: AppColors.white,
                        size: 16.sp,
                      ),
                    ),
                  ),
                  // Vendor Info
                  Positioned(
                    left: 16.w,
                    right: 16.w,
                    bottom: 16.h,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.vendor.name,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          widget.vendor.tagline,
                          style: TextStyle(
                            color: AppColors.white.withValues(alpha: 0.9),
                            fontSize: 12.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: AppColors.yellow,
                              size: 16.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '4.8',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              width: 4.w,
                              height: 4.h,
                              decoration: BoxDecoration(
                                color: AppColors.white.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.local_shipping_outlined,
                              color: AppColors.white.withValues(alpha: 0.9),
                              size: 14.sp,
                            ),
                            SizedBox(width: 4.w),
                            // Make the label flexible to avoid overflow on narrow cards
                            Flexible(
                              fit: FlexFit.loose,
                              child: Text(
                                'Fast Delivery',
                                style: TextStyle(
                                  color: AppColors.white.withValues(alpha: 0.9),
                                  fontSize: 12.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
      ),
    );
  }
}

// Animated Vendor Card for List View
class _AnimatedVendorListCard extends StatefulWidget {
  final VendorModel vendor;
  final int index;

  const _AnimatedVendorListCard({required this.vendor, required this.index});

  @override
  State<_AnimatedVendorListCard> createState() =>
      _AnimatedVendorListCardState();
}

class _AnimatedVendorListCardState extends State<_AnimatedVendorListCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StorefrontScreen(
                vendorId: widget.vendor.id,
                vendorName: widget.vendor.name,
              ),
            ),
          ),
          child: Container(
            height: 140.h,
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
            child: Row(
              children: [
                // Banner Image
                ClipRRect(
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(20.r),
                  ),
                  child: SizedBox(
                    width: 120.w,
                    height: double.infinity,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CachedImage(
                            imageUrl: widget.vendor.bannerUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Colors.transparent,
                                  AppColors.black.withValues(alpha: 0.3),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Vendor Info
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24.r,
                              backgroundImage: NetworkImage(
                                widget.vendor.logoUrl,
                              ),
                              backgroundColor: AppColors.white,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          widget.vendor.name,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.neutral900,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Icon(
                                        Icons.verified_rounded,
                                        color: AppColors.success,
                                        size: 18.sp,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    widget.vendor.tagline,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.neutral600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: AppColors.yellow,
                              size: 16.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '4.8',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.neutral700,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary25,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.local_shipping_outlined,
                                    color: AppColors.primary,
                                    size: 14.sp,
                                  ),
                                  SizedBox(width: 4.w),
                                  // Make label flexible to avoid overflow
                                  Flexible(
                                    fit: FlexFit.loose,
                                    child: Text(
                                      'Fast',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: AppColors.neutral400,
                              size: 16.sp,
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
