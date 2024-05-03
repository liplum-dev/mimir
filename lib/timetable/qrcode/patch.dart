import 'package:flutter/widgets.dart';
import 'package:sit/qrcode/protocol.dart';
import 'package:sit/qrcode/utils.dart';
import 'package:sit/r.dart';
import 'package:sit/timetable/entity/patch.dart';

import '../page/patch/qrcode.dart';

class TimetablePatchDeepLink implements DeepLinkHandlerProtocol {
  static const host = "timetable";
  static const path = "/patch";

  const TimetablePatchDeepLink();

  Uri encode(TimetablePatchEntry entry) => Uri(
      scheme: R.scheme, host: host, path: path, query: encodeBytesForUrl(TimetablePatchEntry.encodeByteList(entry)));

  TimetablePatchEntry decode(Uri qrCodeData) =>
      (TimetablePatchEntry.decodeByteList(decodeBytesFromUrl(qrCodeData.query)));

  @override
  bool match(Uri encoded) {
    // for backwards support
    if (encoded.host.isEmpty && encoded.path == "timetable-patch") return true;
    return encoded.host == host && encoded.path == path;
  }

  @override
  Future<void> onHandle({
    required BuildContext context,
    required Uri qrCodeData,
  }) async {
    final patch = decode(qrCodeData);
    await onTimetablePatchFromQrCode(
      context: context,
      patch: patch,
    );
  }
}
