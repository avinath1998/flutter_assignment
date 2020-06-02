import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String errorMsg;

  const ErrorScreen({Key key, this.errorMsg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Text(
      this.errorMsg ?? "Something has gone wrong, try again.",
    ));
  }
}
