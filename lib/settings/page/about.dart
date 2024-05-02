import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:sit/design/adaptive/dialog.dart';
import 'package:sit/design/widgets/list_tile.dart';
import 'package:sit/r.dart';
import 'package:sit/settings/dev.dart';
import 'package:rettulf/rettulf.dart';
import 'package:sit/entity/version.dart';
import 'package:sit/update/utils.dart';
import 'package:sit/utils/error.dart';
import 'package:sit/utils/guard_launch.dart';
import 'package:web_browser_detect/web_browser_detect.dart';
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
    return Scaffold(
      body: CustomScrollView(
        physics: const RangeMaintainingScrollPhysics(),
        slivers: <Widget>[
          SliverAppBar.large(
            pinned: true,
            snap: false,
            floating: false,
            title: i18n.about.title.text(),
          ),
          SliverList.list(
            children: [
              const VersionTile(),
              if (Dev.on)
                DetailListTile(
                  title: "Installer Store",
                  subtitle: R.currentVersion.installerStore,
                ),
              DetailListTile(
                title: i18n.about.icpLicense,
                subtitle: R.icpLicense,
                trailing: PlatformIconButton(
                  icon: const Icon(Icons.open_in_browser),
                  onPressed: () async {
                    await guardLaunchUrlString(context, "https://beian.miit.gov.cn/");
                  },
                ),
              ),
              ListTile(
                title: i18n.about.termsOfUse.text(),
                trailing: PlatformIconButton(
                  icon: const Icon(Icons.open_in_browser),
                  onPressed: () async {
                    await guardLaunchUrlString(
                        context, "https://github.com/liplum-dev/mimir/blob/master/Terms%20of%20use.md");
                  },
                ),
              ),
              ListTile(
                title: i18n.about.privacyPolicy.text(),
                trailing: PlatformIconButton(
                  icon: const Icon(Icons.open_in_browser),
                  onPressed: () async {
                    await guardLaunchUrlString(
                        context, "https://github.com/liplum-dev/mimir/blob/master/Privacy%20Policy.md");
                  },
                ),
              ),
              AboutListTile(
                // FIXME: icon is buggy
                // icon: SvgPicture.asset("assets/icon.svg").sizedAll(32),
                applicationName: R.appNameL10n,
                applicationVersion: R.currentVersion.version.toString(),
                applicationLegalese: "Copyright©️2023–2024 Liplum Dev. All Rights Reserved.",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class VersionTile extends ConsumerStatefulWidget {
  const VersionTile({super.key});

  @override
  ConsumerState<VersionTile> createState() => _VersionTileState();
}

class _VersionTileState extends ConsumerState<VersionTile> {
  int clickCount = 0;

  @override
  Widget build(BuildContext context) {
    final devOn = ref.watch(Dev.$on);
    final version = R.currentVersion;
    return ListTile(
      leading: switch (version.platform) {
        AppPlatform.iOS || AppPlatform.macOS => const Icon(SimpleIcons.apple),
        AppPlatform.android => const Icon(SimpleIcons.android),
        AppPlatform.linux => const Icon(SimpleIcons.linux),
        AppPlatform.windows => const Icon(SimpleIcons.windows),
        AppPlatform.web => Icon(_getBrowserIcon()),
        AppPlatform.unknown => const Icon(Icons.device_unknown_outlined),
      },
      title: i18n.about.version.text(),
      subtitle: "${version.platform.name} ${version.version.toString()}".text(),
      trailing: kIsWeb ? null : const CheckUpdateButton(),
      onTap: devOn && clickCount <= 10
          ? null
          : () async {
              if (ref.read(Dev.$on)) return;
              clickCount++;
              if (clickCount >= 10) {
                clickCount = 0;
                context.showSnackBar(content: i18n.dev.devModeActivateTip.text());
                await ref.read(Dev.$on.notifier).set(true);
                await HapticFeedback.mediumImpact();
              }
            },
    );
  }
}

IconData _getBrowserIcon() {
  final browser = Browser.detectOrNull();
  if (browser == null) return Icons.web;
  return switch (browser.browserAgent) {
    BrowserAgent.UnKnown => Icons.web,
    BrowserAgent.Chrome => SimpleIcons.googlechrome,
    BrowserAgent.Safari => SimpleIcons.safari,
    BrowserAgent.Firefox => SimpleIcons.firefoxbrowser,
    BrowserAgent.Explorer => SimpleIcons.internetexplorer,
    BrowserAgent.Edge => SimpleIcons.microsoftedge,
    BrowserAgent.EdgeChromium => SimpleIcons.microsoftedge,
  };
}

class CheckUpdateButton extends StatefulWidget {
  const CheckUpdateButton({super.key});

  @override
  State<CheckUpdateButton> createState() => _CheckUpdateButtonState();
}

class _CheckUpdateButtonState extends State<CheckUpdateButton> {
  var isChecking = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isChecking
          ? null
          : () async {
              setState(() {
                isChecking = true;
              });
              try {
                await checkAppUpdate(context: context, manually: true);
              } catch (error, stackTrace) {
                debugPrintError(error, stackTrace);
              }
              setState(() {
                isChecking = false;
              });
            },
      child: i18n.about.checkUpdate.text(),
    );
  }
}
