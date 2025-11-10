import 'package:bloc/bloc.dart';
import '../data/repository/marketplace_repository.dart';

part 'storefront_state.dart';

class StorefrontCubit extends Cubit<StorefrontState> {
  final MarketplaceRepository repository;

  StorefrontCubit(this.repository) : super(StorefrontInitial());

  Future<void> loadProductsForVendor(String vendorId) async {
    try {
      if (isClosed) return;
      emit(StorefrontLoading());
      final products = await repository.getProductsByVendor(vendorId);
      if (isClosed) return;
      emit(StorefrontLoaded(products));
    } catch (e) {
      if (!isClosed) emit(StorefrontError(e.toString()));
    }
  }

  Future<void> loadAllProducts() async {
    try {
      if (isClosed) return;
      emit(StorefrontLoading());
      final vendors = await repository.getVendors();
      final List<dynamic> allProducts = [];
      for (final vendor in vendors) {
        if (isClosed) return;
        final products = await repository.getProductsByVendor(vendor.id);
        allProducts.addAll(products);
      }
      if (isClosed) return;
      emit(StorefrontLoaded(allProducts));
    } catch (e) {
      if (!isClosed) emit(StorefrontError(e.toString()));
    }
  }
}
