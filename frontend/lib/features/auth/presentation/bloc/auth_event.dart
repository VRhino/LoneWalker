import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthRegisterEvent extends AuthEvent {
  final String username;
  final String email;
  final String password;
  final String passwordConfirm;

  const AuthRegisterEvent({
    required this.username,
    required this.email,
    required this.password,
    required this.passwordConfirm,
  });

  @override
  List<Object?> get props => [username, email, password, passwordConfirm];
}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class AuthLogoutEvent extends AuthEvent {
  const AuthLogoutEvent();
}

class AuthCheckStatusEvent extends AuthEvent {
  const AuthCheckStatusEvent();
}

class AuthRefreshTokenEvent extends AuthEvent {
  const AuthRefreshTokenEvent();
}
