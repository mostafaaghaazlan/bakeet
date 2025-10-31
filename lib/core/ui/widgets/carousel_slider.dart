import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shimmer/shimmer.dart';
import '../../constant/app_colors/app_colors.dart';
import '../../constant/app_images/app_images.dart';
import 'cached_image.dart';

class CarouselWidget extends StatelessWidget {
  final List<String> images;
  final CarouselSliderController controller;
  final void Function(int index)? onTap;
  final Function(int index) onPageChanged;
  final int currentIndexIndicator;
  final double viewportFraction;
  final double padding;
  final double height;
  final double? width;
  final BoxFit? photoFit;
  final bool hasImageModel;
  final bool autoPlay;
  final bool isEndix;
  final bool isZoomable;

  const CarouselWidget({
    super.key,
    required this.images,
    required this.controller,
    required this.onPageChanged,
    required this.currentIndexIndicator,
    required this.viewportFraction,
    this.hasImageModel = true,
    required this.padding,
    required this.height,
    this.width,
    this.onTap,
    this.photoFit,
    required this.autoPlay,
    this.isZoomable = false,
    this.isEndix = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          carouselController: controller,
          options: CarouselOptions(
            height: height,
            initialPage: 0,
            enableInfiniteScroll: images.length > 1,
            autoPlay: autoPlay,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.easeInOutExpo,
            enlargeCenterPage: true, 
            enlargeFactor: 0.22,
            viewportFraction: viewportFraction, 
            scrollDirection: Axis.horizontal,
            onPageChanged: (index, reason) {
              onPageChanged(index);
            },
          ),
          items: images
              .asMap()
              .map((index, imageUrl) {
                return MapEntry(
                  index,
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: padding),
                    child: GestureDetector(
                      onTap: isZoomable
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => PhotoViewGalleryScreen(
                                    images: images,
                                    initialIndex: index,
                                    heroTag: 'carousel_$index',
                                  ),
                                ),
                              );
                            }
                          : (onTap != null ? () => onTap?.call(index) : null),
                      child: Container(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        child: CachedImage(
                          imageUrl: imageUrl,
                          fit: photoFit ?? BoxFit.fill,
                          width: width ?? double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                  ),
                );
              })
              .values
              .toList(),
        ),
        const SizedBox(height: 10),
        if (images.length > 1 && isEndix == true)
          Center(
            child: SizedBox(
              height: 7,
              child: ListView.separated(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => currentIndexIndicator == index
                    ? Container(
                        height: 7,
                        width: 25,
                        decoration: const BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: AppColors.primary,
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                        ),
                      )
                    : const CircleAvatar(
                        radius: 5,
                        backgroundColor: AppColors.greyDD,
                      ),
                separatorBuilder: (context, index) => const SizedBox(width: 14),
                itemCount: images.length,
              ),
            ),
          ),
      ],
    );
  }
}

class PhotoViewGalleryScreen extends StatelessWidget {
  final List<String> images;
  final int initialIndex;
  final String? heroTag;

  const PhotoViewGalleryScreen({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PhotoViewGallery.builder(
        loadingBuilder: (context, progress) {
          return Center(
            child: progress == null
                ? const SizedBox.shrink()
                : SizedBox(
                    width: 200.w,
                    height: 100.h,
                    child: Shimmer.fromColors(
                      baseColor: AppColors.primary,
                      highlightColor: AppColors.secoundPrimary,
                      child: Image.asset(logoPngImage),
                    ),
                  ),
          );
        },
        itemCount: images.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(images[index]),
            heroAttributes: heroTag != null
                ? PhotoViewHeroAttributes(tag: '$heroTag$index')
                : null,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        pageController: PageController(initialPage: initialIndex),
      ),
    );
  }
}
