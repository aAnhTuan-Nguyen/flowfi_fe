import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

final class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call({
    String? fullName,
    String? currencyCode,
    String? monthlyBudgetLimit,
  }) {
    return _repository.updateProfile(
      fullName: fullName,
      currencyCode: currencyCode,
      monthlyBudgetLimit: monthlyBudgetLimit,
    );
  }
}
