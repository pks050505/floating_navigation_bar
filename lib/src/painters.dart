

import 'package:flutter/material.dart';

Path _buildSmoothNotchedPath(
  Size size,
  double topRadius,
  double bottomRadius,
  double leftRadius,
  double rightRadius,
  double notchRadius,
  double notchCenterX, // ← dynamic center
) {
  final double w = size.width;
  final double h = size.height;

  final double lx = leftRadius.clamp(0.0, w / 2).toDouble();
  final double rx = rightRadius.clamp(0.0, w / 2).toDouble();
  final double ty = topRadius.clamp(0.0, h / 2).toDouble();
  final double by = bottomRadius.clamp(0.0, h / 2).toDouble();

  final double widthScale = (w / 390.0).clamp(0.8, 1.4).toDouble();
  final double heightScale = (h / 81.0).clamp(0.75, 1.4).toDouble();

  final double s = (10.0 * widthScale).clamp(6.0, 16.0).toDouble();
  final double notchInset = (10.0 * widthScale).clamp(6.0, 18.0).toDouble();
  final double depthShift =
      (10.0 * heightScale).clamp(6.0, h * 0.45).toDouble();

  final double maxNotch =
      (((w - lx - rx) / 2) - s - 2.0).clamp(0.0, w / 2).toDouble();
  final double nr = (notchRadius - notchInset).clamp(0.0, maxNotch).toDouble();

  final double cx = notchCenterX;

  return Path()
    ..moveTo(lx, 0)
    ..lineTo(cx - nr - s, 0)
    ..quadraticBezierTo(cx - nr, 0, cx - nr, depthShift)
    ..arcToPoint(
      Offset(cx + nr, depthShift),
      radius: Radius.circular(nr),
      clockwise: false,
    )
    ..quadraticBezierTo(cx + nr, 0, cx + nr + s, 0)
    ..lineTo(w - rx, 0)
    ..quadraticBezierTo(w, 0, w, ty)
    ..lineTo(w, h - by)
    ..quadraticBezierTo(w, h, w - rx, h)
    ..lineTo(lx, h)
    ..quadraticBezierTo(0, h, 0, h - by)
    ..lineTo(0, ty)
    ..quadraticBezierTo(0, 0, lx, 0)
    ..close();
}

class NotchedNavClipper extends CustomClipper<Path> {
  final double topRadius, bottomRadius, leftRadius, rightRadius, notchRadius;
  final double notchCenterX;

  NotchedNavClipper({
    required this.topRadius,
    required this.bottomRadius,
    required this.leftRadius,
    required this.rightRadius,
    required this.notchRadius,
    required this.notchCenterX,
  });

  @override
  Path getClip(Size size) => _buildSmoothNotchedPath(size, topRadius,
      bottomRadius, leftRadius, rightRadius, notchRadius, notchCenterX);

  @override
  bool shouldReclip(covariant NotchedNavClipper old) =>
      old.notchCenterX != notchCenterX;
}

class NotchedNavBorderPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double topRadius, bottomRadius, leftRadius, rightRadius, notchRadius;
  final double notchCenterX;

  NotchedNavBorderPainter({
    required this.borderColor,
    required this.borderWidth,
    required this.topRadius,
    required this.bottomRadius,
    required this.leftRadius,
    required this.rightRadius,
    required this.notchRadius,
    required this.notchCenterX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _buildSmoothNotchedPath(size, topRadius, bottomRadius, leftRadius,
          rightRadius, notchRadius, notchCenterX),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth,
    );
  }

  @override
  bool shouldRepaint(covariant NotchedNavBorderPainter old) =>
      old.notchCenterX != notchCenterX;
}

class NavShadowPainter extends CustomPainter {
  final double topRadius, bottomRadius, leftRadius, rightRadius, notchRadius;
  final double notchCenterX;

  NavShadowPainter({
    required this.topRadius,
    required this.bottomRadius,
    required this.leftRadius,
    required this.rightRadius,
    required this.notchRadius,
    required this.notchCenterX,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawShadow(
      _buildSmoothNotchedPath(size, topRadius, bottomRadius, leftRadius,
          rightRadius, notchRadius, notchCenterX),
      Colors.black.withValues(alpha: 0.18),
      12.0,
      false,
    );
  }

  @override
  bool shouldRepaint(covariant NavShadowPainter old) =>
      old.notchCenterX != notchCenterX;
}
