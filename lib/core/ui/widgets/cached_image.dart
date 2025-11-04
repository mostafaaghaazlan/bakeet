import 'dart:io';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:bakeet/core/constant/app_images/app_images.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../constant/app_colors/app_colors.dart';

class CachedImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit? fit;
  final double? height;
  final double? radius;
  final double? placeHolderHeight;
  final double? width;
  final double? cacheWidth;
  final double? cacheHeight;
  final Color? color;
  final String? fallbackPlaceHolder;
  final bool removeOnDispose;
  final bool isZoomable;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.fit,
    this.height,
    this.radius,
    this.placeHolderHeight,
    this.width,
    this.cacheHeight,
    this.cacheWidth,
    this.color,
    this.fallbackPlaceHolder,
    this.removeOnDispose = true,
    this.isZoomable = false,
  });

  @override
  Widget build(BuildContext context) {
    // Check if imageUrl is a local file path or a network URL
    final bool isLocalFile =
        imageUrl != null &&
        (imageUrl!.startsWith('/') ||
            imageUrl!.startsWith('C:') ||
            imageUrl!.contains(':\\') ||
            File(imageUrl!).existsSync());

    Widget imageWidget;

    if (isLocalFile) {
      // Use ExtendedImage.file for local files
      imageWidget = ExtendedImage.file(
        File(imageUrl!),
        fit: fit,
        borderRadius: BorderRadius.all(Radius.circular(radius ?? 0)),
        height: height,
        width: width,
        color: color,
        clearMemoryCacheWhenDispose: removeOnDispose,
        mode: isZoomable ? ExtendedImageMode.gesture : ExtendedImageMode.none,
        initGestureConfigHandler: isZoomable
            ? (_) => GestureConfig(
                minScale: 1.0,
                animationMinScale: 0.8,
                maxScale: 3.0,
                animationMaxScale: 3.5,
                speed: 1.0,
                inertialSpeed: 100.0,
                initialScale: 1.0,
                inPageView: false,
                initialAlignment: InitialAlignment.center,
              )
            : null,
        loadStateChanged: (ExtendedImageState state) {
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              return Center(
                child: SizedBox(
                  width: cacheWidth ?? 200.w,
                  height: cacheHeight ?? 100.h,
                  child: Shimmer.fromColors(
                    baseColor: AppColors.primary,
                    highlightColor: AppColors.secoundPrimary,
                    child: Image.asset(logoPngImage),
                  ),
                ),
              );
            case LoadState.completed:
              return state.completedWidget;
            case LoadState.failed:
              return Padding(
                padding: EdgeInsets.all(radius ?? 0.0),
                child: ExtendedImage(
                  borderRadius: BorderRadius.all(Radius.circular(radius ?? 0)),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  image: const AssetImage(logoPngImage),
                  clearMemoryCacheWhenDispose: true,
                  fit: BoxFit.contain,
                ),
              );
          }
        },
      );
    } else {
      // Use ExtendedImage.network for URLs
      imageWidget = ExtendedImage.network(
        imageUrl ?? '',
        fit: fit,
        borderRadius: BorderRadius.all(Radius.circular(radius ?? 0)),
        height: height,
        width: width,
        color: color,
        printError: false,
        cacheMaxAge: const Duration(days: 365),
        clearMemoryCacheWhenDispose: removeOnDispose,
        handleLoadingProgress: true,
        mode: isZoomable ? ExtendedImageMode.gesture : ExtendedImageMode.none,
        initGestureConfigHandler: isZoomable
            ? (_) => GestureConfig(
                minScale: 1.0,
                animationMinScale: 0.8,
                maxScale: 3.0,
                animationMaxScale: 3.5,
                speed: 1.0,
                inertialSpeed: 100.0,
                initialScale: 1.0,
                inPageView: false,
                initialAlignment: InitialAlignment.center,
              )
            : null,
        loadStateChanged: (ExtendedImageState state) {
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              return Center(
                child: SizedBox(
                  width: cacheWidth ?? 200.w,
                  height: cacheHeight ?? 100.h,
                  child: Shimmer.fromColors(
                    baseColor: AppColors.primary,
                    highlightColor: AppColors.secoundPrimary,
                    child: Image.asset(logoPngImage),
                  ),
                ),
              );
            case LoadState.completed:
              return state.completedWidget;
            case LoadState.failed:
              return Padding(
                padding: EdgeInsets.all(radius ?? 0.0),
                child: ExtendedImage(
                  borderRadius: BorderRadius.all(Radius.circular(radius ?? 0)),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  image: const AssetImage(logoPngImage),
                  clearMemoryCacheWhenDispose: true,
                  fit: BoxFit.contain,
                ),
              );
          }
        },
      );
    }

    return imageWidget;
  }
}
