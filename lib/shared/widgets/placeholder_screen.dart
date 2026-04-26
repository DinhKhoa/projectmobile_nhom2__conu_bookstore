import 'package:flutter/material.dart';
import 'package:projectmobile_nhom2_conu_bookstore/core/core.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.heading,
          ),
          const SizedBox(height: 8),
          const Text(
            'Chức năng đang được phát triển',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
