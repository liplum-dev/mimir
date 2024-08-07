import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:simple_icons/simple_icons.dart';
import 'package:sit/app.dart';
import 'package:sit/credentials/entity/credential.dart';
import 'package:sit/credentials/entity/login_status.dart';
import 'package:sit/credentials/entity/user_type.dart';
import 'package:sit/credentials/init.dart';
import 'package:sit/credentials/utils.dart';
import 'package:sit/design/adaptive/dialog.dart';
import 'package:sit/design/adaptive/editor.dart';
import 'package:sit/design/adaptive/foundation.dart';
import 'package:sit/design/adaptive/multiplatform.dart';
import 'package:sit/design/widgets/expansion_tile.dart';
import 'package:sit/game/widget/party_popper.dart';
import 'package:sit/init.dart';
import 'package:sit/l10n/extension.dart';
import 'package:sit/login/aggregated.dart';
import 'package:sit/login/utils.dart';
import 'package:sit/qrcode/handle.dart';
import 'package:sit/settings/dev.dart';
import 'package:sit/design/widgets/navigation.dart';
import 'package:rettulf/rettulf.dart';
import 'package:sit/settings/settings.dart';
import 'package:sit/update/init.dart';
import 'package:sit/utils/guard_launch.dart';
import 'package:sit/widgets/inapp_webview/page.dart';
import 'package:url_launcher/url_launcher.dart';
import '../i18n.dart';

class DeveloperOptionsPage extends ConsumerStatefulWidget {
  const DeveloperOptionsPage({
    super.key,
  });

  @override
  ConsumerState<DeveloperOptionsPage> createState() => _DeveloperOptionsPageState();
}

class _DeveloperOptionsPageState extends ConsumerState<DeveloperOptionsPage> {
  @override
  Widget build(BuildContext context) {
    final credentials = ref.watch(CredentialsInit.storage.$oaCredentials);
    final demoMode = ref.watch(Dev.$demoMode);
    return Scaffold(
      body: CustomScrollView(
        physics: const RangeMaintainingScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            pinned: true,
            snap: false,
            floating: false,
            title: i18n.dev.title.text(),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              buildDevModeToggle(),
              buildDemoModeToggle(),
              PageNavigationTile(
                title: i18n.dev.localStorage.text(),
                subtitle: i18n.dev.localStorageDesc.text(),
                leading: const Icon(Icons.storage),
                path: "/settings/developer/local-storage",
              ),
              buildReload(),
              const DebugExpenseUserOverrideTile(),
              if (credentials != null)
                SwitchOaUserTile(
                  currentCredentials: credentials,
                ),
              if (demoMode && credentials != R.demoModeOaCredentials)
                ListTile(
                  leading: const Icon(Icons.adb),
                  title: "Login demo account".text(),
                  trailing: const Icon(Icons.login),
                  onTap: () async {
                    Settings.lastSignature ??= "Liplum";
                    CredentialsInit.storage.oaCredentials = R.demoModeOaCredentials;
                    CredentialsInit.storage.oaLoginStatus = LoginStatus.validated;
                    CredentialsInit.storage.oaLastAuthTime = DateTime.now();
                    CredentialsInit.storage.oaUserType = OaUserType.undergraduate;
                    await Init.initModules();
                    if (!context.mounted) return;
                    context.go("/");
                  },
                ),
              const ReceivedDeepLinksTile(),
              const DebugGoRouteTile(),
              const DebugWebViewTile(),
              const DebugDeepLinkTile(),
              const GoInAppWebviewTile(),
              if (!kIsWeb)
                DebugFetchVersionTile(
                  title: "Official".text(),
                  fetch: () async {
                    final info = await UpdateInit.service.getLatestVersionFromOfficial();
                    return info.version.toString();
                  },
                ),
              if (!kIsWeb)
                DebugFetchVersionTile(
                  leading: const Icon(SimpleIcons.apple),
                  title: "App Store CN".text(),
                  fetch: () async {
                    final info = await UpdateInit.service.getLatestVersionFromAppStore();
                    return "${info!}";
                  },
                ),
              if (!kIsWeb)
                DebugFetchVersionTile(
                  leading: const Icon(SimpleIcons.apple),
                  title: "App Store".text(),
                  fetch: () async {
                    final info = await UpdateInit.service.getLatestVersionFromAppStore(iosAppStoreRegion: null);
                    return "${info!}";
                  },
                ),
              // const DebugDeviceInfoTile(),
              buildPartyPopper(),
            ]),
          ),
        ],
      ),
    );
  }

  Widget buildPartyPopper() {
    return ListTile(
      leading: "🎉".text(style: context.textTheme.headlineLarge),
      title: "Party popper 🎉".text(),
      subtitle: "Tap me!".text(),
      onTap: () {
        context.showSheet((ctx) => Scaffold(
              body: [
                const VictoryPartyPopper(
                  pop: true,
                ),
              ].stack(),
            ));
      },
    );
  }

  Widget buildDevModeToggle() {
    final on = ref.watch(Dev.$on);
    return ListTile(
      title: i18n.dev.devMode.text(),
      leading: const Icon(Icons.developer_mode_outlined),
      trailing: Switch.adaptive(
        value: on,
        onChanged: (newV) {
          ref.read(Dev.$on.notifier).set(newV);
        },
      ),
    );
  }

  Widget buildDemoModeToggle() {
    final demoMode = ref.watch(Dev.$demoMode);
    return ListTile(
      leading: const Icon(Icons.adb),
      title: i18n.dev.demoMode.text(),
      trailing: Switch.adaptive(
        value: demoMode,
        onChanged: (newV) async {
          ref.read(Dev.$demoMode.notifier).set(newV);
          await Init.initModules();
        },
      ),
    );
  }

  Widget buildReload() {
    return ListTile(
      title: i18n.dev.reload.text(),
      subtitle: i18n.dev.reloadDesc.text(),
      leading: Icon(context.icons.refresh),
      onTap: () async {
        await Init.initNetwork();
        await Init.initModules();
        final engine = WidgetsFlutterBinding.ensureInitialized();
        engine.performReassemble();
        if (!mounted) return;
        context.navigator.pop();
      },
    );
  }
}

