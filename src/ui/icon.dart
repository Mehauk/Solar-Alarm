import 'package:flutter/material.dart';

class SIcon extends StatelessWidget {
  final IconData icon;
  final double radius;
  final List<Shadow>? shadows;
  const SIcon(this.icon, {super.key, this.radius = 12}) : shadows = null;

  SIcon.shadow(this.icon, {super.key, this.radius = 12})
    : shadows = [
        Shadow(blurRadius: 20, color: Colors.black54, offset: Offset(4, 4)),
      ];

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: radius * 2,
      color: Color(0xFF8E98A1),
      shadows: shadows,
    );
  }
}
