import 'package:supabase_flutter/supabase_flutter.dart';

class AuthDataSource {
  final SupabaseClient _client =
      Supabase.instance.client;

  Future<AuthResponse> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
      },
    );
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(
    String email,
  ) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo:
          'http://localhost:58565/reset-password',
    );
  }
}