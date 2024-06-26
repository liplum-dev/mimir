import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sit/design/adaptive/dialog.dart';
import 'package:sit/design/widgets/app.dart';
import 'package:sit/init.dart';
import 'package:rettulf/rettulf.dart';
import 'package:sit/utils/error.dart';

const _whitelist = {
  "221042Y213",
  "2210511239",
  "201032Y124",
  "2210340140",
  "221032Y116",
  "221032Y128",
  "2210450230",
  "236091101",
  "236091171",
};

class OpenLabDoorAppCard extends ConsumerStatefulWidget {
  const OpenLabDoorAppCard({super.key});

  static bool isAvailable({required String oaAccount}) {
    return _whitelist.contains(oaAccount);
  }

  @override
  ConsumerState<OpenLabDoorAppCard> createState() => _OpenLabDoorAppCardState();
}

class _OpenLabDoorAppCardState extends ConsumerState<OpenLabDoorAppCard> {
  var opening = false;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      title: "机协实验室的门".text(),
      subtitle: '请先连接 Wi-Fi "Robot"'.text(),
      leftActions: [
        FilledButton.icon(
          icon: const Icon(Icons.assignment),
          onPressed: opening ? null : openDoor,
          label: "开门".text(),
        ),
      ],
    );
  }

  Future<void> openDoor() async {
    setState(() {
      opening = true;
    });
    final result = await _openDoor();
    if (result) {
      await Future.delayed(const Duration(milliseconds: 2000));
      if (!mounted) return;
      setState(() {
        opening = false;
      });
      context.showSnackBar(content: "开门成功".text());
    } else {
      if (!mounted) return;
      setState(() {
        opening = false;
      });
      context.showSnackBar(content: "开门失败".text());
    }
  }
}

const _url =
    "aHR0cDovLzIxMC4zNS45OC4xNzg6NzEwMS9MTVdlYi9XZWJBcGkvSFNoaVlhblNoaS5hc2h4P01ldGhvZD1TYXZlUmVtb3RlT3BlbkRvb3ImU2hpWWFuU2hpSUQmS2FIYW89NTE1RkY1NzImTWFjSUQ9Mjg6NTI6Rjk6MTg6ODQ6Njc=";

Future<bool> _openDoor() async {
  try {
    final res = await Init.dio.get(
      String.fromCharCodes(base64Decode(_url)),
    );
    return res.data.toString() == "1,5000";
  } catch (error, stackTrace) {
    debugPrintError(error, stackTrace);
    return false;
  }
}
