import 'package:flutter/material.dart';

import '../components/gradient_bordered_box.dart';

class STextField extends StatelessWidget {
  final String labelText;
  final String hintText;
  final TextEditingController? controller;
  const STextField({
    super.key,
    this.labelText = 'Enter text',
    this.hintText = 'Enter text',
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GradientBorderedBox(
      borderRadius: BorderRadius.circular(8),
      border: const EdgeInsets.all(1),
      borderGradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        stops: [0, 0.9, 1],
        colors: [Color(0xFF5D666D), Color(0x0023282D), Color(0xFF5D666D)],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
