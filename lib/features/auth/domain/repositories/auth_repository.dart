import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  Future<AuthUser?> bootstrap();

  Future<AuthUser> signIn({required String email, required String password});

  Future<AuthUser> signUp({
    required String email,
    required String password,
    String? fullName,
  });

  Future<AuthUser> updateProfile({
    String? fullName,
    String? currencyCode,
    String? monthlyBudgetLimit,
  });

  Future<void> signOut();
}
