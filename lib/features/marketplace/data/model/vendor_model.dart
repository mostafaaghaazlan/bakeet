import 'package:flutter/material.dart';

class VendorModel {
  final String id;
  final String name;
  final String logoUrl;
  final String bannerUrl;
  final String tagline;
  final Color primaryColor;
  final Color secondaryColor;
  final Color accentColor;
  // Optional richer theme fields
  final String? backgroundImageUrl;
  final List<int>? gradientColors; // ARGB ints
  final String? fontFamily;
  final Color? textColor;

  VendorModel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.bannerUrl,
    required this.tagline,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
    this.backgroundImageUrl,
    this.gradientColors,
    this.fontFamily,
    this.textColor,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) => VendorModel(
    id: json['id'].toString(),
    name: json['name'] ?? '',
    logoUrl: json['logoUrl'] ?? '',
    bannerUrl: json['bannerUrl'] ?? '',
    tagline: json['tagline'] ?? '',
    primaryColor: Color(json['primaryColor'] ?? 0xFF2196F3),
    secondaryColor: Color(json['secondaryColor'] ?? 0xFF1976D2),
    accentColor: Color(json['accentColor'] ?? 0xFF64B5F6),
    backgroundImageUrl: json['backgroundImageUrl'],
    gradientColors: json['gradientColors'] != null
        ? List<int>.from(json['gradientColors'])
        : null,
    fontFamily: json['fontFamily'],
    textColor: json['textColor'] != null ? Color(json['textColor']) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'logoUrl': logoUrl,
    'bannerUrl': bannerUrl,
    'tagline': tagline,
    'primaryColor': primaryColor.toARGB32(),
    'secondaryColor': secondaryColor.toARGB32(),
    'accentColor': accentColor.toARGB32(),
    'backgroundImageUrl': backgroundImageUrl,
    'gradientColors': gradientColors,
    'fontFamily': fontFamily,
    'textColor': textColor?.toARGB32(),
  };
}
