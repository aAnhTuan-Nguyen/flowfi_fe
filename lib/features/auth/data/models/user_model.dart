import '../../domain/entities/auth_user.dart';

final class UserModel {
  const UserModel({
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

  factory UserModel.fromJson(Map<String, Object?> json) {
    final source = _unwrapData(json);
    return UserModel(
      id: source['id'] as String? ?? '',
      email: source['email'] as String? ?? '',
      fullName: source['fullName'] as String?,
      currencyCode: source['currencyCode'] as String? ?? 'VND',
      monthlyBudgetLimit: source['monthlyBudgetLimit']?.toString(),
    );
  }

  AuthUser toDomain() {
    return AuthUser(
      id: id,
      email: email,
      fullName: fullName,
      currencyCode: currencyCode,
      monthlyBudgetLimit: monthlyBudgetLimit,
    );
  }
}

Map<String, Object?> _unwrapData(Map<String, Object?> json) {
  final data = json['data'];
  if (data is Map<String, Object?>) {
    return data;
  }
  if (data is Map) {
    return Map<String, Object?>.from(data);
  }
  return json;
}
