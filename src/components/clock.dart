import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:solar_alarm/models/prayers.dart';

import '../globals.dart';
import '../ui/text.dart';
import '../utils/formatting_extensions.dart';
import 'prayer_icons.dart';

part 'digital_clock.dart';

enum TimePart { hour, minute }

const oneTwelfth = (2 * pi / 12);
const oneSixtyth = (2 * pi / 60);

class Clock extends StatelessWidget {
  final double clockDiameter;
  final TimeOfDay time;
  final TimePart editingPart;
  final void Function(TimeOfDay timeUpdate) onUpdate;
  const Clock({
    super.key,
    required this.time,
    required this.editingPart,
    required this.onUpdate,
    this.clockDiameter = 176,
  });

  void updateHour(double dx, double dy) {
    final theta = atan(dy / dx);
    double angle;
    if (dx >= 0) {
      if (theta < 0) {
        angle = theta + 2 * pi;
      } else {
        angle = theta;
      }
    } else {
      if (theta < 0) {
        angle = pi + theta;
      } else {
        angle = pi + theta;
      }
    }
    double gamma = 0;
    int hour = 3;
    while (gamma < 2 * pi) {
      gamma += oneTwelfth;
      if (gamma > angle) {
        if (gamma - angle < oneTwelfth / 2) {
          hour += 1;
        }
        onUpdate(TimeOfDay(hour: hour, minute: time.minute));
        return;
      }
      hour += 1;
      hour = hour % 12;
    }
  }

