// import 'package:bakeet/core/ui/widgets/cached_image.dart';
// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';

// class AppImageCarousel extends StatefulWidget {
//   final List<String> images;

//   final bool isAsset;

//   final double height;

//   final double viewportFraction;

//   final bool enlargeCenterPage;

//   final bool autoPlay;

//   final Duration autoPlayInterval;

//   final bool enableInfiniteScroll;

//   final BorderRadius borderRadius;

//   final ValueChanged<int>? onIndexChanged;

//   final bool showIndicator;

//   final CarouselSliderController? controller;

//   const AppImageCarousel({
//     super.key,
//     required this.images,
//     this.isAsset = true,
//     this.height = 200,
//     this.viewportFraction = 0.86,
//     this.enlargeCenterPage = true,
//     this.autoPlay = true,
//     this.autoPlayInterval = const Duration(seconds: 4),
//     this.enableInfiniteScroll = true,
//     this.borderRadius = const BorderRadius.all(Radius.circular(16)),
//     this.onIndexChanged,
//     this.showIndicator = true,
//     this.controller,
//   });

//   @override
//   State<AppImageCarousel> createState() => _AppImageCarouselState();
// }

// class _AppImageCarouselState extends State<AppImageCarousel> {
//   late final CarouselSliderController _internalController;
//   int _activeIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     _internalController = widget.controller ?? CarouselSliderController();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final items = widget.images;

//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         CarouselSlider.builder(
//           carouselController: _internalController,
//           itemCount: items.length,
//           itemBuilder: (context, index, _) {
//             final path = items[index];
//             final image = widget.isAsset
//                 ? Image.asset(path, fit: BoxFit.cover)
//                 : CachedImage(imageUrl: path, fit: BoxFit.cover);

//             return Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 6),
//               child: ClipRRect(borderRadius: widget.borderRadius, child: image),
//             );
//           },
//           options: CarouselOptions(
//             height: widget.height,
//             viewportFraction: widget.viewportFraction,
//             enlargeCenterPage: widget.enlargeCenterPage,
//             enlargeStrategy: CenterPageEnlargeStrategy.scale,
//             enlargeFactor: 0.18,
//             enableInfiniteScroll: widget.enableInfiniteScroll,
//             autoPlay: widget.autoPlay,
//             autoPlayInterval: widget.autoPlayInterval,
//             padEnds: false,
//             onPageChanged: (i, _) {
//               setState(() => _activeIndex = i);
//               widget.onIndexChanged?.call(i);
//             },
//           ),
//         ),
//         if (widget.showIndicator) ...[
//           const SizedBox(height: 8),
//           AnimatedSmoothIndicator(
//             activeIndex: _activeIndex,
//             count: items.length,
//             effect: const ExpandingDotsEffect(
//               dotHeight: 6,
//               dotWidth: 6,
//               expansionFactor: 3,
//               spacing: 6,
//             ),
//             onDotClicked: (idx) => _internalController.animateToPage(idx),
//           ),
//         ],
//       ],
//     );
//   }
// }
