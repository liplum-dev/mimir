import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:sit/credentials/entity/login_status.dart';
import 'package:sit/credentials/widgets/oa_scope.dart';
import 'package:sit/life/electricity/index.dart';
import 'package:sit/life/expense_records/index.dart';
import 'package:sit/settings/settings.dart';
import 'package:rettulf/rettulf.dart';

import 'event.dart';
import "i18n.dart";

class LifePage extends StatefulWidget {
  const LifePage({super.key});

  @override
  State<LifePage> createState() => _LifePageState();
}

class _LifePageState extends State<LifePage> {
  LoginStatus? loginStatus;
  final $campus = Settings.listenCampus();

  @override
  void initState() {
    $campus.addListener(refresh);
    super.initState();
  }

  @override
  void dispose() {
    $campus.removeListener(refresh);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    final newLoginStatus = context.auth.loginStatus;
    if (loginStatus != newLoginStatus) {
      setState(() {
        loginStatus = newLoginStatus;
      });
    }
    super.didChangeDependencies();
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final campus = Settings.campus;
    return PlatformScaffold(
      body: NestedScrollView(
        floatHeaderSlivers: true,
        headerSliverBuilder: (context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              sliver: PlatformSliverAppBar(
                title: i18n.navigation.text(),
                material: (ctx, platform){
                  return MaterialSliverAppBarData(
                    forceElevated: innerBoxIsScrolled,
                  );
                },
              ),
            ),
          ];
        },
        body: RefreshIndicator.adaptive(
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          onRefresh: () async {
            debugPrint("Life page refreshed");
            await HapticFeedback.heavyImpact();
            await lifeEventBus.notifyListeners();
          },
          child: CustomScrollView(
            slivers: [
              if (loginStatus != LoginStatus.never)
                const SliverToBoxAdapter(
                  child: ExpenseRecordsAppCard(),
                ),
              if (campus.capability.enableElectricity)
                const SliverToBoxAdapter(
                  child: ElectricityBalanceAppCard(),
                ),
              // FIXME: https://github.com/flutter/flutter/issues/36158
              const SliverFillRemaining(),
            ],
          ),
        ),
      ),
      material: (ctx, platform) {
        return MaterialScaffoldData(
          resizeToAvoidBottomInset: false,
        );
      },
    );
  }
}
