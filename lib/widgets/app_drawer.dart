import 'package:flutter/material.dart';
import '../core/core.dart';

class _DrawerMenuItem {
  final IconData icon;
  final String title;
  final String routeId;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.routeId,
  });
}

class AppDrawer extends StatelessWidget {
  final String currentRoute;
  final void Function(String routeId) onItemSelected;

  const AppDrawer({
    super.key,
    required this.currentRoute,
    required this.onItemSelected,
  });

  static const List<_DrawerMenuItem> _menuItems = [
    _DrawerMenuItem(icon: Icons.home_outlined, title: AppConstants.navHome, routeId: 'home'),
    _DrawerMenuItem(icon: Icons.point_of_sale, title: AppConstants.navSales, routeId: 'sales'),
    _DrawerMenuItem(icon: Icons.bar_chart, title: AppConstants.navReport, routeId: 'report'),
    _DrawerMenuItem(icon: Icons.category_outlined, title: AppConstants.navProducts, routeId: 'products'),
    _DrawerMenuItem(icon: Icons.layers_outlined, title: AppConstants.navCategories, routeId: 'categories'),
    _DrawerMenuItem(icon: Icons.people_outline, title: AppConstants.navCustomers, routeId: 'customers'),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.drawerBackground,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                final isSelected = item.routeId == currentRoute;
                return _buildMenuItem(context, item, isSelected);
              },
            ),
          ),
          const Divider(color: Colors.white24, height: 1),
          _buildLogoutItem(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: const BoxDecoration(
        color: AppColors.drawerHeader,
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white54, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 40,
                color: AppColors.iconWhite,
              ),
            ),
            const SizedBox(height: 12),
            const Text('CONU', style: AppTextStyles.drawerHeaderTitle),
            const SizedBox(height: 2),
            const Text('B O O K S T O R E', style: AppTextStyles.drawerHeaderSubtitle),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, _DrawerMenuItem item, bool isSelected) {
    return Container(
      color: isSelected ? AppColors.drawerSelectedItem : Colors.transparent,
      child: ListTile(
        leading: Icon(item.icon, color: AppColors.iconWhite, size: 22),
        title: Text(item.title, style: AppTextStyles.drawerItem),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        onTap: () {
          Navigator.pop(context);
          onItemSelected(item.routeId);
        },
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout, color: AppColors.iconWhite, size: 22),
      title: const Text(AppConstants.navLogout, style: AppTextStyles.drawerItem),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      onTap: () {
        Navigator.pop(context);
        _showLogoutDialog(context);
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onItemSelected('logout');
            },
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }
}
