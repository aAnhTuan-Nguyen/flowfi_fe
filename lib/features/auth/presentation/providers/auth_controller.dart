import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../di/injection.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/bootstrap_auth_session_use_case.dart';
import '../../domain/usecases/sign_in_use_case.dart';
import '../../domain/usecases/sign_out_use_case.dart';
import '../../domain/usecases/sign_up_use_case.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => serviceLocator<AuthRepository>(),
);

final bootstrapAuthSessionUseCaseProvider =
    Provider<BootstrapAuthSessionUseCase>(
      (ref) => BootstrapAuthSessionUseCase(ref.watch(authRepositoryProvider)),
    );

final signInUseCaseProvider = Provider<SignInUseCase>(
  (ref) => SignInUseCase(ref.watch(authRepositoryProvider)),
);

final signUpUseCaseProvider = Provider<SignUpUseCase>(
  (ref) => SignUpUseCase(ref.watch(authRepositoryProvider)),
);

final signOutUseCaseProvider = Provider<SignOutUseCase>(
  (ref) => SignOutUseCase(ref.watch(authRepositoryProvider)),
);

enum AuthStatus { authenticated, unauthenticated }

final class AuthState {
  const AuthState._({required this.status, this.user});

  const AuthState.authenticated(AuthUser user)
    : this._(status: AuthStatus.authenticated, user: user);

  const AuthState.unauthenticated()
    : this._(status: AuthStatus.unauthenticated);

  final AuthStatus status;
  final AuthUser? user;
}

class AuthController extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final user = await ref.watch(bootstrapAuthSessionUseCaseProvider)();
    if (user == null) {
      return const AuthState.unauthenticated();
    }
    return AuthState.authenticated(user);
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(signInUseCaseProvider)(
        email: email,
        password: password,
      );
      return AuthState.authenticated(user);
    });
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(signUpUseCaseProvider)(
        email: email,
        password: password,
        fullName: fullName,
      );
      return AuthState.authenticated(user);
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(signOutUseCaseProvider)();
      return const AuthState.unauthenticated();
    });
  }
}

final authControllerProvider = AsyncNotifierProvider<AuthController, AuthState>(
  AuthController.new,
);
