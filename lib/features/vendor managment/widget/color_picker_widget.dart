import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/app_colors/app_colors.dart';
import '../../../core/constant/text_styles/app_text_style.dart';
import '../../../core/ui/widgets/custom_button.dart';

class ColorPickerDialog extends StatefulWidget {
  final String title;
  final Color initialColor;
  final Function(Color) onColorSelected;

  const ColorPickerDialog({
    super.key,
    required this.title,
    required this.initialColor,
    required this.onColorSelected,
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog>
    with SingleTickerProviderStateMixin {
  late Color _selectedColor;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.all(20.r),
        constraints: BoxConstraints(maxWidth: 400.w, maxHeight: 600.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              widget.title,
              style: AppTextStyle.getSemiBoldStyle(
                color: AppColors.neutral900,
                fontSize: 18.sp,
              ),
            ),
            SizedBox(height: 16.h),

            // Current color preview
            Container(
              width: double.infinity,
              height: 60.h,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.neutral300, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: _selectedColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '#${_selectedColor.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
                  style: AppTextStyle.getSemiBoldStyle(
                    color: _getContrastColor(_selectedColor),
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),

            // Tab bar
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.neutral600,
              indicatorColor: AppColors.primary,
              tabs: [
                Tab(text: 'Wheel'),
                Tab(text: 'Shades'),
                Tab(text: 'Palette'),
              ],
            ),
            SizedBox(height: 16.h),

            // Tab views
            Flexible(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Color Wheel Picker
                  SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: _selectedColor,
                      onColorChanged: (color) {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      colorPickerWidth: 300.w,
                      pickerAreaHeightPercent: 0.7,
                      enableAlpha: false,
                      displayThumbColor: true,
                      paletteType: PaletteType.hsvWithHue,
                      labelTypes: const [],
                      pickerAreaBorderRadius: BorderRadius.circular(12.r),
                    ),
                  ),

                  // Material Color Picker
                  SingleChildScrollView(
                    child: MaterialPicker(
                      pickerColor: _selectedColor,
                      onColorChanged: (color) {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      enableLabel: false,
                    ),
                  ),

                  // Block Color Picker
                  SingleChildScrollView(
                    child: BlockPicker(
                      pickerColor: _selectedColor,
                      onColorChanged: (color) {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      availableColors: [
                        const Color(0xFFB91C1C), // Red shades
                        const Color(0xFFEF4444),
                        const Color(0xFFFCA5A5),
                        const Color(0xFFEA580C), // Orange shades
                        const Color(0xFFFF9800),
                        const Color(0xFFFFCC80),
                        const Color(0xFF92400E), // Brown shades
                        const Color(0xFFB45309),
                        const Color(0xFFD97706),
                        const Color(0xFFF59E0B), // Yellow
                        const Color(0xFFFDE68A),
                        const Color(0xFFEAB308),
                        const Color(0xFF065F46), // Green shades
                        const Color(0xFF10B981),
                        const Color(0xFFA7F3D0),
                        const Color(0xFF059669),
                        const Color(0xFF0EA5A4), // Teal shades
                        const Color(0xFF06B6D4),
                        const Color(0xFFBAE6FD),
                        const Color(0xFF0284C7), // Blue shades
                        const Color(0xFF42A5F5),
                        const Color(0xFF90CAF9),
                        const Color(0xFF6366F1), // Indigo shades
                        const Color(0xFF4F46E5),
                        const Color(0xFF818CF8),
                        const Color(0xFF7C3AED), // Purple shades
                        const Color(0xFF6D28D9),
                        const Color(0xFFC4B5FD),
                        const Color(0xFF9C27B0), // Purple
                        const Color(0xFFBA68C8),
                        const Color(0xFFE91E63), // Pink
                        const Color(0xFFF06292),
                        const Color(0xFF111827), // Gray/Black shades
                        const Color(0xFF374151),
                        const Color(0xFF6B7280),
                        const Color(0xFF9CA3AF),
                        const Color(0xFFD1D5DB),
                        const Color(0xFFFFFFFF), // White
                      ],
                      layoutBuilder: (context, colors, child) {
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            crossAxisSpacing: 8.w,
                            mainAxisSpacing: 8.h,
                          ),
                          itemCount: colors.length,
                          itemBuilder: (context, index) {
                            return child(colors[index]);
                          },
                        );
                      },
                      itemBuilder: (color, isCurrentColor, changeColor) {
                        return GestureDetector(
                          onTap: changeColor,
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isCurrentColor
                                    ? AppColors.primary
                                    : AppColors.neutral300,
                                width: isCurrentColor ? 3 : 2,
                              ),
                            ),
                            child: isCurrentColor
                                ? Icon(
                                    Icons.check,
                                    color: _getContrastColor(color),
                                    size: 20.sp,
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: AppTextStyle.getMediumStyle(
                      color: AppColors.neutral600,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                CustomButton(
                  text: 'Select',
                  onPressed: () {
                    widget.onColorSelected(_selectedColor);
                    Navigator.pop(context);
                  },
                  w: 100.w,
                  h: 40.h,
                  radius: 8.r,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper to determine contrasting color for check icon and text
  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
