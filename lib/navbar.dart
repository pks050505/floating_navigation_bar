import 'package:custom_floating_navigation_bar/nav_item.dart';
import 'package:flutter/material.dart';

class FloatingNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavItem> items;
  final Widget floatingWidget;

  final double floatingSize;
  final double floatingLift;

  FloatingNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    required this.floatingWidget,
    this.floatingSize = 72,
    this.floatingLift = 34,
  }) : assert(items.isNotEmpty, "At least two item required");

  int get totalSlots => items.length + 1;

  int get middleSlotIndex => totalSlots ~/ 2;

  int get floatingActionIndex => items.length ~/ 2;

  @override
  Widget build(BuildContext context) {
    final double horizontalMargin = MediaQuery.of(context).size.width * 0.0001;
    const double barHeight = 74;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: horizontalMargin, vertical: 0),
      height: barHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(27),
          topRight: Radius.circular(27),
        ),
        border: Border.all(color: const Color(0xffFFE49B), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: List.generate(totalSlots, (slotIndex) {
              if (slotIndex == middleSlotIndex) {
                return const Expanded(child: SizedBox());
              }

              final itemIndex = slotIndex < middleSlotIndex
                  ? slotIndex
                  : slotIndex - 1;

              final item = items[itemIndex];
              final bool isSelected = currentIndex == item.index;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(item.index),
                  borderRadius: BorderRadius.circular(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected ? item.filledIcon : item.outlineIcon,
                        color: isSelected
                            ? const Color(0xff3A3333)
                            : const Color(0xff484C52),
                        size: isSelected ? 28 : 26,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xff3A3333)
                              : const Color(0xff484C52),
                          fontSize: isSelected ? 12 : 10,
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

          Positioned(
            top: -floatingLift,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => onTap(floatingActionIndex),
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
