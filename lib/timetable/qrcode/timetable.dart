import 'package:flutter/widgets.dart';
import 'package:sit/qrcode/protocol.dart';
import 'package:sit/qrcode/utils.dart';
import 'package:sit/r.dart';
import 'package:sit/timetable/entity/timetable.dart';

import '../page/mine.dart';

class TimetableDeepLink implements DeepLinkHandlerProtocol {
  static const host = "timetable";
  static const path = "/timetable";

  const TimetableDeepLink();

  Uri encode(SitTimetable timetable) =>
      Uri(scheme: R.scheme, host: host, path: path, query: encodeBytesForUrl(SitTimetable.encodeByteList(timetable)));

  SitTimetable decode(Uri qrCodeData) => (SitTimetable.decodeByteList(decodeBytesFromUrl(qrCodeData.query)));

  @override
  bool match(Uri encoded) {
    // for backwards support
    if (encoded.host.isEmpty && encoded.path == "timetable") return true;
    return encoded.host == host && encoded.path == path;
  }

  @override
  Future<void> onHandle({
    required BuildContext context,
    required Uri qrCodeData,
  }) async {
    final timetable = decode(qrCodeData);
    await onTimetableFromFile(
      context: context,
      timetable: timetable,
    );
  }
}
