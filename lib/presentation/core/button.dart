import 'package:flutter/material.dart';

import 'gradient_bordered_box.dart';

class SButton extends StatelessWidget {
  final void Function()? onTap;
  final double buttonRadius;
  final EdgeInsets padding;
  final Widget child;
  final bool destructive;

  const SButton({
    super.key,
    required this.onTap,
    this.buttonRadius = 16,
    this.padding = const EdgeInsets.symmetric(vertical: 14, horizontal: 40),
    this.destructive = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.6 : 1,
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(buttonRadius),
        child: GradientBorderedBox(
          borderRadius: BorderRadius.circular(buttonRadius),
          border: const EdgeInsets.all(1.0),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                destructive
                    ? const [
                      Color.fromARGB(255, 109, 93, 93),
                      Color.fromARGB(255, 49, 36, 36),
                    ]
                    : const [Color(0xFF5D666D), Color(0xFF242B31)],
          ),
          backgroundGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                destructive
                    ? const [
                      Color.fromARGB(255, 80, 63, 63),
                      Color.fromARGB(255, 70, 54, 54),
                    ]
                    : const [Color(0xFF3F4850), Color(0xFF363E46)],
          ),
          child: Material(
            borderRadius: BorderRadius.circular(buttonRadius),
            clipBehavior: Clip.antiAlias,
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      ),
    );
  }
}
