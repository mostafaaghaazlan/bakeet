import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constant/app_colors/app_colors.dart';
import '../../../core/constant/text_styles/app_text_style.dart';
import '../../../core/ui/widgets/custom_button.dart';
import '../screen/vendor_registration_screen.dart';

/// Example widget showing how to navigate to vendor registration
/// You can add this button to your home screen or profile screen
class VendorRegistrationButton extends StatelessWidget {
  const VendorRegistrationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: 'Become a Vendor',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const VendorRegistrationScreen(),
          ),
        );
      },
      color: AppColors.primary,
      h: 56.h,
      radius: 12.r,
      icon: Icon(Icons.store_outlined, color: Colors.white, size: 24.sp),
    );
  }
}

/// Example: Add to your home screen or marketplace screen
class ExampleIntegration extends StatelessWidget {
  const ExampleIntegration({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marketplace'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Your existing content here
            SizedBox(height: 24.h),

            // Vendor Registration Card
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.store, color: Colors.white, size: 32.sp),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'Become a Vendor',
                          style: AppTextStyle.getBoldStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Start selling your products on our platform. Register your store, add products, and reach thousands of customers.',
                    style: AppTextStyle.getRegularStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  CustomButton(
                    text: 'Register Now',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const VendorRegistrationScreen(),
                        ),
                      );
                    },
                    color: Colors.white,
                    textStyle: AppTextStyle.getSemiBoldStyle(
                      color: AppColors.primary,
                      fontSize: 16.sp,
                    ),
                    h: 48.h,
                    radius: 8.r,
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
