import 'package:flutter/material.dart';
import 'package:projectmobile_nhom2_conu_bookstore/core/core.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: AppLogo(
        iconSize: 100,
        titleFontSize: 48,
        subtitleFontSize: 16,
      ),
    );
  }
}
