import 'package:json_annotation/json_annotation.dart';
import 'package:sit/entity/meta.dart';
import 'package:version/version.dart';

part 'artifact.g.dart';

@JsonSerializable(createToJson: false)
class ArtifactVersionInfo {
  @JsonKey(fromJson: Version.parse)
  final Version version;
  @JsonKey(name: "release_time")
  final DateTime releaseTime;
  @JsonKey(name: "release_note")
  final String releaseNote;
  @JsonKey()
  final Map<String, ArtifactDownload> downloads;

  const ArtifactVersionInfo({
    required this.version,
    required this.releaseTime,
    required this.releaseNote,
    required this.downloads,
  });

  ArtifactDownload? downloadOf(AppPlatform platform) => downloads[platform.name];

  factory ArtifactVersionInfo.fromJson(Map<String, dynamic> json) => _$ArtifactVersionInfoFromJson(json);

  @override
  String toString() {
    return {
      "version": version,
      "releaseTime": releaseTime,
      "releaseNote": releaseNote.replaceAll(RegExp(r"[\t\n\r]+"), ""),
      "downloads": downloads,
    }.toString();
  }
}

@JsonSerializable(createToJson: false)
class ArtifactDownload {
  @JsonKey()
  final String name;
  @JsonKey(name: "default")
  final String defaultUrlName;
  @JsonKey()
  final String sha256;
  @JsonKey(name: "url")
  final Map<String, String> name2Url;

  const ArtifactDownload({
    required this.name,
    required this.sha256,
    required this.defaultUrlName,
    required this.name2Url,
  });

  String? get defaultUrl => name2Url[defaultUrlName];

  factory ArtifactDownload.fromJson(Map<String, dynamic> json) => _$ArtifactDownloadFromJson(json);

  @override
  String toString() {
    return {
      "name": name,
      "defaultUrlName": defaultUrlName,
      "sha256": sha256,
      "name2Url": name2Url,
    }.toString();
  }
}
