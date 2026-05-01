import 'package:flutter/material.dart';
import 'package:projectmobile_nhom2__conu_bookstore/injection_container.dart'
    as di;

import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const ConuBookstoreApp());
}
