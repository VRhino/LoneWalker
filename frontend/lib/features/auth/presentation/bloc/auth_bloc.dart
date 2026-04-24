import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/models/user_model.dart';
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

      await remoteDataSource.apiClient.saveTokens(
        result.accessToken,
        result.refreshToken,
      );
      await remoteDataSource.apiClient.saveUserData(
        result.user.toJson(),
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

      await remoteDataSource.apiClient.saveTokens(
        result.accessToken,
        result.refreshToken,
      );
      await remoteDataSource.apiClient.saveUserData(
        result.user.toJson(),
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
    if (!remoteDataSource.apiClient.isAuthenticated()) {
      emit(const AuthUnauthenticated());
      return;
    }

    final userData = remoteDataSource.apiClient.getUserData();
    if (userData == null) {
      emit(const AuthUnauthenticated());
      return;
    }

    // Restore session immediately from local storage (no network needed)
    emit(AuthAuthenticated(user: UserModel.fromJson(userData)));

    // Validate token with server; only log out if both tokens are truly expired.
    // Network errors keep the session alive (offline-first).
    try {
      final valid = await remoteDataSource.verifyToken();
      if (!valid) {
        await remoteDataSource.apiClient.logout();
        emit(const AuthUnauthenticated());
      }
    } catch (_) {
      // Network error — keep session alive
    }
  }
}
