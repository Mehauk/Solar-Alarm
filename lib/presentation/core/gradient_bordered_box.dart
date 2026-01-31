import 'package:flutter/material.dart';

class GradientBorderedBox extends StatelessWidget {
  final Widget child;
  final EdgeInsets border;
  final BorderRadius borderRadius;
  final Gradient borderGradient;
  final Gradient backgroundGradient;
  const GradientBorderedBox({
    super.key,
    required this.child,
    this.border = const EdgeInsets.only(top: 1.5),
    this.borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(16),
      topRight: Radius.circular(16),
    ),
    this.borderGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF5D666D), Color(0x0023282D)],
    ),
    this.backgroundGradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF363E46), Color(0xFF2C343C)],
    ),
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: borderGradient,
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: border,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: backgroundGradient,
          ),
          child: child,
        ),
      ),
    );
  }
}
