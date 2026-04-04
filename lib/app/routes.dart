import 'package:flutter/material.dart';
import '../features/features.dart';
import '../navigation/main_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String login = '/login';
  static const String main = '/main';

  static Map<String, WidgetBuilder> get routes => {
        login: (_) => const LoginScreen(),
        main: (_) => const MainScreen(),
      };
}
