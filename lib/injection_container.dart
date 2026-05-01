import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/auth/domain/repositories/auth_repository.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/auth/domain/usecases/login_usecase.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/category/data/datasources/category_remote_data_source.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/category/data/repositories/category_repository_impl.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/category/domain/repositories/category_repository.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/category/presentation/bloc/category_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/customer/data/datasources/customer_remote_data_source.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/customer/data/repositories/customer_repository_impl.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/customer/domain/repositories/customer_repository.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/customer/presentation/bloc/customer_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/home/presentation/bloc/dashboard_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/data/datasources/product_remote_data_source.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/data/repositories/product_repository_impl.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/domain/repositories/product_repository.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/domain/usecases/get_all_products_usecase.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/product/presentation/bloc/product_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/report/data/datasources/report_remote_data_source.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/report/data/repositories/report_repository_impl.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/report/domain/repositories/report_repository.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/report/presentation/bloc/report_bloc.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/sales/data/datasources/order_remote_data_source.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/sales/data/repositories/order_repository_impl.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/sales/domain/repositories/order_repository.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/sales/presentation/bloc/sales_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerFactory(() => AuthBloc(loginUseCase: sl(), authRepository: sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), sharedPreferences: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerFactory(
    () => ProductBloc(getAllProductsUseCase: sl(), repository: sl()),
  );
  sl.registerLazySingleton(() => GetAllProductsUseCase(sl()));
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton(() => CategoryBloc(repository: sl()));
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CategoryRemoteDataSource>(
    () => CategoryRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerFactory(() => CustomerBloc(repository: sl()));
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<CustomerRemoteDataSource>(
    () => CustomerRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerFactory(() => SalesBloc(repository: sl()));
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerFactory(() => DashboardBloc(reportRepository: sl()));
  sl.registerFactory(() => ReportBloc(repository: sl()));
  sl.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ReportRemoteDataSource>(
    () => ReportRemoteDataSourceImpl(dio: sl()),
  );
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:3000/api',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        contentType: 'application/json',
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = sharedPreferences.getString('token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
    return dio;
  });
}