class ReceivedDeepLinksTile extends ConsumerWidget {
  const ReceivedDeepLinksTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appLinks = ref.watch($appLinks);
    return AnimatedExpansionTile(
      leading: const Icon(Icons.link),
      title: "Deep links".text(),
      children: appLinks
          .map((uri) => ListTile(
                title: context.formatYmdhmsNum(uri.ts).text(),
                subtitle: Uri.decodeFull(uri.uri.toString()).text(),
              ))
          .toList(),
    );
  }
}

class DebugGoRouteTile extends StatelessWidget {
  const DebugGoRouteTile({super.key});

  @override
  Widget build(BuildContext context) {
    return TextInputActionTile(
      leading: const Icon(Icons.route_outlined),
      title: "Go route".text(),
      canSubmit: (route) => route.isNotEmpty,
      hintText: "/anyway",
      onSubmit: (route) {
        if (!route.startsWith("/")) {
          route = "/$route";
        }
        context.push(route);
        return true;
      },
    );
  }
}

class DebugWebViewTile extends StatelessWidget {
  const DebugWebViewTile({super.key});

  @override
  Widget build(BuildContext context) {
    return TextInputActionTile(
      leading: const Icon(Icons.web),
      title: "Type URL".text(),
      hintText: R.websiteUri.toString(),
      canSubmit: (url) => url.isEmpty || Uri.tryParse(url) != null,
      onSubmit: (url) {
        if (url.isEmpty) {
          url = R.websiteUri.toString();
        }
        var uri = Uri.tryParse(url);
        if (uri == null) return false;
        if (uri.scheme.isEmpty) {
          uri = uri.replace(scheme: "https");
        }
        guardLaunchUrl(context, uri);
        return true;
      },
    );
  }
}

