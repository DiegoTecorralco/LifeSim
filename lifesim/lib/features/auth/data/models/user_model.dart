import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
  });

  factory UserModel.fromSupabaseUser(
    dynamic user,
  ) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
    );
  }
}