import 'dart:io';

import 'package:flutter/material.dart';

/// AdaptiveImage: picks Image.asset for local asset paths or Image.file for
/// absolute/local file paths, otherwise uses Image.network.
class AdaptiveImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;

  const AdaptiveImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit,
    this.placeholder,
  });

  bool _isNetwork(String u) =>
      u.startsWith('http://') || u.startsWith('https://');
  bool _isAsset(String u) => u.startsWith('assets/');
  bool _isLocalFile(String u) =>
      u.startsWith('/') ||
      (Platform.isWindows &&
          (u.length > 2 && RegExp(r'^[A-Za-z]:\\').hasMatch(u)));

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return placeholder ?? const SizedBox.shrink();
    }

    final u = url!;
    if (_isNetwork(u)) {
      return Image.network(u, width: width, height: height, fit: fit);
    }

    if (_isAsset(u)) {
      return Image.asset(u, width: width, height: height, fit: fit);
    }

    if (_isLocalFile(u)) {
      try {
        return Image.file(File(u), width: width, height: height, fit: fit);
      } catch (_) {
        return placeholder ?? const SizedBox.shrink();
      }
    }

    // Fallback to network (in case it's a remote URL without scheme)
    return Image.network(u, width: width, height: height, fit: fit);
  }
}
