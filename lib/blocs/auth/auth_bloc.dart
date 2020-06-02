import 'dart:async';

import 'package:assignment/exceptions/current_user_not_found_exception.dart';
import 'package:assignment/models/current_user.dart';
import 'package:assignment/services/authable.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:meta/meta.dart';
import 'package:assignment/exceptions/authentication_exception.dart';

part 'auth_event.dart';
part 'auth_state.dart';

///Handles the authentication states for the widget tree, several
///authentication methods have been done including Facebook and biometrics.
///
///Takes an `Authable` as intial input
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Authable authService;
  final Logger logger = Logger();

  AuthBloc({@required this.authService});

  @override
  AuthState get initialState => AuthInitial();

  @override
  Stream<AuthState> mapEventToState(
    AuthEvent event,
  ) async* {
    if (event is FacebookLoginEvent) {
      yield* facebookLogin();
    } else if (event is BiometricsLoginEvent) {
      yield* biometricLogin();
    } else if (event is LoginPrecheckEvent) {
      yield* precheckLogin();
    } else if (event is SignOutEvent) {
      yield* signout();
    }
  }

  ///Prechecks the users login
  ///Yields `Stream<AuthState>` after initial login process
  Stream<AuthState> precheckLogin() async* {
    try {
      logger.i("Prechecking logging");
      CurrentUser user = await authService.precheckLogin();
      logger.i("Prechecked in, going to home screen");
      yield (SignedInState(user));
    } on CurrentUserNotFoundException catch (e) {
      logger.e("Current user not found");
      yield (SignedOutState());
    }
  }

  ///login with biometrics
  ///Yields `Stream<AuthState>` after login process
  Stream<AuthState> biometricLogin() async* {
    try {
      logger.i("Logging in with biometrics");
      CurrentUser user = await authService.loginWithBiometrics();
      logger.i("Logged in with bio");

      yield (SignedInState(user));
    } on AuthenticationException catch (e) {
      yield SignedInFailedState(e);
      logger.e("Sign in Failed: ${e.errorMsg}");
    } on PlatformException catch (e) {
      yield SignedInFailedState(AuthenticationException(
          errorMsg: e.message,
          displayText: "Could not authenticate, try again."));
      logger.e("Sign in Failed: ${e.message}");
    }
  }

  ///Signs user out
  ///Yields `Stream<AuthState>` after signout process
  Stream<AuthState> signout() async* {
    try {
      logger.i("Signing out");
      await authService.signout();
      yield (SignedOutState());
    } on AuthenticationException catch (e) {
      logger.e("Signing out has failed");
      yield (SignedOutState());
    }
  }

  ///login with facebook
  ///Yields `Stream<AuthState>` after login process
  Stream<AuthState> facebookLogin() async* {
    try {
      yield (SigninLoadingState());
      logger.i("Facebook Logging in...");
      CurrentUser user = await authService.loginWithFacebook();
      logger.i("Facebook Login has completed: ${user.userId}");
      yield (SignedInState(user));
    } on AuthenticationException catch (e) {
      logger.e("An authentication exception has occured: ${e.errorMsg}");
      yield SignedInFailedState(e);
    }
  }
}
