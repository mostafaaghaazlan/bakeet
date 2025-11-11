import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constant/app_colors/app_colors.dart';
import '../../../core/constant/text_styles/app_text_style.dart';
import '../../../core/ui/widgets/custom_text_form_field.dart';
import '../../../core/ui/widgets/upload.dart';
import '../../marketplace/screen/storefront_screen.dart';
import '../cubit/v_vendor_managment_cubit.dart';
import '../data/model/vendor_registration_model.dart';
import '../widget/add_product_dialog.dart';
import '../widget/color_picker_widget.dart';
import '../widget/product_card_widget.dart';
import 'storefront_preview_screen.dart';

class VendorRegistrationScreen extends StatefulWidget {
  const VendorRegistrationScreen({super.key});

  @override
  State<VendorRegistrationScreen> createState() =>
      _VendorRegistrationScreenState();
}

class _VendorRegistrationScreenState extends State<VendorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _taglineController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _logoFile;
  File? _bannerFile;
  File? _backgroundFile;
  Color _primaryColor = const Color(0xFFB91C1C);
  Color _secondaryColor = const Color(0xFFEF4444);
  Color _accentColor = const Color(0xFFFECACA);

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAddProductDialog([ProductRegistrationModel? product, int? index]) {
    // Get the cubit reference BEFORE showing the dialog
    final cubit = context.read<VVendorManagmentCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AddProductDialog(
        product: product,
        onSave: (updatedProduct) {
          debugPrint(
            '🟡 onSave callback called in screen for: ${updatedProduct.title}',
          );
          // Use the cubit reference we got earlier
          if (index != null) {
            debugPrint('🟡 Updating product at index $index');
            cubit.updateProduct(index, updatedProduct);
          } else {
            debugPrint('🟡 Adding new product');
            cubit.addProduct(updatedProduct);
          }
        },
      ),
    );
  }

  void _showColorPicker(
    String title,
    Color initialColor,
    Function(Color) onColorChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        title: title,
        initialColor: initialColor,
        onColorSelected: onColorChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          tr('vendor_registration'),
          style: AppTextStyle.getBoldStyle(
            color: Colors.white,
            fontSize: 20.sp,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary600,
                AppColors.secondary,
              ],
            ),
          ),
        ),
      ),
      body: BlocConsumer<VVendorManagmentCubit, VVendorManagmentState>(
        listener: (context, state) {
          if (state is VendorRegistrationSuccess) {
            // Show preview screen if vendor and products are available
            if (state.vendor != null && state.products != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StorefrontPreviewScreen(
                    vendorId: state.vendorId,
                    vendorData: state.vendorData,
                    vendor: state.vendor!,
                    products: state.products!,
                  ),
                ),
              ).then((approved) async {
                if (approved == true) {
                  // ignore: use_build_context_synchronously
                  final cubit = context.read<VVendorManagmentCubit>();
                  await cubit.approveAndPublishVendor(
                    state.vendorId,
                    state.vendor!,
                    state.products!,
                  );
                }
              });
            }
          } else if (state is VendorPublished) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Navigate to the actual storefront
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => StorefrontScreen(
                  vendorId: state.vendorId,
                  vendorName: state.vendorName,
                ),
              ),
            );
          } else if (state is VendorRegistrationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        buildWhen: (previous, current) {
          // Rebuild for all states except initial
          debugPrint('🟠 BlocConsumer buildWhen: ${current.runtimeType}');
          return true; // Rebuild for all state changes
        },
        builder: (context, state) {
          debugPrint(
            '🟠 BlocConsumer builder called with state: ${state.runtimeType}',
          );
          final cubit = context.read<VVendorManagmentCubit>();
          final isLoading = state is VendorRegistrationLoading;

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20.w,
              right: 20.w,
              top: MediaQuery.of(context).padding.top + 70.h,
              bottom: 24.h,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Modern Hero Header with Gradient Card
                  _buildHeroHeader(),
                  SizedBox(height: 32.h),

                  // Vendor Information Section - Modern Card
                  _buildModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCardHeader(
                          icon: Icons.store_rounded,
                          title: tr('vendor_information'),
                          subtitle: tr('fill_vendor_info'),
                        ),
                        SizedBox(height: 20.h),
                        CustomTextFormField(
                          controller: _nameController,
                          labelText: '${tr('vendor_name')} *',
                          hintText: tr('enter_store_name'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return tr('vendor_name_required');
                            }
                            return null;
                          },
                          onChanged: (value) {
                            cubit.updateVendorInfo(vendorName: value);
                          },
                        ),
                        SizedBox(height: 16.h),
                        CustomTextFormField(
                          controller: _taglineController,
                          labelText: '${tr('tagline')} *',
                          hintText: tr('brief_store_description'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return tr('tagline_required');
                            }
                            return null;
                          },
                          onChanged: (value) {
                            cubit.updateVendorInfo(tagline: value);
                          },
                        ),
                        SizedBox(height: 16.h),
                        CustomTextFormField(
                          controller: _descriptionController,
                          labelText: tr('store_description'),
                          hintText: tr('detailed_store_description'),
                          maxLines: 4,
                          onChanged: (value) {
                            cubit.updateVendorInfo(description: value);
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Visual Assets Section - Modern Card
                  _buildModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCardHeader(
                          icon: Icons.image_rounded,
                          title: tr('store_banner'),
                          subtitle: tr('wide_banner_description'),
                        ),
                        SizedBox(height: 20.h),
                        _buildEnhancedUploadField(
                          hint: tr('upload_banner_image'),
                          file: _bannerFile,
                          aspectRatio: 16 / 9,
                          onSelected: (files) {
                            if (files.isNotEmpty) {
                              setState(() {
                                _bannerFile = files.first.file;
                              });
                              cubit.updateBanner(files.first.file);
                            }
                          },
                        ),
                        SizedBox(height: 24.h),
                        Divider(color: AppColors.neutral200),
                        SizedBox(height: 24.h),
                        _buildCardHeader(
                          icon: Icons.account_circle_rounded,
                          title: '${tr('store_logo')} *',
                          subtitle: tr('store_logo_square'),
                        ),
                        SizedBox(height: 20.h),
                        _buildEnhancedUploadField(
                          hint: tr('store_logo_square'),
                          file: _logoFile,
                          aspectRatio: 1,
                          onSelected: (files) {
                            if (files.isNotEmpty) {
                              setState(() {
                                _logoFile = files.first.file;
                              });
                              cubit.updateLogo(files.first.file);
                            }
                          },
                        ),
                        SizedBox(height: 24.h),
                        Divider(color: AppColors.neutral200),
                        SizedBox(height: 24.h),
                        _buildCardHeader(
                          icon: Icons.wallpaper_rounded,
                          title: tr('background_image'),
                          subtitle: tr('background_pattern_description'),
                        ),
                        SizedBox(height: 20.h),
                        _buildEnhancedUploadField(
                          hint: tr('upload_background_image'),
                          file: _backgroundFile,
                          aspectRatio: 16 / 9,
                          onSelected: (files) {
                            if (files.isNotEmpty) {
                              setState(() {
                                _backgroundFile = files.first.file;
                              });
                              cubit.updateBackground(files.first.file);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Brand Colors Section - Modern Card
                  _buildModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCardHeader(
                          icon: Icons.palette_rounded,
                          title: tr('brand_colors'),
                          subtitle: 'Choose your store\'s color identity',
                        ),
                        SizedBox(height: 20.h),
                        _buildModernColorPicker(
                          label: tr('primary_color'),
                          color: _primaryColor,
                          icon: Icons.star_rounded,
                          onTap: () => _showColorPicker(
                            tr('select_primary_color'),
                            _primaryColor,
                            (color) {
                              setState(() => _primaryColor = color);
                              cubit.updateVendorInfo(
                                primaryColor: color.toARGB32(),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildModernColorPicker(
                          label: tr('secondary_color'),
                          color: _secondaryColor,
                          icon: Icons.auto_awesome_rounded,
                          onTap: () => _showColorPicker(
                            tr('select_secondary_color'),
                            _secondaryColor,
                            (color) {
                              setState(() => _secondaryColor = color);
                              cubit.updateVendorInfo(
                                secondaryColor: color.toARGB32(),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildModernColorPicker(
                          label: tr('accent_color'),
                          color: _accentColor,
                          icon: Icons.brush_rounded,
                          onTap: () => _showColorPicker(
                            tr('select_accent_color'),
                            _accentColor,
                            (color) {
                              setState(() => _accentColor = color);
                              cubit.updateVendorInfo(
                                accentColor: color.toARGB32(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Products Section - Modern Card
                  _buildModernCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: _buildCardHeader(
                                icon: Icons.inventory_2_rounded,
                                title: '${tr('vendor_products')} *',
                                subtitle: tr('add_one_vendor_product'),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primary600,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _showAddProductDialog(),
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 12.h,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.add_circle_rounded,
                                          color: Colors.white,
                                          size: 20.sp,
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          tr('add_vendor_product'),
                                          style: AppTextStyle.getSemiBoldStyle(
                                            color: Colors.white,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        // Products List
                        BlocBuilder<
                          VVendorManagmentCubit,
                          VVendorManagmentState
                        >(
                          buildWhen: (previous, current) {
                            // Rebuild when products are added, updated, removed, or data is updated
                            final shouldRebuild =
                                current is ProductAdded ||
                                current is ProductUpdated ||
                                current is ProductRemoved ||
                                current is VendorDataUpdated;
                            debugPrint(
                              '🟣 BlocBuilder buildWhen: shouldRebuild=$shouldRebuild, state=${current.runtimeType}',
                            );
                            return shouldRebuild;
                          },
                          builder: (context, state) {
                            final currentCubit = context
                                .read<VVendorManagmentCubit>();
                            final products = currentCubit.vendorData.products;
                            debugPrint(
                              '🟣 BlocBuilder building with ${products.length} products',
                            );
                            if (products.isEmpty) {
                              return Container(
                                padding: EdgeInsets.all(32.h),
                                decoration: BoxDecoration(
                                  color: AppColors.neutral100,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(
                                    color: AppColors.neutral300,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.inventory_2_outlined,
                                        size: 48.sp,
                                        color: AppColors.neutral400,
                                      ),
                                      SizedBox(height: 12.h),
                                      Text(
                                        tr('no_vendor_products_added'),
                                        style: AppTextStyle.getMediumStyle(
                                          color: AppColors.neutral600,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        tr('add_one_vendor_product'),
                                        style: AppTextStyle.getRegularStyle(
                                          color: AppColors.neutral400,
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: products.length,
                              separatorBuilder: (context, index) =>
                                  SizedBox(height: 12.h),
                              itemBuilder: (context, index) {
                                final product = products[index];
                                return ProductCardWidget(
                                  product: product,
                                  onEdit: () =>
                                      _showAddProductDialog(product, index),
                                  onDelete: () => cubit.removeProduct(index),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Submit Button - Modern Gradient
                  _buildModernSubmitButton(isLoading, cubit),

                  SizedBox(height: 16.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildModernSubmitButton(bool isLoading, VVendorManagmentCubit cubit) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isLoading
              ? [AppColors.neutral400, AppColors.neutral600]
              : [AppColors.primary, AppColors.primary600, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: isLoading
            ? []
            : [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    cubit.submitVendorRegistration();
                  }
                },
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            height: 60.h,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        tr('vendor_submitting'),
                        style: AppTextStyle.getSemiBoldStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.rocket_launch_rounded,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        tr('submit_vendor_registration'),
                        style: AppTextStyle.getBoldStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // Modern Card Container
  Widget _buildModernCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(24.w),
      child: child,
    );
  }

  // Hero Header
  Widget _buildHeroHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(24.w),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primary600],
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              Icons.storefront_rounded,
              color: Colors.white,
              size: 32.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('become_vendor'),
                  style: AppTextStyle.getBoldStyle(
                    color: AppColors.neutral900,
                    fontSize: 22.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  tr('fill_vendor_info'),
                  style: AppTextStyle.getRegularStyle(
                    color: AppColors.neutral600,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Card Header
  Widget _buildCardHeader({
    required IconData icon,
    required String title,
    String? subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.15),
                AppColors.secondary.withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 24.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyle.getSemiBoldStyle(
                  color: AppColors.neutral900,
                  fontSize: 16.sp,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: AppTextStyle.getRegularStyle(
                    color: AppColors.neutral600,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // Enhanced Upload Field
  Widget _buildEnhancedUploadField({
    required String hint,
    required File? file,
    required double aspectRatio,
    required Function(List<SmartPickedFile>) onSelected,
  }) {
    return SmartUploadField(
      hint: hint,
      allowedTypes: const SmartAllowedTypes(images: true),
      maxSizeInMB: 5,
      initialPreview: file != null ? FileImage(file) : null,
      onSelected: onSelected,
    );
  }

  // Modern Color Picker
  Widget _buildModernColorPicker({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.neutral50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.neutral200, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: AppTextStyle.getMediumStyle(
                  color: AppColors.neutral800,
                  fontSize: 14.sp,
                ),
              ),
            ),
            Container(
              width: 60.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.edit_rounded, color: AppColors.neutral400, size: 20.sp),
          ],
        ),
      ),
    );
  }
}
