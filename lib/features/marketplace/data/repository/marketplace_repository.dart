import 'package:flutter/material.dart';
import 'package:bakeet/features/marketplace/data/model/product_model.dart';
import 'package:bakeet/features/marketplace/data/model/vendor_model.dart';

class MarketplaceRepository {
  // Mock in-app data
  final List<VendorModel> _vendors = [
    VendorModel(
      id: 'v1',
      name: 'Baghdad Crafts',
      logoUrl:
          'https://images.unsplash.com/photo-1545239351-1141bd82e8a6?w=400&h=400&fit=crop',
      bannerUrl:
          'https://images.unsplash.com/photo-1503602642458-232111445657?w=1200&h=400&fit=crop',
      tagline: 'Handmade & traditional',
      primaryColor: const Color(0xFFD97757), // Warm terracotta
      secondaryColor: const Color(0xFFC95D3F), // Darker terracotta
      accentColor: const Color(0xFFE89B80), // Light terracotta
    ),
    VendorModel(
      id: 'v2',
      name: 'Erbil Studio',
      logoUrl:
          'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=400&h=400&fit=crop',
      bannerUrl:
          'https://images.unsplash.com/photo-1505691723518-36a3d1d28e4a?w=1200&h=400&fit=crop',
      tagline: 'Modern design & furniture',
      primaryColor: const Color(0xFF6366F1), // Modern indigo
      secondaryColor: const Color(0xFF4F46E5), // Deep indigo
      accentColor: const Color(0xFF818CF8), // Light indigo
    ),
    VendorModel(
      id: 'v3',
      name: 'Basra Home',
      logoUrl:
          'https://images.unsplash.com/photo-1519710164239-da123dc03ef4?w=400&h=400&fit=crop',
      bannerUrl:
          'https://images.unsplash.com/photo-1493666438817-866a91353ca9?w=1200&h=400&fit=crop',
      tagline: 'Local home essentials',
      primaryColor: const Color(0xFF10B981), // Fresh green
      secondaryColor: const Color(0xFF059669), // Emerald green
      accentColor: const Color(0xFF34D399), // Light green
    ),
  ];

  final List<ProductModel> _products = [
    ProductModel(
      id: 'p1',
      vendorId: 'v1',
      title: 'Handmade Ceramic Vase',
      images: [
        'https://images.unsplash.com/photo-1503602642458-232111445657?w=1200&h=800&fit=crop',
      ],
      price: 45000.0,
      compareAtPrice: 60000.0,
      shortDescription:
          'A beautiful handmade ceramic vase crafted by local artisans in Iraq.',
      tags: ['home', 'decor'],
      category: 'Home',
    ),
    ProductModel(
      id: 'p2',
      vendorId: 'v1',
      title: 'Woven Storage Basket',
      images: [
        'https://images.unsplash.com/photo-1540574163026-643ea20ade25?w=1200&h=800&fit=crop',
      ],
      price: 22000.0,
      compareAtPrice: null,
      shortDescription:
          'Natural woven basket ideal for storage and home styling.',
      tags: ['home', 'storage'],
      category: 'Home',
    ),
    ProductModel(
      id: 'p3',
      vendorId: 'v2',
      title: 'Oak Side Table',
      images: [
        'https://images.unsplash.com/photo-1540574163026-643ea20ade25?w=1200&h=800&fit=crop',
      ],
      price: 120000.0,
      compareAtPrice: 150000.0,
      shortDescription: 'Solid oak side table with modern lines, made locally.',
      tags: ['furniture'],
      category: 'Furniture',
    ),
    ProductModel(
      id: 'p4',
      vendorId: 'v3',
      title: 'Comfort Hoodie',
      images: [
        'https://images.unsplash.com/photo-1520975911044-3d4a5a0a0b4e?w=1200&h=800&fit=crop',
      ],
      price: 55000.0,
      compareAtPrice: 80000.0,
      shortDescription:
          'Comfortable streetwear hoodie from Basra Home collection.',
      tags: ['clothing'],
      category: 'Clothing',
    ),
  ];

  Future<List<VendorModel>> getVendors() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _vendors;
  }

  Future<List<ProductModel>> getProductsByVendor(String vendorId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _products.where((p) => p.vendorId == vendorId).toList();
  }

  Future<ProductModel?> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
