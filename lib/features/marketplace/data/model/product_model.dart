class ProductModel {
  final String id;
  final String vendorId;
  final String title;
  final List<String> images;
  final double price;
  final double? compareAtPrice;
  final String shortDescription;
  final List<String> tags;
  final String category;
  final String description;
  final List<ProductColor>? availableColors;

  ProductModel({
    required this.id,
    required this.vendorId,
    required this.title,
    required this.images,
    required this.price,
    this.compareAtPrice,
    required this.shortDescription,
    required this.tags,
    required this.category,
    required this.description,
    this.availableColors,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: json['id'].toString(),
    vendorId: json['vendorId'].toString(),
    title: json['title'] ?? '',
    images:
        (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        [],
    price: (json['price'] ?? 0).toDouble(),
    compareAtPrice: json['compareAtPrice'] != null
        ? (json['compareAtPrice'] as num).toDouble()
        : null,
    shortDescription: json['shortDescription'] ?? '',
    tags:
        (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        [],
    category: json['category'] ?? '',
    description: json['description'] ?? '',
    availableColors: (json['availableColors'] as List<dynamic>?)
        ?.map((e) => ProductColor.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'vendorId': vendorId,
    'title': title,
    'images': images,
    'price': price,
    'compareAtPrice': compareAtPrice,
    'shortDescription': shortDescription,
    'tags': tags,
    'category': category,
    'description': description,
    'availableColors': availableColors?.map((c) => c.toJson()).toList(),
  };
}

class ProductColor {
  final String name;
  final int colorValue;

  ProductColor({required this.name, required this.colorValue});

  Map<String, dynamic> toJson() => {'name': name, 'colorValue': colorValue};

  factory ProductColor.fromJson(Map<String, dynamic> json) =>
      ProductColor(name: json['name'], colorValue: json['colorValue']);
}
