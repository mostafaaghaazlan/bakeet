part of 'auth_cubit.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthLoginSuccess extends AuthState {
  final String email;
  final bool isMerchant;

  AuthLoginSuccess(this.email, {this.isMerchant = false});
}

final class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}

final class AuthPasswordVisibilityChanged extends AuthState {
  final bool isObscure;

  AuthPasswordVisibilityChanged(this.isObscure);
}

final class AuthRememberMeChanged extends AuthState {
  final bool rememberMe;

  AuthRememberMeChanged(this.rememberMe);
}
