import 'package:equatable/equatable.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.displayName,
    this.email,
    this.avatarUrl,
    this.isDarkMode = false,
    this.themeIndex = 0,
    this.isLoading = false,
  });

  final String? displayName;
  final String? email;
  final String? avatarUrl;
  final bool isDarkMode;
  final int themeIndex;
  final bool isLoading;

  @override
  List<Object?> get props =>
      [displayName, email, avatarUrl, isDarkMode, themeIndex, isLoading];
}
