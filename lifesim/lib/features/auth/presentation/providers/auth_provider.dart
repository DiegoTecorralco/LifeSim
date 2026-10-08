import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

final authDataSourceProvider = Provider<AuthDataSource>(
  (ref) => AuthDataSource(),
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) {
    return AuthRepositoryImpl(
      ref.read(authDataSourceProvider),
    );
  },
);

final authProvider =
    NotifierProvider<AuthNotifier, AsyncValue<User?>>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AsyncValue<User?>> {
  late final AuthRepository _repository;

  @override
  AsyncValue<User?> build() {
    _repository = ref.read(authRepositoryProvider);

    return const AsyncValue.data(null);
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final user = await _repository.register(
        email: email,
        password: password,
      );

      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      final user = await _repository.login(
        email: email,
        password: password,
      );

      state = AsyncValue.data(user);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> logout() async {
    await _repository.logout();

    state = const AsyncValue.data(null);
  }

  Future<void> resetPassword(String email) async {
    await _repository.resetPassword(email);
  }
}