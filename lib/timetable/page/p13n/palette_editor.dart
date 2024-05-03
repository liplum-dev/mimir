import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart' hide isCupertino;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rettulf/rettulf.dart';
import 'package:sit/design/adaptive/dialog.dart';
import 'package:sit/design/adaptive/multiplatform.dart';
import 'package:sit/design/adaptive/swipe.dart';
import 'package:sit/l10n/extension.dart';
import 'package:sit/timetable/page/preview.dart';
import 'package:sit/utils/save.dart';

import '../../entity/platte.dart';
import '../../i18n.dart';
import '../../init.dart';

/// [TimetablePalette] object will be popped.
class TimetablePaletteEditorPage extends ConsumerStatefulWidget {
  final TimetablePalette palette;

  const TimetablePaletteEditorPage({
    super.key,
    required this.palette,
  });

  @override
  ConsumerState<TimetablePaletteEditorPage> createState() => _TimetablePaletteEditorPageState();
}

class _Tab {
  static const length = 2;
  static const info = 0;
  static const colors = 1;
}

class _TimetablePaletteEditorPageState extends ConsumerState<TimetablePaletteEditorPage> {
  late final $name = TextEditingController(text: widget.palette.name);
  late final $author = TextEditingController(text: widget.palette.author);
  late var colors = widget.palette.colors;
  var anyChanged = false;

  void markChanged() => anyChanged |= true;

  @override
  void initState() {
    super.initState();
    $name.addListener(() {
      if ($name.text != widget.palette.name) {
        setState(() => markChanged());
      }
    });
    $author.addListener(() {
      if ($author.text != widget.palette.author) {
        setState(() => markChanged());
      }
    });
  }

