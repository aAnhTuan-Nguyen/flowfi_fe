import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

final class SignUpUseCase {
  const SignUpUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call({
    required String email,
    required String password,
    String? fullName,
  }) {
    return _repository.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );
  }
}
