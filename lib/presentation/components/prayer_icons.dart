import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../data/models/prayers.dart';

extension on Prayer {
  _CustomPainter painter(Color color, PrayerIconWeight weight) {
    switch (this) {
      case Prayer.fajr:
        return _FajrIconPainter(color, weight);
      case Prayer.sunrise:
        return _SunriseIconPainter(color, weight);
      case Prayer.dhuhr:
        return _DhuhrIconPainter(color, weight);
      case Prayer.asr:
        return _AsrIconPainter(color, weight);
      case Prayer.maghrib:
        return _MaghribIconPainter(color, weight);
      case Prayer.isha:
        return _IshaIconPainter(color, weight);
      case Prayer.midnight:
        return _MidNightIconPainter(color, weight);
    }
  }
}

enum PrayerIconWeight {
  thin,
  normal;

  double get width {
    switch (this) {
      case thin:
        return 1.5;
      case normal:
        return 2.0;
    }
  }
}

class PrayerIcon extends StatelessWidget {
  final Prayer prayer;
  final double radius;
  final PrayerIconWeight weight;
  final Color color;
  const PrayerIcon(
    this.prayer, {
    super.key,
    this.radius = 12,
    this.weight = PrayerIconWeight.normal,
    this.color = const Color(0xFF8E98A1),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.fromRadius(radius),
      painter: prayer.painter(color, weight),
    );
  }
}

class _FajrIconPainter extends _CustomPainter {
  _FajrIconPainter(super.color, super.weight);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color
          ..strokeWidth = weight.width;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: cx * 0.5);

    canvas.drawArc(rect, 0, pi, true, paint);

    final rayPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color
          ..strokeWidth = weight.width;

    final rayLength = cx * 0.7;
    const rayCount = 7;
    for (int i = 0; i < rayCount; i++) {
      final angle = ((pi + pi / 6) / rayCount) * i;
      final startX = cx + (cx * 0.45) * cos(angle);
      final startY = cy + (cx * 0.45) * sin(angle);
      final endX = cx + rayLength * cos(angle);
      final endY = cy + rayLength * sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), rayPaint);
    }

    canvas.drawPoints(PointMode.lines, [
      Offset(cx, cy),
      Offset(cx, cy - cx * 0.5),
      Offset(cx + cx * 0.25, cy - cx * 0.25),
      Offset(cx, cy - cx * 0.5),
      Offset(cx - cx * 0.25, cy - cx * 0.25),
      Offset(cx, cy - cx * 0.5),
    ], paint);
  }

  @override
  bool shouldRepaint(covariant _CustomPainter oldDelegate) => false;
}

class _SunriseIconPainter extends _CustomPainter {
  _SunriseIconPainter(super.color, super.weight);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color
          ..strokeWidth = weight.width;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: cx * 0.5);

    canvas.drawArc(rect, pi, pi, true, paint);

    final rayPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color
          ..strokeWidth = weight.width;

    final rayLength = cx * 0.8;
    const rayCount = 7;
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
      Offset(cx, cy),
      Offset(cx + cx * 0.25, cy + cx * 0.25),
      Offset(cx, cy),
      Offset(cx - cx * 0.25, cy + cx * 0.25),
      Offset(cx, cy),
    ], paint);
  }

  @override
  bool shouldRepaint(covariant _CustomPainter oldDelegate) => false;
}

class _DhuhrIconPainter extends _CustomPainter {
  _DhuhrIconPainter(super.color, super.weight);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color
          ..strokeWidth = weight.width;

    canvas.drawCircle(Offset(cx, cy), cx * 0.45, paint);

    final rayPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color
          ..strokeWidth = weight.width;

    final rayLength = cx * 0.7;
    const rayCount = 12;
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
  bool shouldRepaint(covariant _CustomPainter oldDelegate) => false;
}

class _AsrIconPainter extends _CustomPainter {
  _AsrIconPainter(super.color, super.weight);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color
          ..strokeWidth = weight.width;

    canvas.drawCircle(Offset(cx, cy), cx * 0.45, paint);

    final rayPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color
          ..strokeWidth = weight.width;

    final rayLengthBig = cx * 0.7;
    final rayLength = cx * 0.6;
    const rayCount = 7;
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
  bool shouldRepaint(covariant _CustomPainter oldDelegate) => false;
}

class _MaghribIconPainter extends _CustomPainter {
  _MaghribIconPainter(super.color, super.weight);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color
          ..strokeWidth = weight.width;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: cx * 0.5);

    canvas.drawArc(rect, pi, pi, true, paint);

    final rayPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color
          ..strokeWidth = weight.width;

    final rayLength = cx * 0.65;
    const rayCount = 7;
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
      Offset(cx, cy + cx * 0.5),
      Offset(cx + cx * 0.25, cy + cx * 0.25),
      Offset(cx, cy + cx * 0.5),
      Offset(cx - cx * 0.25, cy + cx * 0.25),
      Offset(cx, cy + cx * 0.5),
    ], paint);
  }

  @override
  bool shouldRepaint(covariant _CustomPainter oldDelegate) => false;
}

class _IshaIconPainter extends _CustomPainter {
  _IshaIconPainter(super.color, super.weight);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color
          ..strokeWidth = weight.width;

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
  bool shouldRepaint(covariant _CustomPainter oldDelegate) => false;
}

class _MidNightIconPainter extends _CustomPainter {
  _MidNightIconPainter(super.color, super.weight);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final paint =
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color
          ..strokeWidth = weight.width;

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
          ..color = color
          ..strokeWidth = weight.width;

    final rayLengthBig = cx * 0.7;
    final rayLength = cx * 0.6;
    const rayCount = 5;
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
  bool shouldRepaint(covariant _CustomPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.weight != weight;
  }
}

abstract class _CustomPainter extends CustomPainter {
  Color color;
  PrayerIconWeight weight;

  _CustomPainter(this.color, this.weight);
}