  void updateMinute(double dx, double dy) {
    final theta = atan(dy / dx);
    double angle;
    if (dx >= 0) {
      if (theta < 0) {
        angle = theta + 2 * pi;
      } else {
        angle = theta;
      }
    } else {
      if (theta < 0) {
        angle = pi + theta;
      } else {
        angle = pi + theta;
      }
    }
    double gamma = 0;
    int minute = 15;
    while (gamma < 2 * pi) {
      gamma += oneSixtyth;
      if (gamma > angle) {
        if (gamma - angle < oneSixtyth / 2) {
          minute += 1;
          minute = minute % 60;
        }
        onUpdate(TimeOfDay(hour: time.hour, minute: minute));
        return;
      }
      minute += 1;
      minute = minute % 60;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      clipBehavior: Clip.none,
      shape: const CircleBorder(),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF5D666D), Color(0xFF232A30)],
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 12,
              offset: Offset(8, 8),
              color: Colors.black38,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3E464F), Color(0xFF424A53)],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.bottomRight,
                    end: Alignment.topLeft,
                    colors: [Color(0xFF5D666D), Color(0xFF232A30)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Stack(
                    children: [
                      DecoratedBox(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF363E46), Color(0xFF2C343C)],
                          ),
                        ),
                        child: SizedBox(
                          height: clockDiameter,
                          width: clockDiameter,
                          child: _TickMarksContainer(
                            diameter: clockDiameter,
                            child: GestureDetector(
                              onTapUp: (details) {
                                final dx =
                                    -(clockDiameter / 2) +
                                    details.localPosition.dx;
                                final dy =
                                    (-(clockDiameter / 2) +
                                        details.localPosition.dy);
                                (editingPart == TimePart.hour)
                                    ? updateHour(dx, dy)
                                    : updateMinute(dx, dy);
                              },
                              onVerticalDragUpdate: (details) {
                                final dx =
                                    -(clockDiameter / 2) +
                                    details.localPosition.dx;
                                final dy =
                                    (-(clockDiameter / 2) +
                                        details.localPosition.dy);
                                (editingPart == TimePart.hour)
                                    ? updateHour(dx, dy)
                                    : updateMinute(dx, dy);
                              },
                              child: CustomPaint(
                                size: Size(clockDiameter, clockDiameter),
                                painter: _ClockHandPainter(time, editingPart),
                              ),
                            ),
                          ),
                        ),
                      ),
                      IgnorePointer(
                        child: DecoratedBox(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              center: Alignment(0.5, 0.4),
                              radius: 0.9,
                              colors: [Colors.transparent, Colors.black38],
                              stops: [0.7, 1],
                            ),
                          ),
                          child: SizedBox(
                            height: clockDiameter,
                            width: clockDiameter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClockHandPainter extends CustomPainter {
  final TimeOfDay time;
  final TimePart editing;

  _ClockHandPainter(this.time, this.editing);

  void paintHand(
    Canvas canvas,
    Offset center,
    double handLength,
    Offset direction,
    Offset perp,
    Paint paint,
    double radius,
    bool glow,
  ) {
    final handWidth = (radius / handLength);
    final centerWidth = (radius * 2 / handLength);
    final handLengthBack = handLength * 0.6;
    final handBackWidth = (radius * 2.4 / handLength);
    final dotRadius = (radius * 4 / handLength);

    final point1 =
        center -
        direction.scale(handLengthBack, handLengthBack) -
        perp.scale(handBackWidth, handBackWidth);
    final point2 =
        center -
        direction.scale(handLengthBack, handLengthBack) +
        perp.scale(handBackWidth, handBackWidth);

    final point3 = center - perp.scale(centerWidth, centerWidth);
    final point4 = center + perp.scale(centerWidth, centerWidth);

    final point5 =
        center +
        direction.scale(handLength, handLength) -
        perp.scale(handWidth, handWidth);
    final point6 =
        center +
        direction.scale(handLength, handLength) +
        perp.scale(handWidth, handWidth);

    final path = Path()..moveTo(point3.dx, point3.dy);

    path.lineTo(point1.dx, point1.dy);
    path.arcToPoint(point2, radius: Radius.circular(handBackWidth));
    path.lineTo(point4.dx, point4.dy);
    path.lineTo(point6.dx, point6.dy);
    path.arcToPoint(point5, radius: Radius.circular(handWidth));
    path.lineTo(point3.dx, point3.dy);

    path.close();

    canvas.drawPath(path, paint);
    if (glow) canvas.drawShadow(path, paint.color, 12, false);
    canvas.drawCircle(center, dotRadius, Paint()..color = paint.color);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final int hour = time.hour % 12;
    final hourAngle = (-pi / 2) + hour * oneTwelfth;

    final hourHandLength = radius * 0.5;
    final hourPaint =
        Paint()
          ..color =
              editing == TimePart.hour
                  ? const Color(0xFFFD251E)
                  : const Color(0xFF8E98A1)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.fill;

    final direction = Offset(cos(hourAngle), sin(hourAngle));
    final perp = Offset(cos(-(pi / 2 - hourAngle)), sin(-(pi / 2 - hourAngle)));

    paintHand(
      canvas,
      center,
      hourHandLength,
      direction,
      perp,
      hourPaint,
      radius,
      editing == TimePart.hour,
    );

    final int minute = time.minute;
    final minuteAngle = (-pi / 2) + minute * oneSixtyth;
    final minuteHandLength = radius * 0.7;

    final minutePaint =
        Paint()
          ..color =
              editing == TimePart.minute
                  ? const Color(0xAAFD251E)
                  : const Color(0xFF8E98A1)
          ..strokeWidth = 4
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.fill;

    final directionM = Offset(cos(minuteAngle), sin(minuteAngle));
    final perpM = Offset(
      cos(-(pi / 2 - minuteAngle)),
      sin(-(pi / 2 - minuteAngle)),
    );

    paintHand(
      canvas,
      center,
      minuteHandLength,
      directionM,
      perpM,
      minutePaint,
      radius,
      editing == TimePart.minute,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _TickMarksContainer extends StatelessWidget {
  final Widget child;
  final double diameter;
  const _TickMarksContainer({required this.diameter, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: Size(diameter, diameter),
          painter: _TickMarkPainter(),
        ),
        child,
      ],
    );
  }
}

class _TickMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final tickPaint =
        Paint()
          ..color = const Color(0xFF5D666D)
          ..strokeWidth = 2;

    const tickCount = 12;
    for (int i = 0; i < tickCount; i++) {
      final angle = 2 * pi * i / tickCount;
      final innerRadius = radius - 15;
      final outerRadius = radius - 12;

      final Offset p1;

      if (i % 3 == 0) {
        p1 = Offset(
          center.dx + (innerRadius - 5) * cos(angle),
          center.dy + (innerRadius - 5) * sin(angle),
        );
      } else {
        p1 = Offset(
          center.dx + innerRadius * cos(angle),
          center.dy + innerRadius * sin(angle),
        );
      }

      final p2 = Offset(
        center.dx + outerRadius * cos(angle),
        center.dy + outerRadius * sin(angle),
      );

      canvas.drawLine(p1, p2, tickPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
