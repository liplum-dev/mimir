import 'package:carousel_slider/carousel_slider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:rettulf/rettulf.dart';
import 'package:sit/design/adaptive/dialog.dart';
import 'package:sit/design/adaptive/foundation.dart';
import 'package:sit/design/adaptive/multiplatform.dart';
import 'package:sit/design/widgets/card.dart';
import 'package:sit/design/widgets/entry_card.dart';
import 'package:sit/l10n/extension.dart';
import 'package:sit/qrcode/page/view.dart';
import 'package:sit/timetable/entity/platte.dart';
import 'package:sit/timetable/entity/timetable.dart';
import 'package:sit/timetable/init.dart';
import 'package:sit/timetable/platte.dart';
import 'package:sit/utils/color.dart';
import 'package:sit/utils/format.dart';
import 'package:text_scroll/text_scroll.dart';

import '../../i18n.dart';
import '../../qrcode/palette.dart';
import '../../widgets/style.dart';
import '../../widgets/timetable/weekly.dart';
import 'palette_editor.dart';
import '../preview.dart';

class TimetableP13nPage extends StatefulWidget {
  final int? tab;

  const TimetableP13nPage({
    super.key,
    this.tab,
  }) : assert(tab == null || (0 <= tab && tab < TimetableP13nTab.length), "#$tab tab not found");

  @override
  State<TimetableP13nPage> createState() => _TimetableP13nPageState();
}

class TimetableP13nTab {
  static const length = 2;
  static const custom = 0;
  static const builtin = 1;
}

class _TimetableP13nPageState extends State<TimetableP13nPage> with SingleTickerProviderStateMixin {
  final $paletteList = TimetableInit.storage.palette.$any;
  late final TabController tabController;
  final $selected = TimetableInit.storage.timetable.$selected;
  var selectedTimetable = TimetableInit.storage.timetable.selectedRow;

  @override
  void initState() {
    super.initState();
    $selected.addListener(refresh);
    $paletteList.addListener(refresh);
    tabController = TabController(vsync: this, length: TimetableP13nTab.length);
    final selectedId = TimetableInit.storage.palette.selectedId;
    final forceTab = widget.tab;
    if (forceTab != null) {
      tabController.index = forceTab.clamp(TimetableP13nTab.custom, TimetableP13nTab.builtin);
    } else if (selectedId == null || BuiltinTimetablePalettes.all.any((palette) => palette.id == selectedId)) {
      tabController.index = TimetableP13nTab.builtin;
    }
  }

  @override
  void dispose() {
    $paletteList.removeListener(refresh);
    tabController.dispose();
    $selected.removeListener(refresh);
    super.dispose();
  }

