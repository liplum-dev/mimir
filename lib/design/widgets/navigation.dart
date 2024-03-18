import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';

class PageNavigationTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget leading;
  final String path;

  const PageNavigationTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.leading,
    required this.path,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformListTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: const Icon(Icons.navigate_next_rounded),
      onTap: () {
        context.push(path);
      },
    );
  }
}
