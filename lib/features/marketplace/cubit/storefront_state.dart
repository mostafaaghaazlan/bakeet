part of 'storefront_cubit.dart';

abstract class StorefrontState {}

class StorefrontInitial extends StorefrontState {}

class StorefrontLoading extends StorefrontState {}

class StorefrontLoaded extends StorefrontState {
  final List<dynamic> products;
  StorefrontLoaded(this.products);
}

class StorefrontError extends StorefrontState {
  final String message;
  StorefrontError(this.message);
}
