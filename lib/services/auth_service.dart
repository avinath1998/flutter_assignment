import 'package:assignment/exceptions/current_user_not_found_exception.dart';
import 'package:assignment/models/current_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:assignment/exceptions/authentication_exception.dart';

import 'package:flutter_local_auth_invisible/flutter_local_auth_invisible.dart';
import 'package:logger/logger.dart';

import 'authable.dart';

class AuthService implements Authable {
  final FacebookLogin facebookLogin;
  final LocalAuthentication localAuth;
  final Logger logger = Logger();
  CurrentSignInMethod _currentSigninMethod;
  AuthService({this.facebookLogin, this.localAuth});

  ///attempts to login using the devices biometrics
  ///
  ///Throws an [AuthenticationException] if user was not authenticated.
  ///Throws an [AuthenticationException] if the device does not have any available biometrics
  @override
  Future<CurrentUser> loginWithBiometrics() async {
    assert(localAuth != null);
    logger.i("biometricating");
    if (await localAuth.canCheckBiometrics) {
      bool didAuthenticate = await localAuth.authenticateWithBiometrics(
          localizedReason: 'Login to start using this app!',
          useErrorDialogs: true);
      if (didAuthenticate) {
        _currentSigninMethod = CurrentSignInMethod.biometrics;
        //there is no username or user id when user uses biometric login details
        return CurrentUser("BiometricUserLogin", "BiometricUserLoggedIn");
      } else {
        throw AuthenticationException(
            errorMsg: "could not authenticate user",
            displayText: "Whoops, could not authenticate you.");
      }
    } else {
      throw AuthenticationException(
          errorMsg: "cannot perform biometrics evaluation on device",
          displayText:
              "Whoops, your device is not compatible for biometric login");
    }
  }

  ///logs user in with facebook login
  ///
  ///Throws an [AuthenticationException] if the Facebook Auth Provider does not return any credentials.
  ///Throws an [AuthenticationException] if the Firebase Auth does not return any result.
  @override
  Future<CurrentUser> loginWithFacebook() async {
    final result = await facebookLogin.logIn(['email']);
    if (result.status == FacebookLoginStatus.error) {
      throw AuthenticationException(
          errorMsg: result.status.toString(),
          displayText:
              "Whoops, looks like we had trouble connecting to Facebook.");
    } else if (result.status == FacebookLoginStatus.cancelledByUser) {
      throw AuthenticationException(
          errorMsg: result.status.toString(),
          displayText:
              "Whoops, looks like you canelled logging in, try again!");
    }
    final AuthCredential facebookAuthCred = FacebookAuthProvider.getCredential(
        accessToken: result.accessToken.token);
    if (facebookAuthCred == null)
      throw AuthenticationException(
          errorMsg: "facebook auth cred is null",
          displayText:
              "Whoops, looks like we had trouble connecting to Facebook.");

    //final auth result is then saved to firebase auth.
    final AuthResult authResult =
        await FirebaseAuth.instance.signInWithCredential(facebookAuthCred);
    if (authResult == null)
      throw AuthenticationException(
          errorMsg: "Firebase Auth Result is null",
          displayText:
              "Whoops, something went wrong with logging you in, try again.");
    CurrentUser user =
        CurrentUser(authResult.user.providerId, authResult.user.displayName);

    _currentSigninMethod = CurrentSignInMethod.facebook;
    return user;
  }

  ///Signs user out.
  @override
  Future<void> signout() {
    switch (_currentSigninMethod) {
      case CurrentSignInMethod.biometrics:
        //nothing needs to be done for the user to sign out of biometrics, simple go to the login screen.
        logger.i("Signing out of biometrics");
        return null;
        break;
      case CurrentSignInMethod.facebook:
        logger.i("Signing out with firebase auth");
        return FirebaseAuth.instance.signOut();
        break;
      default:
        return null;
    }
  }

  ///prechecks if the user is already logged in
  ///
  ///Throws an [CurrentUserNotFoundException] if the current user is not found.
  @override
  Future<CurrentUser> precheckLogin() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    if (user != null) {
      _currentSigninMethod = CurrentSignInMethod.biometrics;
      return CurrentUser(user.providerId, user.displayName);
    } else {
      throw CurrentUserNotFoundException(
          displayText: "User not signed in",
          errorMsg: "current user not found, user is not signed in");
    }
  }
}

enum CurrentSignInMethod { biometrics, facebook }
