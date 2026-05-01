import 'package:dartz/dartz.dart';
import 'package:projectmobile_nhom2__conu_bookstore/core/error/failures.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/auth/domain/entities/user_entity.dart';
import 'package:projectmobile_nhom2__conu_bookstore/features/auth/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPreferences,
  });

  @override
  Future<Either<Failure, UserEntity>> login(
    String username,
    String password,
  ) async {
    try {
      final userModel = await remoteDataSource.login(username, password);
      if (userModel.token != null) {
        await sharedPreferences.setString('token', userModel.token!);
      }
      return Right(userModel);
    } catch (e) {
      String message = e.toString();
      if (message.startsWith('Exception: ')) {
        message = message.substring(11);
      }
      return Left(ServerFailure(message));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    await sharedPreferences.remove('token');
    return const Right(null);
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = sharedPreferences.getString('token');
    return token != null && token.isNotEmpty;
  }
}
