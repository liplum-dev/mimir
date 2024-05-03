import 'package:flutter/material.dart';
import 'package:rettulf/rettulf.dart';
import 'package:sit/game/2048/widget/card.dart';

class AppCard extends StatelessWidget {
  /// [SizedBox] by default.
  final Widget? view;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final List<Widget>? leftActions;

  /// 12 by default.
  final double? leftActionsSpacing;
  final List<Widget>? rightActions;

  /// 0 by default
  final double? rightActionsSpacing;

  const AppCard({
    super.key,
    this.view,
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.leftActions,
    this.rightActions,
    this.leftActionsSpacing,
    this.rightActionsSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final leftActions = this.leftActions ?? const <Widget>[];
    final rightActions = this.rightActions ?? const <Widget>[];
    final textTheme = context.textTheme;
    return Card.filled(
      clipBehavior: Clip.hardEdge,
      child: [
        Theme(
          data: context.theme.copyWith(
            cardTheme: context.theme.cardTheme.copyWith(
              // in light mode, cards look in a lower level.
              elevation: context.isDarkMode ? 4 : 2,
            ),
          ),
          child: AnimatedSize(
            duration: Durations.long2,
            alignment: Alignment.topCenter,
            curve: Curves.fastEaseInToSlowEaseOut,
            child: view ?? const SizedBox(),
          ),
        ),
        ListTile(
          leading: leading,
          titleTextStyle: textTheme.titleLarge,
          title: title,
          subtitleTextStyle: textTheme.bodyLarge?.copyWith(color: context.colorScheme.onSurfaceVariant),
          subtitle: subtitle,
          trailing: trailing,
        ),
        OverflowBar(
          alignment: MainAxisAlignment.spaceBetween,
          children: [
            leftActions.wrap(spacing: leftActionsSpacing ?? 8),
            rightActions.wrap(spacing: rightActionsSpacing ?? 0),
          ],
        ).padOnly(l: 16, b: rightActions.isEmpty ? 12 : 8, r: 16),
      ].column(),
    );
  }
}
