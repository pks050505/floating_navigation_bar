import 'package:flutter/material.dart';

class NavItem {
  final Widget outlineIcon;
  final Widget filledIcon;
  final String label;
  final int index;
  const NavItem({
    required this.outlineIcon,
    required this.filledIcon,
    required this.label,
    required this.index,
  });
}
