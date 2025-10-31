import 'package:flutter/material.dart';

import '../../variables/variables.dart';

class DoubleBackToClose extends StatelessWidget {
  final Widget child;
  const DoubleBackToClose({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(child: child, onWillPop: () async{
      final now = DateTime.now();
        const backPressTimeout = Duration(seconds: 1);
        if (lastPressed == null ||
            now.difference(lastPressed!) > backPressTimeout) {
          lastPressed = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('اضغط مرة أخرى للخروج')),
          );
          return false;
        }
        return true;
    },);
  }
}