class DebugDeepLinkTile extends StatelessWidget {
  const DebugDeepLinkTile({super.key});

  @override
  Widget build(BuildContext context) {
    return TextInputActionTile(
      leading: const Icon(Icons.link),
      title: "Deep Link".text(),
      hintText: "${R.scheme}://",
      canSubmit: (url) {
        if (url.isEmpty) return false;
        final uri = Uri.tryParse(url);
        if (uri == null) return false;
        if (!uri.isScheme(R.scheme)) return false;
        return getFirstDeepLinkHandler(deepLink: uri) != null;
      },
      onSubmit: (uri) async {
        await onHandleDeepLinkString(context: context, deepLink: uri);
        return true;
      },
    );
  }
}

class TextInputActionTile extends StatefulWidget {
  final Widget? title;
  final Widget? leading;
  final String? hintText;

  /// return true to consume the text
  final FutureOr<bool> Function(String text) onSubmit;
  final bool Function(String text)? canSubmit;

  const TextInputActionTile({
    super.key,
    this.title,
    this.leading,
    required this.onSubmit,
    this.canSubmit,
    this.hintText,
  });

  @override
  State<TextInputActionTile> createState() => _TextInputActionTileState();
}

class _TextInputActionTileState extends State<TextInputActionTile> {
  final $text = TextEditingController();

  @override
  void dispose() {
    $text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = widget.canSubmit;
    return ListTile(
      isThreeLine: true,
      leading: widget.leading,
      title: widget.title,
      subtitle: TextField(
        controller: $text,
        textInputAction: TextInputAction.go,
        onSubmitted: (text) {
          if (widget.canSubmit?.call(text) != false) {
            onSubmit();
          }
        },
        decoration: InputDecoration(
          hintText: widget.hintText,
        ),
      ),
      trailing: $text >>
          (ctx, text) => PlatformIconButton(
                onPressed: canSubmit == null
                    ? onSubmit
                    : canSubmit(text.text)
                        ? onSubmit
                        : null,
                icon: const Icon(Icons.arrow_forward),
              ),
    );
  }

  Future<void> onSubmit() async {
    final result = await widget.onSubmit($text.text);
    if (result) {
      $text.clear();
    }
  }
}

class SwitchOaUserTile extends StatefulWidget {
  final Credentials currentCredentials;

  const SwitchOaUserTile({
    super.key,
    required this.currentCredentials,
  });

  @override
  State<SwitchOaUserTile> createState() => _SwitchOaUserTileState();
}

class _SwitchOaUserTileState extends State<SwitchOaUserTile> {
  bool isLoggingIn = false;

  @override
  Widget build(BuildContext context) {
    final credentialsList = Dev.getSavedOaCredentialsList() ?? [];
    if (credentialsList.none((c) => c.account == widget.currentCredentials.account)) {
      credentialsList.add(widget.currentCredentials);
    }
    return AnimatedExpansionTile(
      title: "Switch OA user".text(),
      subtitle: "Without logging out".text(),
      initiallyExpanded: true,
      leading: const Icon(Icons.swap_horiz),
      trailing: isLoggingIn
          ? const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator.adaptive(),
            )
          : null,
      children: [
        ...credentialsList.map(buildCredentialsHistoryTile).map((e) => e.padOnly(l: 32)),
        buildLoginNewTile().padOnly(l: 32),
      ],
    );
  }

  Widget buildCredentialsHistoryTile(Credentials credentials) {
    final isCurrent = credentials == widget.currentCredentials;
    return ListTile(
      leading: Icon(context.icons.accountCircle),
      title: credentials.account.text(),
      subtitle: isCurrent ? "Current user".text() : estimateOaUserType(credentials.account)?.l10n().text(),
      trailing: const Icon(Icons.login).padAll(8),
      enabled: !isCurrent,
      onTap: () async {
        await loginWith(credentials);
      },
      onLongPress: () async {
        context.showSnackBar(content: i18n.copyTipOf(i18n.oaCredentials.oaAccount).text());
        await Clipboard.setData(ClipboardData(text: credentials.account));
      },
    );
  }

  Widget buildLoginNewTile() {
    return ListTile(
      leading: Icon(context.icons.add),
      title: "New account".text(),
      onTap: () async {
        final credentials = await Editor.showAnyEditor(
          context,
          initial: const Credentials(account: "", password: ""),
        );
        if (credentials == null) return;
        await loginWith(credentials);
      },
    );
  }

  Future<void> loginWith(Credentials credentials) async {
    setState(() => isLoggingIn = true);
    try {
      await Init.cookieJar.deleteAll();
      await LoginAggregated.login(credentials);
      final former = Dev.getSavedOaCredentialsList() ?? [];
      former.add(credentials);
      await Dev.setSavedOaCredentialsList(former);
      if (!mounted) return;
      setState(() => isLoggingIn = false);
      context.go("/");
    } on Exception catch (error, stackTrace) {
      if (!mounted) return;
      setState(() => isLoggingIn = false);
      await handleLoginException(context: context, error: error, stackTrace: stackTrace);
    }
  }
}

