import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/prayers.dart';

extension on Prayer {
  CustomPainter get painter {
    switch (this) {
      case Prayer.fajr:
        return _FajrIconPainter();
      case Prayer.sunrise:
        return _SunriseIconPainter();
      case Prayer.dhuhr:
        return _DhuhrIconPainter();
      case Prayer.asr:
        return _AsrIconPainter();
      case Prayer.maghrib:
        return _MaghribIconPainter();
      case Prayer.isha:
        return _IshaIconPainter();
      case Prayer.midnight:
        return _MidNightIconPainter();
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

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: cx * 0.5);

    canvas.drawArc(rect, 0, pi, true, paint);

    final rayPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Color(0xFF8E98A1)
          ..strokeWidth = 2.0;

    final rayLength = cx * 0.7;
    final rayCount = 7;
    for (int i = 0; i < rayCount; i++) {
      final angle = (-(pi + pi / 6) / rayCount) * i;
      final startX = cx + (cx * 0.45) * cos(angle);
      final startY = cy + (cx * 0.45) * sin(angle);
      final endX = cx + rayLength * cos(angle);
      final endY = cy + rayLength * sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SunriseIconPainter extends CustomPainter {
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
      final startY = cy + (cx * 0.45) * sin(angle);
      final endX = cx + rayLength * cos(angle);
      final endY = cy + rayLength * sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), rayPaint);
    }

    canvas.drawPoints(PointMode.lines, [
      Offset(cx, cy),
      Offset(cx + cx * 0.5, cy + cx * 0.5),
      Offset(cx + cx * 0.5, cy + cx * 0.5),
      Offset(cx - cx * 0.5, cy + cx * 0.5),
      Offset(cx - cx * 0.5, cy + cx * 0.5),
      Offset(cx, cy),
    ], paint);
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

    final rayLength = cx * 0.7;
    final rayCount = 12;
    for (int i = 0; i < rayCount; i++) {
      final angle = (2 * pi / rayCount) * i;
      final startX = cx + (cx * 0.45) * cos(angle);
      final startY = cy + (cx * 0.45) * sin(angle);
      final endX = cx + rayLength * cos(angle);
      final endY = cy + rayLength * sin(angle);
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

class _MaghribIconPainter extends CustomPainter {
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

    canvas.drawArc(rect, pi, pi, true, paint);

    final rayPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Color(0xFF8E98A1)
          ..strokeWidth = 2.0;

    final rayLength = cx * 0.65;
    final rayCount = 7;
    for (int i = 0; i < rayCount; i++) {
      final angle = (-(pi + pi / 6) / rayCount) * i;
      final startX = cx + (cx * 0.45) * cos(angle);
      final startY = cy + (cx * 0.45) * sin(angle);
      final endX = cx + rayLength * cos(angle);
      final endY = cy + rayLength * sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), rayPaint);
    }
    canvas.drawPoints(PointMode.lines, [
      Offset(cx, cy + cx * 0.5),
      Offset(cx + cx * 0.5, cy),
      Offset(cx + cx * 0.5, cy),
      Offset(cx - cx * 0.5, cy),
      Offset(cx - cx * 0.5, cy),
      Offset(cx, cy + cx * 0.5),
    ], paint);
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

class _MidNightIconPainter extends CustomPainter {
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

    final rayPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Color(0xFF8E98A1)
          ..strokeWidth = 2.0;

    final rayLengthBig = cx * 0.7;
    final rayLength = cx * 0.6;
    final rayCount = 5;
    for (int i = 0; i < rayCount; i++) {
      final rayLength0 = (i % 2 == 0) ? rayLengthBig : rayLength;
      final angle = ((pi - pi / 6) / rayCount) * (i + 1);
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
