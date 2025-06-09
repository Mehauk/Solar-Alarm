import 'dart:math';

import 'package:flutter/material.dart';

import '../models/prayers.dart';

extension on Prayer {
  CustomPainter get painter {
    switch (this) {
      case Prayer.fajr:
        return _FajrIconPainter();
      case Prayer.sunrise:
        // TODO: Handle this case.
        throw UnimplementedError();
      case Prayer.dhuhr:
        return _DhuhrIconPainter();
      case Prayer.asr:
        return _AsrIconPainter();
      case Prayer.maghrib:
        // TODO: Handle this case.
        throw UnimplementedError();
      case Prayer.isha:
        return _IshaIconPainter();
      case Prayer.midnight:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }
}

class PrayerIcon extends StatelessWidget {
  final Prayer prayer;
  final double radius;
  const PrayerIcon(this.prayer, {super.key, this.radius = 12});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.fromRadius(radius), painter: prayer.painter);
  }
}

class _FajrIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Color(0xFF8E98A1)
          ..strokeWidth = 2.0;

    final rect = Rect.fromCircle(
      center: Offset(cx, cy + (cy / 4)),
      radius: cx * 0.5,
    );

    canvas.drawArc(rect, pi, pi, true, paint);

    final rayPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Color(0xFF8E98A1)
          ..strokeWidth = 2.0;

    final rayLength = cx * 0.8;
    final rayCount = 7;
    for (int i = 0; i < rayCount; i++) {
      final angle = (-(pi + pi / 6) / rayCount) * i;
      final startX = cx + (cx * 0.45) * cos(angle);
      final startY = cy + (cy / 4) + (cx * 0.45) * sin(angle);
      final endX = cx + rayLength * cos(angle);
      final endY = cy + (cy / 4) + rayLength * sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DhuhrIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Color(0xFF8E98A1)
          ..strokeWidth = 2.0;

    canvas.drawCircle(Offset(cx, cy), cx * 0.45, paint);

    final rayPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Color(0xFF8E98A1)
          ..strokeWidth = 2.0;

    final rayLengthBig = cx * 0.7;
    final rayLength = cx * 0.8;
    final rayCount = 12;
    for (int i = 0; i < rayCount; i++) {
      final rayLength0 = (i % 2 != 0) ? rayLengthBig : rayLength;
      final angle = (2 * pi / rayCount) * i;
      final startX = cx + (cx * 0.45) * cos(angle);
      final startY = cy + (cx * 0.45) * sin(angle);
      final endX = cx + rayLength0 * cos(angle);
      final endY = cy + rayLength0 * sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AsrIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Color(0xFF8E98A1)
          ..strokeWidth = 2.0;

    canvas.drawCircle(Offset(cx, cy), cx * 0.45, paint);

    final rayPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Color(0xFF8E98A1)
          ..strokeWidth = 2.0;

    final rayLengthBig = cx * 0.7;
    final rayLength = cx * 0.6;
    final rayCount = 7;
    for (int i = 0; i < rayCount; i++) {
      final rayLength0 = (i % 2 != 0) ? rayLengthBig : rayLength;
      final angle = ((pi + pi / 6) / rayCount) * i;
      final startX = cx + (cx * 0.45) * cos(angle);
      final startY = cy + (cx * 0.45) * sin(angle);
      final endX = cx + rayLength0 * cos(angle);
      final endY = cy + rayLength0 * sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _IshaIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Color(0xFF8E98A1)
          ..strokeWidth = 2.0;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: cx * 0.5);

    final path1 =
        Path()
          ..arcTo(rect, 0.1 * pi, 1.3 * pi, false)
          ..quadraticBezierTo(
            0.4 * (cx * 2),
            (cy * 2) * (1 - 0.3),
            cx + cx * 0.5,
            cy,
          );

    canvas.drawArc(rect, 0 * pi, 1.3 * pi, false, paint);
    canvas.drawPath(path1, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
