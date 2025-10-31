import 'dart:ui';

import '../constant/app_colors/app_colors.dart';

enum Gender { male, female }

enum MaritalStatus { single, married, divorced, widow }

enum NationalityType { iraqi, arab, foreigner }

enum AffiliateRequestStatusEnum { pending, inProgress, approved, rejected }

extension GenderExtension on Gender {
  int get value {
    switch (this) {
      case Gender.male:
        return 1;
      case Gender.female:
        return 2;
    }
  }

  String get displayName {
    switch (this) {
      case Gender.male:
        return "Male";
      case Gender.female:
        return "Female";
    }
  }
}

extension MaritalStatusExtension on MaritalStatus {
  int get value {
    switch (this) {
      case MaritalStatus.single:
        return 1;
      case MaritalStatus.married:
        return 2;
      case MaritalStatus.divorced:
        return 3;
      case MaritalStatus.widow:
        return 4;
    }
  }

  String get displayName {
    switch (this) {
      case MaritalStatus.single:
        return "Single";
      case MaritalStatus.married:
        return "Married";
      case MaritalStatus.divorced:
        return "Divorced";
      case MaritalStatus.widow:
        return "Widow";
    }
  }
}

extension NationalityTypeExtension on NationalityType {
  int get value {
    switch (this) {
      case NationalityType.iraqi:
        return 1;
      case NationalityType.arab:
        return 2;
      case NationalityType.foreigner:
        return 3;
    }
  }

  String get displayName {
    switch (this) {
      case NationalityType.iraqi:
        return "عراقي";
      case NationalityType.arab:
        return "عربي";
      case NationalityType.foreigner:
        return "اجنبي";
    }
  }
}

extension AffiliateRequestStatusEnumExt on AffiliateRequestStatusEnum {
  static AffiliateRequestStatusEnum fromInt(int? value) {
    switch (value) {
      case 1:
        return AffiliateRequestStatusEnum.pending;
      case 2:
        return AffiliateRequestStatusEnum.inProgress;
      case 3:
        return AffiliateRequestStatusEnum.approved;
      case 4:
        return AffiliateRequestStatusEnum.rejected;
      default:
        return AffiliateRequestStatusEnum.pending;
    }
  }

  String get label {
    switch (this) {
      case AffiliateRequestStatusEnum.pending:
        return "قيد الانتظار";
      case AffiliateRequestStatusEnum.inProgress:
        return "قيد المعالجة";
      case AffiliateRequestStatusEnum.approved:
        return "تمت الموافقة";
      case AffiliateRequestStatusEnum.rejected:
        return "مرفوض";
    }
  }

  Color get color {
    switch (this) {
      case AffiliateRequestStatusEnum.pending:
        return AppColors.neutral400;
      case AffiliateRequestStatusEnum.inProgress:
        return AppColors.primary;
      case AffiliateRequestStatusEnum.approved:
        return AppColors.success;
      case AffiliateRequestStatusEnum.rejected:
        return AppColors.danger;
    }
  }
}
