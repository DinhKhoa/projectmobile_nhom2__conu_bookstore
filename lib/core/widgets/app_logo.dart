import 'package:flutter/material.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/core.dart';

class AppLogo extends StatelessWidget {
  final double iconSize;
  final double titleFontSize;
  final double subtitleFontSize;
  final Color color;

  const AppLogo({
    super.key,
    this.iconSize = 80,
    this.titleFontSize = 36,
    this.subtitleFontSize = 14,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.menu_book_rounded,
          size: iconSize,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(
          'CONU',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 4,
            height: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'B O O K S T O R E',
          style: TextStyle(
            fontSize: subtitleFontSize,
            fontWeight: FontWeight.w400,
            color: color,
            letterSpacing: 5,
          ),
        ),
      ],
    );
  }
}
