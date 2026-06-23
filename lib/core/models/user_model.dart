import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.dateOfBirth,
    required this.currencyCode,
    this.monthlyBudgetLimit,
    required this.authProvider,
    required this.isVerified,
    required this.role,
    required this.createdAt,
  });

  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String currencyCode;
  final double? monthlyBudgetLimit;
  final String authProvider;
  final bool isVerified;
  final String role;
  final DateTime createdAt;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'].toString())
          : null,
      currencyCode: json['currencyCode'] as String? ?? 'USD',
      monthlyBudgetLimit: (json['monthlyBudgetLimit'] as num?)?.toDouble(),
      authProvider: json['authProvider'] as String? ?? 'local',
      isVerified: json['isVerified'] as bool? ?? false,
      role: json['role'] as String? ?? 'user',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      if (fullName != null) 'fullName': fullName,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      if (dateOfBirth != null) 'dateOfBirth': dateOfBirth?.toIso8601String().split('T').first,
      'currencyCode': currencyCode,
      if (monthlyBudgetLimit != null) 'monthlyBudgetLimit': monthlyBudgetLimit,
      'authProvider': authProvider,
      'isVerified': isVerified,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        avatarUrl,
        dateOfBirth,
        currencyCode,
        monthlyBudgetLimit,
        authProvider,
        isVerified,
        role,
        createdAt,
      ];
}
