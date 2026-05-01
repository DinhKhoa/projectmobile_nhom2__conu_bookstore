import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/app/routes.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/core.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/category/presentation/bloc/category_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/home/presentation/bloc/dashboard_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/presentation/bloc/product_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/report/presentation/bloc/report_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/sales/presentation/bloc/sales_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/injection_container.dart';

class ConuBookstoreApp extends StatelessWidget {
  const ConuBookstoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<AuthBloc>()),
        BlocProvider(create: (_) => sl<ProductBloc>()),
        BlocProvider(create: (_) => sl<CategoryBloc>()),
        BlocProvider(create: (_) => sl<CustomerBloc>()),
        BlocProvider(create: (_) => sl<SalesBloc>()),
        BlocProvider(create: (_) => sl<DashboardBloc>()),
        BlocProvider(create: (_) => sl<ReportBloc>()),
      ],
      child: MaterialApp(
        title: AppConstants.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.login,
        routes: AppRoutes.routes,
      ),
    );
  }
}
