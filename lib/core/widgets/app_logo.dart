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
    return Image.asset(
      'assets/images/co_nu_xanh.png',
      height: iconSize * 1.5,
      fit: BoxFit.contain,
    );
  }
}
