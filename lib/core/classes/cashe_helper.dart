// // import 'package:bakeet/features/brand/data/model/brand.dart';
// // import 'package:bakeet/features/configration/data/model/setting.dart';
// // import 'package:bakeet/features/matrix/data/model/matrix.dart';
// // import 'package:bakeet/features/product/data/model/discount.dart';
// // import 'package:bakeet/features/product/data/model/discount_tem.dart';
// // import 'package:bakeet/features/product/data/model/product.dart';
// // import 'package:bakeet/features/product/data/model/product_price_model.dart';
// // import 'package:bakeet/features/product/data/model/suom_model.dart';
// // import 'package:bakeet/features/shopping/data/model/category.dart';
// // import 'package:bakeet/features/sliderBanner/data/model/document_model.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:bakeet/core/constant/end_points/cashe_helper_constant.dart';
// // import '../../features/cart/cubit/cart_cubit.dart';
// // import '../../features/configration/data/model/config_model.dart';
// // import '../../features/auth/data/model/login_model.dart';

// class CacheHelper {
//   static late Box<dynamic> box;
//   static late Box<dynamic> wishlistBox;
//   static late Box<dynamic> cartBox;
//   static late Box<dynamic> currentUserBox;
//   static late Box<dynamic> settingBox;

//   static init() async {
//     await Hive.initFlutter();
//     // Hive.registerAdapter(CurrentCustomerModelAdapter());

//     box = await Hive.openBox("default_box");
//     wishlistBox = await Hive.openBox("model_box");
//     cartBox = await Hive.openBox("cart_box");
//     currentUserBox = await Hive.openBox("current_user_box");
//     settingBox = await Hive.openBox("setting_box");
//   }

//   static Future<void> setLang(String value) => box.put(languageValue, value);

//   static Future<void> setToken(String? value) =>
//       box.put(accessToken, value ?? '');
//   static Future<void> setDeviceToken(String? value) =>
//       box.put(deviceToken, value ?? '');
//   static Future<void> setRefreshToken(String? value) =>
//       box.put(refreshToken, value ?? '');
//   static Future<void> setUserId(String? value) => box.put(userId, value ?? 0);
//   static Future<void> setUserName(String? value) =>
//       box.put(userName, value ?? 0);
//   static Future<void> setExpiresIn(int? value) =>
//       box.put(expiresIn, value ?? 0);
//   static Future<void> setFirstTime(bool value) => box.put(isFirstTime, value);

//   static Future<void> setTheme(String value) => box.put('app_theme', value);

//   static Future<void> setDateWithExpiry(int expiresInSeconds) {
//     DateTime expiryDateTime = DateTime.now().add(
//       Duration(seconds: expiresInSeconds),
//     );
//     return box.put(date, expiryDateTime);
//   }

//   ////////////////////////////////Get///////////////////////////////

//   static String get lang => box.get(languageValue) ?? 'ar';
//   static String get theme => box.get('app_theme', defaultValue: 'light');
//   static String? get token {
//     if (!box.containsKey(accessToken)) return null;
//     return "${box.get(accessToken)}";
//   }

//   static String? get getDeviceToken {
//     if (!box.containsKey(deviceToken)) return null;
//     return "${box.get(deviceToken)}";
//   }

//   static String? get refreshtoken {
//     if (!box.containsKey(refreshToken)) return null;
//     return "${box.get(refreshToken)}";
//   }

//   static String? get userID {
//     if (!box.containsKey(userId)) return null;
//     return "${box.get(userId)}";
//   }

//   static String? get userNAme {
//     if (!box.containsKey(userName)) return null;
//     return "${box.get(userName)}";
//   }

//   static bool get firstTime => box.get(isFirstTime) ?? true;
//   static int? get expiresin => box.get(expiresIn);
//   static DateTime? get datenow => box.get(date);

//   static void deleteCertificates() {
//     setToken(null);
//     setUserId(null);
//   }
// }
