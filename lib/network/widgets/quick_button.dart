import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:sit/design/adaptive/dialog.dart';
import 'package:sit/utils/guard_launch.dart';
import 'package:rettulf/rettulf.dart';

import '../i18n.dart';

const easyConnectDownloadUrl = "https://vpn1.sit.edu.cn/com/installClient.html";

class QuickButtons extends StatefulWidget {
  const QuickButtons({super.key});

  @override
  State<StatefulWidget> createState() => _QuickButtonsState();
}

class _QuickButtonsState extends State<QuickButtons> {
  @override
  Widget build(BuildContext context) {
    return [
      FilledButton(
        child: i18n.easyconnect.launchBtn.text(),
        onPressed: () async {
          final launched = await guardLaunchUrlString(context, 'sangfor://easyconnect');
          if (!launched) {
            if (!context.mounted) return;
            final confirm = await context.showRequest(
              title: i18n.easyconnect.launchFailed,
              desc: i18n.easyconnect.launchFailedDesc,
              yes: i18n.download,
              no: i18n.cancel,
              destructive: true,
            );
            if (confirm == true) {
              if (!context.mounted) return;
              await guardLaunchUrlString(context, easyConnectDownloadUrl);
            }
          }
        },
      ),
      OutlinedButton(
        onPressed: () {
          AppSettings.openAppSettings(type: AppSettingsType.wifi);
        },
        child: i18n.openWlanSettingsBtn.text(),
      ),
    ].row(
      maa: MainAxisAlignment.spaceEvenly,
    );
  }
}
