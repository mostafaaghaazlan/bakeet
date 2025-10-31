part of 'vendors_cubit.dart';

@immutable
abstract class VendorsState {}

class VendorsInitial extends VendorsState {}

class VendorsLoading extends VendorsState {}

class VendorsLoaded extends VendorsState {
  final List<dynamic> vendors;
  VendorsLoaded(this.vendors);
}

class VendorsError extends VendorsState {
  final String message;
  VendorsError(this.message);
}
