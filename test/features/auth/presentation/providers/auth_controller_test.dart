import 'package:flowfi_fe/features/auth/domain/entities/auth_user.dart';
import 'package:flowfi_fe/features/auth/domain/repositories/auth_repository.dart';
import 'package:flowfi_fe/features/auth/domain/usecases/bootstrap_auth_session_use_case.dart';
import 'package:flowfi_fe/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:flowfi_fe/features/auth/domain/usecases/sign_out_use_case.dart';
import 'package:flowfi_fe/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:flowfi_fe/features/auth/presentation/providers/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts unauthenticated when bootstrap has no session', () async {
    final container = _container(FakeAuthRepository());

    final state = await container.read(authControllerProvider.future);

    expect(state.status, AuthStatus.unauthenticated);
  });

  test('signs in and publishes authenticated state', () async {
    final repository = FakeAuthRepository();
    final container = _container(repository);
    await container.read(authControllerProvider.future);

    await container
        .read(authControllerProvider.notifier)
        .signIn(email: 'alex@example.com', password: 'password123');

    final state = container.read(authControllerProvider).requireValue;
    expect(state.status, AuthStatus.authenticated);
    expect(state.user?.email, 'alex@example.com');
    expect(repository.signInCalled, isTrue);
  });

  test('signs out and returns to unauthenticated state', () async {
    final repository = FakeAuthRepository(
      bootstrappedUser: const AuthUser(
        id: 'user-1',
        email: 'alex@example.com',
        fullName: 'Alex Morgan',
        currencyCode: 'VND',
      ),
    );
    final container = _container(repository);
    await container.read(authControllerProvider.future);

    await container.read(authControllerProvider.notifier).signOut();

    final state = container.read(authControllerProvider).requireValue;
    expect(state.status, AuthStatus.unauthenticated);
    expect(repository.signOutCalled, isTrue);
  });
}

ProviderContainer _container(FakeAuthRepository repository) {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      bootstrapAuthSessionUseCaseProvider.overrideWithValue(
        BootstrapAuthSessionUseCase(repository),
      ),
      signInUseCaseProvider.overrideWithValue(SignInUseCase(repository)),
      signUpUseCaseProvider.overrideWithValue(SignUpUseCase(repository)),
      signOutUseCaseProvider.overrideWithValue(SignOutUseCase(repository)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.bootstrappedUser});

  final AuthUser? bootstrappedUser;
  bool signInCalled = false;
  bool signOutCalled = false;

  @override
  Future<AuthUser?> bootstrap() async => bootstrappedUser;

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    signInCalled = true;
    return AuthUser(
      id: 'user-1',
      email: email,
      fullName: 'Alex Morgan',
      currencyCode: 'VND',
    );
  }

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return AuthUser(
      id: 'user-1',
      email: email,
      fullName: fullName,
      currencyCode: 'VND',
    );
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }
}
