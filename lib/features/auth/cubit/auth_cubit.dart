import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  bool _isObscure = true;
  bool _rememberMe = false;

  bool get isObscure => _isObscure;
  bool get rememberMe => _rememberMe;

  void togglePasswordVisibility() {
    _isObscure = !_isObscure;
    emit(AuthPasswordVisibilityChanged(_isObscure));
  }

  void toggleRememberMe(bool value) {
    _rememberMe = value;
    emit(AuthRememberMeChanged(_rememberMe));
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Check for specific test user
      if (email.toLowerCase() == 'user@gmail.com' && password.length >= 6) {
        // Regular user - navigate to MainShell
        emit(AuthLoginSuccess(email, isMerchant: false));
      } else if (email.isNotEmpty && password.length >= 6) {
        // Check if email contains "merchant" to determine user type
        final isMerchant = email.toLowerCase().contains('merchant');
        emit(AuthLoginSuccess(email, isMerchant: isMerchant));
      } else {
        emit(AuthError('Invalid credentials'));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void resetToInitial() {
    emit(AuthInitial());
  }
}
