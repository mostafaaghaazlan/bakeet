import 'package:bakeet/features/home/cubit/home_cubit.dart';
import 'package:bakeet/features/marketplace/data/repository/marketplace_repository.dart';
import 'package:bakeet/features/marketplace/cubit/cart_cubit.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setUp() async {
  getIt.registerLazySingleton(() => HomeCubit());
  getIt.registerLazySingleton(() => MarketplaceRepository());
  getIt.registerLazySingleton(() => CartCubit());
}
