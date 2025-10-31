import 'package:flutter/material.dart';
import 'package:bakeet/features/marketplace/data/model/product_model.dart';
import 'package:bakeet/features/marketplace/data/model/vendor_model.dart';

import 'mock_products.dart';

class MarketplaceRepository {
  // Mock in-app data
  final List<VendorModel> _vendors = [
    VendorModel(
      id: 'v01',
      name: 'Baghdad Bazaar',
      logoUrl: 'https://picsum.photos/seed/v01-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v01-banner/1200/400',
      tagline: 'Traditional crafts & homeware',
      primaryColor: const Color(0xFFB91C1C), // warm red
      secondaryColor: const Color(0xFFEF4444),
      accentColor: const Color(0xFFFECACA),
      backgroundImageUrl: 'https://picsum.photos/seed/v01-bg/1600/600',
      gradientColors: [0xFFB91C1C, 0xFFEF4444],
      fontFamily: 'Cairo',
      textColor: const Color(0xFFFAFAFA),
    ),

    VendorModel(
      id: 'v02',
      name: 'Erbil Studio',
      logoUrl: 'https://picsum.photos/seed/v02-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v02-banner/1200/400',
      tagline: 'Modern design & furniture',
      primaryColor: const Color(0xFF6366F1),
      secondaryColor: const Color(0xFF4F46E5),
      accentColor: const Color(0xFF818CF8),
      backgroundImageUrl: 'https://picsum.photos/seed/v02-bg/1600/600',
      gradientColors: [0xFF6366F1, 0xFF4F46E5, 0xFF818CF8],
      fontFamily: 'Montserrat',
      textColor: const Color(0xFFFFFFFF),
    ),

    VendorModel(
      id: 'v03',
      name: 'Mosul Handworks',
      logoUrl: 'https://picsum.photos/seed/v03-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v03-banner/1200/400',
      tagline: 'Artisan rugs & textiles',
      primaryColor: const Color(0xFF92400E),
      secondaryColor: const Color(0xFFEA580C),
      accentColor: const Color(0xFFFDE68A),
      backgroundImageUrl: 'https://picsum.photos/seed/v03-bg/1600/600',
      gradientColors: [0xFF92400E, 0xFFEA580C],
      fontFamily: 'Amiri',
      textColor: const Color(0xFF0F172A),
    ),

    VendorModel(
      id: 'v04',
      name: 'Basra Spice House',
      logoUrl: 'https://picsum.photos/seed/v04-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v04-banner/1200/400',
      tagline: 'Fine spices & blends',
      primaryColor: const Color(0xFF92400E),
      secondaryColor: const Color(0xFFB45309),
      accentColor: const Color(0xFFFDE68A),
      backgroundImageUrl: 'https://picsum.photos/seed/v04-bg/1600/600',
      gradientColors: [0xFF92400E, 0xFFB45309],
      fontFamily: 'Tajawal',
      textColor: const Color(0xFF0F172A),
    ),

    VendorModel(
      id: 'v05',
      name: 'Nineveh Antiques',
      logoUrl: 'https://picsum.photos/seed/v05-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v05-banner/1200/400',
      tagline: 'Curated vintage pieces',
      primaryColor: const Color(0xFF854D0E),
      secondaryColor: const Color(0xFF7C2D12),
      accentColor: const Color(0xFFFDE68A),
      backgroundImageUrl: 'https://picsum.photos/seed/v05-bg/1600/600',
      gradientColors: [0xFF854D0E, 0xFF7C2D12],
      fontFamily: 'Lora',
      textColor: const Color(0xFFFAFAFA),
    ),

    VendorModel(
      id: 'v06',
      name: 'Kurdish Loom',
      logoUrl: 'https://picsum.photos/seed/v06-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v06-banner/1200/400',
      tagline: 'Handwoven textiles & scarves',
      primaryColor: const Color(0xFF0EA5A4),
      secondaryColor: const Color(0xFF0891B2),
      accentColor: const Color(0xFF67E8F9),
      backgroundImageUrl: 'https://picsum.photos/seed/v06-bg/1600/600',
      gradientColors: [0xFF0EA5A4, 0xFF0891B2],
      fontFamily: 'Cairo',
      textColor: const Color(0xFF042A2B),
    ),

    VendorModel(
      id: 'v07',
      name: 'Tigris Books',
      logoUrl: 'https://picsum.photos/seed/v07-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v07-banner/1200/400',
      tagline: 'Local authors & English imports',
      primaryColor: const Color(0xFF065F46),
      secondaryColor: const Color(0xFF10B981),
      accentColor: const Color(0xFFA7F3D0),
      backgroundImageUrl: 'https://picsum.photos/seed/v07-bg/1600/600',
      gradientColors: [0xFF065F46, 0xFF10B981],
      fontFamily: 'NotoSans',
      textColor: const Color(0xFFFFFFFF),
    ),

    VendorModel(
      id: 'v08',
      name: 'Ziggurat Decor',
      logoUrl: 'https://picsum.photos/seed/v08-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v08-banner/1200/400',
      tagline: 'Contemporary home accents',
      primaryColor: const Color(0xFF111827),
      secondaryColor: const Color(0xFF374151),
      accentColor: const Color(0xFF9CA3AF),
      backgroundImageUrl: 'https://picsum.photos/seed/v08-bg/1600/600',
      gradientColors: [0xFF111827, 0xFF374151],
      fontFamily: 'Montserrat',
      textColor: const Color(0xFFFFFFFF),
    ),

    VendorModel(
      id: 'v09',
      name: 'Sulaymaniyah Styles',
      logoUrl: 'https://picsum.photos/seed/v09-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v09-banner/1200/400',
      tagline: 'Urban fashion & streetwear',
      primaryColor: const Color(0xFF0EA5A4),
      secondaryColor: const Color(0xFF06B6D4),
      accentColor: const Color(0xFFBAE6FD),
      backgroundImageUrl: 'https://picsum.photos/seed/v09-bg/1600/600',
      gradientColors: [0xFF0EA5A4, 0xFF06B6D4],
      fontFamily: 'Poppins',
      textColor: const Color(0xFF042A2B),
    ),

    VendorModel(
      id: 'v10',
      name: 'Diyala Delights',
      logoUrl: 'https://picsum.photos/seed/v10-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v10-banner/1200/400',
      tagline: 'Gourmet sweets & pastries',
      primaryColor: const Color(0xFFB91C1C),
      secondaryColor: const Color(0xFFF97316),
      accentColor: const Color(0xFFFECACA),
      backgroundImageUrl: 'https://picsum.photos/seed/v10-bg/1600/600',
      gradientColors: [0xFFB91C1C, 0xFFF97316],
      fontFamily: 'Lato',
      textColor: const Color(0xFFFFFFFF),
    ),

    VendorModel(
      id: 'v11',
      name: 'Karbala Ceramics',
      logoUrl: 'https://picsum.photos/seed/v11-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v11-banner/1200/400',
      tagline: 'Handmade pottery & kitchenware',
      primaryColor: const Color(0xFF92400E),
      secondaryColor: const Color(0xFFDC2626),
      accentColor: const Color(0xFFFDE68A),
      backgroundImageUrl: 'https://picsum.photos/seed/v11-bg/1600/600',
      gradientColors: [0xFF92400E, 0xFFDC2626],
      fontFamily: 'Cairo',
      textColor: const Color(0xFF0F172A),
    ),

    VendorModel(
      id: 'v12',
      name: 'Iraq Tech Store',
      logoUrl: 'https://picsum.photos/seed/v12-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v12-banner/1200/400',
      tagline: 'Gadgets & accessories',
      primaryColor: const Color(0xFF0EA5A4),
      secondaryColor: const Color(0xFF0284C7),
      accentColor: const Color(0xFFBAE6FD),
      backgroundImageUrl: 'https://picsum.photos/seed/v12-bg/1600/600',
      gradientColors: [0xFF0EA5A4, 0xFF0284C7],
      fontFamily: 'Roboto',
      textColor: const Color(0xFFFFFFFF),
    ),

    VendorModel(
      id: 'v13',
      name: 'Mahmoud\'s Sweets',
      logoUrl: 'https://picsum.photos/seed/v13-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v13-banner/1200/400',
      tagline: 'Traditional desserts & snacks',
      primaryColor: const Color(0xFFEF4444),
      secondaryColor: const Color(0xFFF97316),
      accentColor: const Color(0xFFFDE68A),
      backgroundImageUrl: 'https://picsum.photos/seed/v13-bg/1600/600',
      gradientColors: [0xFFEF4444, 0xFFF97316],
      fontFamily: 'Tajawal',
      textColor: const Color(0xFFFFFFFF),
    ),

    VendorModel(
      id: 'v14',
      name: 'Erbil Electronics',
      logoUrl: 'https://picsum.photos/seed/v14-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v14-banner/1200/400',
      tagline: 'Home appliances & electronics',
      primaryColor: const Color(0xFF0F172A),
      secondaryColor: const Color(0xFF1F2937),
      accentColor: const Color(0xFF9CA3AF),
      backgroundImageUrl: 'https://picsum.photos/seed/v14-bg/1600/600',
      gradientColors: [0xFF0F172A, 0xFF1F2937],
      fontFamily: 'Poppins',
      textColor: const Color(0xFFFFFFFF),
    ),

    VendorModel(
      id: 'v15',
      name: 'Basra Oils',
      logoUrl: 'https://picsum.photos/seed/v15-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v15-banner/1200/400',
      tagline: 'Premium olive oils & condiments',
      primaryColor: const Color(0xFF065F46),
      secondaryColor: const Color(0xFF10B981),
      accentColor: const Color(0xFFA7F3D0),
      backgroundImageUrl: 'https://picsum.photos/seed/v15-bg/1600/600',
      gradientColors: [0xFF065F46, 0xFF10B981],
      fontFamily: 'Lora',
      textColor: const Color(0xFFFFFFFF),
    ),

    VendorModel(
      id: 'v16',
      name: 'Baghdad Bites',
      logoUrl: 'https://picsum.photos/seed/v16-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v16-banner/1200/400',
      tagline: 'Street food & ready meals',
      primaryColor: const Color(0xFFEF4444),
      secondaryColor: const Color(0xFFEA580C),
      accentColor: const Color(0xFFFDE68A),
      backgroundImageUrl: 'https://picsum.photos/seed/v16-bg/1600/600',
      gradientColors: [0xFFEF4444, 0xFFEA580C],
      fontFamily: 'NotoSans',
      textColor: const Color(0xFFFFFFFF),
    ),

    VendorModel(
      id: 'v17',
      name: 'Handmade by Hiba',
      logoUrl: 'https://picsum.photos/seed/v17-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v17-banner/1200/400',
      tagline: 'Jewelry & small gifts',
      primaryColor: const Color(0xFF7C3AED),
      secondaryColor: const Color(0xFF6D28D9),
      accentColor: const Color(0xFFEDE9FE),
      backgroundImageUrl: 'https://picsum.photos/seed/v17-bg/1600/600',
      gradientColors: [0xFF7C3AED, 0xFF6D28D9],
      fontFamily: 'Cairo',
      textColor: const Color(0xFFFFFFFF),
    ),

    VendorModel(
      id: 'v18',
      name: 'Mosul Motors',
      logoUrl: 'https://picsum.photos/seed/v18-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v18-banner/1200/400',
      tagline: 'Auto parts & accessories',
      primaryColor: const Color(0xFF111827),
      secondaryColor: const Color(0xFF374151),
      accentColor: const Color(0xFF9CA3AF),
      backgroundImageUrl: 'https://picsum.photos/seed/v18-bg/1600/600',
      gradientColors: [0xFF111827, 0xFF374151],
      fontFamily: 'Roboto',
      textColor: const Color(0xFFFFFFFF),
    ),

    VendorModel(
      id: 'v19',
      name: 'Samarra Silver',
      logoUrl: 'https://picsum.photos/seed/v19-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v19-banner/1200/400',
      tagline: 'Silverware & ornaments',
      primaryColor: const Color(0xFF6366F1),
      secondaryColor: const Color(0xFF4338CA),
      accentColor: const Color(0xFFEDE9FE),
      backgroundImageUrl: 'https://picsum.photos/seed/v19-bg/1600/600',
      gradientColors: [0xFF6366F1, 0xFF4338CA],
      fontFamily: 'Lora',
      textColor: const Color(0xFFFFFFFF),
    ),

    VendorModel(
      id: 'v20',
      name: 'Erbil Eco Goods',
      logoUrl: 'https://picsum.photos/seed/v20-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v20-banner/1200/400',
      tagline: 'Eco-friendly household items',
      primaryColor: const Color(0xFF16A34A),
      secondaryColor: const Color(0xFF4ADE80),
      accentColor: const Color(0xFFD1FAE5),
      backgroundImageUrl: 'https://picsum.photos/seed/v20-bg/1600/600',
      gradientColors: [0xFF16A34A, 0xFF4ADE80],
      fontFamily: 'Poppins',
      textColor: const Color(0xFF042A2B),
    ),
  ];

  Future<List<VendorModel>> getVendors() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _vendors;
  }

  Future<List<ProductModel>> getProductsByVendor(String vendorId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return mockProducts.where((p) => p.vendorId == vendorId).toList();
  }

  Future<ProductModel?> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return mockProducts.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
