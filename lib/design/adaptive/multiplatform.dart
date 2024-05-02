import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:sit/r.dart';
import 'package:universal_platform/universal_platform.dart';

bool get isCupertino => R.debugCupertino || UniversalPlatform.isIOS || UniversalPlatform.isMacOS;

bool get supportContextMenu =>
    kIsWeb || UniversalPlatform.isIOS || UniversalPlatform.isMacOS || UniversalPlatform.isDesktop || R.debugCupertino;

extension ShareX on BuildContext {
  Rect? getSharePositionOrigin() {
    final box = findRenderObject() as RenderBox?;
    final sharePositionOrigin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
    if (UniversalPlatform.isIOS || UniversalPlatform.isMacOS) {
      assert(sharePositionOrigin != null, "sharePositionOrigin should be nonnull on iPad and macOS");
    }
    return sharePositionOrigin;
  }
}

extension BuildContextPlatformIconsX on BuildContext {
  PlatformIcons get icons => PlatformIcons(this);
}

extension PlatformIconsX on PlatformIcons {
  IconData get lock => isMaterial(context) ? Icons.lock : CupertinoIcons.lock;

  IconData get copy => isMaterial(context) ? Icons.copy : CupertinoIcons.plus_square_on_square;

  IconData get calendar => isMaterial(context) ? Icons.calendar_month : CupertinoIcons.calendar;

  IconData get qrcode => isMaterial(context) ? Icons.qr_code : CupertinoIcons.qrcode;

  IconData get preview => isMaterial(context) ? Icons.preview : CupertinoIcons.eye;

  IconData get warningFilled => isMaterial(context) ? Icons.error : CupertinoIcons.exclamationmark_circle_fill;

  IconData get warning => isMaterial(context) ? Icons.error_outline : CupertinoIcons.exclamationmark_circle;

  IconData get troubleshoot => isMaterial(context) ? Icons.troubleshoot : CupertinoIcons.wrench;
}
