import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<User?> register({
    required String email,
    required String password,
  }) async {
    final response = await _dataSource.register(
      email: email,
      password: password,
    );

    if (response.user == null) {
      return null;
    }

    return UserModel.fromSupabaseUser(
      response.user!,
    );
  }

  @override
  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final response = await _dataSource.login(
      email: email,
      password: password,
    );

    if (response.user == null) {
      return null;
    }

    return UserModel.fromSupabaseUser(
      response.user!,
    );
  }

  @override
  Future<void> logout() async {
    await _dataSource.logout();
  }

  @override
  Future<void> resetPassword(String email) async {
    await _dataSource.resetPassword(email);
  }

  @override
  User? getCurrentUser() {
    final user = supabase.Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return null;
    }

    return UserModel.fromSupabaseUser(user);
  }
}