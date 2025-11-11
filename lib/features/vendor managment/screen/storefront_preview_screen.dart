import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/app_colors/app_colors.dart';
import '../../../core/constant/text_styles/app_text_style.dart';
import '../../../core/ui/widgets/cached_image.dart';
import '../../../core/ui/widgets/custom_button.dart';
import '../../../core/utils/functions/currency_formatter.dart';
import '../../marketplace/data/model/product_model.dart';
import '../../marketplace/data/model/vendor_model.dart';
import '../../marketplace/data/model/vendor_theme.dart';
import '../data/model/vendor_registration_model.dart';

/// Preview screen for vendor storefront before approval
class StorefrontPreviewScreen extends StatelessWidget {
  final String vendorId;
  final VendorRegistrationModel vendorData;
  final VendorModel vendor;
  final List<ProductModel> products;

  const StorefrontPreviewScreen({
    super.key,
    required this.vendorId,
    required this.vendorData,
    required this.vendor,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    final theme = VendorTheme.fromVendor(vendor);

    return Scaffold(
      backgroundColor: AppColors.appWhite,
      body: CustomScrollView(
        slivers: [
          // Preview App Bar with Actions
          SliverAppBar(
            expandedHeight: 80.h,
            pinned: true,
            backgroundColor: theme.primaryColor,
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                'Preview: ${vendor.name}',
                style: AppTextStyle.getSemiBoldStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),

          // Preview Banner
          SliverToBoxAdapter(
            child: Container(
              color: theme.accentColor.withValues(alpha: 0.2),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Icon(Icons.preview, color: theme.primaryColor, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'This is how your storefront will look. Review and approve to publish.',
                      style: AppTextStyle.getRegularStyle(
                        color: theme.primaryColor,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Vendor Header
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  // Logo
                  Container(
                    width: 100.w,
                    height: 100.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.primaryColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withValues(alpha: 0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: vendor.logoUrl.startsWith('http')
                          ? CachedImage(imageUrl: vendor.logoUrl)
                          : Image.file(vendorData.logoFile!, fit: BoxFit.cover),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Vendor Name
                  Text(
                    vendor.name,
                    style: AppTextStyle.getBoldStyle(
                      color: AppColors.neutral900,
                      fontSize: 24.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),

                  // Tagline
                  if (vendor.tagline.isNotEmpty)
                    Text(
                      vendor.tagline,
                      style: AppTextStyle.getRegularStyle(
                        color: AppColors.neutral600,
                        fontSize: 14.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  SizedBox(height: 8.h),

                  // Color Palette Preview
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildColorDot(theme.primaryColor, 'Primary'),
                      SizedBox(width: 12.w),
                      _buildColorDot(theme.secondaryColor, 'Secondary'),
                      SizedBox(width: 12.w),
                      _buildColorDot(theme.accentColor, 'Accent'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Products Section Header
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Text(
                    'Products',
                    style: AppTextStyle.getSemiBoldStyle(
                      color: AppColors.neutral900,
                      fontSize: 18.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${products.length}',
                      style: AppTextStyle.getSemiBoldStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Products Grid
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final product = products[index];
                return _buildProductCard(product, theme);
              }, childCount: products.length),
            ),
          ),

          // Bottom Spacing for Buttons
          SliverToBoxAdapter(child: SizedBox(height: 120.h)),
        ],
      ),

      // Action Buttons
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Cancel',
                  onPressed: () => Navigator.pop(context, false),
                  color: AppColors.neutral300,
                  h: 50.h,
                  radius: 12.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: CustomButton(
                  text: 'Approve & Publish',
                  onPressed: () => _approveAndPublish(context),
                  color: theme.primaryColor,
                  h: 50.h,
                  radius: 12.r,
                  icon: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color, String label) {
    return Column(
      children: [
        Container(
          width: 30.w,
          height: 30.h,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.neutral300, width: 2),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: AppTextStyle.getRegularStyle(
            color: AppColors.neutral400,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product, VendorTheme theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            child: AspectRatio(
              aspectRatio: 1,
              child: product.images.first.startsWith('http')
                  ? CachedImage(imageUrl: product.images.first)
                  : Image.file(
                      vendorData.products
                          .firstWhere((p) => p.id == product.id)
                          .imageFiles
                          .first,
                      fit: BoxFit.cover,
                    ),
            ),
          ),

          // Product Info
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.title,
                    style: AppTextStyle.getMediumStyle(
                      color: AppColors.neutral900,
                      fontSize: 13.sp,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Available Colors
                      if (product.availableColors != null &&
                          product.availableColors!.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        SizedBox(
                          height: 16.h,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: product.availableColors!.length.clamp(
                              0,
                              5,
                            ),
                            separatorBuilder: (_, __) => SizedBox(width: 4.w),
                            itemBuilder: (context, index) {
                              final color = product.availableColors![index];
                              return Container(
                                width: 16.w,
                                height: 16.h,
                                decoration: BoxDecoration(
                                  color: Color(color.colorValue),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.neutral300,
                                    width: 1,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 4.h),
                      ],
                      if (product.compareAtPrice != null &&
                          product.compareAtPrice! > product.price)
                        Text(
                          CurrencyFormatter.formatIraqiDinar(
                            product.compareAtPrice!,
                          ),
                          style: AppTextStyle.getRegularStyle(
                            color: AppColors.neutral400,
                            fontSize: 10.sp,
                          ).copyWith(decoration: TextDecoration.lineThrough),
                        ),
                      Text(
                        CurrencyFormatter.formatIraqiDinar(product.price),
                        style: AppTextStyle.getBoldStyle(
                          color: theme.primaryColor,
                          fontSize: 14.sp,
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
    );
  }

  void _approveAndPublish(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 24.sp),
            SizedBox(width: 8.w),
            Text(
              'Approve Storefront',
              style: AppTextStyle.getSemiBoldStyle(
                color: AppColors.neutral900,
                fontSize: 18.sp,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to approve and publish this storefront? It will be visible to customers immediately.',
          style: AppTextStyle.getRegularStyle(
            color: AppColors.neutral600,
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: AppTextStyle.getMediumStyle(
                color: AppColors.neutral600,
                fontSize: 14.sp,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Close dialog
              Navigator.pop(context, true); // Return true to indicate approval
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Approve',
              style: AppTextStyle.getMediumStyle(
                color: Colors.white,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
