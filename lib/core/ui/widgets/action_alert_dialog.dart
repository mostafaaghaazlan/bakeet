import 'package:flutter/material.dart';
import 'package:bakeet/core/constant/app_images/app_images.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../constant/app_colors/app_colors.dart';
import '../../constant/app_size/app_size.dart';
import '../../constant/text_styles/app_text_style.dart';
import 'cached_image.dart';

class ActionAlertDialog extends StatelessWidget {
  final String? message;
  final String dialogTitle;
  final Widget? imageWidget;
  final String? cancelText;
  final String? confirmText;
  final Widget? secondaryWidget;
  final Widget? confirmWidget;
  final VoidCallback? onCancel;
  final Function? onWillPopScope;
  final VoidCallback? onConfirm;
  final Function? hideDialog;
  final bool? isExistOr;
  final double? padding;
  final Color? color;
  final Color? confirmFillColor;
  final TextStyle? titleStyle;
  final TextStyle? buttonStyle;
  final String? image;
  final double? imageHeight;
  final bool isImageUrl;

  static Future<void> show(
    BuildContext context, {
    String? message,
    String? image,
    double? imageHeight,
    required String dialogTitle,
    Widget? imageWidget,
    String? cancelText,
    TextStyle? titleStyle,
    String? confirmText,
    TextStyle? buttonStyle,
    VoidCallback? onCancel,
    final VoidCallback? onWillPopScope,
    VoidCallback? onConfirm,
    Alignment? alignment,
    Color? color,
    Color? confirmFillColor,
    Function? hideDialog,
    final Widget? secondaryWidget,
    bool isExistOr = false,
    double? padding,
    bool isImageUrl = false,

    Widget? confirmWidget,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        if (hideDialog != null) hideDialog();
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (onWillPopScope != null) onWillPopScope();
          },
          child: Dialog(
            alignment: alignment,
            backgroundColor: color ?? Colors.white,
            insetPadding: EdgeInsets.all(padding ?? 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ActionAlertDialog(
              message: message,
              image: image,
              onCancel: onCancel,
              onConfirm: onConfirm,
              cancelText: cancelText,
              confirmText: confirmText,
              dialogTitle: dialogTitle,
              imageWidget: imageWidget,
              isExistOr: isExistOr,
              titleStyle: titleStyle,
              buttonStyle: buttonStyle,
              secondaryWidget: secondaryWidget,
              color: color,
              confirmFillColor: confirmFillColor,
              confirmWidget: confirmWidget,
              isImageUrl: isImageUrl,
            ),
          ),
        );
      },
    );
  }

  const ActionAlertDialog({
    super.key,
    required this.message,
    required this.dialogTitle,
    this.onWillPopScope,
    this.onCancel,
    this.titleStyle,
    this.imageHeight,
    this.buttonStyle,
    required this.onConfirm,
    required this.cancelText,
    required this.confirmText,
    this.imageWidget,
    this.secondaryWidget,
    this.hideDialog,
    this.isExistOr,
    this.padding,
    this.color,
    this.confirmFillColor,
    this.confirmWidget,
    this.image,
    this.isImageUrl = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppSize.size_16,
        horizontal: padding ?? AppSize.size_12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 10.w),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsetsDirectional.only(start: 30),
                    child: Center(
                      child: isImageUrl
                          ? (image != null && image!.startsWith('http')
                                ? CachedImage(
                                    imageUrl: image!,
                                    height: imageHeight ?? 200.h,
                                  )
                                : Image.asset(
                                    logoPngImage,
                                    height: imageHeight ?? 200.h,
                                  ))
                          : Image.asset(
                              image ?? logoPngImage,
                              height: imageHeight ?? 200.h,
                              // repeat: false,
                            ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          if (dialogTitle.isNotEmpty) const SizedBox(height: AppSize.size_25),
          if (dialogTitle.isNotEmpty)
            Text(
              dialogTitle,
              textAlign: TextAlign.center,
              style:
                  titleStyle ??
                  AppTextStyle.getMediumStyle(
                    color: AppColors.black14,
                    fontSize: AppSize.size_14,
                  ),
            ),
          if (message != null)
            Padding(
              padding: const EdgeInsets.only(top: 22.0),
              child: Text(
                message!,
                textAlign: TextAlign.center,
                style: AppTextStyle.getMediumStyle(
                  color: AppColors.black14,
                  fontSize: AppSize.size_12,
                ),
              ),
            ),
          const SizedBox(height: AppSize.size_25),
          if (secondaryWidget != null) secondaryWidget!,
          if (secondaryWidget == null) const SizedBox(height: 8),
          Row(
            children: [
              if (cancelText != null)
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        elevation: const WidgetStatePropertyAll(0),
                        backgroundColor: WidgetStatePropertyAll(
                          confirmFillColor ?? Colors.white,
                        ),
                        shape: const WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            side: BorderSide(color: AppColors.primary),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        cancelText!,
                        textAlign: TextAlign.center,
                        style:
                            buttonStyle ??
                            AppTextStyle.getMediumStyle(
                              color: AppColors.black14,
                              fontSize: AppSize.size_14,
                            ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: AppSize.size_12),
              if (confirmText != null)
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        elevation: const WidgetStatePropertyAll(0),
                        backgroundColor: WidgetStatePropertyAll(
                          confirmFillColor ?? AppColors.primary,
                        ),
                        shape: const WidgetStatePropertyAll(
                          RoundedRectangleBorder(
                            side: BorderSide(color: AppColors.grey9A),
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                        ),
                      ),
                      onPressed: onConfirm,
                      child: Text(
                        confirmText!,
                        style:
                            buttonStyle ??
                            AppTextStyle.getMediumStyle(
                              color: AppColors.white,
                              fontSize: AppSize.size_14,
                            ),
                      ),
                    ),
                  ),
                ),
              if (confirmWidget != null) confirmWidget!,
            ],
          ),
        ],
      ),
    );
  }
}
