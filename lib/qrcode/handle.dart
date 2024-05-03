import 'package:flutter/widgets.dart';
import 'package:sit/qrcode/protocol.dart';
import 'package:sit/r.dart';

enum QrCodeHandleResult {
  success,
  unhandled,
  unrecognized,
  invalidFormat;
}

Future<QrCodeHandleResult> onHandleQrCodeUriStringData({
  required BuildContext context,
  required String data,
}) async {
  final qrCodeData = Uri.tryParse(data);
  if (qrCodeData == null) return QrCodeHandleResult.invalidFormat;
  return onHandleQrCodeUriData(context: context, qrCodeData: qrCodeData);
}

Future<QrCodeHandleResult> onHandleQrCodeUriData({
  required BuildContext context,
  required Uri qrCodeData,
}) async {
  // backwards supports.
  if (qrCodeData.scheme != R.scheme && qrCodeData.scheme != "sitlife" && qrCodeData.scheme != "life.mysit")
    return QrCodeHandleResult.unrecognized;
  for (final handler in DeepLinkHandlerProtocol.all) {
    if (handler.match(qrCodeData)) {
      await handler.onHandle(context: context, qrCodeData: qrCodeData);
      return QrCodeHandleResult.success;
    }
  }
  return QrCodeHandleResult.unhandled;
}
