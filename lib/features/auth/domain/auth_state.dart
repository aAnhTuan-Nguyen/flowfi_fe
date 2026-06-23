import 'package:equatable/equatable.dart';

class AuthState extends Equatable {
  const AuthState({
    this.isAuthenticated = false,
    this.userId,
    this.displayName,
    this.email,
    this.avatarUrl,
    this.isLoading = false,
    this.error,
  });

  final bool isAuthenticated;
  final String? userId;
  final String? displayName;
  final String? email;
  final String? avatarUrl;
  final bool isLoading;
  final String? error;

  AuthState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? displayName,
    String? email,
    String? avatarUrl,
    bool? isLoading,
    String? error,
  }) =>
      AuthState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        userId: userId ?? this.userId,
        displayName: displayName ?? this.displayName,
        email: email ?? this.email,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );

  @override
  List<Object?> get props => [
        isAuthenticated,
        userId,
        displayName,
        email,
        avatarUrl,
        isLoading,
        error,
      ];
}
