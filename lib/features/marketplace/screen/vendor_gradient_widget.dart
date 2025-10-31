import 'package:flutter/material.dart';

/// A small animated gradient background used to give vendors a unique look.
/// It animates the gradient's alignment to create a subtle, moving effect.
class AnimatedVendorGradient extends StatefulWidget {
  final List<Color> colors;
  final BorderRadius? borderRadius;
  final Duration duration;

  const AnimatedVendorGradient({
    Key? key,
    required this.colors,
    this.borderRadius,
    this.duration = const Duration(seconds: 6),
  }) : super(key: key);

  @override
  State<AnimatedVendorGradient> createState() => _AnimatedVendorGradientState();
}

class _AnimatedVendorGradientState extends State<AnimatedVendorGradient>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final begin = Alignment(-1.0 + (t * 2.0), -1.0 + (t * 0.6));
        final end = Alignment(1.0 - (t * 2.0), 1.0 - (t * 0.6));

        return Container(
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: widget.colors,
            ),
          ),
        );
      },
    );
  }
}
