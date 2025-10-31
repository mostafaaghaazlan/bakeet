// import '../../../core/classes/cashe_helper.dart';
// import '../../../features/matrix/data/model/matrix.dart';

// double getMatrixPrice(MatrixModel matrixModel) {
//   if (matrixModel.products != null && matrixModel.products!.isNotEmpty) {
//     var productPrice = matrixModel.products![0].productPrice;
//     var currencyCode = CacheHelper.setting?.currencyCode;

//     if (currencyCode == productPrice?.curr) {
//       return productPrice?.price?.toDouble() ?? 0.0;
//     } else if (currencyCode == productPrice?.curr1) {
//       return double.tryParse((productPrice?.addPrice1 ?? "0").toString()) ??
//           0.0;
//     } else if (currencyCode == productPrice?.curr2) {
//       return double.tryParse((productPrice?.addPrice2 ?? "0").toString()) ??
//           0.0;
//     }
//   }
//   return 0.0;
// }
