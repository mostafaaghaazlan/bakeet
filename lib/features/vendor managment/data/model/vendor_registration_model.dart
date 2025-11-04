import 'dart:io';

class VendorRegistrationModel {
  final String vendorName;
  final String tagline;
  final String description;
  final File? logoFile;
  final String? logoUrl;
  final File? bannerFile;
  final String? bannerUrl;
  final File? backgroundFile;
  final String? backgroundUrl;
  final List<ProductRegistrationModel> products;
  final int primaryColor;
  final int secondaryColor;
  final int accentColor;

  VendorRegistrationModel({
    required this.vendorName,
    required this.tagline,
    required this.description,
    this.logoFile,
    this.logoUrl,
    this.bannerFile,
    this.bannerUrl,
    this.backgroundFile,
    this.backgroundUrl,
    this.products = const [],
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
  });

  Map<String, dynamic> toJson() => {
    'vendorName': vendorName,
    'tagline': tagline,
    'description': description,
    'products': products.map((p) => p.toJson()).toList(),
    'primaryColor': primaryColor,
    'secondaryColor': secondaryColor,
    'accentColor': accentColor,
    'bannerUrl': bannerUrl,
    'backgroundUrl': backgroundUrl,
  };

  VendorRegistrationModel copyWith({
    String? vendorName,
    String? tagline,
    String? description,
    File? logoFile,
    String? logoUrl,
    File? bannerFile,
    String? bannerUrl,
    File? backgroundFile,
    String? backgroundUrl,
    List<ProductRegistrationModel>? products,
    int? primaryColor,
    int? secondaryColor,
    int? accentColor,
  }) {
    return VendorRegistrationModel(
      vendorName: vendorName ?? this.vendorName,
      tagline: tagline ?? this.tagline,
      description: description ?? this.description,
      logoFile: logoFile ?? this.logoFile,
      logoUrl: logoUrl ?? this.logoUrl,
      bannerFile: bannerFile ?? this.bannerFile,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      backgroundFile: backgroundFile ?? this.backgroundFile,
      backgroundUrl: backgroundUrl ?? this.backgroundUrl,
      products: products ?? this.products,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      accentColor: accentColor ?? this.accentColor,
    );
  }
}

class ProductRegistrationModel {
  final String id;
  final String title;
  final String description;
  final String shortDescription;
  final double price;
  final double? compareAtPrice;
  final String category;
  final List<String> tags;
  final List<File> imageFiles;
  final List<String> imageUrls;
  final List<ColorOption> availableColors;

  ProductRegistrationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.shortDescription,
    required this.price,
    this.compareAtPrice,
    required this.category,
    this.tags = const [],
    this.imageFiles = const [],
    this.imageUrls = const [],
    this.availableColors = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'shortDescription': shortDescription,
    'price': price,
    'compareAtPrice': compareAtPrice,
    'category': category,
    'tags': tags,
    'availableColors': availableColors.map((c) => c.toJson()).toList(),
  };

  ProductRegistrationModel copyWith({
    String? id,
    String? title,
    String? description,
    String? shortDescription,
    double? price,
    double? compareAtPrice,
    String? category,
    List<String>? tags,
    List<File>? imageFiles,
    List<String>? imageUrls,
    List<ColorOption>? availableColors,
  }) {
    return ProductRegistrationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      price: price ?? this.price,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      imageFiles: imageFiles ?? this.imageFiles,
      imageUrls: imageUrls ?? this.imageUrls,
      availableColors: availableColors ?? this.availableColors,
    );
  }
}

class ColorOption {
  final String name;
  final int colorValue;

  ColorOption({required this.name, required this.colorValue});

  Map<String, dynamic> toJson() => {'name': name, 'colorValue': colorValue};

  factory ColorOption.fromJson(Map<String, dynamic> json) =>
      ColorOption(name: json['name'], colorValue: json['colorValue']);
}
