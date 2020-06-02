class CurrentUserNotFoundException implements Exception {
  final String errorMsg;
  final String displayText;

  CurrentUserNotFoundException({this.errorMsg, this.displayText});
}
