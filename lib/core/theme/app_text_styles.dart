import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle heading = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle headingWhite = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
  );

  static const TextStyle subHeading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle appBarTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
    letterSpacing: 2.0,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyWhite = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textWhite,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelWhite = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textWhite,
  );

  static const TextStyle hint = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
  );

  static const TextStyle loginTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.buttonText,
  );

  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    decoration: TextDecoration.none,
  );

  static const TextStyle drawerItem = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textWhite,
  );

  static const TextStyle drawerHeaderTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textWhite,
    letterSpacing: 3.0,
  );

  static const TextStyle drawerHeaderSubtitle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: AppColors.textWhite,
    letterSpacing: 5.0,
  );
}
