import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart' hide isCupertino;
import 'package:rettulf/rettulf.dart';
import 'package:sit/design/adaptive/foundation.dart';
import 'package:sit/design/adaptive/menu.dart';
import 'package:sit/design/adaptive/multiplatform.dart';
import 'package:sit/design/widgets/card.dart';
import 'package:super_context_menu/super_context_menu.dart';

enum EntryActionType {
  edit,
  share,
  other;
}

class EntryAction {
  final IconData? icon;
  final bool main;
  final String label;
  final EntryActionType type;
  final bool oneShot;
  final SingleActivator? activator;
  final Future<void> Function() action;

  const EntryAction({
    required this.label,
    this.main = false,
    this.icon,
    this.oneShot = false,
    required this.action,
    this.activator,
    this.type = EntryActionType.other,
  });

  const EntryAction.edit({
    required this.label,
    this.main = false,
    this.oneShot = false,
    this.icon,
    required this.action,
    this.activator,
  }) : type = EntryActionType.edit;

  const EntryAction.delete({
    required this.label,
    this.main = false,
    this.icon,
    required this.action,
    this.activator = const SingleActivator(LogicalKeyboardKey.delete),
  })  : oneShot = true,
        type = EntryActionType.edit;
}

class EntrySelectAction {
  final String selectLabel;
  final String selectedLabel;
  final Future<void> Function() action;

  const EntrySelectAction({
    required this.selectLabel,
    required this.selectedLabel,
    required this.action,
  });
}

class EntryCard extends StatelessWidget {
  final bool selected;
  final String title;
  final Widget Function(BuildContext context) itemBuilder;
  final Widget Function(BuildContext context, List<Widget> Function(BuildContext context)? actionsBuilder)
      detailsBuilder;
  final List<EntryAction> Function(BuildContext context) actions;
  final EntrySelectAction? Function(BuildContext context) selectAction;
  final EntryAction Function(BuildContext context)? deleteAction;

  const EntryCard({
    super.key,
    required this.title,
    required this.selected,
    required this.itemBuilder,
    required this.actions,
    required this.selectAction,
    required this.detailsBuilder,
    this.deleteAction,
  });

  @override
  Widget build(BuildContext context) {
    return supportContextMenu ? buildCardWithContextMenu(context) : buildCardWithDropMenu(context);
  }

  Widget buildCardWithDropMenu(BuildContext context) {
    final actions = this.actions(context);
    final mainActions = actions.where((action) => action.main).toList();
    final secondaryActions = actions.where((action) => !action.main).toList();
    final selectAction = this.selectAction(context);

    Widget buildMaterialMainActions() {
      final all = <Widget>[];
      if (selectAction != null) {
        all.add(
          selected
              ? FilledButton.icon(
                  icon: Icon(context.icons.checkMark),
                  onPressed: null,
                  label: selectAction.selectedLabel.text(),
                )
              : FilledButton(
                  onPressed: selectAction.action,
                  child: selectAction.selectLabel.text(),
                ),
        );
      }
      for (final action in mainActions) {
        all.add(OutlinedButton(
          onPressed: action.action,
          child: action.label.text(),
        ));
      }
      return all.wrap(spacing: 4);
    }

    Widget buildSecondaryActionPopup() {
      return PullDownMenuButton(
        itemBuilder: (ctx) {
          final all = <PullDownEntry>[];
          for (final action in secondaryActions) {
            final callback = action.action;
            all.add(PullDownItem(
              title: action.label,
              icon: action.icon,
              onTap: () async {
                await callback();
              },
            ));
          }
          final deleteAction = this.deleteAction;
          if (deleteAction != null) {
            final deleteActionWidget = deleteAction(context);
            all.add(const PullDownDivider());
            all.add(PullDownItem(
              title: deleteActionWidget.label,
              icon: deleteActionWidget.icon,
              onTap: () async {
                await deleteActionWidget.action();
              },
            ));
          }
          return all;
        },
      );
    }

    return InkWell(
      child: [
        itemBuilder(context),
        OverflowBar(
          alignment: MainAxisAlignment.spaceBetween,
          children: [
            buildMaterialMainActions(),
            buildSecondaryActionPopup(),
          ],
        ),
      ].column(caa: CrossAxisAlignment.start).padSymmetric(v: 10, h: 15),
      onTap: () async {
        await context.showSheet((ctx) => detailsBuilder(context, buildDetailsActions));
      },
    ).inAnyCard(
      type: selected ? CardVariant.filled : CardVariant.outlined,
      clip: Clip.hardEdge,
    );
  }

