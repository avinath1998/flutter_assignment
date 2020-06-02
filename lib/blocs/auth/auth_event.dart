part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent {}

class FacebookLoginEvent extends AuthEvent {}

class BiometricsLoginEvent extends AuthEvent {}

class LoginPrecheckEvent extends AuthEvent {}

class SignOutEvent extends AuthEvent {}
