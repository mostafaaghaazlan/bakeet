import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFuncation {
  static getDate({required DateTime dateTimeValue}) {
    return DateFormat('dd-MMM-yyyy').format(dateTimeValue);
  }

  static getDateFromString({required String dateTimeValue}) {
    DateFormat format = DateFormat("yyyy-MM-ddTHH:mm:ss.SSSSSSZ");
    DateTime dateTime = format.parse(dateTimeValue);
    return DateFormat('dd-MMM-yyyy').format(dateTime);
  }

  static Future<void> selectDate(
    final TextEditingController controller,
    final Function(String) onSelected,
    final BuildContext context,
  ) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final formattedDate = DateFormat('yyyy-MM-dd', 'en').format(pickedDate);
      controller.text = formattedDate;
      onSelected(formattedDate);
    }
  }
}
