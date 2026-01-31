import 'package:flutter/material.dart';

enum STextWeight {
  thin,
  normal,
  medium,
  bold;

  FontWeight get w {
    switch (this) {
      case thin:
        return FontWeight.w300;
      case STextWeight.normal:
        return FontWeight.normal;
      case STextWeight.medium:
        return FontWeight.w500;
      case STextWeight.bold:
        return FontWeight.w700;
    }
  }
}

class SText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final TextStyle textStyle;
  final STextWeight weight;
  final double height;
  final Color color;
  final int? maxLines;
  final bool shadow;
  final bool glow;
  SText(
    this.text, {
    super.key,
    this.fontSize,
    this.weight = STextWeight.medium,
    this.height = 1,
    this.maxLines = 1,
    this.shadow = false,
    this.glow = false,
    this.color = const Color(0xFF8E98A1),
  }) : textStyle = TextStyle(
         fontSize: fontSize,
         color: color,
         fontWeight: weight.w,
         height: height,
         shadows: [
           if (shadow)
             const Shadow(
               blurRadius: 20,
               color: Colors.black54,
               offset: Offset(4, 4),
             ),
           if (glow)
             Shadow(blurRadius: 20, color: color, offset: const Offset(0, 1)),
         ],
       );

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: textStyle,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
