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
    logoUrl: 'https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=400&h=400&fit=crop',
    bannerUrl: 'https://images.unsplash.com/photo-1544197150-b99a580bb7a8?w=1200&h=400&fit=crop',
    tagline: 'Traditional crafts & homeware',
    primaryColor: const Color(0xFFB91C1C), // warm red
    secondaryColor: const Color(0xFFEF4444),
    accentColor: const Color(0xFFFECACA),
    backgroundImageUrl: 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?w=1600&h=600&fit=crop',
    gradientColors: [0xFFB91C1C, 0xFFEF4444],
    fontFamily: 'Cairo',
    textColor: const Color(0xFFFAFAFA),
  ),

  VendorModel(
    id: 'v02',
    name: 'Erbil Studio',
    logoUrl: 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=400&h=400&fit=crop',
    bannerUrl: 'https://images.unsplash.com/photo-1505691723518-36a3d1d28e4a?w=1200&h=400&fit=crop',
    tagline: 'Modern design & furniture',
    primaryColor: const Color(0xFF6366F1),
    secondaryColor: const Color(0xFF4F46E5),
    accentColor: const Color(0xFF818CF8),
    backgroundImageUrl: 'https://images.unsplash.com/photo-1519710164239-da123dc03ef4?w=1600&h=600&fit=crop',
    gradientColors: [0xFF6366F1, 0xFF4F46E5, 0xFF818CF8],
    fontFamily: 'Montserrat',
    textColor: const Color(0xFFFFFFFF),
  ),

  VendorModel(
    id: 'v03',
    name: 'Mosul Handworks',
    logoUrl: 'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?w=400&h=400&fit=crop',
    bannerUrl: 'https://images.unsplash.com/photo-1549221986-4a5d8d1b2d6a?w=1200&h=400&fit=crop',
    tagline: 'Artisan rugs & textiles',
    primaryColor: const Color(0xFF92400E),
    secondaryColor: const Color(0xFFEA580C),
    accentColor: const Color(0xFFFDE68A),
    backgroundImageUrl: 'https://images.unsplash.com/photo-1504198453319-5ce911bafcde?w=1600&h=600&fit=crop',
    gradientColors: [0xFF92400E, 0xFFEA580C],
    fontFamily: 'Amiri',
    textColor: const Color(0xFF0F172A),
  ),

  VendorModel(
    id: 'v04',
    name: 'Basra Spice House',
    logoUrl: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&h=400&fit=crop',
    bannerUrl: 'https://images.unsplash.com/photo-1526318472351-c75fcf070c97?w=1200&h=400&fit=crop',
    tagline: 'Fine spices & blends',
    primaryColor: const Color(0xFF92400E),
    secondaryColor: const Color(0xFFB45309),
    accentColor: const Color(0xFFFDE68A),
    backgroundImageUrl: 'https://images.unsplash.com/photo-1466637574441-749b8f19452f?w=1600&h=600&fit=crop',
    gradientColors: [0xFF92400E, 0xFFB45309],
    fontFamily: 'Tajawal',
    textColor: const Color(0xFF0F172A),
  ),

  VendorModel(
    id: 'v05',
    name: 'Nineveh Antiques',
    logoUrl: 'https://images.unsplash.com/photo-1549880338-65ddcdfd017b?w=400&h=400&fit=crop',
    bannerUrl: 'https://images.unsplash.com/photo-1509395176047-4a66953fd231?w=1200&h=400&fit=crop',
    tagline: 'Curated vintage pieces',
    primaryColor: const Color(0xFF854D0E),
    secondaryColor: const Color(0xFF7C2D12),
    accentColor: const Color(0xFFFDE68A),
    backgroundImageUrl: 'https://images.unsplash.com/photo-1504198458649-3128b932f49b?w=1600&h=600&fit=crop',
    gradientColors: [0xFF854D0E, 0xFF7C2D12],
    fontFamily: 'Lora',
    textColor: const Color(0xFFFAFAFA),
  ),

  VendorModel(
    id: 'v06',
    name: 'Kurdish Loom',
    logoUrl: 'https://images.unsplash.com/photo-1531974328632-8f0f0a799976?w=400&h=400&fit=crop',
    bannerUrl: 'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=1200&h=400&fit=crop',
    tagline: 'Handwoven textiles & scarves',
    primaryColor: const Color(0xFF0EA5A4),
    secondaryColor: const Color(0xFF0891B2),
    accentColor: const Color(0xFF67E8F9),
    backgroundImageUrl: 'https://images.unsplash.com/photo-1520975923396-6c2f0a6d5f3d?w=1600&h=600&fit=crop',
    gradientColors: [0xFF0EA5A4, 0xFF0891B2],
    fontFamily: 'Cairo',
    textColor: const Color(0xFF042A2B),
  ),

  VendorModel(
    id: 'v07',
    name: 'Tigris Books',
    logoUrl: 'https://images.unsplash.com/photo-1519681393784-1208c6a6f6b8?w=400&h=400&fit=crop',
    bannerUrl: 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=1200&h=400&fit=crop',
    tagline: 'Local authors & English imports',
    primaryColor: const Color(0xFF065F46),
    secondaryColor: const Color(0xFF10B981),
    accentColor: const Color(0xFFA7F3D0),
    backgroundImageUrl: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=1600&h=600&fit=crop',
    gradientColors: [0xFF065F46, 0xFF10B981],
    fontFamily: 'NotoSans',
    textColor: const Color(0xFFFFFFFF),
  ),

  VendorModel(
    id: 'v08',
    name: 'Ziggurat Decor',
    logoUrl: 'https://images.unsplash.com/photo-1505691723518-36a3d1d28e4a?w=400&h=400&fit=crop',
    bannerUrl: 'https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=1200&h=400&fit=crop',
    tagline: 'Contemporary home accents',
    primaryColor: const Color(0xFF111827),
    secondaryColor: const Color(0xFF374151),
    accentColor: const Color(0xFF9CA3AF),
    backgroundImageUrl: 'https://images.unsplash.com/photo-1493666438817-866a91353ca9?w=1600&h=600&fit=crop',
    gradientColors: [0xFF111827, 0xFF374151],
    fontFamily: 'Montserrat',
    textColor: const Color(0xFFFFFFFF),
  ),

  VendorModel(
    id: 'v09',
    name: 'Sulaymaniyah Styles',
    logoUrl: 'https://images.unsplash.com/photo-1542117843-9a036f3d3a70?w=400&h=400&fit=crop',
    bannerUrl: 'https://images.unsplash.com/photo-1513708928671-3e7f2f2b1c3b?w=1200&h=400&fit=crop',
    tagline: 'Urban fashion & streetwear',
    primaryColor: const Color(0xFF0EA5A4),
    secondaryColor: const Color(0xFF06B6D4),
    accentColor: const Color(0xFFBAE6FD),
    backgroundImageUrl: 'https://images.unsplash.com/photo-1520975912708-7a6a9d6d5b30?w=1600&h=600&fit=crop',
    gradientColors: [0xFF0EA5A4, 0xFF06B6D4],
    fontFamily: 'Poppins',
    textColor: const Color(0xFF042A2B),
  ),

  VendorModel(
    id: 'v10',
    name: 'Diyala Delights',
    logoUrl: 'https://images.unsplash.com/photo-1526318472351-c75fcf070c97?w=400&h=400&fit=crop',
    bannerUrl: 'https://images.unsplash.com/photo-1502741126161-b048400d6f05?w=1200&h=400&fit=crop',
    tagline: 'Gourmet sweets & pastries',
    primaryColor: const Color(0xFFB91C1C),
    secondaryColor: const Color(0xFFF97316),
    accentColor: const Color(0xFFFECACA),
    backgroundImageUrl: 'https://images.unsplash.com/photo-1512058564366-c9e3d3287c3f?w=1600&h=600&fit=crop',
    gradientColors: [0xFFB91C1C, 0xFFF97316],
    fontFamily: 'Lato',
    textColor: const Color(0xFFFFFFFF),
  ),

  VendorModel(
    id: 'v11',
    name: 'Karbala Ceramics',
    logoUrl: 'https://images.unsplash.com/photo-1519710164239-9b8a7f8b1f14?w=400&h=400&fit=crop',
    bannerUrl: 'https://images.unsplash.com/photo-1506277881230-3b6a1f4bdb9f?w=1200&h=400&fit=crop',
    tagline: 'Handmade pottery & kitchenware',
    primaryColor: const Color(0xFF92400E),
    secondaryColor: const Color(0xFFDC2626),
    accentColor: const Color(0xFFFDE68A),
    backgroundImageUrl: 'https://images.unsplash.com/photo-1515548213410-68f4b9b4d6c1?w=1600&h=600&fit=crop',
    gradientColors: [0xFF92400E, 0xFFDC2626],
    fontFamily: 'Cairo',
    textColor: const Color(0xFF0F172A),
  ),

  VendorModel(
    id: 'v12',
    name: 'Iraq Tech Store',
    logoUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=400&h=400&fit=crop',
    bannerUrl: 'https://images.unsplash.com/photo-1519389950473-47ba0277781c?w=1200&h=400&fit=crop',
    tagline: 'Gadgets & accessories',
    primaryColor: const Color(0xFF0EA5A4),
    secondaryColor: const Color(0xFF0284C7),
    accentColor: const Color(0xFFBAE6FD),
    backgroundImageUrl: 'https://images.unsplash.com/photo-1518770660439-4636190af475?w=1600&h=600&fit=crop',
    gradientColors: [0xFF0EA5A4, 0xFF0284C7],
    fontFamily: 'Roboto',
    textColor: const Color(0xFFFFFFFF),
  ),

  VendorModel(
    id: 'v13',
    name: 'Mahmoud\'s Sweets',
    logoUrl: 'https://images.unsplash.com/photo-1516687427003-2b9e28b1f1c2?w=400&h=400&fit=crop',
    bannerUrl: 'https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?w=1200&h=400&fit=crop',
    tagline: 'Traditional desserts & snacks',
    primaryColor: const Color(0xFFEF4444),
    secondaryColor: const Color(0xFFF97316),
    accentColor: const Color(0xFFFDE68A),
    backgroundImageUrl: 'https://images.unsplash.com/photo-1527515637460-0a6f3b6417a8?w=1600&h=600&fit=crop',
    gradientColors: [0xFFEF4444, 0xFFF97316],
    fontFamily: 'Tajawal',
    textColor: const Color(0xFFFFFFFF),
  ),

  VendorModel(
    id: 'v14',
    name: 'Erbil Electronics',
    logoUrl: 'https://images.unsplash.com/photo-1510557880182-3d4d3c9b5f4f?w=400&h=400&fit=crop',
    bannerUrl: 'https://images.unsplash.com/photo-1517048676732-d65bc937f952?w=1200&h=400&fit=crop',
    tagline: 'Home appliances & electronics',
    primaryColor: const Color(0xFF0F172A),
    secondaryColor: const Color(0xFF1F2937),
    accentColor: const Color(0xFF9CA3AF),
    backgroundImageUrl: 'https://images.unsplash.com/photo-1518779578993-ec3579fee39f?w=1600&h=600&fit=crop',
    gradientColors: [0xFF0F172A, 0xFF1F2937],
    fontFamily: 'Poppins',
    textColor: const Color(0xFFFFFFFF),
  ),

  VendorModel(
    id: 'v15',
    name: 'Basra Oils',
    logoUrl: 'https://images.unsplash.com/photo-1519744792095-2f2205e87b6f?w=400&h=400&fit=crop',
    bannerUrl: 'https://images.unsplash.com/photo-1504754524776-8f4f37790ca0?w=1200&h=400&fit=crop',
    tagline: 'Premium olive oils & condiments',
    primaryColor: const Color(0xFF065F46),
    secondaryColor: const Color(0xFF10B981),
    accentColor: const Color(0xFFA7F3D0),
    backgroundImageUrl: 'https://images.unsplash.com/photo-1498575207499-0c1c1b1d1e6a?w=1600&h=600&fit=crop',
    gradientColors: [0xFF065F46, 0xFF10B981],
    fontFamily: 'Lora',
    textColor: const Color(0xFFFFFFFF),
  ),

  VendorModel(
    id: 'v16',
    name: 'Baghdad Bites',
    logoUrl: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400&h=400&fit=crop',
    bannerUrl: 'https://images.unsplash.com/photo-1512058564366-c9e3d3287c3f?w=1200&h=400&fit=crop',
    tagline: 'Street food & ready meals',
    primaryColor: const Color(0xFFEF4444),
    secondaryColor: const Color(0xFFEA580C),
    accentColor: const Color(0xFFFDE68A),
    backgroundImageUrl: 'https://images.unsplash.com/photo-1543353071-873f17a7a088?w=1600&h=600&fit=crop',
    gradientColors: [0xFFEF4444, 0xFFEA580C],
    fontFamily: 'NotoSans',
    textColor: const Color(0xFFFFFFFF),
  ),

  VendorModel(
    id: 'v17',
    name: 'Handmade by Hiba',
    logoUrl: 'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=400&h=400&fit=crop',
    bannerUrl: 'https://images.unsplash.com/photo-1522199710521-72d69614c702?w=1200&h=400&fit=crop',
    tagline: 'Jewelry & small gifts',
    primaryColor: const Color(0xFF7C3AED),
    secondaryColor: const Color(0xFF6D28D9),
    accentColor: const Color(0xFFEDE9FE),
    backgroundImageUrl: 'https://images.unsplash.com/photo-1519741490931-8f8e2b3c2c3a?w=1600&h=600&fit=crop',
    gradientColors: [0xFF7C3AED, 0xFF6D28D9],
    fontFamily: 'Cairo',
    textColor: const Color(0xFFFFFFFF),
  ),

  VendorModel(
    id: 'v18',
    name: 'Mosul Motors',
    logoUrl: 'https://images.unsplash.com/photo-1502877338535-766e1452684a?w=400&h=400&fit=crop',
    bannerUrl: 'https://images.unsplash.com/photo-1511919884226-fd3cad34687c?w=1200&h=400&fit=crop',
    tagline: 'Auto parts & accessories',
    primaryColor: const Color(0xFF111827),
    secondaryColor: const Color(0xFF374151),
    accentColor: const Color(0xFF9CA3AF),
    backgroundImageUrl: 'https://images.unsplash.com/photo-1511919884226-fd3cad34687c?w=1600&h=600&fit=crop',
    gradientColors: [0xFF111827, 0xFF374151],
    fontFamily: 'Roboto',
    textColor: const Color(0xFFFFFFFF),
  ),

  VendorModel(
    id: 'v19',
    name: 'Samarra Silver',
    logoUrl: 'https://images.unsplash.com/photo-1526403224745-7376e3f0f08f?w=400&h=400&fit=crop',
    bannerUrl: 'https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb?w=1200&h=400&fit=crop',
    tagline: 'Silverware & ornaments',
    primaryColor: const Color(0xFF6366F1),
    secondaryColor: const Color(0xFF4338CA),
    accentColor: const Color(0xFFEDE9FE),
    backgroundImageUrl: 'https://images.unsplash.com/photo-1503341455253-b2e723bb3dbb?w=1600&h=600&fit=crop',
    gradientColors: [0xFF6366F1, 0xFF4338CA],
    fontFamily: 'Lora',
    textColor: const Color(0xFFFFFFFF),
  ),

  VendorModel(
    id: 'v20',
    name: 'Erbil Eco Goods',
    logoUrl: 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?w=400&h=400&fit=crop',
    bannerUrl: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=1200&h=400&fit=crop',
    tagline: 'Eco-friendly household items',
    primaryColor: const Color(0xFF16A34A),
    secondaryColor: const Color(0xFF4ADE80),
    accentColor: const Color(0xFFD1FAE5),
    backgroundImageUrl: 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=1600&h=600&fit=crop',
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
