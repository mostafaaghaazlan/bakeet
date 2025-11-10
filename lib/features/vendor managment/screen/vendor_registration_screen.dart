import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constant/app_colors/app_colors.dart';
import '../../../core/constant/text_styles/app_text_style.dart';
import '../../../core/ui/widgets/custom_button.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(tr('vendor_registration')),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
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
                  // User approved, now publish the vendor
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
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Text(
                    tr('become_vendor'),
                    style: AppTextStyle.getBoldStyle(
                      color: AppColors.neutral900,
                      fontSize: 24.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    tr('fill_vendor_info'),
                    style: AppTextStyle.getRegularStyle(
                      color: AppColors.neutral600,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Vendor Information Section
                  _buildSectionTitle(tr('vendor_information')),
                  SizedBox(height: 16.h),

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
                  SizedBox(height: 24.h),

                  // Logo Upload Section
                  _buildSectionTitle('${tr('store_logo')} *'),
                  SizedBox(height: 12.h),
                  SmartUploadField(
                    hint: tr('store_logo_square'),
                    allowedTypes: const SmartAllowedTypes(images: true),
                    maxSizeInMB: 5,
                    initialPreview: _logoFile != null
                        ? FileImage(_logoFile!)
                        : null,
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

                  // Banner Upload Section
                  _buildSectionTitle(tr('store_banner')),
                  SizedBox(height: 8.h),
                  Text(
                    tr('wide_banner_description'),
                    style: AppTextStyle.getRegularStyle(
                      color: AppColors.neutral600,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SmartUploadField(
                    hint: tr('upload_banner_image'),
                    allowedTypes: const SmartAllowedTypes(images: true),
                    maxSizeInMB: 5,
                    initialPreview: _bannerFile != null
                        ? FileImage(_bannerFile!)
                        : null,
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

                  // Background Upload Section
                  _buildSectionTitle(tr('background_image')),
                  SizedBox(height: 8.h),
                  Text(
                    tr('background_pattern_description'),
                    style: AppTextStyle.getRegularStyle(
                      color: AppColors.neutral600,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SmartUploadField(
                    hint: tr('upload_background_image'),
                    allowedTypes: const SmartAllowedTypes(images: true),
                    maxSizeInMB: 5,
                    initialPreview: _backgroundFile != null
                        ? FileImage(_backgroundFile!)
                        : null,
                    onSelected: (files) {
                      if (files.isNotEmpty) {
                        setState(() {
                          _backgroundFile = files.first.file;
                        });
                        cubit.updateBackground(files.first.file);
                      }
                    },
                  ),
                  SizedBox(height: 24.h),

                  // Brand Colors Section
                  _buildSectionTitle(tr('brand_colors')),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildColorOption(
                          tr('primary_color'),
                          _primaryColor,
                          () => _showColorPicker(
                            tr('select_primary_color'),
                            _primaryColor,
                            (color) {
                              setState(() => _primaryColor = color);
                              cubit.updateVendorInfo(primaryColor: color.value);
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildColorOption(
                          tr('secondary_color'),
                          _secondaryColor,
                          () => _showColorPicker(
                            tr('select_secondary_color'),
                            _secondaryColor,
                            (color) {
                              setState(() => _secondaryColor = color);
                              cubit.updateVendorInfo(
                                secondaryColor: color.value,
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildColorOption(
                          tr('accent_color'),
                          _accentColor,
                          () => _showColorPicker(
                            tr('select_accent_color'),
                            _accentColor,
                            (color) {
                              setState(() => _accentColor = color);
                              cubit.updateVendorInfo(accentColor: color.value);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // Products Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('${tr('vendor_products')} *'),
                      TextButton.icon(
                        onPressed: () => _showAddProductDialog(),
                        icon: const Icon(Icons.add),
                        label: Text(tr('add_vendor_product')),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),

                  // Products List
                  BlocBuilder<VVendorManagmentCubit, VVendorManagmentState>(
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
                            onEdit: () => _showAddProductDialog(product, index),
                            onDelete: () => cubit.removeProduct(index),
                          );
                        },
                      );
                    },
                  ),

                  SizedBox(height: 32.h),

                  // Submit Button
                  CustomButton(
                    text: isLoading ? tr('vendor_submitting') : tr('submit_vendor_registration'),
                    onPressed: isLoading
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              cubit.submitVendorRegistration();
                            }
                          },
                    color: AppColors.primary,
                    h: 56.h,
                    radius: 12.r,
                  ),

                  SizedBox(height: 16.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyle.getSemiBoldStyle(
        color: AppColors.neutral900,
        fontSize: 18.sp,
      ),
    );
  }

  Widget _buildColorOption(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.neutral100,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.neutral300),
        ),
        child: Column(
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.neutral300, width: 2),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: AppTextStyle.getRegularStyle(
                color: AppColors.neutral700,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
