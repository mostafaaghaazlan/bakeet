import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import '../../marketplace/data/model/product_model.dart';
import '../../marketplace/data/model/vendor_model.dart';
import '../../marketplace/data/repository/marketplace_repository.dart';
import '../data/model/vendor_registration_model.dart';

part 'v_vendor_managment_state.dart';

class VVendorManagmentCubit extends Cubit<VVendorManagmentState> {
  final MarketplaceRepository _repository;

  VVendorManagmentCubit(this._repository) : super(VVendorManagmentInitial());

  VendorRegistrationModel _vendorData = VendorRegistrationModel(
    vendorName: '',
    tagline: '',
    description: '',
    primaryColor: 0xFFB91C1C,
    secondaryColor: 0xFFEF4444,
    accentColor: 0xFFFECACA,
  );

  VendorRegistrationModel get vendorData => _vendorData;

  void updateVendorInfo({
    String? vendorName,
    String? tagline,
    String? description,
    int? primaryColor,
    int? secondaryColor,
    int? accentColor,
  }) {
    _vendorData = _vendorData.copyWith(
      vendorName: vendorName,
      tagline: tagline,
      description: description,
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      accentColor: accentColor,
    );
    emit(VendorDataUpdated(_vendorData));
  }

  void updateLogo(dynamic logo) {
    if (logo is String) {
      _vendorData = _vendorData.copyWith(logoUrl: logo);
    } else {
      _vendorData = _vendorData.copyWith(logoFile: logo);
    }
    emit(VendorDataUpdated(_vendorData));
  }

  void updateBanner(dynamic banner) {
    if (banner is String) {
      _vendorData = _vendorData.copyWith(bannerUrl: banner);
    } else {
      _vendorData = _vendorData.copyWith(bannerFile: banner);
    }
    emit(VendorDataUpdated(_vendorData));
  }

  void updateBackground(dynamic background) {
    if (background is String) {
      _vendorData = _vendorData.copyWith(backgroundUrl: background);
    } else {
      _vendorData = _vendorData.copyWith(backgroundFile: background);
    }
    emit(VendorDataUpdated(_vendorData));
  }

  void addProduct(ProductRegistrationModel product) {
    print('🔵 Adding product: ${product.title}');
    final products = List<ProductRegistrationModel>.from(_vendorData.products);
    products.add(product);
    _vendorData = _vendorData.copyWith(products: products);
    print('🔵 Total products after add: ${_vendorData.products.length}');
    print('🔵 Emitting ProductAdded state');
    emit(ProductAdded(product));
  }

  void updateProduct(int index, ProductRegistrationModel product) {
    final products = List<ProductRegistrationModel>.from(_vendorData.products);
    if (index >= 0 && index < products.length) {
      products[index] = product;
      _vendorData = _vendorData.copyWith(products: products);
      emit(ProductUpdated(index, product));
    }
  }

  void removeProduct(int index) {
    final products = List<ProductRegistrationModel>.from(_vendorData.products);
    if (index >= 0 && index < products.length) {
      products.removeAt(index);
      _vendorData = _vendorData.copyWith(products: products);
      emit(ProductRemoved(index));
    }
  }

