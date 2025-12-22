import 'package:flutter/material.dart';

class SIcon extends StatelessWidget {
  final IconData icon;
  final double radius;
  final List<Shadow>? shadows;
  final Color color;
  const SIcon(
    this.icon, {
    super.key,
    this.radius = 14,
    this.color = const Color(0xFF8E98A1),
  }) : shadows = null;

  SIcon.shadow(
    this.icon, {
    super.key,
    this.radius = 14,
    this.color = const Color(0xFF8E98A1),
  }) : shadows = [
         const Shadow(
           blurRadius: 20,
           color: Colors.black54,
           offset: Offset(4, 4),
         ),
       ];

  SIcon.glow(
    this.icon, {
    super.key,
    this.radius = 14,
    this.color = const Color(0xFF8E98A1),
  }) : shadows = [
         Shadow(blurRadius: 10, color: color, offset: const Offset(0, 1)),
       ];

  @override
  Widget build(BuildContext context) {
    return Icon(icon, color: color, size: radius * 2, shadows: shadows);
  }
}

class SIconButton extends StatelessWidget {
  final IconData icon;
  final double radius;
  final List<Shadow>? shadows;
  final void Function()? onTap;
  const SIconButton(this.icon, {super.key, this.radius = 14, this.onTap})
    : shadows = null;

  SIconButton.shadow(this.icon, {super.key, this.radius = 14, this.onTap})
    : shadows = [
        const Shadow(
          blurRadius: 20,
          color: Colors.black54,
          offset: Offset(4, 4),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: SIcon(icon, radius: radius),
      ),
    );
  }
}
