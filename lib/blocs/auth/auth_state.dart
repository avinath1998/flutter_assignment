part of 'auth_bloc.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class SignedInState extends AuthState {
  final CurrentUser user;
  SignedInState(this.user);
}

class SigninLoadingState extends AuthState {}

class SignedOutState extends AuthState {
  SignedOutState();
}

class SignedInFailedState extends AuthState {
  final AuthenticationException authException;
  SignedInFailedState(this.authException);
}