  void refresh() {
    setState(() {
      selectedTimetable = TimetableInit.storage.timetable.selectedRow;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        label: i18n.p13n.palette.fab.text(),
        icon: Icon(context.icons.add),
        onPressed: () async {
          final palette = TimetablePalette(
            name: i18n.p13n.palette.newPaletteName,
            author: "",
            colors: [],
            lastModified: DateTime.now(),
          );
          TimetableInit.storage.palette.add(palette);
          tabController.index = TimetableP13nTab.custom;
        },
      ),
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          // These are the slivers that show up in the "outer" scroll view.
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: SliverAppBar(
                floating: true,
                title: i18n.p13n.palette.title.text(),
                forceElevated: innerBoxIsScrolled,
                bottom: TabBar(
                  controller: tabController,
                  isScrollable: true,
                  tabs: [
                    Tab(child: i18n.p13n.palette.customTab.text()),
                    Tab(child: i18n.p13n.palette.builtinTab.text()),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: tabController,
          children: [
            buildPaletteList(TimetableInit.storage.palette.getRows()),
            buildPaletteList(BuiltinTimetablePalettes.all.map((e) => (id: e.id, row: e)).toList()),
          ],
        ),
      ),
    );
  }

  Widget buildPaletteList(List<({int id, TimetablePalette row})> palettes) {
    final selectedId = TimetableInit.storage.palette.selectedId ?? BuiltinTimetablePalettes.classic.id;
    palettes.sort((a, b) {
      final $a = a.row.lastModified;
      final $b = b.row.lastModified;
      if ($a == $b) return 0;
      if ($a == null) {
        return 1;
      } else if ($b == null) {
        return -1;
      }
      return $b.compareTo($a);
    });
    return CustomScrollView(
      slivers: [
        SliverList.builder(
          itemCount: palettes.length,
          itemBuilder: (ctx, i) {
            final (:id, row: palette) = palettes[i];
            return PaletteCard(
              id: id,
              palette: palette,
              timetable: selectedTimetable,
              selected: selectedId == id,
              onDuplicate: () {
                tabController.index = TimetableP13nTab.custom;
              },
              allPaletteNames: palettes.map((p) => p.row.name).toList(),
            ).padH(6);
          },
        ),
      ],
    );
  }
}

class PaletteCard extends StatelessWidget {
  final int id;
  final TimetablePalette palette;
  final bool selected;
  final SitTimetable? timetable;
  final VoidCallback? onDuplicate;
  final List<String>? allPaletteNames;

