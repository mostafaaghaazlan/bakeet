import 'package:flutter/material.dart';
import 'package:bakeet/core/constant/app_size/app_size.dart';
import 'package:shimmer/shimmer.dart';

class LoadingWidget extends StatelessWidget {
  final double? width;
  final double? height;

  const LoadingWidget({super.key, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSize.size_16,
        bottom: AppSize.size_16,
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.white,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(24),
          ),
          width: double.infinity,
          height: height ?? 100,
        ),
      ),
    );
  }
}
