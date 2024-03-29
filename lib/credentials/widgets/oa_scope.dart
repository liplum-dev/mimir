import 'package:flutter/widgets.dart';
import 'package:sit/credentials/entity/credential.dart';
import 'package:sit/credentials/entity/user_type.dart';

import '../entity/login_status.dart';
import '../init.dart';

extension OaAuthX on BuildContext {
  OaAuth get auth => OaAuth.of(this);
}

class OaAuthManager extends StatefulWidget {
  final Widget child;

  const OaAuthManager({super.key, required this.child});

  @override
  State<OaAuthManager> createState() => _OaAuthManagerState();
}

class _OaAuthManagerState extends State<OaAuthManager> {
  final onOaChanged = CredentialsInit.storage.listenOaChange();

  @override
  void initState() {
    super.initState();
    onOaChanged.addListener(anyChange);
  }

  @override
  void dispose() {
    onOaChanged.removeListener(anyChange);
    super.dispose();
  }

  void anyChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final storage = CredentialsInit.storage;
    return OaAuth(
      credentials: storage.oaCredentials,
      lastAuthTime: storage.oaLastAuthTime,
      loginStatus: storage.oaLoginStatus ?? LoginStatus.never,
      userType: storage.oaUserType ?? OaUserType.other,
      child: widget.child,
    );
  }
}

class OaAuth extends InheritedWidget {
  final Credentials? credentials;
  final DateTime? lastAuthTime;
  final LoginStatus loginStatus;
  final OaUserType userType;

  const OaAuth({
    super.key,
    this.credentials,
    this.lastAuthTime,
    required this.loginStatus,
    required this.userType,
    required super.child,
  });

  static OaAuth of(BuildContext context) {
    final OaAuth? result = context.dependOnInheritedWidgetOfExactType<OaAuth>();
    assert(result != null, 'No AuthScope found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(OaAuth oldWidget) {
    return credentials != oldWidget.credentials ||
        lastAuthTime != oldWidget.lastAuthTime ||
        loginStatus != oldWidget.loginStatus ||
        userType != oldWidget.userType;
  }
}
