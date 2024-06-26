import 'package:flutter/widgets.dart';
import 'package:sit/qrcode/deep_link.dart';
import 'package:sit/qrcode/utils.dart';
import 'package:sit/r.dart';

import '../p13n/entity/palette.dart';
import '../p13n/page/palette.dart';

class TimetablePaletteDeepLink implements DeepLinkHandlerProtocol {
  static const host = "timetable";
  static const path = "/palette";

  const TimetablePaletteDeepLink();

  Uri encode(TimetablePalette palette) => Uri(
      scheme: R.scheme,
      host: host,
      path: path,
      query: encodeBytesForUrl(
        palette.encodeByteList(),
        compress: false,
      ));

  TimetablePalette decode(Uri qrCodeData) => TimetablePalette.decodeFromByteList(decodeBytesFromUrl(
        qrCodeData.query,
        compress: false,
      ));

  @override
  bool match(Uri encoded) {
    // for backwards support
    if (encoded.host.isEmpty && encoded.path == "timetable-palette") return true;
    return encoded.host == host && encoded.path == path;
  }

  @override
  Future<void> onHandle({
    required BuildContext context,
    required Uri qrCodeData,
  }) async {
    final palette = decode(qrCodeData);
    await onTimetablePaletteFromQrCode(
      context: context,
      palette: palette,
    );
  }
}
