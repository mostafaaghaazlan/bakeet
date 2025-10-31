// import 'package:bakeet/features/product/data/model/product.dart';
// import '../../../core/classes/cashe_helper.dart';

// double getProductPrice(ProductModel productModel) {
//   var productPrice = productModel.productPrice;
//   var currencyCode = CacheHelper.setting?.currencyCode;

//   if (currencyCode == productPrice?.curr) {
//     return productPrice?.price?.toDouble() ?? 0.0;
//   } else if (currencyCode == productPrice?.curr1) {
//     return double.tryParse((productPrice?.addPrice1 ?? "0").toString()) ?? 0.0;
//   } else if (currencyCode == productPrice?.curr2) {
//     return double.tryParse((productPrice?.addPrice2 ?? "0").toString()) ?? 0.0;
//   }

//   return 0.0;
// }
