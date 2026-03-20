import 'package:custom_floating_navigation_bar/src/nav_item.dart';
import 'package:custom_floating_navigation_bar/src/painters.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum FloatingPosition {
  center,
  left,
  right,
  custom,
}

class CustomFloatingNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavItem> items;
  final Widget floatingWidget;
  final bool enableHaptic;

  final FloatingPosition floatingPosition;
  final int? customFloatingSlotIndex;
  final Function(int)? onFloatingTap;

  // ── Sizing ──────────────────────────────────────────────────
  final double floatingSize;
  final double floatingLift;
  final double centerGapWidth;
  final double barHeight;
  final double iconSize;

  // ── Shape ───────────────────────────────────────────────────
  final double notchRadius;
  final double topRadius;
  final double bottomRadius;
  final double leftRadius;
  final double rightRadius;

  // ── Colors ──────────────────────────────────────────────────
  final Color backgroundColor;
  final Color selectedColor;
  final Color unselectedColor;
  final Color borderColor;
  final Color shadowColor;
  final double shadowBlur;

  CustomFloatingNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    required this.floatingWidget,
    this.floatingPosition = FloatingPosition.center,
    this.customFloatingSlotIndex,
    this.onFloatingTap,
    this.enableHaptic = true,

    // ── Sizing ──
    this.floatingSize = 64,
    this.floatingLift = 30,
    this.centerGapWidth = 80,
    this.barHeight = 64,
    this.iconSize = 24,

    // ── Shape ──
    this.notchRadius = 40,
    this.topRadius = 14,
    this.bottomRadius = 20,
    this.leftRadius = 24,
    this.rightRadius = 12,

    // ── Colors ──
    this.backgroundColor = Colors.white,
    this.selectedColor = const Color(0xff3A3333),
    this.unselectedColor = const Color(0xff60646C),
    this.borderColor = const Color(0xFFF0F0F0),
    this.shadowColor = Colors.black,
    this.shadowBlur = 12.0,
  })  : assert(items.length >= 2, "At least two items required"),
        assert(
          floatingPosition != FloatingPosition.custom ||
              customFloatingSlotIndex != null,
          "customFloatingSlotIndex required when floatingPosition is custom",
        );

  int _resolveFloatingSlotIndex() {
    final int totalSlots = items.length + 1;

    switch (floatingPosition) {
      case FloatingPosition.center:
        return totalSlots ~/ 2;
      case FloatingPosition.left:
        return 0;
      case FloatingPosition.right:
        return totalSlots - 1;
      case FloatingPosition.custom:
        final idx = customFloatingSlotIndex!;
        if (idx < 0 || idx >= totalSlots) {
          assert(
            false,
            "customFloatingSlotIndex ($idx) out of range (0..${totalSlots - 1}), falling back to center",
          );
          return totalSlots ~/ 2;
        }
        return idx;
    }
  }

  int _resolveFloatingItemIndex(int slotIndex) {
    final int totalSlots = items.length + 1;
    if (slotIndex >= totalSlots - 1) return items.last.index;
    if (slotIndex <= 0) return items.first.index;
    return items[slotIndex - 1].index;
  }

  @override
  Widget build(BuildContext context) {
    final int totalSlots = items.length + 1;
    final int floatingSlotIndex = _resolveFloatingSlotIndex();
    final int floatingItemIndex = _resolveFloatingItemIndex(floatingSlotIndex);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double totalWidth = constraints.maxWidth;
        final double slotWidth = totalWidth / totalSlots;
        final double floatingCenterX =
            (floatingSlotIndex * slotWidth) + (slotWidth / 2);

        return SizedBox(
          height: barHeight,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── 1. Shadow Layer ────────────────────────────────────
              Positioned.fill(
                child: CustomPaint(
                  painter: NavShadowPainter(
                    topRadius: topRadius,
                    bottomRadius: bottomRadius,
                    leftRadius: leftRadius,
                    rightRadius: rightRadius,
                    notchRadius: notchRadius,
                    notchCenterX: floatingCenterX,
                    shadowColor: shadowColor,
                    shadowBlur: shadowBlur,
                  ),
                ),
              ),

              // ── 2. Main Nav Bar ────────────────────────────────────
              ClipPath(
                clipper: NotchedNavClipper(
                  topRadius: topRadius,
                  bottomRadius: bottomRadius,
                  leftRadius: leftRadius,
                  rightRadius: rightRadius,
                  notchRadius: notchRadius,
                  notchCenterX: floatingCenterX,
                ),
                child: Container(
                  height: barHeight,
                  color: backgroundColor,
                  child: CustomPaint(
                    painter: NotchedNavBorderPainter(
                      borderColor: borderColor,
                      borderWidth: 1.5,
                      topRadius: topRadius,
                      bottomRadius: bottomRadius,
                      leftRadius: leftRadius,
                      rightRadius: rightRadius,
                      notchRadius: notchRadius,
                      notchCenterX: floatingCenterX,
                    ),
                    child: Row(
                      children: List.generate(totalSlots, (slotIndex) {
                        // Floating slot → gap
                        if (slotIndex == floatingSlotIndex) {
                          return SizedBox(width: centerGapWidth);
                        }

                        final int itemIndex = slotIndex < floatingSlotIndex
                            ? slotIndex
                            : slotIndex - 1;

                        // Bounds guard
                        if (itemIndex < 0 || itemIndex >= items.length) {
                          return const SizedBox.shrink();
                        }

                        final NavItem item = items[itemIndex];
                        final bool isSelected = currentIndex == item.index;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (enableHaptic) {
                                HapticFeedback.lightImpact();
                              }
                              onTap(item.index);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // ── Icon with optional Badge ──
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    SizedBox(
                                      height: iconSize,
                                      width: iconSize,
                                      child: isSelected
                                          ? item.filledIcon
                                          : item.outlineIcon,
                                    ),
                                    if (item.showBadge)
                                      Positioned(
                                        right: -4,
                                        top: -4,
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          constraints: const BoxConstraints(
                                            minWidth: 14,
                                            minHeight: 14,
                                          ),
                                          child: item.badgeText != null
                                              ? Text(
                                                  item.badgeText!,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                )
                                              : const SizedBox.shrink(),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                // ── Label ──
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    color: isSelected
                                        ? selectedColor
                                        : unselectedColor,
                                    fontSize: isSelected ? 12 : 11,
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

              // ── 3. Floating Widget ─────────────────────────────────
              Positioned(
                top: -floatingLift,
                left: floatingCenterX - (floatingSize / 2),
                child: GestureDetector(
                  onTap: () {
                    if (enableHaptic) {
                      HapticFeedback.mediumImpact();
                    }
                    if (onFloatingTap != null) {
                      onFloatingTap!(floatingItemIndex);
                    } else {
                      onTap(floatingItemIndex);
                    }
                  },
                  child: SizedBox(
                    width: floatingSize,
                    height: floatingSize,
                    child: floatingWidget,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}


// import 'package:custom_floating_navigation_bar/src/nav_item.dart';
// import 'package:custom_floating_navigation_bar/src/painters.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// enum FloatingPosition {
//   center,
//   left,
//   right,
//   custom,
// }

// class CustomFloatingNavigationBar extends StatelessWidget {
//   final int currentIndex;
//   final Function(int) onTap;
//   final List<NavItem> items;
//   final Widget floatingWidget;
//   final bool enableHaptic;

//   final FloatingPosition floatingPosition;

//   final int? customFloatingSlotIndex;

//   final Function(int)? onFloatingTap;

//   final double floatingSize;
//   final double floatingLift;
//   final double centerGapWidth;
//   final double barHeight;
//   final double notchRadius;
//   final double topRadius;
//   final double bottomRadius;
//   final double leftRadius;
//   final double rightRadius;

//   CustomFloatingNavigationBar({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//     required this.items,
//     required this.floatingWidget,
//     this.floatingPosition = FloatingPosition.center,
//     this.customFloatingSlotIndex,
//     this.onFloatingTap,
//     this.floatingSize = 132,
//     this.floatingLift = 68,
//     this.centerGapWidth = 136,
//     this.barHeight = 81,
//     this.notchRadius = 48,
//     this.topRadius = 14,
//     this.bottomRadius = 20,
//     this.leftRadius = 24,
//     this.rightRadius = 12,
//     this.enableHaptic = true, 

//   })  : assert(items.isNotEmpty, "At least three item required"),
//         assert(
//           floatingPosition != FloatingPosition.custom ||
//               customFloatingSlotIndex != null,
//           "customFloatingSlotIndex required when floatingPosition is custom",
//         );

//   int _resolveFloatingSlotIndex() {
//     final int totalSlots = items.length + 1;

//     switch (floatingPosition) {
//       case FloatingPosition.center:
//         return totalSlots ~/ 2; // auto center

//       case FloatingPosition.left:
//         return 0; 

//       case FloatingPosition.right:
//         return totalSlots - 1; 

//       case FloatingPosition.custom:
//         final idx = customFloatingSlotIndex!;
//         if (idx < 0 || idx >= totalSlots) {
//           assert(false,
//               "customFloatingSlotIndex ($idx) out of range (0..${totalSlots - 1}), falling back to center");
//           return totalSlots ~/ 2;
//         }
//         return idx;
//     }
//   }

//   int _resolveFloatingItemIndex(int slotIndex) {
//     final int totalSlots = items.length + 1;

//     if (slotIndex >= totalSlots - 1) return items.last.index;
//     if (slotIndex <= 0) return items.first.index;

//     return items[slotIndex - 1].index;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final int totalSlots = items.length + 1;
//     final int floatingSlotIndex = _resolveFloatingSlotIndex();
//     final int floatingItemIndex = _resolveFloatingItemIndex(floatingSlotIndex);

//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final double totalWidth = constraints.maxWidth;
//         final double slotWidth = totalWidth / totalSlots;

//         final double floatingCenterX =
//             (floatingSlotIndex * slotWidth) + (slotWidth / 2);

//         return Container(
//           margin: EdgeInsets.zero,
//           child: Stack(
//             clipBehavior: Clip.none,
//             children: [
//               // ── 1. Shadow Layer ──────────────────────────────────────
//               Positioned.fill(
//                 child: CustomPaint(
//                   painter: NavShadowPainter(
//                     topRadius: topRadius.r,
//                     bottomRadius: bottomRadius.r,
//                     leftRadius: leftRadius.r,
//                     rightRadius: rightRadius.r,
//                     notchRadius: notchRadius.r,
//                     notchCenterX: floatingCenterX,
//                   ),
//                 ),
//               ),

//               // ── 2. Main Nav Bar ──────────────────────────────────────
//               ClipPath(
//                 clipper: NotchedNavClipper(
//                   topRadius: topRadius,
//                   bottomRadius: bottomRadius.r,
//                   leftRadius: leftRadius.r,
//                   rightRadius: rightRadius.r,
//                   notchRadius: notchRadius.r,
//                   notchCenterX: floatingCenterX,
//                 ),
//                 child: Container(
//                   height: barHeight.h,
//                   color: Colors.white,
//                   child: CustomPaint(
//                     painter: NotchedNavBorderPainter(
//                       borderColor: const Color(0xFFF0F0F0),
//                       borderWidth: 1.5,
//                       topRadius: topRadius,
//                       bottomRadius: bottomRadius.r,
//                       leftRadius: leftRadius.r,
//                       rightRadius: rightRadius.r,
//                       notchRadius: notchRadius.r,
//                       notchCenterX: floatingCenterX,
//                     ),
//                     child: Row(
//                       children: List.generate(totalSlots, (slotIndex) {
//                         // Floating slot → gap
//                         if (slotIndex == floatingSlotIndex) {
//                           return SizedBox(width: centerGapWidth.w);
//                         }

//                         final int itemIndex = slotIndex < floatingSlotIndex
//                             ? slotIndex
//                             : slotIndex - 1;

//                         // Bounds guard
//                         if (itemIndex < 0 || itemIndex >= items.length) {
//                           return const SizedBox.shrink();
//                         }

//                         final NavItem item = items[itemIndex];
//                         final bool isSelected = currentIndex == item.index;

//                         return Expanded(
//                           child: GestureDetector(
//                             onTap: () {
//                               if (enableHaptic) {
//                                 HapticFeedback.lightImpact(); // ← condition
//                               }
//                               onTap(item.index);
//                             },
//                             // onTap: () => onTap(item.index),
//                             behavior: HitTestBehavior.opaque,
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 // ── Icon with optional Badge ──
//                                 Stack(
//                                   clipBehavior: Clip.none,
//                                   children: [
//                                     SizedBox(
//                                       height: 26.h,
//                                       width: 26.w,
//                                       child: isSelected
//                                           ? item.filledIcon
//                                           : item.outlineIcon,
//                                     ),
//                                     if (item.showBadge)
//                                       Positioned(
//                                         right: -4,
//                                         top: -4,
//                                         child: Container(
//                                           padding: const EdgeInsets.all(2),
//                                           decoration: const BoxDecoration(
//                                             color: Colors.red,
//                                             shape: BoxShape.circle,
//                                           ),
//                                           constraints: const BoxConstraints(
//                                             minWidth: 14,
//                                             minHeight: 14,
//                                           ),
//                                           child: item.badgeText != null
//                                               ? Text(
//                                                   item.badgeText!,
//                                                   style: const TextStyle(
//                                                     color: Colors.white,
//                                                     fontSize: 8,
//                                                     fontWeight: FontWeight.bold,
//                                                   ),
//                                                   textAlign: TextAlign.center,
//                                                 )
//                                               : const SizedBox.shrink(),
//                                         ),
//                                       ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 6),
//                                 // ── Label ──
//                                 Text(
//                                   item.label,
//                                   style: TextStyle(
//                                     color: isSelected
//                                         ? const Color(0xff3A3333)
//                                         : const Color(0xff60646C),
//                                     fontSize: isSelected ? 13 : 12,
//                                     fontWeight: isSelected
//                                         ? FontWeight.w600
//                                         : FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       }),
//                     ),
//                   ),
//                 ),
//               ),

//               // ── 3. Floating Widget ───────────────────────────────────
//               Positioned(
//                 top: -floatingLift.h,
//                 // Center ke bajaye dynamic X position
//                 left: floatingCenterX - (floatingSize / 2),
//                 child: GestureDetector(
//                   // onTap: () => onFloatingTap != null
//                   //     ? onFloatingTap!(floatingItemIndex)
//                   //     : onTap(floatingItemIndex),
//                   onTap: () {
//                     if (enableHaptic) {
//                       HapticFeedback.mediumImpact(); // ← condition
//                     }
//                     if (onFloatingTap != null) {
//                       onFloatingTap!(floatingItemIndex);
//                     } else {
//                       onTap(floatingItemIndex);
//                     }
//                   },
//                   child: SizedBox(
//                     width: floatingSize,
//                     height: floatingSize,
//                     child: floatingWidget,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
