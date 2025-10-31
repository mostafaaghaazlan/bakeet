import 'package:flutter/material.dart';
import '../../constant/app_colors/app_colors.dart';
import '../../constant/app_size/app_size.dart';
import '../../constant/text_styles/app_text_style.dart';

class CurvedTopAppBar extends StatelessWidget {
  const CurvedTopAppBar({
    super.key,
    required this.title,
    this.onBack,
    this.fontSize,
  });

  final String title;
  final double? fontSize;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(color: AppColors.primary),

          SafeArea(
            bottom: false,
            child: SizedBox(
              height: 66,
              child: Stack(
                children: [
                  PositionedDirectional(
                    start: 8,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      onPressed:
                          onBack ?? () => Navigator.of(context).maybePop(),
                      icon: const BackButtonIcon(),
                      color: Colors.white,
                    ),
                  ),
                  Positioned.fill(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: AppTextStyle.getSemiBoldStyle(
                              fontSize: fontSize ?? AppSize.size_20,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Positioned(
            left: 0,
            right: 0,
            bottom: -24,
            child: SizedBox(
              height: 48,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
