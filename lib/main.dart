import 'package:flutter/material.dart';
import 'core/core.dart';
import 'screens/screens.dart';

void main() {
  runApp(const ConuBookstoreApp());
}

class ConuBookstoreApp extends StatelessWidget {
  const ConuBookstoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/main': (_) => const MainScreen(),
      },
    );
  }
}
