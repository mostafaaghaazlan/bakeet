class VendorModel {
  final String id;
  final String name;
  final String logoUrl;
  final String bannerUrl;
  final String tagline;

  VendorModel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.bannerUrl,
    required this.tagline,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) => VendorModel(
    id: json['id'].toString(),
    name: json['name'] ?? '',
    logoUrl: json['logoUrl'] ?? '',
    bannerUrl: json['bannerUrl'] ?? '',
    tagline: json['tagline'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'logoUrl': logoUrl,
    'bannerUrl': bannerUrl,
    'tagline': tagline,
  };
}
