class AuthenticationException implements Exception {
  final String errorMsg;
  final String displayText;

  const AuthenticationException({this.errorMsg, this.displayText});
}
