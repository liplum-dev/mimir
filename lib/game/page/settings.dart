import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sit/settings/settings.dart';
import 'package:rettulf/rettulf.dart';
import '../i18n.dart';

class GameSettingsPage extends ConsumerStatefulWidget {
  const GameSettingsPage({
    super.key,
  });

  @override
  ConsumerState<GameSettingsPage> createState() => _GameSettingsPageState();
}

class _GameSettingsPageState extends ConsumerState<GameSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const RangeMaintainingScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            pinned: true,
            snap: false,
            floating: false,
            title: i18n.navigation.text(),
          ),
          SliverList.list(
            children: const [
              HapticFeedbackTile(),
              ShowGameNavigationTile(),
            ],
          ),
        ],
      ),
    );
  }
}

class HapticFeedbackTile extends ConsumerWidget {
  const HapticFeedbackTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(Settings.game.$enableHapticFeedback) ?? true;
    return ListTile(
      title: i18n.settings.enableHapticFeedback.text(),
      subtitle: i18n.settings.enableHapticFeedbackDesc.text(),
      leading: const Icon(Icons.vibration),
      trailing: Switch.adaptive(
        value: on,
        onChanged: (newV) {
          ref.read(Settings.game.$enableHapticFeedback.notifier).set(newV);
        },
      ),
    );
  }
}


class ShowGameNavigationTile extends ConsumerWidget {
  const ShowGameNavigationTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(Settings.game.$showGameNavigation) ?? true;
    return ListTile(
      title: i18n.settings.showGameNavigation.text(),
      subtitle: i18n.settings.showGameNavigationDesc.text(),
      leading: const Icon(Icons.vibration),
      trailing: Switch.adaptive(
        value: on,
        onChanged: (newV) {
          ref.read(Settings.game.$showGameNavigation.notifier).set(newV);
        },
      ),
    );
  }
}