  @override
  void dispose() {
    $name.dispose();
    $author.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timetable = ref.watch(TimetableInit.storage.timetable.$selectedRow);
    return PromptSaveBeforeQuitScope(
      changed: anyChanged,
      onSave: onSave,
      child: Scaffold(
        body: DefaultTabController(
          length: _Tab.length,
          child: NestedScrollView(
            floatHeaderSlivers: true,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return <Widget>[
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                  sliver: SliverAppBar(
                    floating: true,
                    title: i18n.p13n.palette.title.text(),
                    actions: [
                      if (timetable != null && colors.isNotEmpty)
                        PlatformTextButton(
                          child: i18n.preview.text(),
                          onPressed: () async {
                            await previewTimetable(
                              context,
                              timetable: timetable,
                              palette: buildPalette(),
                            );
                          },
                        ),
                      PlatformTextButton(
                        onPressed: onSave,
                        child: i18n.save.text(),
                      ),
                    ],
                    forceElevated: innerBoxIsScrolled,
                    bottom: TabBar(
                      isScrollable: true,
                      tabs: [
                        Tab(child: i18n.p13n.palette.infoTab.text()),
                        Tab(child: i18n.p13n.palette.colorsTab.text()),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverList.list(children: [
                      buildName(),
                      buildAuthor(),
                    ]),
                  ],
                ),
                CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(
                      child: LightDarkColorsHeaderTitle(),
                    ),
                    SliverList.builder(
                      itemCount: colors.length,
                      itemBuilder: buildColorTile,
                    ),
                    SliverList.list(children: [
                      const Divider(indent: 12, endIndent: 12),
                      ListTile(
                        leading: Icon(context.icons.add),
                        title: i18n.p13n.palette.addColor.text(),
                        onTap: () {
                          setState(() {
                            colors.add(TimetablePalette.defaultColor);
                          });
                          markChanged();
                        },
                      ),
                    ]),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onSave() {
    final palette = buildPalette();
    context.navigator.pop(palette);
  }

  TimetablePalette buildPalette() {
    return TimetablePalette(
      name: $name.text,
      author: $author.text,
      colors: colors,
      lastModified: DateTime.now(),
    );
  }

  Widget buildColorTile(BuildContext ctx, int index) {
    Future<void> changeColor(Color old, Brightness brightness) async {
      final newColor = await showColorPickerDialog(
        ctx,
        old,
        enableOpacity: true,
        enableShadesSelection: true,
        enableTonalPalette: true,
        showColorCode: true,
        pickersEnabled: const <ColorPickerType, bool>{
          ColorPickerType.both: true,
          ColorPickerType.primary: false,
          ColorPickerType.accent: false,
          ColorPickerType.custom: true,
          ColorPickerType.wheel: true,
        },
      );
      if (newColor != old) {
        await HapticFeedback.mediumImpact();
        setState(() {
          if (brightness == Brightness.light) {
            colors[index] = (light: newColor, dark: colors[index].dark);
          } else {
            colors[index] = (light: colors[index].light, dark: newColor);
          }
        });
      }
    }

    final current = colors[index];
    return WithSwipeAction(
      childKey: ObjectKey(current),
      right: SwipeAction.delete(
        icon: context.icons.delete,
        action: () async {
          setState(() {
            colors.removeAt(index);
          });
          markChanged();
        },
      ),
      child: PaletteColorTile(
        colors: current,
        onEdit: (old, brightness) async {
          await changeColor(old, brightness);
          markChanged();
        },
      ),
    );
  }

  Widget buildName() {
    return ListTile(
      isThreeLine: true,
      title: i18n.p13n.palette.name.text(),
      subtitle: TextField(
        controller: $name,
        decoration: InputDecoration(
          hintText: i18n.p13n.palette.namePlaceholder,
        ),
      ),
    );
  }

  Widget buildAuthor() {
    return ListTile(
      isThreeLine: true,
      title: i18n.p13n.palette.author.text(),
      subtitle: TextField(
        controller: $author,
        decoration: InputDecoration(
          hintText: i18n.p13n.palette.authorPlaceholder,
        ),
      ),
    );
  }
}

class LightDarkColorsHeaderTitle extends StatelessWidget {
  const LightDarkColorsHeaderTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: [
        [const Icon(Icons.light_mode), Brightness.light.l10n().text()].row(mas: MainAxisSize.min),
        [const Icon(Icons.dark_mode), Brightness.dark.l10n().text()].row(mas: MainAxisSize.min),
      ].row(maa: MainAxisAlignment.spaceBetween),
    );
  }
}

class PaletteColorTile extends StatelessWidget {
  final Color2Mode colors;
  final void Function(Color old, Brightness brightness)? onEdit;

  const PaletteColorTile({
    super.key,
    required this.colors,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final (:light, :dark) = colors;
    return ListTile(
      isThreeLine: true,
      visualDensity: VisualDensity.compact,
      title: [
        "#${light.hexAlpha}".text(),
        "#${dark.hexAlpha}".text(),
      ].row(maa: MainAxisAlignment.spaceBetween),
      subtitle: [
        PaletteColorBar(
          color: light,
          brightness: Brightness.light,
          onEdit: onEdit,
        ).expanded(),
        const SizedBox(width: 5),
        PaletteColorBar(
          color: dark,
          brightness: Brightness.dark,
          onEdit: onEdit,
        ).expanded(),
      ].row(mas: MainAxisSize.min, maa: MainAxisAlignment.spaceEvenly),
    );
  }
}

class PaletteColorBar extends StatelessWidget {
  final Color color;
  final Brightness brightness;
  final void Function(Color old, Brightness brightness)? onEdit;

  const PaletteColorBar({
    super.key,
    required this.color,
    required this.brightness,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final onEdit = this.onEdit;
    // final textColor = color.resolveTextColorForReadability();
    final textColor = brightness == Brightness.light ? Colors.black : Colors.white;
    return Card.outlined(
      color: textColor,
      margin: EdgeInsets.zero,
      child: Card.filled(
        color: color,
        clipBehavior: Clip.hardEdge,
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onEdit == null
              ? null
              : () {
                  onEdit.call(color, brightness);
                },
          onLongPress: () async {
            await Clipboard.setData(ClipboardData(text: "#${color.hexAlpha}"));
            if (!context.mounted) return;
            context.showSnackBar(content: i18n.copyTipOf(i18n.p13n.palette.color).text());
          },
          child: SizedBox(
            height: 35,
            child:
                // "${brightness.l10n()} ${calculateContrastRatio(textColor!, color).toStringAsFixed(2)}"
                brightness.l10n().text(style: context.textTheme.bodyLarge?.copyWith(color: textColor)).center(),
          ),
        ),
      ),
    );
  }
}
