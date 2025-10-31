import 'package:flutter/material.dart';
import 'package:bakeet/core/constant/app_colors/app_colors.dart';
import 'package:bakeet/core/constant/text_styles/app_text_style.dart';

import '../../constant/app_size/app_size.dart';

class BackWidget extends StatelessWidget {
  final Widget? titleWidget;
  final Widget? endWidget;
  final VoidCallback? onBack;
  final String? title;
  final bool existBack;
  const BackWidget({
    super.key,
    this.titleWidget,
    this.title,
    this.onBack,
    this.endWidget,
    this.existBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (existBack)
          InkWell(
            onTap: onBack != null ? onBack! : () => Navigator.pop(context),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.arrow_back_ios_new_rounded),
            ),
          ),
        const Spacer(),
        titleWidget != null
            ? titleWidget!
            : Text(
                title ?? "اضغط مرة اخرة للخروج",
                textAlign: TextAlign.center,
                style: AppTextStyle.getBoldStyle(
                  color: AppColors.black1c,
                  fontSize: AppSize.size_20,
                ),
              ),
        const Spacer(),
        if (endWidget != null) endWidget!,
      ],
    );
  }
}
