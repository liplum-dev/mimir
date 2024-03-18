import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sit/design/adaptive/dialog.dart';
import 'package:sit/design/widgets/list_tile.dart';
import 'package:sit/r.dart';
import 'package:sit/settings/dev.dart';
import 'package:rettulf/rettulf.dart';
import 'package:sit/entity/version.dart';
import 'package:sit/update/utils.dart';
import 'package:sit/utils/guard_launch.dart';
import 'package:unicons/unicons.dart';
import 'package:universal_platform/universal_platform.dart';
import '../i18n.dart';

class AboutSettingsPage extends StatefulWidget {
  const AboutSettingsPage({
    super.key,
  });

  @override
  State<AboutSettingsPage> createState() => _AboutSettingsPageState();
}

class _AboutSettingsPageState extends State<AboutSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: CustomScrollView(
        physics: const RangeMaintainingScrollPhysics(),
        slivers: <Widget>[
          PlatformSliverAppBar(
            material: (ctx, platform) {
              return MaterialSliverAppBarData(
                pinned: true,
                snap: false,
                floating: false,
              );
            },
            cupertino: (ctx,p){
              return CupertinoSliverAppBarData(
                previousPageTitle: i18n.title,
              );
            },
            title: i18n.about.title.text(),
          ),
          SliverList.list(
            children: [
              const VersionTile(),
              DetailListTile(
                title: i18n.about.icpLicense,
                subtitle: R.icpLicense,
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_browser),
                  onPressed: () async {
                    await guardLaunchUrlString(context, "https://beian.miit.gov.cn/");
                  },
                ),
              ),
              PlatformListTile(
                title: i18n.about.termsOfUse.text(),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_browser),
                  onPressed: () async {
                    await guardLaunchUrlString(
                        context, "https://github.com/liplum-dev/mimir/blob/master/Terms%20of%20use.md");
                  },
                ),
              ),
              PlatformListTile(
                title: i18n.about.privacyPolicy.text(),
                trailing: IconButton(
                  icon: const Icon(Icons.open_in_browser),
                  onPressed: () async {
                    await guardLaunchUrlString(
                        context, "https://github.com/liplum-dev/mimir/blob/master/Privacy%20Policy.md");
                  },
                ),
              ),
              // AboutListTile(
              //   // FIXME: icon is buggy
              //   // icon: SvgPicture.asset("assets/icon.svg").sizedAll(32),
              //   applicationName: R.appNameL10n,
              //   applicationVersion: R.currentVersion.version.toString(),
              //   applicationLegalese: "Copyright©️2023 Liplum Dev. All Rights Reserved.",
              // ),
            ],
          ),
        ],
      ),
    );
  }
}

class VersionTile extends StatefulWidget {
  const VersionTile({super.key});

  @override
  State<VersionTile> createState() => _VersionTileState();
}

class _VersionTileState extends State<VersionTile> {
  int clickCount = 0;
  final $isDeveloperMode = Dev.listenDevMode();

  @override
  void initState() {
    super.initState();
    $isDeveloperMode.addListener(refresh);
  }

  @override
  void dispose() {
    $isDeveloperMode.removeListener(refresh);
    super.dispose();
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final version = R.currentVersion;
    return PlatformListTile(
      leading: switch (version.platform) {
        AppPlatform.iOS || AppPlatform.macOS => const Icon(UniconsLine.apple),
        AppPlatform.android => const Icon(Icons.android),
        AppPlatform.linux => const Icon(UniconsLine.linux),
        AppPlatform.windows => const Icon(UniconsLine.windows),
        AppPlatform.web => const Icon(UniconsLine.browser),
        AppPlatform.unknown => const Icon(Icons.device_unknown_outlined),
      },
      title: i18n.about.version.text(),
      subtitle: "${version.platform.name} ${version.version.toString()}".text(),
      trailing: UniversalPlatform.isIOS || UniversalPlatform.isMacOS || kIsWeb
          ? null
          : OutlinedButton(
              onPressed: () async {
                await checkAppUpdate(
                  context: context,
                  manually: true,
                );
              },
              child: i18n.about.checkUpdate.text(),
            ),
      onTap: Dev.on && clickCount <= 10
          ? null
          : () async {
              if (Dev.on) return;
              clickCount++;
              if (clickCount >= 10) {
                clickCount = 0;
                Dev.on = true;
                context.showSnackBar(content: i18n.dev.devModeActivateTip.text());
                await HapticFeedback.mediumImpact();
              }
            },
    );
  }
}
