import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../data/repository/marketplace_repository.dart';

part 'vendors_state.dart';

class VendorsCubit extends Cubit<VendorsState> {
  final MarketplaceRepository repository;

  VendorsCubit(this.repository) : super(VendorsInitial());

  Future<void> loadVendors() async {
    try {
      emit(VendorsLoading());
      final vendors = await repository.getVendors();
      emit(VendorsLoaded(vendors));
    } catch (e) {
      emit(VendorsError(e.toString()));
    }
  }
}
