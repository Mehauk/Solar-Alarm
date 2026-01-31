import 'dart:math';

import 'package:flutter/material.dart';

import '../../utils/mixins.dart';

enum SSwitchStatus with Toggleable<SSwitchStatus> {
  off,
  on;

  @override
  SSwitchStatus get me => this;

  @override
  List<SSwitchStatus> get ordered => values;
}

class SSwitch<T extends Toggleable<T>> extends StatelessWidget {
  final T value;
  final void Function(T) onChanged;
  final Size trackSize;
  final double trackBorderRadius;
  final bool enabledTrackShadow;
  final Gradient? enabledTrackGradient;
  final Gradient? disabledTrackGradient;
  final Size toggleSize;
  final double toggleJut;
  final Color enabledToggleColor;
  final Color disabledToggleColor;
  final Widget toggle;
  final EdgeInsets? padding;

  SSwitch(
    this.value, {
    super.key,
    required this.onChanged,
    this.trackSize = const Size(33, 14),
    this.trackBorderRadius = 16,
    this.enabledTrackShadow = true,
    this.enabledTrackGradient,
    this.disabledTrackGradient,
    this.padding,
    this.toggleSize = const Size(21, 21),
    this.enabledToggleColor = const Color(0XFFA2ADB9),
    this.disabledToggleColor = const Color(0XFF4E565F),
    final double? toggleJut,
    final Widget? toggle,
  }) : toggle =
           toggle ??
           _DefaultToggle(
             value,
             value.isOn ? enabledToggleColor : disabledToggleColor,
           ),
       toggleJut = toggleJut ?? (toggleSize.width / 4);

  @override
  Widget build(BuildContext context) {
    final trueLength = toggleJut + trackSize.width + toggleJut;
    final double portion =
        (trueLength - toggleSize.width) / (value.ordered.length - 1);
    final double leftPosition = value.vindex * portion;
    return GestureDetector(
      onTap: () => onChanged(value.toggle),
      onHorizontalDragEnd: (details) => onChanged(value.toggle),
      child: Container(
        color: Colors.transparent, //WTF?
        padding: padding ?? EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // total size
            SizedBox(
              height: max(trackSize.height, toggleSize.height),
              width: trueLength,
            ),

            SizedBox(
              width: trackSize.width,
              height: trackSize.height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(trackBorderRadius),
                  boxShadow:
                      value.isOn && enabledTrackShadow
                          ? [
                            const BoxShadow(
                              blurRadius: 10,
                              color: Color(0xAAFD2A22),
                              offset: Offset(0, 1),
                            ),
                          ]
                          : null,
                  gradient:
                      value.isOn
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
              left: leftPosition,
              child: SizedBox(
                width: toggleSize.width,
                height: toggleSize.height,
                child: toggle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DefaultToggle<T extends Toggleable> extends StatelessWidget {
  final T value;
  final Color color;
  const _DefaultToggle(this.value, this.color);

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
                value.isOn
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
