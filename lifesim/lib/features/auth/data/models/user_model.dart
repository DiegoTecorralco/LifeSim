import 'package:supabase_flutter/supabase_flutter.dart'
    as supabase;

import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.fullName,
  });

  factory UserModel.fromSupabaseUser(
    supabase.User user,
  ) {
    final metadata = user.userMetadata;

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      fullName: metadata?['full_name']?.toString(),
    );
  }
}