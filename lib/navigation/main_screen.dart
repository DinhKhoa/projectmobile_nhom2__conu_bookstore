import 'package:flutter/material.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/core.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/features.dart';

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
        return const SalesScreen();
      case 'report':
        return const ReportScreen();
      case 'products':
        return const ProductsScreen();
      case 'categories':
        return const CategoryScreen();
      case 'customers':
        return const CustomerScreen();
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
