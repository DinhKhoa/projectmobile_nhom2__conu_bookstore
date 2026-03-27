import 'package:flutter/material.dart';
import '../core/core.dart';
import '../widgets/widgets.dart';
import 'home_screen.dart';
import 'report_screen.dart';
import 'placeholder_screen.dart';
import 'category_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _currentRoute = 'home';

  Widget _getBodyForRoute(String route) {
    switch (route) {
      case 'home':
        return const HomeScreen();
      case 'sales':
        return const PlaceholderScreen(
          title: AppConstants.navSales,
          icon: Icons.point_of_sale,
        );
      case 'report':
        return const ReportScreen();
      case 'products':
        return const PlaceholderScreen(
          title: AppConstants.navProducts,
          icon: Icons.category_outlined,
        );
      case 'categories':
        return const CategoryScreen();   
      case 'customers':
        return const PlaceholderScreen(
          title: AppConstants.navCustomers,
          icon: Icons.people_outline,
        );
      default:
        return const HomeScreen();
    }
  }

  void _onDrawerItemSelected(String routeId) {
    if (routeId == 'logout') {
      _handleLogout();
      return;
    }

    setState(() {
      _currentRoute = routeId;
    });
  }

  void _handleLogout() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(),
      drawer: AppDrawer(
        currentRoute: _currentRoute,
        onItemSelected: _onDrawerItemSelected,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _getBodyForRoute(_currentRoute),
      ),
    );
  }
}
