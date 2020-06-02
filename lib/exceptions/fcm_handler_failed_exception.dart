class FcmHandlerFailedException implements Exception {
  final String errorMsg;
  final String displayText;

  FcmHandlerFailedException(this.errorMsg, this.displayText);
}
