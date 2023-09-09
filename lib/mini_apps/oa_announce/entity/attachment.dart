import 'package:mimir/hive/type_id.dart';

part 'attachment.g.dart';

@HiveType(typeId: HiveTypeOaAnnounce.attachment)
class AnnounceAttachment {
  /// 附件标题
  @HiveField(0)
  String name = '';

  /// 附件下载网址
  @HiveField(1)
  String url = '';

  @override
  String toString() {
    return 'Attachment{name: $name, url: $url}';
  }
}
