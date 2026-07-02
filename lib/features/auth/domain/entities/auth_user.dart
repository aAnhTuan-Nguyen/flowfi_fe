final class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    this.fullName,
    required this.currencyCode,
    this.monthlyBudgetLimit,
  });

  final String id;
  final String email;
  final String? fullName;
  final String currencyCode;
  final String? monthlyBudgetLimit;
}
