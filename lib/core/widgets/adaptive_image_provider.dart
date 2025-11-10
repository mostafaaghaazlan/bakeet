import 'dart:io';

import 'package:flutter/material.dart';

ImageProvider adaptiveImageProvider(String? url, {String? fallbackAsset}) {
  if (url == null || url.isEmpty) {
    return AssetImage(fallbackAsset ?? 'assets/images/logo.png');
  }

  final u = url;
  if (u.startsWith('http://') || u.startsWith('https://')) {
    return NetworkImage(u);
  }

  if (u.startsWith('assets/')) {
    return AssetImage(u);
  }

  // Treat as local file if looks like an absolute path
  if (u.startsWith('/') ||
      (u.length > 2 && RegExp(r'^[A-Za-z]:\\').hasMatch(u))) {
    return FileImage(File(u));
  }

  // Fallback to network (in case of scheme-less URL)
  return NetworkImage(u);
}