  const PaletteCard({
    super.key,
    required this.id,
    required this.palette,
    required this.selected,
    this.timetable,
    this.onDuplicate,
    this.allPaletteNames,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final timetable = this.timetable;
    return EntryCard(
      title: palette.name,
      selected: selected,
      selectAction: (ctx) => palette.colors.isEmpty
          ? null
          : EntrySelectAction(
              selectLabel: i18n.use,
              selectedLabel: i18n.used,
              action: () async {
                TimetableInit.storage.palette.selectedId = id;
              },
            ),
      deleteAction: palette is BuiltinTimetablePalette
          ? null
          : (ctx) => EntryAction.delete(
                label: i18n.delete,
                icon: context.icons.delete,
                action: () async {
                  final confirm = await ctx.showRequest(
                    title: i18n.p13n.palette.deleteRequest,
                    desc: i18n.p13n.palette.deleteRequestDesc,
                    yes: i18n.delete,
                    no: i18n.cancel,
                    destructive: true,
                  );
                  if (confirm == true) {
                    TimetableInit.storage.palette.delete(id);
                  }
                },
              ),
      actions: (ctx) => [
        if (palette is! BuiltinTimetablePalette)
          EntryAction.edit(
            main: true,
            label: i18n.edit,
            icon: context.icons.edit,
            activator: const SingleActivator(LogicalKeyboardKey.keyE),
            action: () async {
              final newPalette = await context.push<TimetablePalette>("/timetable/palette/edit/$id");
              if (newPalette != null) {
                TimetableInit.storage.palette[id] = newPalette;
              }
            },
          ),
        if (timetable != null && palette.colors.isNotEmpty)
          EntryAction(
            label: i18n.preview,
            icon: isCupertino ? CupertinoIcons.eye : Icons.preview,
            activator: const SingleActivator(LogicalKeyboardKey.keyP),
            action: () async {
              await context.show$Sheet$(
                (context) => TimetableStyleProv(
                  palette: palette,
                  child: TimetablePreviewPage(
                    timetable: timetable,
                  ),
                ),
              );
            },
          ),
        EntryAction(
          label: i18n.duplicate,
          icon: context.icons.copy,
          oneShot: true,
          activator: const SingleActivator(LogicalKeyboardKey.keyD),
          action: () async {
            final duplicate = palette.copyWith(
              name: getDuplicateFileName(palette.name, all: allPaletteNames),
              author: palette.author,
              lastModified: DateTime.now(),
            );
            TimetableInit.storage.palette.add(duplicate);
            onDuplicate?.call();
          },
        ),
        // Uint64 is not supporting on web
        if (!kIsWeb)
          EntryAction(
            label: i18n.p13n.palette.shareQrCode,
            icon: context.icons.qrcode,
            action: () async {
              final qrCodeData = const TimetablePaletteDeepLink().encode(palette);
              await ctx.show$Sheet$(
                (context) => QrCodePage(
                  title: palette.name.text(),
                  data: qrCodeData.toString(),
                ),
              );
            },
          ),
        if (kDebugMode)
          EntryAction(
            label: "Copy Dart code",
            action: () async {
              final code = palette.colors.toString();
              debugPrint(code);
              await Clipboard.setData(ClipboardData(text: code));
            },
          ),
      ],
      detailsBuilder: (ctx, actions) {
        return PaletteDetailsPage(id: id, palette: palette, actions: actions?.call(ctx));
      },
      itemBuilder: (ctx) => [
        palette.name.text(style: theme.textTheme.titleLarge),
        if (palette.author.isNotEmpty)
          palette.author.text(
            style: const TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
        PaletteColorsPreview(palette.colors),
      ],
    );
  }
}

class PaletteDetailsPage extends StatefulWidget {
  final int id;
  final TimetablePalette palette;
  final List<Widget>? actions;

  const PaletteDetailsPage({
    super.key,
    required this.id,
    required this.palette,
    this.actions,
  });

  @override
  State<PaletteDetailsPage> createState() => _PaletteDetailsPageState();
}

class _PaletteDetailsPageState extends State<PaletteDetailsPage> {
  late final $row = TimetableInit.storage.palette.listenRowChange(widget.id);
  late TimetablePalette palette = widget.palette;

  @override
  void initState() {
    super.initState();
    $row.addListener(refresh);
  }

  @override
  void dispose() {
    $row.removeListener(refresh);
    super.dispose();
  }

  void refresh() {
    final palette = TimetableInit.storage.palette[widget.id];
    if (palette == null) {
      context.pop();
      return;
    } else {
      setState(() {
        this.palette = palette;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = this.palette;
    final actions = widget.actions;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.medium(
            title: TextScroll(palette.name),
            actions: actions,
          ),
          SliverList.list(children: [
            ListTile(
              leading: const Icon(Icons.drive_file_rename_outline),
              title: i18n.p13n.palette.name.text(),
              subtitle: palette.name.text(),
            ),
            if (palette.author.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.person),
                title: i18n.p13n.palette.author.text(),
                subtitle: palette.author.text(),
              ),
            if (palette.colors.isNotEmpty) const Divider(),
            if (palette.colors.isNotEmpty)
              TimetableStyleProv(
                palette: palette,
                child: const TimetableP13nLivePreview(),
              ),
            const Divider(),
            const LightDarkColorsHeaderTitle(),
          ]),
          SliverList.builder(
            itemCount: palette.colors.length,
            itemBuilder: (ctx, i) {
              return PaletteColorTile(colors: palette.colors[i]);
            },
          )
        ],
      ),
    );
  }
}

class PaletteColorsPreview extends StatelessWidget {
  final List<Color2Mode> colors;

  const PaletteColorsPreview(this.colors, {super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = context.theme.brightness;
    return colors
        .map((c) {
          final color = c.byBrightness(brightness);
          return OutlinedCard(
            color: brightness == Brightness.light ? Colors.black : Colors.white,
            margin: EdgeInsets.zero,
            child: TweenAnimationBuilder(
              tween: ColorTween(begin: color, end: color),
              duration: const Duration(milliseconds: 300),
              builder: (ctx, value, child) => FilledCard(
                margin: EdgeInsets.zero,
                color: value,
                child: const SizedBox(
                  width: 32,
                  height: 32,
                ),
              ),
            ),
          );
        })
        .toList()
        .wrap(spacing: 4, runSpacing: 4)
        .padV(4);
  }
}

class TimetableP13nLivePreview extends StatelessWidget {
  const TimetableP13nLivePreview({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, box) {
      final height = box.maxHeight.isFinite ? box.maxHeight : context.mediaQuery.size.height / 2;
      return buildLivePreview(context, fullSize: Size(box.maxWidth, height));
    });
  }

