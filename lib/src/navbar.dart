import 'package:custom_floating_navigation_bar/src/nav_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class CustomFloatingNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavItem> items;
  final Widget floatingWidget;

  final double floatingSize;
  final double floatingLift;
  final double centerGapWidth;
  final double barHeight;
  final double notchRadius;
  final double topRadius;
  final double bottomRadius;
  final double leftRadius;
  final double rightRadius;

  CustomFloatingNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    required this.floatingWidget,
    this.floatingSize = 132,
    this.floatingLift = 68,
    this.centerGapWidth = 136,
    this.barHeight = 81,
    this.notchRadius = 48,
    this.topRadius = 14,
    this.bottomRadius = 20,
    this.leftRadius = 24,
    this.rightRadius = 12,
  }) : assert(items.isNotEmpty, "At least two items required");

  @override
  Widget build(BuildContext context) {
    int totalSlots = items.length + 1;
    int middleSlotIndex = totalSlots ~/ 2;

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // 1. Shadow Layer (Using CustomPaint to avoid white background issues)
          Positioned.fill(
            child: CustomPaint(
              painter: _NavShadowPainter(
                topRadius: topRadius.r,
                bottomRadius: bottomRadius.r,
                leftRadius: leftRadius.r,
                rightRadius: rightRadius.r,
                notchRadius: notchRadius.r,
              ),
            ),
          ),
          // 2. Main Nav Bar with ClipPath for perfect transparency
          ClipPath(
            clipper: _NotchedNavClipper(
              topRadius: topRadius,
              bottomRadius: bottomRadius.r,
              leftRadius: leftRadius.r,
              rightRadius: rightRadius.r,
              notchRadius: notchRadius.r,
            ),
            child: Container(
              height: barHeight.h,
              color: Colors.white,
              child: CustomPaint(
                painter: _NotchedNavBorderPainter(
                  borderColor: const Color(0xFFF0F0F0),
                  borderWidth: 1.5,
                  topRadius: topRadius,
                  bottomRadius: bottomRadius.r,
                  leftRadius: leftRadius.r,
                  rightRadius: rightRadius.r,
                  notchRadius: notchRadius.r,
                ),
                child: Row(
                  children: List.generate(totalSlots, (slotIndex) {
                    if (slotIndex == middleSlotIndex) {
                      return SizedBox(width: centerGapWidth.w);
                    }

                    final itemIndex =
                        slotIndex < middleSlotIndex ? slotIndex : slotIndex - 1;
                    final item = items[itemIndex];
                    final bool isSelected = currentIndex == item.index;

                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onTap(item.index),
                        // borderRadius: BorderRadius.circular(30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 26.h,
                              width: 26.w,
                              child: isSelected
                                  ? item.filledIcon
                                  : item.outlineIcon,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.label,
                              style: TextStyle(
                                color: isSelected
                                    ? const Color(0xff3A3333)
                                    : const Color(0xff60646C),
                                fontSize: isSelected ? 13 : 12,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          // 3. Floating Widget
          Positioned(
            top: -floatingLift.h,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => onTap(2), // Center action
                child: SizedBox(
                  width: floatingSize,
                  height: floatingSize,
                  child: floatingWidget,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Path _buildSmoothNotchedPath(
  Size size,
  double topRadius,
  double bottomRadius,
  double leftRadius,
  double rightRadius,
  double notchRadius,
) {
  final double w = size.width;
  final double h = size.height;

  // Keep radii in valid bounds for any device size.
  final double lx = leftRadius.clamp(0.0, w / 2).toDouble();
  final double rx = rightRadius.clamp(0.0, w / 2).toDouble();
  final double ty = topRadius.clamp(0.0, h / 2).toDouble();
  final double by = bottomRadius.clamp(0.0, h / 2).toDouble();

  // Responsive scaling based on actual nav bar size.
  final double widthScale = (w / 390.0).clamp(0.8, 1.4).toDouble();
  final double heightScale = (h / 81.0).clamp(0.75, 1.4).toDouble();

  // Smooth entry/exit around notch (replaces fixed 10px).
  final double s = (10.0 * widthScale).clamp(6.0, 16.0).toDouble();
  final double notchInset = (10.0 * widthScale).clamp(6.0, 18.0).toDouble();
  final double depthShift =
      (10.0 * heightScale).clamp(6.0, h * 0.45).toDouble();

  final double maxNotch =
      (((w - lx - rx) / 2) - s - 2.0).clamp(0.0, w / 2).toDouble();
  final double nr =
      (notchRadius.r - notchInset).clamp(0.0, maxNotch).toDouble();
  final double cx = w / 2;

  final path = Path()
    // 1. Start after top-left corner
    ..moveTo(lx, 0)
    // 2. Line to notch start
    ..lineTo(cx - nr - s, 0)
    // 3. Bezier curve into the notch
    ..quadraticBezierTo(cx - nr, 0, cx - nr, depthShift)
    // 4. The Notch Arc
    ..arcToPoint(
      Offset(cx + nr, depthShift),
      radius: Radius.circular(nr),
      clockwise: false,
    )
    // 5. Bezier curve out of the notch
    ..quadraticBezierTo(cx + nr, 0, cx + nr + s, 0)
    // 6. Top-Right Corner
    ..lineTo(w - rx, 0)
    ..quadraticBezierTo(w, 0, w, ty)
    // 7. Bottom-Right Corner
    ..lineTo(w, h - by)
    ..quadraticBezierTo(w, h, w - rx, h)
    // 8. Bottom-Left Corner
    ..lineTo(lx, h)
    ..quadraticBezierTo(0, h, 0, h - by)
    // 9. Back to Top-Left
    ..lineTo(0, ty)
    ..quadraticBezierTo(0, 0, lx, 0)
    ..close();

  return path;
}

class _NotchedNavClipper extends CustomClipper<Path> {
  final double topRadius;
  final double bottomRadius;
  final double leftRadius;
  final double rightRadius;
  final double notchRadius;
  _NotchedNavClipper({
    required this.topRadius,
    required this.bottomRadius,
    required this.leftRadius,
    required this.rightRadius,
    required this.notchRadius,
  });

  @override
  Path getClip(Size size) => _buildSmoothNotchedPath(
        size,
        topRadius,
        bottomRadius,
        leftRadius,
        rightRadius,
        notchRadius,
      );

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class _NotchedNavBorderPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double topRadius;
  final double bottomRadius;
  final double leftRadius;
  final double rightRadius;
  final double notchRadius;

  _NotchedNavBorderPainter({
    required this.borderColor,
    required this.borderWidth,
    required this.topRadius,
    required this.bottomRadius,
    required this.leftRadius,
    required this.rightRadius,
    required this.notchRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawPath(
      _buildSmoothNotchedPath(
        size,
        topRadius,
        bottomRadius,
        leftRadius,
        rightRadius,
        notchRadius,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _NavShadowPainter extends CustomPainter {
  final double topRadius;
  final double bottomRadius;
  final double leftRadius;
  final double rightRadius;
  final double notchRadius;
  _NavShadowPainter({
    required this.topRadius,
    required this.bottomRadius,
    required this.leftRadius,
    required this.rightRadius,
    required this.notchRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = _buildSmoothNotchedPath(
      size,
      topRadius,
      bottomRadius,
      leftRadius,
      rightRadius,
      notchRadius,
    );
    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.18), 12.0, false);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