class DebugExpenseUserOverrideTile extends ConsumerWidget {
  const DebugExpenseUserOverrideTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(Dev.$expenseUserOverride);
    return ListTile(
      leading: Icon(context.icons.person),
      title: "Expense user".text(),
      subtitle: user?.text(),
      onTap: () async {
        final res = await Editor.showStringEditor(
          context,
          desc: "OA account",
          initial: user ?? "",
        );
        if (res == null) return;
        if (res.isEmpty) {
          ref.read(Dev.$expenseUserOverride.notifier).set(null);
          return;
        }
        if (estimateOaUserType(res) == null) {
          if (!context.mounted) return;
          await context.showTip(
            title: "Error",
            desc: "Invalid OA account format.",
            primary: "OK",
          );
        } else {
          ref.read(Dev.$expenseUserOverride.notifier).set(res);
        }
      },
      trailing: Icon(context.icons.edit),
    );
  }
}

class DebugFetchVersionTile extends StatefulWidget {
  final Widget? title;
  final Widget? leading;
  final Future<String> Function() fetch;

  const DebugFetchVersionTile({
    super.key,
    this.title,
    this.leading,
    required this.fetch,
  });

  @override
  State<DebugFetchVersionTile> createState() => _DebugFetchVersionTileState();
}

class _DebugFetchVersionTileState extends State<DebugFetchVersionTile> {
  String? version;
  var isFetching = false;

  @override
  void initState() {
    super.initState();
    fetch();
  }

  Future<void> fetch() async {
    setState(() {
      isFetching = true;
    });
    final v = await widget.fetch();
    if (!mounted) return;
    setState(() {
      version = v;
      isFetching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: widget.title,
      leading: widget.leading,
      subtitle: version?.text(),
      trailing: isFetching ? const CircularProgressIndicator.adaptive() : null,
    );
  }
}

class DebugDeviceInfoTile extends StatelessWidget {
  const DebugDeviceInfoTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: "Device info".text(),
      subtitle: R.meta.deviceInfo.toString().text(),
    );
  }
}

class GoInAppWebviewTile extends ConsumerWidget {
  const GoInAppWebviewTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextInputActionTile(
      leading: const Icon(Icons.route_outlined),
      title: "In-app Webview".text(),
      canSubmit: (url) => url.isEmpty || Uri.tryParse(url) != null,
      hintText: R.websiteUri.toString(),
      onSubmit: (url) {
        if (url.isEmpty) {
          url = R.websiteUri.toString();
        }
        var uri = Uri.tryParse(url);
        if (uri == null) return false;
        if (uri.scheme.isEmpty) {
          uri = uri.replace(scheme: "https");
        }
        context.navigator.push(MaterialPageRoute(
          builder: (ctx) => InAppWebviewPage(initialUri: WebUri.uri(uri!)),
        ));
        return true;
      },
    );
  }
}
