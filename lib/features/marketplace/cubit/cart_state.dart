part of 'cart_cubit.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartUpdated extends CartState {
  final List<dynamic> items; // use CartItem model later
  CartUpdated(this.items);
}
