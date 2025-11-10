import 'package:flutter/material.dart';
import 'package:bakeet/features/marketplace/data/model/product_model.dart';
import 'package:bakeet/features/marketplace/data/model/vendor_model.dart';

import 'mock_products.dart';

class MarketplaceRepository {
  // Singleton pattern
  static final MarketplaceRepository _instance = MarketplaceRepository._internal();
  factory MarketplaceRepository() => _instance;
  MarketplaceRepository._internal();

  // Mock in-app data
  final List<VendorModel> _vendors = [
    VendorModel(
      id: 'v01',
      name: 'امينو',
      logoUrl: 'https://picsum.photos/seed/v01-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v01-banner/1200/400',
      tagline: 'حرف تقليدية وأدوات منزلية',
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
      name: 'استوديو أربيل',
      logoUrl: 'https://picsum.photos/seed/v02-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v02-banner/1200/400',
      tagline: 'تصميم عصري وأثاث',
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
      name: 'حرفيات الموصل',
      logoUrl: 'https://picsum.photos/seed/v03-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v03-banner/1200/400',
      tagline: 'سجاد ومنسوجات حرفية',
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
      name: 'بيت البصرة للبهارات',
      logoUrl: 'https://picsum.photos/seed/v04-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v04-banner/1200/400',
      tagline: 'بهارات فاخرة ومخلوطات',
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
      name: 'تحف نينوى',
      logoUrl: 'https://picsum.photos/seed/v05-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v05-banner/1200/400',
      tagline: 'قطع عتيقة مختارة',
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
      name: 'نول كردستان',
      logoUrl: 'https://picsum.photos/seed/v06-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v06-banner/1200/400',
      tagline: 'منسوجات وأوشحة منسوجة يدوياً',
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
      name: 'مكتبة دجلة',
      logoUrl: 'https://picsum.photos/seed/v07-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v07-banner/1200/400',
      tagline: 'مؤلفون محليون وكتب مستوردة',
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
      name: 'ديكور الزقورة',
      logoUrl: 'https://picsum.photos/seed/v08-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v08-banner/1200/400',
      tagline: 'إكسسوارات منزلية معاصرة',
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
      name: 'أزياء السليمانية',
      logoUrl: 'https://picsum.photos/seed/v09-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v09-banner/1200/400',
      tagline: 'موضة حضرية وملابس الشارع',
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
      name: 'لذائذ ديالى',
      logoUrl: 'https://picsum.photos/seed/v10-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v10-banner/1200/400',
      tagline: 'حلويات ومعجنات فاخرة',
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
      name: 'خزفيات كربلاء',
      logoUrl: 'https://picsum.photos/seed/v11-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v11-banner/1200/400',
      tagline: 'فخار وأدوات مطبخ يدوية الصنع',
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
      name: 'متجر العراق للتكنولوجيا',
      logoUrl: 'https://picsum.photos/seed/v12-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v12-banner/1200/400',
      tagline: 'أجهزة وإكسسوارات',
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
      name: 'حلويات محمود',
      logoUrl: 'https://picsum.photos/seed/v13-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v13-banner/1200/400',
      tagline: 'حلويات ووجبات خفيفة تقليدية',
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
      name: 'إلكترونيات أربيل',
      logoUrl: 'https://picsum.photos/seed/v14-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v14-banner/1200/400',
      tagline: 'أجهزة منزلية وإلكترونيات',
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
      name: 'زيوت البصرة',
      logoUrl: 'https://picsum.photos/seed/v15-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v15-banner/1200/400',
      tagline: 'زيوت زيتون فاخرة وتوابل',
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
      name: 'لقيمات بغداد',
      logoUrl: 'https://picsum.photos/seed/v16-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v16-banner/1200/400',
      tagline: 'طعام الشارع ووجبات جاهزة',
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
      name: 'صناعة هبة اليدوية',
      logoUrl: 'https://picsum.photos/seed/v17-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v17-banner/1200/400',
      tagline: 'مجوهرات وهدايا صغيرة',
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
      name: 'موتورات الموصل',
      logoUrl: 'https://picsum.photos/seed/v18-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v18-banner/1200/400',
      tagline: 'قطع غيار وإكسسوارات سيارات',
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
      name: 'فضيات سامراء',
      logoUrl: 'https://picsum.photos/seed/v19-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v19-banner/1200/400',
      tagline: 'فضيات وزينة',
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
      name: 'منتجات أربيل الصديقة للبيئة',
      logoUrl: 'https://picsum.photos/seed/v20-logo/400/400',
      bannerUrl: 'https://picsum.photos/seed/v20-banner/1200/400',
      tagline: 'منتجات منزلية صديقة للبيئة',
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

  Future<VendorModel> addVendor(VendorModel vendor) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _vendors.add(vendor);
    print('🔷 Vendor added to repository: ${vendor.id} - ${vendor.name}');
    print('🔷 Total vendors in repository: ${_vendors.length}');
    return vendor;
  }

  Future<void> addProduct(ProductModel product) async {
    await Future.delayed(const Duration(milliseconds: 400));
    mockProducts.add(product);
    print('🔷 Product added to repository: ${product.id} - ${product.title}');
    print('🔷 Total products in repository: ${mockProducts.length}');
  }

  Future<List<ProductModel>> getProductsByVendor(String vendorId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final products = mockProducts.where((p) => p.vendorId == vendorId).toList();
    print(
      '🔷 Getting products for vendor $vendorId: found ${products.length} products',
    );
    return products;
  }

  Future<List<ProductModel>> getAllProducts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockProducts;
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
