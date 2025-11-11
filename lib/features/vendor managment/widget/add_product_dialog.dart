import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/constant/app_colors/app_colors.dart';
import '../../../core/constant/text_styles/app_text_style.dart';
import '../../../core/ui/widgets/custom_text_form_field.dart';
import '../../../core/ui/widgets/upload.dart';
import '../data/model/vendor_registration_model.dart';
import 'color_picker_widget.dart';

class AddProductDialog extends StatefulWidget {
  final ProductRegistrationModel? product;
  final Function(ProductRegistrationModel) onSave;

  const AddProductDialog({super.key, this.product, required this.onSave});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _comparePriceController = TextEditingController();
  final _categoryController = TextEditingController();
  final _tagsController = TextEditingController();

  List<File> _productImages = [];
  List<ColorOption> _selectedColors = [];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _titleController.text = widget.product!.title;
      _shortDescController.text = widget.product!.shortDescription;
      _descController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _comparePriceController.text =
          widget.product!.compareAtPrice?.toString() ?? '';
      _categoryController.text = widget.product!.category;
      _tagsController.text = widget.product!.tags.join(', ');
      _productImages = List.from(widget.product!.imageFiles);
      _selectedColors = List.from(widget.product!.availableColors);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _shortDescController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _comparePriceController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _addColor() async {
    // First, show color picker
    Color? selectedColor;
    await showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        title: tr('select_product_color'),
        initialColor: Colors.blue,
        onColorSelected: (color) {
          selectedColor = color;
        },
      ),
    );

    // If color was selected, ask for name
    if (selectedColor != null && mounted) {
      final nameController = TextEditingController();
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            tr('name_this_color'),
            style: AppTextStyle.getSemiBoldStyle(
              color: AppColors.neutral900,
              fontSize: 18.sp,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Color preview
              Container(
                width: double.infinity,
                height: 60.h,
                decoration: BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.neutral300, width: 2),
                ),
                child: Center(
                  child: Text(
                    '#${selectedColor!.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                    style: AppTextStyle.getSemiBoldStyle(
                      color: selectedColor!.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              CustomTextFormField(
                controller: nameController,
                labelText: tr('vendor_color_name'),
                hintText: tr('vendor_color_name_placeholder'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                tr('cancel'),
                style: AppTextStyle.getMediumStyle(
                  color: AppColors.neutral600,
                  fontSize: 14.sp,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primary600],
                ),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (nameController.text.isNotEmpty) {
                      Navigator.pop(context, true);
                    }
                  },
                  borderRadius: BorderRadius.circular(8.r),
                  child: Container(
                    width: 80.w,
                    height: 40.h,
                    alignment: Alignment.center,
                    child: Text(
                      tr('add'),
                      style: AppTextStyle.getSemiBoldStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true && nameController.text.isNotEmpty) {
        debugPrint(
          '🎨 Color selected: ${nameController.text} with value ${selectedColor!.toARGB32()}',
        );
        setState(() {
          _selectedColors.add(
            ColorOption(
              name: nameController.text,
              colorValue: selectedColor!.toARGB32(),
            ),
          );
          debugPrint('🎨 Total colors after add: ${_selectedColors.length}');
        });
      }
      nameController.dispose();
    }
  }

  void _saveProduct() {
    debugPrint('🟢 Save product called');
    if (_formKey.currentState!.validate()) {
      debugPrint('🟢 Form validated successfully');
      debugPrint('🎨 Saving product with ${_selectedColors.length} colors');
      if (_selectedColors.isNotEmpty) {
        debugPrint(
          '🎨 Colors: ${_selectedColors.map((c) => '${c.name}(${c.colorValue})').join(', ')}',
        );
      }
      final product = ProductRegistrationModel(
        id: widget.product?.id ?? DateTime.now().toString(),
        title: _titleController.text,
        description: _descController.text,
        shortDescription: _shortDescController.text,
        price: double.parse(_priceController.text),
        compareAtPrice: _comparePriceController.text.isNotEmpty
            ? double.parse(_comparePriceController.text)
            : null,
        category: _categoryController.text,
        tags: _tagsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        imageFiles: _productImages,
        availableColors: _selectedColors,
      );

      debugPrint('🟢 Calling onSave callback with product: ${product.title}');
      debugPrint('🎨 Product has ${product.availableColors.length} colors');
      widget.onSave(product);
      debugPrint('🟢 Closing dialog');
      Navigator.pop(context);
    } else {
      debugPrint('🔴 Form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 40,
              offset: const Offset(0, 20),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Modern Gradient Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
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
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24.r),
                  topRight: Radius.circular(24.r),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      widget.product == null
                          ? Icons.add_shopping_cart_rounded
                          : Icons.edit_rounded,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product == null
                              ? tr('add_vendor_product')
                              : tr('edit_vendor_product'),
                          style: AppTextStyle.getBoldStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          widget.product == null
                              ? 'Add a new product to your store'
                              : 'Update product information',
                          style: AppTextStyle.getRegularStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Information Section
                      _buildSectionHeader(
                        icon: Icons.info_outline_rounded,
                        title: 'Product Information',
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        controller: _titleController,
                        labelText: '${tr('vendor_product_title')} *',
                        hintText: tr('enter_vendor_product_name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return tr('vendor_product_title_required');
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        controller: _shortDescController,
                        labelText: '${tr('vendor_short_description')} *',
                        hintText: tr('brief_vendor_product_description'),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return tr('vendor_short_description_required');
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        controller: _descController,
                        labelText: tr('vendor_full_description'),
                        hintText: tr('detailed_vendor_product_description'),
                        maxLines: 4,
                      ),
                      SizedBox(height: 24.h),

                      // Pricing Section
                      _buildSectionHeader(
                        icon: Icons.attach_money_rounded,
                        title: 'Pricing',
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Expanded(
                            child: CustomTextFormField(
                              controller: _priceController,
                              labelText: '${tr('vendor_price_iqd')} *',
                              hintText: '0',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return tr('vendor_price_required');
                                }
                                if (double.tryParse(value) == null) {
                                  return tr('vendor_invalid_price');
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: CustomTextFormField(
                              controller: _comparePriceController,
                              labelText: tr('vendor_compare_price_iqd'),
                              hintText: '0',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),

                      // Category & Tags Section
                      _buildSectionHeader(
                        icon: Icons.category_rounded,
                        title: 'Organization',
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        controller: _categoryController,
                        labelText: '${tr('vendor_category')} *',
                        hintText: tr('vendor_category_placeholder'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return tr('vendor_category_required');
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),
                      CustomTextFormField(
                        controller: _tagsController,
                        labelText: tr('vendor_tags'),
                        hintText: tr('vendor_tags_placeholder'),
                      ),
                      SizedBox(height: 24.h),

                      // Product Images Section
                      _buildSectionHeader(
                        icon: Icons.photo_library_rounded,
                        title: '${tr('vendor_product_images')} *',
                      ),
                      SizedBox(height: 16.h),
                      SmartUploadField(
                        hint: tr('upload_vendor_product_images'),
                        allowedTypes: const SmartAllowedTypes(images: true),
                        allowMultiple: true,
                        maxSizeInMB: 5,
                        onSelected: (files) {
                          setState(() {
                            _productImages = files.map((f) => f.file).toList();
                          });
                        },
                      ),
                      if (_productImages.isNotEmpty) ...[
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppColors.success50,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.success200,
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.success,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '${_productImages.length} ${tr('vendor_images_selected')}',
                                style: AppTextStyle.getMediumStyle(
                                  color: AppColors.success700,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: 24.h),

                      // Available Colors Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionHeader(
                            icon: Icons.palette_rounded,
                            title: tr('vendor_available_colors'),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary600,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10.r),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _addColor,
                                borderRadius: BorderRadius.circular(10.r),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 8.h,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add_circle_rounded,
                                        color: Colors.white,
                                        size: 16.sp,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        tr('add_vendor_color'),
                                        style: AppTextStyle.getSemiBoldStyle(
                                          color: Colors.white,
                                          fontSize: 12.sp,
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
                      if (_selectedColors.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: _selectedColors.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final color = entry.value;
                            return Container(
                              decoration: BoxDecoration(
                                color: AppColors.neutral50,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: Color(
                                    color.colorValue,
                                  ).withValues(alpha: 0.3),
                                  width: 2,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20.r),
                                  onTap: () {
                                    // Optional: Show color details
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12.w,
                                      vertical: 8.h,
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 24.w,
                                          height: 24.h,
                                          decoration: BoxDecoration(
                                            color: Color(color.colorValue),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Color(
                                                  color.colorValue,
                                                ).withValues(alpha: 0.4),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Text(
                                          color.name,
                                          style: AppTextStyle.getMediumStyle(
                                            color: AppColors.neutral800,
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              _selectedColors.removeAt(index);
                                            });
                                          },
                                          child: Icon(
                                            Icons.close_rounded,
                                            size: 16.sp,
                                            color: AppColors.neutral600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ] else ...[
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.neutral50,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.neutral200,
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.neutral400,
                                size: 20.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  'No colors added yet. Tap the button to add colors.',
                                  style: AppTextStyle.getRegularStyle(
                                    color: AppColors.neutral600,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Modern Footer Actions
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24.r),
                  bottomRight: Radius.circular(24.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.neutral100,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: AppColors.neutral300,
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          borderRadius: BorderRadius.circular(14.r),
                          child: Container(
                            height: 52.h,
                            alignment: Alignment.center,
                            child: Text(
                              tr('vendor_cancel'),
                              style: AppTextStyle.getSemiBoldStyle(
                                color: AppColors.neutral700,
                                fontSize: 15.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    flex: 3,
                    child: Container(
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
                        borderRadius: BorderRadius.circular(14.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _saveProduct,
                          borderRadius: BorderRadius.circular(14.r),
                          child: Container(
                            height: 52.h,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  tr('save_vendor_product'),
                                  style: AppTextStyle.getBoldStyle(
                                    color: Colors.white,
                                    fontSize: 15.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Modern Section Header
  Widget _buildSectionHeader({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.15),
                AppColors.secondary.withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18.sp),
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: AppTextStyle.getSemiBoldStyle(
            color: AppColors.neutral900,
            fontSize: 15.sp,
          ),
        ),
      ],
    );
  }
}