  Future<void> submitVendorRegistration() async {
    emit(VendorRegistrationLoading());
    try {
      // Validation
      if (_vendorData.vendorName.isEmpty) {
        emit(VendorRegistrationError('Vendor name is required'));
        return;
      }
      if (_vendorData.logoFile == null && _vendorData.logoUrl == null) {
        emit(VendorRegistrationError('Logo is required'));
        return;
      }
      if (_vendorData.products.isEmpty) {
        emit(VendorRegistrationError('At least one product is required'));
        return;
      }

      // Generate a unique vendor ID
      final vendorId = 'vendor_${DateTime.now().millisecondsSinceEpoch}';

      // Convert VendorRegistrationModel to VendorModel (for preview)
      final vendor = VendorModel(
        id: vendorId,
        name: _vendorData.vendorName,
        logoUrl: _vendorData.logoFile != null
            ? _vendorData.logoFile!.path
            : (_vendorData.logoUrl ??
                  'https://picsum.photos/seed/$vendorId-logo/400/400'),
        bannerUrl: _vendorData.bannerFile != null
            ? _vendorData.bannerFile!.path
            : (_vendorData.bannerUrl ??
                  'https://picsum.photos/seed/$vendorId-banner/1200/400'),
        tagline: _vendorData.tagline.isNotEmpty
            ? _vendorData.tagline
            : 'New vendor',
        primaryColor: Color(_vendorData.primaryColor),
        secondaryColor: Color(_vendorData.secondaryColor),
        accentColor: Color(_vendorData.accentColor),
        backgroundImageUrl: _vendorData.backgroundFile != null
            ? _vendorData.backgroundFile!.path
            : (_vendorData.backgroundUrl ??
                  'https://picsum.photos/seed/$vendorId-bg/1600/600'),
        gradientColors: [_vendorData.primaryColor, _vendorData.secondaryColor],
        fontFamily: 'Cairo',
        textColor: const Color(0xFFFFFFFF),
      );

      // Convert products for preview
      print('🟢 Preparing ${_vendorData.products.length} products for preview');
      final products = <ProductModel>[];
      for (final productReg in _vendorData.products) {
        // Use uploaded image files if available, otherwise use URLs, fallback to placeholder
        List<String> productImages;
        if (productReg.imageFiles.isNotEmpty) {
          // Convert File paths to strings
          productImages = productReg.imageFiles
              .map((file) => file.path)
              .toList();
        } else if (productReg.imageUrls.isNotEmpty) {
          productImages = productReg.imageUrls;
        } else {
          // Fallback to placeholder
          productImages = [
            'https://picsum.photos/seed/${productReg.id}/800/800',
          ];
        }

        // Convert ColorOption to ProductColor
        final availableColors = productReg.availableColors
            .map(
              (colorOption) => ProductColor(
                name: colorOption.name,
                colorValue: colorOption.colorValue,
              ),
            )
            .toList();

        print(
          '🎨 Product ${productReg.title}: Converting ${productReg.availableColors.length} colors',
        );
        if (availableColors.isNotEmpty) {
          print('🎨 Colors: ${availableColors.map((c) => c.name).join(", ")}');
        }

        final product = ProductModel(
          id: productReg.id,
          vendorId: vendorId,
          title: productReg.title,
          images: productImages,
          price: productReg.price,
          compareAtPrice: productReg.compareAtPrice,
          shortDescription: productReg.shortDescription,
          tags: productReg.tags,
          category: productReg.category,
          description: productReg.description,
          availableColors: availableColors.isNotEmpty ? availableColors : null,
        );
        products.add(product);
      }

      // Emit success state with vendor and products for preview (not saved yet)
      emit(
        VendorRegistrationSuccess(
          'Review your storefront',
          vendorId,
          _vendorData,
          vendor: vendor,
          products: products,
        ),
      );
    } catch (e) {
      emit(VendorRegistrationError(e.toString()));
    }
  }

  Future<void> approveAndPublishVendor(
    String vendorId,
    VendorModel vendor,
    List<ProductModel> products,
  ) async {
    emit(VendorRegistrationLoading());
    try {
      // Add vendor to repository
      print('🟢 Adding vendor to repository: $vendorId - ${vendor.name}');
      await _repository.addVendor(vendor);
      print('🟢 Vendor added successfully');

      // Add products
      print('🟢 Adding ${products.length} products');
      for (final product in products) {
        print(
          '🟢 Adding product: ${product.title} (${product.id}) for vendor $vendorId with ${product.images.length} images and ${product.availableColors?.length ?? 0} colors',
        );
        if (product.availableColors != null &&
            product.availableColors!.isNotEmpty) {
          print(
            '🎨 Product colors: ${product.availableColors!.map((c) => c.name).join(", ")}',
          );
        }
        await _repository.addProduct(product);
      }
      print('🟢 All products added successfully');

      emit(
        VendorPublished(
          'Vendor published successfully!',
          vendorId,
          vendor.name,
        ),
      );
    } catch (e) {
      emit(VendorRegistrationError(e.toString()));
    }
  }

  void reset() {
    _vendorData = VendorRegistrationModel(
      vendorName: '',
      tagline: '',
      description: '',
      primaryColor: 0xFFB91C1C,
      secondaryColor: 0xFFEF4444,
      accentColor: 0xFFFECACA,
    );
    emit(VVendorManagmentInitial());
  }
}
