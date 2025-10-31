import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:bakeet/core/utils/functions/reg_exp.dart';

class AppValidators {
  static String? validateFillFields(BuildContext context, String? name) {
    if (name == null || name.isEmpty) {
      return 'fill_field'.tr();
    }
    return null;
  }

  static String? validatePasswordFields(
    BuildContext context,
    String? password,
  ) {
    if (password == null || password.isEmpty) {
      return 'fill_field'.tr();
    }

    if (password.length < 8) {
      return "كلمة المرور يجب أن تكون 8 أحرف على الأقل";
    }

    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return "يجب أن تحتوي كلمة المرور على حرف كبير واحد على الأقل (A-Z)";
    }

    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return "يجب أن تحتوي كلمة المرور على حرف صغير واحد على الأقل (a-z)";
    }

    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return "يجب أن تحتوي كلمة المرور على رقم واحد على الأقل";
    }

    if (!RegExp(r'[!@#\$&*~]').hasMatch(password)) {
      return "يجب أن تحتوي كلمة المرور على رمز خاص واحد على الأقل مثل @ أو # أو \$ أو & أو * أو ~";
    }

    return null;
  }

  static String? validateRepeatPasswordFields(
    BuildContext context,
    String? password,
    String? repeatedPassword,
  ) {
    if (repeatedPassword == null || repeatedPassword.isEmpty) {
      return 'fill_field'.tr();
    }
    if (password != repeatedPassword) {
      return 'must_same_password'.tr();
    }
    return null;
  }

  static String? validateEmailFields(BuildContext context, String? email) {
    if (email == null || email.isEmpty) {
      return 'fill_field'.tr();
    } else if (AppRegexp.emailRegexp.hasMatch(email) == false) {
      return "email_regexp".tr();
    }
    return null;
  }

  static String? validatePhoneFields(BuildContext context, String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'fill_field'.tr();
    }
    if (AppRegexp.phoneRegexp.hasMatch(phone) == false) {
      return "phone_regexp";
    }
    return null;
  }
}
