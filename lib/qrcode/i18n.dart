import 'package:easy_localization/easy_localization.dart';

const i18n = _I18n();

class _I18n {
  const _I18n();

  static const ns = "scanner";

  String get barcodeNotRecognized => "$ns.barcodeNotRecognized".tr();
}
