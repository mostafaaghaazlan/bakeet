import 'package:flutter/material.dart';
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

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _selectedColor;

  // Predefined color palette
  final List<Color> _colors = [
    const Color(0xFFB91C1C), // Red
    const Color(0xFFEF4444),
    const Color(0xFFFECACA),
    const Color(0xFFEA580C), // Orange
    const Color(0xFFFF9800),
    const Color(0xFFFDE68A),
    const Color(0xFF92400E), // Brown
    const Color(0xFFB45309),
    const Color(0xFF065F46), // Green
    const Color(0xFF10B981),
    const Color(0xFFA7F3D0),
    const Color(0xFF0EA5A4), // Teal
    const Color(0xFF06B6D4),
    const Color(0xFFBAE6FD),
    const Color(0xFF0284C7), // Blue
    const Color(0xFF42A5F5),
    const Color(0xFF6366F1), // Indigo
    const Color(0xFF4F46E5),
    const Color(0xFF818CF8),
    const Color(0xFF7C3AED), // Purple
    const Color(0xFF6D28D9),
    const Color(0xFFEDE9FE),
    const Color(0xFF9C27B0), // Purple
    const Color(0xFFE91E63), // Pink
    const Color(0xFF111827), // Gray/Black
    const Color(0xFF374151),
    const Color(0xFF9CA3AF),
    const Color(0xFFFFFFFF), // White
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: AppTextStyle.getSemiBoldStyle(
          color: AppColors.neutral900,
          fontSize: 18.sp,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current color preview
            Container(
              width: double.infinity,
              height: 60.h,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.neutral300, width: 2),
              ),
            ),
            SizedBox(height: 16.h),
            // Color palette
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h,
              ),
              itemCount: _colors.length,
              itemBuilder: (context, index) {
                final color = _colors[index];
                final isSelected = _selectedColor == color;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.neutral300,
                        width: isSelected ? 3 : 2,
                      ),
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: _getContrastColor(color),
                            size: 16.sp,
                          )
                        : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
      actions: [
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
    );
  }

  // Helper to determine contrasting color for check icon
  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
