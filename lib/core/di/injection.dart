import 'package:bakeet/features/home/cubit/home_cubit.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setUp() async {
  getIt.registerLazySingleton(() => HomeCubit());
}
