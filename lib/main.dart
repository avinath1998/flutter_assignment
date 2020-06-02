import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:assignment/screens/root_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'blocs/fcm_handler/fcm_handler_bloc.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FcmHandlerBloc fcmHandlerBloc;

  ///initializes the function
  ///initializes the FCM Messenger Handler
  @override
  void initState() {
    super.initState();
    fcmHandlerBloc = FcmHandlerBloc(FirebaseMessaging());
    fcmHandlerBloc.add(FcmInit());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Assignment',
      theme: ThemeData(
        cardColor: Colors.white,
        primaryColor: Colors.pink,
        secondaryHeaderColor: Colors.white,
        buttonColor: Colors.pink,
        textTheme: TextTheme(
            headline6: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            headline1: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 40.0)),
        accentColor: Colors.pink,
        backgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BlocListener(
          listener: (context, state) {
            print(state);
            if (state is FcmMessageLoadedState) {
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.all(Radius.circular(20.0))),
                      title: Text(state.title),
                      content: Text(state.message),
                      actions: <Widget>[
                        FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Dismiss"),
                        )
                      ],
                    );
                  });
            }
          },
          bloc: fcmHandlerBloc,
          child: RootScreen()),
    );
  }
}
