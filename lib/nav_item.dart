import 'package:flutter/material.dart';

class NavItem {
  final Widget outlineIcon;
  final Widget filledIcon;
  final String label;
  final int index;
  final bool showBadge;
  final String? badgeText;

  const NavItem({
    required this.outlineIcon,
    required this.filledIcon,
    required this.label,
    required this.index,
    this.showBadge = false,
    this.badgeText,
  });
}
