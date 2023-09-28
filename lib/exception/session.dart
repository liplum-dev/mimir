enum OaCredentialsErrorType {
  accountPassword,
  captcha,
  frozen,
}

class YwbCredentialsException implements Exception {
  final String message;

  const YwbCredentialsException({
    required this.message,
  });

  @override
  String toString() {
    return message;
  }
}

/// 认证失败
class OaCredentialsException implements Exception {
  final OaCredentialsErrorType type;
  final String message;

  const OaCredentialsException({
    required this.type,
    required this.message,
  });

  @override
  String toString() {
    return "$type $message";
  }
}

class LoginCaptchaCancelledException implements Exception {
  const LoginCaptchaCancelledException();
}

/// 操作之前需要先登录
class LoginRequiredException implements Exception {
  final String url;

  const LoginRequiredException({required this.url});

  @override
  String toString() {
    return url;
  }
}

/// 未知的验证错误
class UnknownAuthException implements Exception {
  const UnknownAuthException();
}
