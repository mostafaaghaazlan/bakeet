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

  VendorModel({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.bannerUrl,
    required this.tagline,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentColor,
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
  };
}
