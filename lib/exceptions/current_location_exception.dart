class CurrentLocationException implements Exception {
  final String errorMsg;
  final String displayText;

  CurrentLocationException({this.errorMsg, this.displayText});
}
