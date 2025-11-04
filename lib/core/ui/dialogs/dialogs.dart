import 'package:animated_snack_bar/animated_snack_bar.dart';
import '../../classes/keys.dart';

class Dialogs {
  static showSnackBar({
    required String message,
    AnimatedSnackBarType typeSnackBar = AnimatedSnackBarType.success,
  }) {
    return AnimatedSnackBar.material(
      message,
      type: typeSnackBar,
    ).show(Keys.navigatorKey.currentContext!);
  }

  static showErrorSnackBar({
    required String message,
    AnimatedSnackBarType typeSnackBar = AnimatedSnackBarType.error,
  }) {
    return AnimatedSnackBar.material(
      message,
      type: typeSnackBar,
    ).show(Keys.navigatorKey.currentContext!);
  }
}
