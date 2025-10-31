import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constant/app_colors/app_colors.dart';
import '../../constant/app_images/app_images.dart';
import '../../constant/app_size/app_size.dart';
import '../../constant/text_styles/app_text_style.dart';
import '../screens/base_hens_state_screen.dart';

class GeneralErrorWidget extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget? body;
  final String? message;
  final String? buttonText;
  final double? height;
  final double? width;
  const GeneralErrorWidget({
    super.key,
    this.onTap,
    this.message,
    this.buttonText,
    this.body,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BaseHensStateScreen(
        width: 150.w,
        textWidget: Text(
          message ?? '',
          textAlign: TextAlign.center,
          style: AppTextStyle.getRegularStyle(
            color: AppColors.grey9A,
            fontSize: AppSize.size_16,
          ),
        ),
        buttonText: 'try_again'.tr(),
        image: logoPngImage,
        onTap: onTap,
        description: '',
      ),
    );
  }
}
