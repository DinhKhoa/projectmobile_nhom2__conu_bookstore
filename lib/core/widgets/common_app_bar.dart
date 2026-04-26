import 'package:flutter/material.dart';
import 'package:projectmobile_nhom2_conu_bookstore/core/core.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onProfilePressed;
  final List<Widget>? additionalActions;

  const CommonAppBar({
    super.key,
    this.title = AppConstants.appName,
    this.onMenuPressed,
    this.onProfilePressed,
    this.additionalActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.appBarBackground,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.iconWhite),
        onPressed: onMenuPressed ?? () => Scaffold.of(context).openDrawer(),
      ),
      title: Text(
        title,
        style: AppTextStyles.appBarTitle,
      ),
      centerTitle: true,
      actions: [
        ...?additionalActions,
        IconButton(
          icon: const Icon(Icons.account_circle_outlined, color: AppColors.iconWhite, size: 28),
          onPressed: onProfilePressed ?? () {},
        ),
      ],
    );
  }
}