  Widget buildLivePreview(
    BuildContext context, {
    required Size fullSize,
  }) {
    final style = TimetableStyle.of(context);
    final cellStyle = style.cellStyle;
    final palette = style.platte;
    final cellSize = Size(fullSize.width / 5, fullSize.height / 3);
    final themeColor = context.colorScheme.primary;
    Widget buildCell({
      required int colorId,
      required String name,
      required String place,
      required List<String> teachers,
      bool grayOut = false,
    }) {
      var color = palette.safeGetColor(colorId).byTheme(context.theme);
      if (cellStyle.harmonizeWithThemeColor) {
        color = color.harmonizeWith(themeColor);
      }
      if (grayOut) {
        color = color.monochrome();
      }
      final alpha = cellStyle.alpha;
      if (alpha < 1.0) {
        color = color.withOpacity(alpha);
      }
      return TweenAnimationBuilder(
        tween: ColorTween(begin: color, end: color),
        duration: const Duration(milliseconds: 300),
        builder: (ctx, value, child) => CourseCell(
          courseName: name,
          color: value!,
          place: place,
          teachers: cellStyle.showTeachers ? teachers : null,
        ),
      );
    }

    Widget livePreview(
      int index, {
      required int colorId,
      bool grayOut = false,
    }) {
      final data = i18n.p13n.livePreview(index);
      return buildCell(
        colorId: colorId,
        name: data.name,
        place: data.place,
        teachers: data.teachers,
        grayOut: grayOut,
      );
    }

    final grayOut = cellStyle.grayOutTakenLessons;
    return CarouselSlider.builder(
      itemCount: palette.colors.length,
      options: CarouselOptions(
        height: cellSize.height,
        viewportFraction: 0.24,
        // FIXME: https://github.com/serenader2014/flutter_carousel_slider/issues/291
        enableInfiniteScroll: true,
        padEnds: false,
        autoPlay: true,
        autoPlayInterval: const Duration(milliseconds: 1500),
        autoPlayCurve: Curves.fastEaseInToSlowEaseOut,
      ),
      itemBuilder: (BuildContext context, int i, int pageViewIndex) {
        return livePreview(i % 4, colorId: i, grayOut: grayOut && i % 4 < 2).padH(8);
      },
    );
  }
}

class BrightnessSwitch extends StatelessWidget {
  final ValueNotifier<Brightness> $brightness;

  const BrightnessSwitch(
    this.$brightness, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return $brightness >>
        (ctx, brightness) => SegmentedButton<Brightness>(
              segments: [
                ButtonSegment<Brightness>(
                  value: Brightness.light,
                  label: Brightness.light.l10n().text(),
                  icon: const Icon(Icons.light_mode),
                ),
                ButtonSegment<Brightness>(
                  value: Brightness.dark,
                  label: Brightness.dark.l10n().text(),
                  icon: const Icon(Icons.dark_mode),
                ),
              ],
              selected: <Brightness>{brightness},
              onSelectionChanged: (newSelection) async {
                $brightness.value = newSelection.first;
                await HapticFeedback.selectionClick();
              },
            );
  }
}

Future<void> onTimetablePaletteFromQrCode({
  required BuildContext context,
  required TimetablePalette palette,
}) async {
  final confirm = await context.showActionRequest(
    desc: i18n.p13n.palette.addFromQrCodeDesc,
    action: i18n.p13n.palette.addFromQrCodeAction,
    cancel: i18n.cancel,
  );
  if (confirm != true) return;
  TimetableInit.storage.palette.add(palette);
  await HapticFeedback.mediumImpact();
  if (!context.mounted) return;
  context.push("/timetable/p13n/custom");
}
