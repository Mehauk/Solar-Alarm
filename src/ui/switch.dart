import 'dart:math';

import 'package:flutter/material.dart';

class SSwitch extends StatelessWidget {
  final bool value;
  final void Function(bool) onChanged;
  final Size trackSize;
  final double trackRadius;
  final bool enabledTrackShadow;
  final Gradient? enabledTrackGradient;
  final Gradient? disabledTrackGradient;
  final Size toggleSize;
  final Color enabledToggleColor;
  final Color disabledToggleColor;
  final Widget toggle;

  SSwitch(
    this.value, {
    super.key,
    required this.onChanged,
    this.trackSize = const Size(36, 14),
    this.trackRadius = 16,
    this.enabledTrackShadow = true,
    this.enabledTrackGradient,
    this.disabledTrackGradient,
    this.toggleSize = const Size(21, 21),
    this.enabledToggleColor = const Color(0XFFA2ADB9),
    this.disabledToggleColor = const Color(0XFF4E565F),
    final Widget? toggle,
  }) : toggle =
           toggle ??
           _DefaultToggle(
             value,
             value ? enabledToggleColor : disabledToggleColor,
           );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: max(trackSize.height, toggleSize.height),
            width: trackSize.width + (0.25 * toggleSize.width),
          ),
          SizedBox(
            width: trackSize.width,
            height: trackSize.height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(trackRadius),
                boxShadow:
                    value && enabledTrackShadow
                        ? [
                          const BoxShadow(
                            blurRadius: 10,
                            color: Color(0xFFFD2A22),
                            offset: Offset(0, 1),
                          ),
                        ]
                        : null,
                gradient:
                    value
                        ? const LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFFFD2A22), Color(0xFFFE6C57)],
                        )
                        : const LinearGradient(
                          colors: [Color(0xFF282F35), Color(0xFF282F35)],
                        ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: Durations.short2,
            curve: Curves.easeInOut,
            right: value ? 0 : trackSize.width - toggleSize.width * 0.75,
            left: value ? trackSize.width - toggleSize.width * 0.75 : 0,
            child: SizedBox(
              width: toggleSize.width,
              height: toggleSize.height,
              child: toggle,
            ),
          ),
        ],
      ),
    );
  }
}

class _DefaultToggle extends StatelessWidget {
  final bool enabled;
  final Color color;
  const _DefaultToggle(this.enabled, this.color);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      shape: const CircleBorder(),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors:
                enabled
                    ? [const Color(0xFFCCD4DC), const Color(0xFF7A8998)]
                    : [const Color(0xFF666E74), const Color(0xFF21272D)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(1),
          child: DecoratedBox(
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ),
      ),
    );
  }
}
