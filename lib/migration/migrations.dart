import 'package:flutter/foundation.dart';
import 'package:sit/files.dart';
import 'package:sit/settings/entity/proxy.dart';
import 'package:sit/settings/settings.dart';
import 'package:sit/storage/hive/init.dart';
import 'package:sit/utils/error.dart';
import 'package:sit/utils/hive.dart';
import 'package:version/version.dart';

import 'foundation.dart';

class Migrations {
  static final _manager = MigrationManager();
  static Migration? _onNullVersion;

  static void init() {
    Version(1, 0, 0) <<
        Migration.run((phrase) async {
          if (phrase == MigrationPhrase.afterHive) {
            await HiveInit.clearCache();
          }
        });
    Version(2, 4, 0) <<
        Migration.run((phrase) async {
          if (kIsWeb) return;
          switch (phrase) {
            case MigrationPhrase.beforeHive:
              final oldTimetableBackgroundFi = Files.user.subFile("timetable", "background.img");
              final oldExists = await oldTimetableBackgroundFi.exists();
              final newExists = await Files.timetable.backgroundFile.exists();
              if (oldExists && !newExists) {
                await oldTimetableBackgroundFi.copy(Files.timetable.backgroundFile.path);
                await oldTimetableBackgroundFi.delete();
              }
            case MigrationPhrase.afterHive:
              await HiveInit.ywb.clear();
              // proxy
              final proxyBox = Settings.proxy.box;
              for (final cat in ProxyCat.values) {
                // if the user has already added new proxy profile, ignore this
                if (Settings.proxy.getProfileOf(cat) != null) continue;
                final address = proxyBox.safeGet<String>("/proxy/${cat.name}/address");
                final addressUri = address != null ? Uri.tryParse(address) : null;
                final enabled = proxyBox.safeGet<bool>("/proxy/${cat.name}/enabled");
                final mode = proxyBox.safeGet<ProxyMode>("/proxy/${cat.name}/proxyMode");
                if (addressUri != null && !cat.isDefaultUri(addressUri)) {
                  await Settings.proxy.setProfileOf(
                    cat,
                    ProxyProfile(
                      address: addressUri,
                      enabled: enabled ?? true,
                      mode: mode ?? ProxyMode.schoolOnly,
                    ),
                  );
                }
                await proxyBox.delete("/proxy/${cat.name}/address");
                await proxyBox.delete("/proxy/${cat.name}/enabled");
                await proxyBox.delete("/proxy/${cat.name}/proxyMode");
              }
            case MigrationPhrase.afterInitStorage:
          }
        });
  }

  static MigrationMatch match({
    required Version? from,
    required Version? to,
  }) {
    final result = <Migration>[];
    if (from == null) {
      final onNullVersion = _onNullVersion;
      if (onNullVersion != null) {
        result.add(onNullVersion);
      }
    } else if (to != null) {
      final all = _manager.collectBetween(from, to);
      result.addAll(all);
    }
    return MigrationMatch(result);
  }
}

class MigrationMatch {
  final List<Migration> _migrations;

  const MigrationMatch(this._migrations);

  Future<void> perform(MigrationPhrase phrase) async {
    try {
      for (final migration in _migrations) {
        await migration.perform(phrase);
      }
    } catch (error, stackTrace) {
      debugPrintError(error, stackTrace);
    }
  }
}

extension _MigrationEx on Version {
  void operator <<(Migration migration) {
    Migrations._manager.addWhen(this, perform: migration);
  }
}
