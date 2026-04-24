import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../domain/entities/user.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRemoteDataSource remoteDataSource;

  AuthBloc({required this.remoteDataSource}) : super(const AuthInitial()) {
    on<AuthRegisterEvent>(_onRegister);
    on<AuthLoginEvent>(_onLogin);
    on<AuthLogoutEvent>(_onLogout);
    on<AuthCheckStatusEvent>(_onCheckStatus);
  }

  Future<void> _onRegister(
    AuthRegisterEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final result = await remoteDataSource.register(
        username: event.username,
        email: event.email,
        password: event.password,
        passwordConfirm: event.passwordConfirm,
      );

      // Save tokens
      await remoteDataSource.apiClient.saveTokens(
        result.accessToken,
        result.refreshToken,
      );

      emit(AuthAuthenticated(user: result.user));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLogin(
    AuthLoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final result = await remoteDataSource.login(
        email: event.email,
        password: event.password,
      );

      // Save tokens
      await remoteDataSource.apiClient.saveTokens(
        result.accessToken,
        result.refreshToken,
      );

      emit(AuthAuthenticated(user: result.user));
    } catch (e) {
      emit(AuthError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onLogout(
    AuthLogoutEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      await remoteDataSource.logout();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onCheckStatus(
    AuthCheckStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final isAuthenticated = remoteDataSource.apiClient.isAuthenticated();

    if (isAuthenticated) {
      // In a real app, you'd verify the token with the server
      emit(AuthAuthenticated(
        user: User(
          id: '',
          username: '',
          email: '',
          privacyMode: 'PUBLIC',
          explorationPercent: 0,
          totalXp: 0,
          medalsCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ));
    } else {
      emit(const AuthUnauthenticated());
    }
  }
}
