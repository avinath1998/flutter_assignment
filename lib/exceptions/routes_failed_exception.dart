class RoutesFailedException implements Exception {
  final String errorMsg;
  final String displayText;

  RoutesFailedException({this.errorMsg, this.displayText});
}
