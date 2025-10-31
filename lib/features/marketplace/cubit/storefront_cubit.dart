import 'package:bloc/bloc.dart';
import '../data/repository/marketplace_repository.dart';

part 'storefront_state.dart';

class StorefrontCubit extends Cubit<StorefrontState> {
  final MarketplaceRepository repository;

  StorefrontCubit(this.repository) : super(StorefrontInitial());

  Future<void> loadProductsForVendor(String vendorId) async {
    try {
      emit(StorefrontLoading());
      final products = await repository.getProductsByVendor(vendorId);
      emit(StorefrontLoaded(products));
    } catch (e) {
      emit(StorefrontError(e.toString()));
    }
  }

  Future<void> loadAllProducts() async {
    try {
      emit(StorefrontLoading());
      final vendors = await repository.getVendors();
      final List<dynamic> allProducts = [];
      for (final vendor in vendors) {
        final products = await repository.getProductsByVendor(vendor.id);
        allProducts.addAll(products);
      }
      emit(StorefrontLoaded(allProducts));
    } catch (e) {
      emit(StorefrontError(e.toString()));
    }
  }
}
