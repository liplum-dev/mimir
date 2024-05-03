import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sit/files.dart';
import 'package:sit/init.dart';
import 'package:sit/session/backend.dart';
import 'package:sit/utils/error.dart';
import 'package:universal_platform/universal_platform.dart';
import 'package:version/version.dart';

import '../entity/artifact.dart';

const _itunesURL = 'https://itunes.apple.com';

class UpdateService {
  BackendSession get _session => Init.backend;

  Dio get _dio => Init.dio;

  const UpdateService();

  Future<ArtifactVersionInfo> getLatestVersionFromOfficial() async {
    late Response res;
    try {
      res = await _session.get(
        "https://g.mysit.life/artifact/latest.json",
      );
    } catch (error, stackTrace) {
      debugPrintError(error, stackTrace);
      res = await _session.get(
        "https://get.mysit.life/artifact/latest.json",
      );
    }
    final json = res.data as Map<String, dynamic>;
    return ArtifactVersionInfo.fromJson(json);
  }

  /// return null if the version from iTunes isn't identical to official's
  Future<ArtifactVersionInfo?> getLatestVersionFromAppStoreAndOfficial() async {
    final official = await getLatestVersionFromOfficial();
    final version = await getLatestVersionFromAppStore();
    if (official.version == version) {
      return official;
    }
    return null;
  }

  Future<Version?> getLatestVersionFromAppStore({String? iosAppStoreRegion = "cn"}) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final version = await _getVersionFromItunes(
      UniversalPlatform.isIOS || UniversalPlatform.isMacOS ? packageInfo.packageName : "life.mysit.SITLife",
      iosAppStoreRegion: iosAppStoreRegion,
    );
    return version;
  }

  Future<Version?> _getVersionFromItunes(String bundleId, {String? iosAppStoreRegion}) async {
    final Uri uri;

    if (iosAppStoreRegion == null) {
      uri = Uri.parse('$_itunesURL/lookup?bundleId=$bundleId');
    } else {
      uri = Uri.parse('$_itunesURL/$iosAppStoreRegion/lookup?bundleId=$bundleId');
    }

    final res = await _dio.requestUri(uri);

    final responseBody = await res.data as String;
    final json = jsonDecode(responseBody);
    final version = _parseVersionFromItunes(json);
    return version;
  }

  Version? _parseVersionFromItunes(Map<String, dynamic> json) {
    final results = json["results"];
    if (results is! List) return null;
    if (results.isEmpty) return null;
    final info = results.first;
    final versionRaw = info["version"];
    if (versionRaw is! String) return null;
    return Version.parse(versionRaw);
  }

  Future<File> downloadArtifactFromUrl(
    String url, {
    required String name,
    ProgressCallback? onProgress,
  }) async {
    final file = Files.artifact.subFile(name);
    await Init.dio.download(url, file.path, onReceiveProgress: onProgress);
    return file;
  }
}
