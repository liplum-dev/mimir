import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:sit/session/sso.dart';

/// jwxt.sit.edu.cn
/// Student registration system for undergraduate
class UgRegistrationSession {
  final SsoSession ssoSession;

  const UgRegistrationSession({required this.ssoSession});

  Future<void> refreshCookie() async {
    await ssoSession.request(
      'http://jwxt.sit.edu.cn/sso/jziotlogin',
      options: Options(
        method: "GET",
      ),
    );
  }

  bool _isRedirectedToLoginPage(Response response) {
    return response.realUri.path == '/jwglxt/xtgl/login_slogin.html';
  }

  Future<Response> request(
    String url, {
    Map<String, String>? para,
    data,
    Options? options,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    options ??= Options();
    // TODO: is this really necessary?
    options.contentType = 'application/x-www-form-urlencoded;charset=utf-8';
    Future<Response> fetch() async {
      return await ssoSession.request(
        url,
        para: para,
        data: data,
        options: options,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    }

    final response = await fetch();
    // 如果返回值是登录页面，那就从 SSO 跳转一次以登录.
    if (_isRedirectedToLoginPage(response)) {
      debugPrint('JwxtSession requires login');
      await refreshCookie();
      return await fetch();
    }
    // 如果还是需要登录
    if (_isRedirectedToLoginPage(response)) {
      debugPrint('JwxtSession still requires login');
      await refreshCookie();
      return await fetch();
    }
    return response;
  }

  Future<bool> checkConnectivity({
    String url = 'http://jwxt.sit.edu.cn/',
  }) async {
    try {
      await request(
        url,
        options: Options(
          method: "GET",
          sendTimeout: const Duration(milliseconds: 3000),
          receiveTimeout: const Duration(milliseconds: 3000),
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: false,
          validateStatus: (status) => status! < 400,
        ),
      );
      return true;
    } catch (e) {
      return false;
    }
  }
}
