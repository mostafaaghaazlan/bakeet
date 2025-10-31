import 'package:flutter/material.dart';

import '../widgets/fade_animation.dart';





extension WidgetExtension on Widget {
  Widget fadeAnimation(double delay) {
    return FadeInAnimation(delay: delay, child: this);
  }
}