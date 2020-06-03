import 'package:assignment/blocs/auth/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatefulWidget {
  final String errorMsg;
  final bool isLoading;

  const LoginScreen({Key key, this.errorMsg, this.isLoading = false})
      : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        child: Center(
            child: Container(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              widget.errorMsg != null
                  ? Text(
                      widget.errorMsg,
                      style: Theme.of(context).textTheme.bodyText1,
                    )
                  : Container(),
              SizedBox(
                height: 10.0,
              ),
              Text(
                "Hi, login.",
                style: Theme.of(context).textTheme.headline1,
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                "Login with the following options.",
                style: TextStyle(fontSize: 15.0, color: Colors.grey),
              ),
              SizedBox(
                height: 20.0,
              ),
              widget.isLoading
                  ? Align(
                      alignment: Alignment.center,
                      child: LinearProgressIndicator())
                  : Container(),
              Divider(
                color: Colors.grey,
              ),
              SizedBox(
                height: 20.0,
              ),
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: <Widget>[
                    RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                      color: Colors.pink,
                      child: Container(
                          padding: const EdgeInsets.all(17.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              FaIcon(
                                FontAwesomeIcons.facebook,
                                color: Colors.white,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text("Login with Facebook",
                                  style: TextStyle(color: Colors.white)),
                            ],
                          )),
                      onPressed: () => BlocProvider.of<AuthBloc>(context)
                          .add(FacebookLoginEvent()),
                    ),
                    SizedBox(height: 30),
                    RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(20.0))),
                        color: Colors.pink,
                        child: Container(
                            padding: const EdgeInsets.all(17.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                FaIcon(
                                  FontAwesomeIcons.fingerprint,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                Text("Login with Fingerprint",
                                    style: TextStyle(color: Colors.white))
                              ],
                            )),
                        onPressed: () {
                          BlocProvider.of<AuthBloc>(context)
                              .add(BiometricsLoginEvent());
                        }),
                  ],
                ),
              )
            ],
          ),
        )),
      ),
    );
  }
}
