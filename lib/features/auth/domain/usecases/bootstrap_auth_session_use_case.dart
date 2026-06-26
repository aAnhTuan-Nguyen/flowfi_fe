import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

final class BootstrapAuthSessionUseCase {
  const BootstrapAuthSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser?> call() {
    return _repository.bootstrap();
  }
}
