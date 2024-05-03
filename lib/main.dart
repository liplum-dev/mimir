import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sit/files.dart';
import 'package:sit/migration/foundation.dart';
import 'package:sit/network/proxy.dart';
import 'package:sit/platform/windows/windows.dart';
import 'package:sit/storage/hive/init.dart';
import 'package:sit/init.dart';
import 'package:sit/migration/migrations.dart';
import 'package:sit/platform/desktop.dart';
import 'package:sit/school/yellow_pages/entity/contact.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sit/settings/meta.dart';
import 'package:sit/settings/dev.dart';
import 'package:sit/entity/meta.dart';
import 'package:sit/storage/prefs.dart';
import 'package:system_theme/system_theme.dart';
import 'package:version/version.dart';

import 'app.dart';

import 'l10n/yaml_assets_loader.dart';
import 'r.dart';

void main() async {
  // debugRepaintRainbowEnabled = true;
  // debugRepaintTextRainbowEnabled = true;
  // debugPaintSizeEnabled = true;
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = kDebugMode;
  final prefs = await SharedPreferences.getInstance();
  final lastSize = prefs.getLastWindowSize();
  await DesktopInit.init(size: lastSize);
  await WindowsInit.registerCustomScheme(R.scheme);
  final installationTime = prefs.getInstallTime();
  debugPrint("First installation time: $installationTime");
  if (installationTime == null) {
    await prefs.setInstallTime(DateTime.now());
  }
  // Initialize the window size before others for a better experience when loading.
  await SystemTheme.accentColor.load();
  await EasyLocalization.ensureInitialized();
  Migrations.init();

  if (!kIsWeb) {
    Files.cache = await getApplicationCacheDirectory();
    debugPrint("Cache ${Files.cache}");
    Files.temp = await getTemporaryDirectory();
    debugPrint("Temp ${Files.temp}");
    Files.internal = await getApplicationSupportDirectory();
    debugPrint("Internal ${Files.internal}");
    Files.user = await getApplicationDocumentsDirectory();
    debugPrint("User ${Files.user}");
  }
  await Files.init();
  // Perform migrations
  R.meta = await getCurrentVersion();
  final currentVersion = R.meta.version;
  final lastVersionRaw = prefs.getLastVersion();
  final lastVersion = lastVersionRaw != null ? Version.parse(lastVersionRaw) : currentVersion;
  debugPrint("Last version: $lastVersion");
  await prefs.setLastVersion(currentVersion.toString());
  final migrations = Migrations.match(from: lastVersion, to: currentVersion);
  // final migrations = Migrations.match(from: Version(2, 3, 2), to: currentVersion);

  await migrations.perform(MigrationPhrase.beforeHive);

  R.roomList = await _loadRoomNumberList();
  R.userAgentList = await _loadUserAgents();
  R.yellowPages = await _loadYellowPages();

  // Initialize Hive
  if (!kIsWeb) {
    await HiveInit.initLocalStorage(
      coreDir: Files.internal.subDir("hive", R.hiveStorageVersionCore),
      // iOS will clear the cache under [getApplicationCacheDirectory()] when device has no enough storage.
      cacheDir: Files.internal.subDir("hive-cache", R.hiveStorageVersionCache),
    );
  }
  HiveInit.initAdapters();
  await HiveInit.initBox();

  // Setup Settings and Meta
  if (kDebugMode) {
    Dev.on = true;
  }
  // The last time when user launch this app
  Meta.lastLaunchTime = Meta.thisLaunchTime;
  Meta.thisLaunchTime = DateTime.now();
  Init.registerCustomEditor();
  await migrations.perform(MigrationPhrase.afterHive);
  HttpOverrides.global = SitHttpOverrides();
  await Init.initNetwork();
  await Init.initModules();
  await Init.initStorage();
  await migrations.perform(MigrationPhrase.afterInitStorage);
  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: R.supportedLocales,
        path: 'assets/l10n',
        fallbackLocale: R.defaultLocale,
        useFallbackTranslations: true,
        assetLoader: _yamlAssetsLoader,
        child: const MimirApp(),
      ),
    ),
  );
}

final _yamlAssetsLoader = YamlAssetLoader();

Future<List<String>> _loadRoomNumberList() async {
  String jsonData = await rootBundle.loadString("assets/room_list.json");
  List<dynamic> list = jsonDecode(jsonData);
  return list.map((e) => e.toString()).toList();
}

Future<List<String>> _loadUserAgents() async {
  String jsonData = await rootBundle.loadString("assets/user_agent.json");
  List<dynamic> list = jsonDecode(jsonData);
  return list.cast<String>();
}

Future<List<SchoolContact>> _loadYellowPages() async {
  String jsonData = await rootBundle.loadString("assets/yellow_pages.json");
  List<dynamic> list = jsonDecode(jsonData);
  return list.map((e) => SchoolContact.fromJson(e)).toList().cast<SchoolContact>();
}
