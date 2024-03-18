import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:locale_names/locale_names.dart';
import 'package:sit/r.dart';
import 'package:rettulf/rettulf.dart';
import '../i18n.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({
    super.key,
  });

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  late var selected = context.locale;

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
                actions: [
                  buildSaveButton(),
                ],
              );
            },
            cupertino: (ctx, p) {
              return CupertinoSliverAppBarData(
                  previousPageTitle: i18n.title,
                  trailing:buildSaveButton(),
              );
            },
            title: i18n.language.text(),
          ),
          SliverList.builder(
            itemCount: R.supportedLocales.length,
            itemBuilder: (ctx, i) {
              final locale = R.supportedLocales[i];
              return PlatformListTile(
                material: (ctx, platform) {
                  return MaterialListTileData(
                    selected: selected == locale,
                  );
                },
                cupertino: (ctx,p){
                  return CupertinoListTileData(
                    trailing:  selected == locale? const Icon(CupertinoIcons.check_mark) : null,
                  );
                },
                title: locale.nativeDisplayLanguageScript.text(),
                onTap: () {
                  setState(() {
                    selected = locale;
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildSaveButton(){
    return PlatformTextButton(
      onPressed: selected != context.locale
          ? saveLanguage
          : null,
      child: i18n.save.text(),
    );
  }

  Future<void> saveLanguage() async {
    await context.setLocale(selected);
    final engine = WidgetsFlutterBinding.ensureInitialized();
    engine.performReassemble();
    if (!mounted) return;
    context.pop();
  }
}
