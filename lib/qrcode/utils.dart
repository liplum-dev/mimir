import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hashlib_codecs/hashlib_codecs.dart';
import 'package:sit/design/adaptive/dialog.dart';
import 'package:sit/settings/dev.dart';
import 'package:sit/utils/guard_launch.dart';

import 'handle.dart';
import 'i18n.dart';

final _codec = ZLibCodec(level: 6);
final _decoder = _codec.decoder;
final _encoder = _codec.encoder;

String encodeBytesForUrl(Uint8List original, {bool compress = true}) {
  final bytes = compress ? _encoder.convert(original) : original;
  final compressedStr = toBase64(bytes, url: true, padding: false);
  if (kDebugMode) {
    if (compress) {
      debugPrint("${original.length} => ${bytes.length}");
      assert(bytes.length <= original.length, "compressed is ${bytes.length} > original is ${original.length}");
      assert(compressedStr.length <= base64Encode(original).length);
    } else {
      debugPrint("${original.length}");
    }
  }
  return compressedStr;
}

Uint8List decodeBytesFromUrl(String url, {bool compress = true}) {
  final bytes = fromBase64(url, padding: false);
  final uncompressed = compress ? _decoder.convert(bytes) : bytes;
  return uncompressed as Uint8List;
}

Future<void> recognizeQrCode(BuildContext context) async {
  final res = await context.push("/tools/scanner");
  if (!context.mounted) return;
  if (Dev.on) {
    await context.showTip(desc: res.toString(), primary: i18n.ok);
  }
  if (!context.mounted) return;
  if (res == null) return;
  await Future.delayed(const Duration(milliseconds: 10));
  if (res is String) {
    final result = await onHandleQrCodeUriStringData(context: context, data: res);
    if (result == QrCodeHandleResult.success) {
      return;
    } else if (result == QrCodeHandleResult.unhandled || result == QrCodeHandleResult.unrecognized) {
      if (!context.mounted) return;
      final maybeUri = Uri.tryParse(res);
      if (maybeUri != null) {
        await guardLaunchUrlString(context, res);
        return;
      }
      await context.showTip(desc: res.toString(), primary: i18n.ok);
    } else if (result == QrCodeHandleResult.invalidFormat) {
      if (!context.mounted) return;
      await context.showTip(desc: i18n.unrecognizedQrCodeTip, primary: i18n.ok);
    }
  } else {
    await context.showTip(desc: res.toString(), primary: i18n.ok);
  }
}
