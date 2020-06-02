import 'package:assignment/models/current_user.dart';

abstract class Authable {
  Future<CurrentUser> loginWithFacebook();
  Future<CurrentUser> loginWithBiometrics();
  Future<CurrentUser> precheckLogin();
  Future<void> signout();
}
