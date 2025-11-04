part of 'v_vendor_managment_cubit.dart';

@immutable
sealed class VVendorManagmentState {}

final class VVendorManagmentInitial extends VVendorManagmentState {}

final class VendorRegistrationLoading extends VVendorManagmentState {}

final class VendorRegistrationSuccess extends VVendorManagmentState {
  final String message;
  final String vendorId;
  final VendorRegistrationModel vendorData;
  final VendorModel? vendor;
  final List<ProductModel>? products;

  VendorRegistrationSuccess(
    this.message,
    this.vendorId,
    this.vendorData, {
    this.vendor,
    this.products,
  });
}

final class VendorPublished extends VVendorManagmentState {
  final String message;
  final String vendorId;
  final String vendorName;
  VendorPublished(this.message, this.vendorId, this.vendorName);
}

final class VendorRegistrationError extends VVendorManagmentState {
  final String error;
  VendorRegistrationError(this.error);
}

final class VendorDataUpdated extends VVendorManagmentState {
  final VendorRegistrationModel vendorData;
  VendorDataUpdated(this.vendorData);
}

final class ProductAdded extends VVendorManagmentState {
  final ProductRegistrationModel product;
  ProductAdded(this.product);
}

final class ProductUpdated extends VVendorManagmentState {
  final int index;
  final ProductRegistrationModel product;
  ProductUpdated(this.index, this.product);
}

final class ProductRemoved extends VVendorManagmentState {
  final int index;
  ProductRemoved(this.index);
}
