import 'package:flutter/widgets.dart';
import 'package:sit/qrcode/protocol.dart';
import 'package:sit/qrcode/utils.dart';
import 'package:sit/r.dart';
import 'package:sit/timetable/entity/patch.dart';

import '../page/patch/qrcode.dart';

class TimetablePatchDeepLink implements DeepLinkHandlerProtocol {
  static const path = "timetable-patch";

  const TimetablePatchDeepLink();

  Uri encode(TimetablePatchEntry entry) =>
      Uri(scheme: R.scheme, path: path, query: encodeBytesForUrl(TimetablePatchEntry.encodeByteList(entry)));

  TimetablePatchEntry decode(Uri qrCodeData) =>
      (TimetablePatchEntry.decodeByteList(decodeBytesFromUrl(qrCodeData.query)));

  @override
  bool match(Uri encoded) {
    return encoded.path == path;
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