  Widget buildCardWithContextMenu(BuildContext context) {
    return Builder(
      builder: (context) {
        final actions = this.actions(context);
        final deleteAction = this.deleteAction?.call(context);
        return ContextMenuWidget(
          menuProvider: (MenuRequest request) {
            return Menu(
              children: buildMenuActions(
                context,
                actions: actions,
                selectAction: selectAction(context),
                deleteAction: deleteAction,
              ),
            );
          },
          child: buildCardWithContextMenuBody(
            context,
            selectAction: selectAction(context),
          ),
        );
      },
    );
  }

  Widget buildCardWithContextMenuBody(
    BuildContext context, {
    required EntrySelectAction? selectAction,
  }) {
    Widget widget = [
      itemBuilder(context),
      OverflowBar(
        alignment: MainAxisAlignment.end,
        children: [
          if (selectAction != null)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: selected ? null : selectAction.action,
              child: selected
                  ? Icon(context.icons.checkMark, color: context.colorScheme.primary)
                  : Icon(context.icons.checkBoxBlankOutlineRounded),
            ),
        ],
      ),
    ].column(caa: CrossAxisAlignment.start).padOnly(t: 12, l: 12, r: 8, b: 4);
    if (isCupertino) {
      return GestureDetector(
        onTap: () => showDetailsSheet(context),
        child: selectedCard(
          child: widget,
        ),
      );
    } else {
      return selectedCard(
        child: InkWell(
          onTap: () => showDetailsSheet(context),
          child: widget,
        ),
      );
    }
  }

  Widget selectedCard({required Widget child}) {
    return child.inAnyCard(
      type: selected ? CardVariant.filled : CardVariant.outlined,
      clip: Clip.hardEdge,
    );
  }

  Future<void> showDetailsSheet(BuildContext context) async {
    await context.showSheet((ctx) => detailsBuilder(ctx, buildDetailsActions));
  }

  List<MenuAction> buildMenuActions(
    BuildContext context, {
    required List<EntryAction> actions,
    required EntrySelectAction? selectAction,
    required EntryAction? deleteAction,
  }) {
    final all = <MenuAction>[];
    if (selectAction != null && !selected) {
      final selectCallback = selectAction.action;
      all.add(MenuAction(
        image: MenuImage.icon(context.icons.checkMark),
        title: selectAction.selectLabel,
        callback: selectCallback,
      ));
    }
    for (final action in actions) {
      final callback = action.action;
      final icon = action.icon;
      all.add(MenuAction(
        image: icon == null ? null : MenuImage.icon(icon),
        title: action.label,
        activator: action.activator,
        callback: callback,
      ));
    }
    if (deleteAction != null) {
      final icon = deleteAction.icon;
      all.add(MenuAction(
        image: icon == null ? null : MenuImage.icon(icon),
        title: deleteAction.label,
        attributes: const MenuActionAttributes(destructive: true),
        activator: deleteAction.activator,
        callback: deleteAction.action,
      ));
    }
    assert(all.isNotEmpty, "CupertinoContextMenuActions can't be empty");
    return all;
  }

  List<Widget> buildDetailsActions(BuildContext context) {
    final all = <Widget>[];
    final actions = this.actions(context);
    final selectAction = this.selectAction.call(context);
    final deleteAction = this.deleteAction?.call(context);
    final editAction = actions.firstWhereOrNull((action) => action.type == EntryActionType.edit);
    if (editAction != null) {
      all.add(PlatformTextButton(
        onPressed: () async {
          if (editAction.oneShot) {
            if (!context.mounted) return;
            context.navigator.pop();
          }
          await editAction.action();
        },
        child: editAction.label.text(),
      ));
      // remove edit action
      actions.retainWhere((action) => action.type != EntryActionType.edit);
      if (selectAction != null && !selected) {
        actions.insert(
          0,
          EntryAction(
            label: selectAction.selectLabel,
            oneShot: true,
            icon: context.icons.checkMark,
            action: selectAction.action,
          ),
        );
      }
    } else if (selectAction != null && !selected) {
      all.add(PlatformTextButton(
        onPressed: () async {
          await selectAction.action();
          if (!context.mounted) return;
          context.navigator.pop();
        },
        child: selectAction.selectLabel.text(),
      ));
    }
    all.add(PullDownMenuButton(
      itemBuilder: (ctx) {
        return [
          ...actions.map(
            (action) => PullDownItem(
              icon: action.icon,
              title: action.label,
              onTap: () async {
                if (action.oneShot) {
                  if (!context.mounted) return;
                  context.navigator.pop();
                }
                await action.action();
              },
            ),
          ),
          if (deleteAction != null) ...[
            const PullDownDivider(),
            PullDownItem.delete(
              title: deleteAction.label,
              icon: context.icons.delete,
              onTap: () async {
                await deleteAction.action();
                if (!context.mounted) return;
                context.navigator.pop();
              },
            ),
          ],
        ];
      },
    ));
    return all;
  }
}
