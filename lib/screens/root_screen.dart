import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:assignment/blocs/auth/auth_bloc.dart';
import 'package:assignment/services/auth_service.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:local_auth/local_auth.dart';
import 'error_screen.dart';
import 'home_screen.dart';
import 'loading_screen.dart';
import 'login_screen.dart';

class RootScreen extends StatefulWidget {
  @override
  _RootScreenState createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  AuthBloc _authBloc;

  ///Initializes the widget, `AuthBloc`
  ///The login is prechecked in `AuthBloc` to check if the user is already logged in after the widgets have been built
  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(
        authService: AuthService(
            facebookLogin: FacebookLogin(), localAuth: LocalAuthentication()));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _authBloc.add(LoginPrecheckEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => _authBloc,
      child: BlocBuilder<AuthBloc, AuthState>(
          bloc: _authBloc,
          builder: (BuildContext context, AuthState state) {
            if (state is AuthInitial) {
              return LoadingScreen();
            } else if (state is SignedInState) {
              return HomeScreen();
            } else if (state is SignedOutState) {
              return LoginScreen();
            } else if (state is SignedInFailedState) {
              return LoginScreen(
                errorMsg: state.authException.displayText,
              );
            } else if (state is SigninLoadingState) {
              return LoginScreen(isLoading: true);
            } else {
              return ErrorScreen(
                  errorMsg: "Whoops, we couldn't log you in. Try again later.");
            }
          }),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _authBloc.close();
  }
}
