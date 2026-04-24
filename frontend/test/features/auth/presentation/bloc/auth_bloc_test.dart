import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lonewalker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:lonewalker/features/auth/presentation/bloc/auth_event.dart';
import 'package:lonewalker/features/auth/presentation/bloc/auth_state.dart';

import '../../../../helpers/test_fakes.dart';

void main() {
  late FakeAuthRemoteDataSource fakeDataSource;

  setUp(() {
    fakeDataSource = FakeAuthRemoteDataSource();
  });

  group('AuthBloc', () {
    group('AuthLoginEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emite [AuthLoading, AuthAuthenticated] cuando login es exitoso',
        build: () => AuthBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const AuthLoginEvent(
          email: 'test@test.com',
          password: 'password123',
        )),
        expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
      );

      blocTest<AuthBloc, AuthState>(
        'AuthAuthenticated contiene el usuario correcto',
        build: () => AuthBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const AuthLoginEvent(
          email: 'test@test.com',
          password: 'password123',
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthAuthenticated>().having(
            (s) => s.user.email,
            'user.email',
            'test@test.com',
          ),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emite [AuthLoading, AuthError] cuando login falla',
        build: () {
          fakeDataSource.loginShouldFail = true;
          return AuthBloc(remoteDataSource: fakeDataSource);
        },
        act: (b) => b.add(const AuthLoginEvent(
          email: 'bad@test.com',
          password: 'wrongpassword',
        )),
        expect: () => [isA<AuthLoading>(), isA<AuthError>()],
      );

      blocTest<AuthBloc, AuthState>(
        'AuthError contiene mensaje de error no vacío',
        build: () {
          fakeDataSource.loginShouldFail = true;
          return AuthBloc(remoteDataSource: fakeDataSource);
        },
        act: (b) => b.add(const AuthLoginEvent(
          email: 'bad@test.com',
          password: 'wrong',
        )),
        expect: () => [
          isA<AuthLoading>(),
          isA<AuthError>().having((s) => s.message, 'message', isNotEmpty),
        ],
      );
    });

    group('AuthRegisterEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emite [AuthLoading, AuthAuthenticated] cuando registro es exitoso',
        build: () => AuthBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const AuthRegisterEvent(
          username: 'newuser',
          email: 'new@test.com',
          password: 'password123',
          passwordConfirm: 'password123',
        )),
        expect: () => [isA<AuthLoading>(), isA<AuthAuthenticated>()],
      );

      blocTest<AuthBloc, AuthState>(
        'emite [AuthLoading, AuthError] cuando usuario ya existe',
        build: () {
          fakeDataSource.registerShouldFail = true;
          return AuthBloc(remoteDataSource: fakeDataSource);
        },
        act: (b) => b.add(const AuthRegisterEvent(
          username: 'existing',
          email: 'taken@test.com',
          password: 'pass123',
          passwordConfirm: 'pass123',
        )),
        expect: () => [isA<AuthLoading>(), isA<AuthError>()],
      );
    });

    group('AuthLogoutEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emite [AuthLoading, AuthUnauthenticated] cuando logout es exitoso',
        build: () => AuthBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const AuthLogoutEvent()),
        expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
      );

      blocTest<AuthBloc, AuthState>(
        'emite [AuthLoading, AuthError] cuando logout falla',
        build: () {
          fakeDataSource.logoutShouldFail = true;
          return AuthBloc(remoteDataSource: fakeDataSource);
        },
        act: (b) => b.add(const AuthLogoutEvent()),
        expect: () => [isA<AuthLoading>(), isA<AuthError>()],
      );
    });

    group('AuthCheckStatusEvent', () {
      blocTest<AuthBloc, AuthState>(
        'emite [AuthAuthenticated] cuando hay token en memoria',
        setUp: () {
          fakeDataSource.setAuthenticated(true);
        },
        build: () => AuthBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const AuthCheckStatusEvent()),
        expect: () => [isA<AuthAuthenticated>()],
      );

      blocTest<AuthBloc, AuthState>(
        'emite [AuthUnauthenticated] cuando no hay token',
        build: () => AuthBloc(remoteDataSource: fakeDataSource),
        act: (b) => b.add(const AuthCheckStatusEvent()),
        expect: () => [isA<AuthUnauthenticated>()],
      );
    });
  });
}
