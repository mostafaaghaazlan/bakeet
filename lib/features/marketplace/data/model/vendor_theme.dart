import 'package:flutter/material.dart';
import 'package:bakeet/core/widgets/adaptive_image_provider.dart';
import 'package:bakeet/features/marketplace/data/model/vendor_model.dart';

/// VendorTheme manages the unique visual identity for each vendor
/// This class provides colors and gradients that are applied throughout
/// the vendor's storefront to create a distinct brand experience
class VendorTheme {
  /// Core colors (kept for backwards compatibility)
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;

  /// Optional richer design properties
  final List<Color>? gradientColors;
  final String? backgroundImageUrl;
  final String? fontFamily;
  final Color? textColor;
  final double buttonRadius;
  final double cardRadius;

  const VendorTheme({
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    this.gradientColors,
    this.backgroundImageUrl,
    this.fontFamily,
    this.textColor,
    this.buttonRadius = 10.0,
    this.cardRadius = 20.0,
  });

  /// Create a VendorTheme from a VendorModel. This keeps the existing
  /// simple color-based theme but also reads any richer properties when
  /// available on the model.
  factory VendorTheme.fromVendor(VendorModel vendor) {
    final gradient =
        vendor.gradientColors != null && vendor.gradientColors!.isNotEmpty
        ? vendor.gradientColors!.map((c) => Color(c)).toList()
        : [vendor.primaryColor, vendor.secondaryColor, vendor.accentColor];

    return VendorTheme(
      primaryColor: vendor.primaryColor,
      secondaryColor: vendor.secondaryColor,
      accentColor: vendor.accentColor,
      gradientColors: gradient,
      backgroundImageUrl: vendor.backgroundImageUrl,
      fontFamily: vendor.fontFamily,
      textColor: vendor.textColor,
    );
  }

  /// Primary gradient used for buttons, chips, and highlighted elements.
  /// Uses `gradientColors` when provided to allow richer multi-stop gradients.
  LinearGradient get primaryGradient => LinearGradient(
    colors: gradientColors ?? [primaryColor, secondaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Accent gradient used for secondary UI elements
  LinearGradient get accentGradient => LinearGradient(
    colors: (gradientColors != null && gradientColors!.length >= 2)
        ? [gradientColors!.last, gradientColors!.first]
        : [secondaryColor, accentColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Light background color based on primary (for chips, badges, etc.)
  Color get lightBackground => primaryColor.withValues(alpha: 0.1);

  /// Medium background color based on primary
  Color get mediumBackground => primaryColor.withValues(alpha: 0.2);

  /// Shadow color based on primary
  Color get shadowColor => primaryColor.withValues(alpha: 0.3);

  /// Background decoration the UI can use. If `backgroundImageUrl` is set
  /// a background image with a subtle gradient overlay is returned. If not,
  /// a soft gradient based on the vendor colors is used.
  BoxDecoration get backgroundDecoration {
    if (backgroundImageUrl != null && backgroundImageUrl!.isNotEmpty) {
      return BoxDecoration(
        image: DecorationImage(
          image: adaptiveImageProvider(backgroundImageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: 0.25),
            BlendMode.darken,
          ),
        ),
        gradient: LinearGradient(
          colors: [
            (gradientColors != null && gradientColors!.isNotEmpty)
                ? gradientColors!.first.withValues(alpha: 0.06)
                : primaryColor.withValues(alpha: 0.06),
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      );
    }

    return BoxDecoration(
      gradient: LinearGradient(
        colors:
            gradientColors ??
            [
              primaryColor.withValues(alpha: 0.06),
              secondaryColor.withValues(alpha: 0.03),
            ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );
  }

  /// Convenience text style for vendor headline text
  TextStyle headlineTextStyle(double size) {
    return TextStyle(
      fontFamily: fontFamily,
      color: textColor ?? Colors.white,
      fontSize: size,
      fontWeight: FontWeight.bold,
    );
  }
}
