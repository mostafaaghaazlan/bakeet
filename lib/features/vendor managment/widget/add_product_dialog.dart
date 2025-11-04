import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/app_colors/app_colors.dart';
import '../../../core/constant/text_styles/app_text_style.dart';
import '../../../core/ui/widgets/custom_button.dart';
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
        title: 'Select Product Color',
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
            'Name This Color',
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
                labelText: 'Color Name',
                hintText: 'e.g., Red, Blue, Forest Green',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: AppTextStyle.getMediumStyle(
                  color: AppColors.neutral600,
                  fontSize: 14.sp,
                ),
              ),
            ),
            CustomButton(
              text: 'Add',
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  Navigator.pop(context, true);
                }
              },
              w: 80.w,
              h: 40.h,
              radius: 8.r,
            ),
          ],
        ),
      );

      if (confirmed == true && nameController.text.isNotEmpty) {
        print('🎨 Color selected: ${nameController.text} with value ${selectedColor!.toARGB32()}');
        setState(() {
          _selectedColors.add(
            ColorOption(name: nameController.text, colorValue: selectedColor!.toARGB32()),
          );
          print('🎨 Total colors after add: ${_selectedColors.length}');
        });
      }
      nameController.dispose();
    }
  }

  void _saveProduct() {
    print('🟢 Save product called');
    if (_formKey.currentState!.validate()) {
      print('🟢 Form validated successfully');
      print('🎨 Saving product with ${_selectedColors.length} colors');
      if (_selectedColors.isNotEmpty) {
        print('🎨 Colors: ${_selectedColors.map((c) => '${c.name}(${c.colorValue})').join(', ')}');
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

      print('🟢 Calling onSave callback with product: ${product.title}');
      print('🎨 Product has ${product.availableColors.length} colors');
      widget.onSave(product);
      print('🟢 Closing dialog');
      Navigator.pop(context);
    } else {
      print('🔴 Form validation failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.product == null ? 'Add Product' : 'Edit Product',
                    style: AppTextStyle.getSemiBoldStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextFormField(
                        controller: _titleController,
                        labelText: 'Product Title *',
                        hintText: 'Enter product name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Product title is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      CustomTextFormField(
                        controller: _shortDescController,
                        labelText: 'Short Description *',
                        hintText: 'Brief product description',
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Short description is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      CustomTextFormField(
                        controller: _descController,
                        labelText: 'Full Description',
                        hintText: 'Detailed product description',
                        maxLines: 4,
                      ),
                      SizedBox(height: 16.h),

                      Row(
                        children: [
                          Expanded(
                            child: CustomTextFormField(
                              controller: _priceController,
                              labelText: 'Price (IQD) *',
                              hintText: '0',
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Price is required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid price';
                                }
                                return null;
                              },
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: CustomTextFormField(
                              controller: _comparePriceController,
                              labelText: 'Compare Price (IQD)',
                              hintText: '0',
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      CustomTextFormField(
                        controller: _categoryController,
                        labelText: 'Category *',
                        hintText: 'e.g., Clothing, Electronics',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Category is required';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.h),

                      CustomTextFormField(
                        controller: _tagsController,
                        labelText: 'Tags (comma separated)',
                        hintText: 'tag1, tag2, tag3',
                      ),
                      SizedBox(height: 24.h),

                      // Product Images
                      Text(
                        'Product Images *',
                        style: AppTextStyle.getSemiBoldStyle(
                          color: AppColors.neutral900,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      SmartUploadField(
                        hint: 'Upload product images',
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
                        SizedBox(height: 8.h),
                        Text(
                          '${_productImages.length} image(s) selected',
                          style: AppTextStyle.getRegularStyle(
                            color: AppColors.neutral600,
                            fontSize: 12.sp,
                          ),
                        ),
                      ],
                      SizedBox(height: 24.h),

                      // Available Colors
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Available Colors',
                            style: AppTextStyle.getSemiBoldStyle(
                              color: AppColors.neutral900,
                              fontSize: 14.sp,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _addColor,
                            icon: const Icon(Icons.add),
                            label: const Text('Add Color'),
                          ),
                        ],
                      ),
                      if (_selectedColors.isNotEmpty) ...[
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: _selectedColors.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final color = entry.value;
                            return Chip(
                              avatar: CircleAvatar(
                                backgroundColor: Color(color.colorValue),
                              ),
                              label: Text(color.name),
                              onDeleted: () {
                                setState(() {
                                  _selectedColors.removeAt(index);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.neutral100,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12.r),
                  bottomRight: Radius.circular(12.r),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                      color: Colors.grey,
                      h: 48.h,
                      radius: 8.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomButton(
                      text: 'Save Product',
                      onPressed: _saveProduct,
                      color: AppColors.primary,
                      h: 48.h,
                      radius: 8.r,
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
}
