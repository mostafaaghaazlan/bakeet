import 'package:flutter/material.dart';
import 'package:bakeet/features/marketplace/data/model/vendor_model.dart';

/// VendorTheme manages the unique visual identity for each vendor
/// This class provides colors and gradients that are applied throughout
/// the vendor's storefront to create a distinct brand experience
class VendorTheme {
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  const VendorTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
  });

  /// Create a VendorTheme from a VendorModel
  factory VendorTheme.fromVendor(VendorModel vendor) {
    return VendorTheme(
      primaryColor: vendor.primaryColor,
      secondaryColor: vendor.secondaryColor,
      accentColor: vendor.accentColor,
    );
  }

  /// Primary gradient used for buttons, chips, and highlighted elements
  LinearGradient get primaryGradient => LinearGradient(
        colors: [primaryColor, secondaryColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Accent gradient used for secondary UI elements
  LinearGradient get accentGradient => LinearGradient(
        colors: [secondaryColor, accentColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  /// Light background color based on primary (for chips, badges, etc.)
  Color get lightBackground => primaryColor.withValues(alpha: 0.1);

  /// Medium background color based on primary
  Color get mediumBackground => primaryColor.withValues(alpha: 0.2);

  /// Shadow color based on primary
  Color get shadowColor => primaryColor.withValues(alpha: 0.3);
}
