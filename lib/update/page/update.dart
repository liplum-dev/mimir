import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:rettulf/rettulf.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:sit/r.dart';
import 'package:sit/settings/settings.dart';
import 'package:sit/update/entity/artifact.dart';
import 'package:sit/widgets/markdown.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../i18n.dart';

class ArtifactUpdatePage extends StatefulWidget {
  final ArtifactVersionInfo info;

  const ArtifactUpdatePage({
    super.key,
    required this.info,
  });

  @override
  State<ArtifactUpdatePage> createState() => _ArtifactUpdatePageState();
}

class _ArtifactUpdatePageState extends State<ArtifactUpdatePage> {
  bool ignore = false;

  @override
  Widget build(BuildContext context) {
    final info = widget.info;
    return Scaffold(
      body: [
        [
          const Spacer(),
          i18n.newVersionAvailable
              .text(
                textAlign: TextAlign.center,
                style: context.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                ),
              )
              .expanded(flex: 5),
          const Spacer(),
        ].row().padV(32),
        [
          ListTile(
            leading: const Icon(Icons.featured_play_list),
            title: info.version.toString().text(),
          ),
          MarkdownWidget(data: info.releaseNote).expanded(),
        ].column().padH(8).expanded(),
        buildSkipTile().padH(32),
        [
          buildSkipButton().padOnly(r: 8).expanded(),
          buildDownloadButton().padOnly(l: 8).expanded(),
        ].row(maa: MainAxisAlignment.spaceEvenly).padAll(8),
      ].column().safeArea(),
    );
  }

  Widget buildSkipButton() {
    final info = widget.info;
    return OutlinedButton(
      onPressed: () {
        if (ignore) {
          Settings.skippedVersion = info.version.toString();
          Settings.lastSkipUpdateTime = DateTime.now();
        }
        context.pop();
      },
      child: i18n.notNow.text(),
    );
  }

  Widget buildDownloadButton() {
    final info = widget.info;
    if (R.debugCupertino || UniversalPlatform.isIOS || UniversalPlatform.isMacOS) {
      return FilledButton.icon(
        icon: const Icon(SimpleIcons.appstore),
        onPressed: ignore
            ? null
            : () async {
                context.pop();
                await launchUrlString(R.iosAppStoreUrl, mode: LaunchMode.externalApplication);
              },
        label: i18n.openAppStore.text(),
      );
    }
    return FilledButton.icon(
      onPressed: ignore
          ? null
          : () async {
              final download = info.downloadOf(R.currentVersion.platform);
              if (download == null) return;
              final url = download.defaultUrl;
              if (url == null) return;
              context.pop();
              await launchUrlString(url, mode: LaunchMode.externalApplication);
            },
      icon: Icon(UniversalPlatform.isDesktop ? Icons.install_desktop : Icons.install_mobile),
      label: i18n.download.text(),
    );
  }

  Widget buildSkipTile() {
    return CheckboxListTile(
      value: ignore,
      onChanged: (value) {
        setState(() {
          ignore = value == true;
        });
      },
      title: i18n.skipThisVersionFor7Days.text(),
    );
  }
}
