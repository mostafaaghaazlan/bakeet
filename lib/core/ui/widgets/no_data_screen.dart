import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constant/app_colors/app_colors.dart';
import '../../constant/app_images/app_images.dart';
import '../../constant/app_size/app_size.dart';
import '../../constant/text_styles/app_text_style.dart';

class NoDataScreen extends StatelessWidget {
  final double? height;
  final double? width;
  const NoDataScreen({super.key, this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 70.h),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              logoPngImage,
              width: width ?? 300.w,
              height: height ?? 230.h,
            ),
            SizedBox(height: 30.h),
            Text(
              "no data",
              style: AppTextStyle.getRegularStyle(
                color: AppColors.grey9A,
                fontSize: AppSize.size_16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
